require("dotenv").config();
const User = require("../models/user.model");
const bcrypt = require("bcrypt");
const jwt = require("jsonwebtoken");
const crypto = require("crypto");

// --- REMOVED: const { path } = require("../app") ---

// Create users
const createUsers = async (req, res) => {
  try {
    const { firstName, lastName, email, password, phone } = req.body;
    const user = await User.findOne({ where: { email: email } });
    if (user) {
      return res
        .status(400)
        .json({ error: true, message: "User already exists" });
    }
    const hashedPassword = await bcrypt.hash(password, 14);

    const newUser = await User.create({
      firstName,
      lastName,
      email,
      phone,
      image_url: "uploads/Avatar.png",
      password: hashedPassword,
    });

    if (newUser) {
      res.status(200).json([{ error: false, message: "User have been saved" }]);
    } else {
      res.status(400).json({ error: true, message: "User isn't created" });
    }
  } catch (e) {
    console.log(e);
    res.status(500).json({ error: true, message: "Server error" });
  }
};

// Login
const login = async (req, res) => {
  try {
    // NOTE: Your frontend likely sends 'username' as the email field
    const { username, password } = req.body;

    if (!username)
      return res
        .status(400)
        .json({ message: "missing_required_parameter", info: "username" });
    if (!password)
      return res
        .status(400)
        .json({ message: "missing_required_parameter", info: "password" });

    const user = await User.findOne({ where: { email: username } });

    if (user) {
      const userCompare = await bcrypt.compare(password, user.password);

      if (userCompare) {
        const xsrfToken = crypto.randomBytes(64).toString("hex");
        const accessToken = generatedAcccesstoken(user, xsrfToken);

        res.cookie("_arl", accessToken, {
          httpOnly: true,
          maxAge: parseInt(process.env.ACCESS_TOKEN_EXPIRESIN) || 86400000,
          secure: false, // Set to true if using HTTPS
        });

        return res
          .status(200)
          .json({ email: user.email, xsrfToken: xsrfToken + "%" + user.id });
      } else {
        return res
          .status(403)
          .json({ error: true, message: "Username or password incorrect!" });
      }
    } else {
      return res.status(403).json({ error: true, message: "User not found!" });
    }
  } catch (e) {
    console.log(e);
    res.status(400).json({ message: "Server database is stopped" });
  }
};

// Helper function
function generatedAcccesstoken(user, xsrfToken) {
  return jwt.sign(
    {
      id: user.id,
      fullname: user.firstName + " " + user.lastName,
      xsrfToken,
    },
    process.env.ACCESS_TOKEN || "secret_key",
    { expiresIn: parseInt(process.env.ACCESS_TOKEN_EXPIRESIN) || 86400000 }
  );
}

// Other functions...
const getDataUser = async (req, res) => {
  const userId = req.params.userId;
  const dataUser = await User.findAll({
    attributes: [
      "firstName",
      "lastName",
      "email",
      "phone",
      "image_url",
      "createdAt",
    ],
    where: { id: userId },
  });
  if (dataUser) return res.status(200).json(dataUser[0]);
  return res.status(400).json({ error: true, message: "Server not working" });
};

const updateDataUser = async (req, res) => {
  const userId = req.params.userId;
  const { firstName, lastName, phoneNumber, email } = req.body;
  const result = await User.update(
    { firstName, lastName, email, phone: phoneNumber },
    { where: { id: userId } }
  );
  if (result)
    return res
      .status(200)
      .json({ message: "User have been updated", error: "false" });
  return res.status(200).json({ message: "User doesn't exist", error: "true" });
};

const uploadImage = async (req, res) => {
  const userId = req.params.userId;
  if (!req.file) return res.status(400).send("No file uploaded.");
  const result = await User.update(
    { image_url: req.file.path },
    { where: { id: userId } }
  );
  if (result)
    return res.status(200).json({
      message: "File uploaded",
      error: "false",
      image_url: req.file.path,
    });
  return res.status(400).send("No file uploaded");
};

const logout = async (req, res) => {
  res.clearCookie("_arl");
  res.json("you logged out successfully !").status(200);
};

module.exports = {
  createUsers,
  login,
  logout,
  getDataUser,
  updateDataUser,
  uploadImage,
};
