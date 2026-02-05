const {
  getDocs,
  collection,
  getDoc,
  doc,
  updateDoc,
} = require("firebase/firestore");
const firebase = require("../config/firebase");
const ClientsModel = require("../models/clients.model");
const bcrypt = require("bcrypt");
const { v4: uuidv4 } = require("uuid");
const jwt = require("jsonwebtoken");
const crypto = require("crypto");

//Create
const createClient = (req, res) => {};

// Helper function to generate access token
function generateAccessToken(client, xsrfToken) {
  return jwt.sign(
    { id: client.id, oderId: client.oderId, xsrfToken },
    process.env.ACCESS_TOKEN,
    { expiresIn: process.env.ACCESS_TOKEN_EXPIRESIN || "24h" }
  );
}

// Login client (mobile app login)
const loginClient = async (req, res) => {
  try {
    const { email, password } = req.body;

    if (!email) {
      return res
        .status(400)
        .json({ error: true, message: "Email is required" });
    }
    if (!password) {
      return res
        .status(400)
        .json({ error: true, message: "Password is required" });
    }

    // Find client by email
    const client = await ClientsModel.findOne({ where: { email: email } });

    if (!client) {
      return res
        .status(403)
        .json({ error: true, message: "Incorrect email. Please try again" });
    }

    // Check password
    const passwordMatch = await bcrypt.compare(password, client.password);

    if (!passwordMatch) {
      return res
        .status(403)
        .json({ error: true, message: "Incorrect password. Please try again" });
    }

    // Generate tokens
    const xsrfToken = crypto.randomBytes(64).toString("hex");
    const accessToken = generateAccessToken(client, xsrfToken);

    // Set cookie
    res.cookie("_arl", accessToken, {
      httpOnly: true,
      maxAge: parseInt(process.env.ACCESS_TOKEN_EXPIRESIN) || 86400000,
      secure: false,
    });

    // Return client data
    return res.status(200).json({
      error: false,
      message: "Login successful",
      user: {
        id: client.id,
        oderId: client.oderId,
        email: client.email,
        firstName: client.firstName,
        lastName: client.lastName,
        username: client.username,
        phoneNumber: client.phoneNumber,
        balance: client.balance,
        accountStatus: client.accountStatus,
      },
      xsrfToken: xsrfToken + "%" + client.userId,
    });
  } catch (e) {
    console.log("Client login error:", e);
    return res.status(500).json({ error: true, message: "Server error" });
  }
};

// Register new client (mobile app registration)
const registerClient = async (req, res) => {
  try {
    const { firstName, lastName, email, password, phone } = req.body;

    // Validate input
    if (!email || !password || !firstName || !lastName) {
      return res
        .status(400)
        .json({ error: true, message: "All fields are required" });
    }

    // Check if client already exists
    const existingClient = await ClientsModel.findOne({
      where: { email: email },
    });
    if (existingClient) {
      return res
        .status(400)
        .json({ error: true, message: "User already exists" });
    }

    // Hash password
    const hashedPassword = await bcrypt.hash(password, 14);

    // Generate unique userId
    const uniqueUserId = uuidv4();

    // Create new client
    const newClient = await ClientsModel.create({
      userId: uniqueUserId,
      username: `${firstName} ${lastName}`,
      email: email,
      password: hashedPassword,
      phoneNumber: phone,
      firstName: firstName,
      lastName: lastName,
      gender: "",
      age: "",
      birthday: "",
      region: "",
      balance: "0",
      totalMinutes: "0",
      totalMeters: "0",
      totalOrders: "0",
      registerChannel: "mobile",
      status: "Enable",
      registerTime: new Date(Date.now()).toLocaleString(),
      lastOrders: "",
      lastOrderTime: "",
      accountStatus: "Active",
      unlockingWay: "phone",
      photos: null,
    });

    if (newClient) {
      return res
        .status(200)
        .json({ error: false, message: "Registration successful" });
    } else {
      return res
        .status(400)
        .json({ error: true, message: "Registration failed" });
    }
  } catch (e) {
    console.log("Client registration error:", e);

    // Handle duplicate email error from database
    if (
      e.name === "SequelizeUniqueConstraintError" ||
      (e.original && e.original.code === "ER_DUP_ENTRY")
    ) {
      return res.status(400).json({
        error: true,
        message: "User already exists",
      });
    }

    return res.status(500).json({ error: true, message: "Server error" });
  }
};

//Read
const readClients = async (req, res) => {
  // const querySnapshot = await getDocs(collection(firebase.db, "users"));
  // querySnapshot.forEach(async (querySnapshot) => {
  //   const client = await ClientsModel.findOne({
  //     where: { userId: querySnapshot.data().userId },
  //   });
  //   if (!client) {
  //     const newClient = await ClientsModel.create({
  //       userId: querySnapshot.data().userId,
  //       username: querySnapshot.data().displayName,
  //       email: querySnapshot.data().email,
  //       phoneNumber: querySnapshot.data().phoneNumber,
  //       firstName: querySnapshot.data().displayName.split(" ")[0],
  //       lastName: querySnapshot.data().displayName.split(" ")[1],
  //       gender: "",
  //       age: "",
  //       birthday: querySnapshot.data().birthday,
  //       region: "",
  //       balance: querySnapshot.data().balance,
  //       totalMinutes: "",
  //       totalMeters: "",
  //       totalOrders: "",
  //       registerChannel: "mobile",
  //       status: "Enable",
  //       registerTime: new Date(Date.now()).toLocaleString(),
  //       lastOrders: "",
  //       lastOrderTime: "",
  //       accountStatus: "Uncommitted",
  //       unlockingWay: "phone",
  //       photos: null,
  //     });
  //   }
  // });
  const client = await ClientsModel.findAll();
  if (client) {
    return res.json(client).status(200);
  } else {
    return res.json({ error: true, message: "Table is empty" }).stats(202); //202 (No content)
  }
};

const readClient = async (req, res) => {
  try {
    const userId = req.params.userId;
    const userData = await ClientsModel.findOne({ where: { userId: userId } });
    if (userData) {
      return res.json(userData).status(200);
    } else {
      return res.json({ error: true, message: "User not exist" }).status(202); //202 (No content)
    }
  } catch (err) {
    return res.json({ error: true, message: "User not exist" }).status(202); //202 (No content)
  }
};

//Update
const updateClient = async (req, res) => {
  const querySnapshot = await getDocs(collection(firebase.db, "users"));
};

const updateBalanceClient = async (req, res) => {
  const { userId, balance, dateUpdate } = req.body;
  const querySnapshot = await getDocs(collection(firebase.db, "users"));
  querySnapshot.forEach(async (value) => {
    if (value.get("userId") == userId) {
      try {
        const updateBalanceUser = await ClientsModel.update(
          { balance: balance, lastOrderTime: dateUpdate },
          { where: { userId: userId } }
        );
        const updateDocument = doc(firebase.db, "users", value.id);
        await updateDoc(updateDocument, { balance: balance });
        if (updateBalanceUser) {
          return res
            .json({
              message: "Your informations has been successfully updated",
            })
            .status(200);
        } else {
          return res
            .json({ error: true, message: "User not exist" })
            .status(400);
        }
      } catch (error) {
        return res.json({ error: true, message: "User not exist" }).status(400);
      }
    }
  });
};

const updateAccountStatus = async (req, res) => {
  const idClient = req.params.userId;
  const { accountStatus } = req.body;

  const updateAccountStatus = await ClientsModel.update(
    { accountStatus: accountStatus },
    { where: { userId: idClient } }
  );
  if (updateAccountStatus) {
    return res
      .json({
        error: false,
        message: "Your informations has been successfully updated",
      })
      .status(200);
  } else {
    return res
      .json({ error: true, message: "The User not updating" })
      .status(400);
  }
};

const updateDisableStatus = async (req, res) => {
  const idClient = req.params.userId;
  const { status } = req.body;
  const updateAccountStatus = await ClientsModel.update(
    { status: status },
    { where: { userId: idClient } }
  );
  if (updateAccountStatus) {
    return res
      .json({
        error: false,
        message: "Your informations has been successfully updated",
      })
      .status(200);
  } else {
    return res
      .json({ error: true, message: "The User not updating" })
      .status(400);
  }
};
//Delete
const deleteClient = async (req, res) => {
  const idClient = req.params.userId;
  const deleteClient = await ClientsModel.update(
    { deleted: true },
    { where: { userId: idClient } }
  );
  if (deleteClient) {
    return res
      .json({
        error: false,
        message: "The user has deleted",
      })
      .status(200);
  } else {
    return res
      .json({ error: true, message: "The user doesn't delete" })
      .status(400);
  }
};

module.exports = {
  createClient,
  registerClient,
  loginClient,
  readClient,
  readClients,
  updateClient,
  deleteClient,
  updateBalanceClient,
  updateAccountStatus,
  updateDisableStatus,
};
