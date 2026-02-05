const express = require("express")
const router = express.Router();
const multer = require('multer');
const path = require('path');


//middlewares
const tokenMiddleware = require("../middlewares/token.midllewares")

//controllers
const auth = require("../controller/user.controller")



const storage = multer.diskStorage({
    destination: (req, file, cb) => {
      cb(null, 'uploads/'); // Specify the directory where files will be stored
    },
    filename: (req, file, cb) => {
      cb(null, Date.now() + '-' + file.originalname); // Use a timestamp to avoid overwriting files
    },
  });
  
  const upload = multer({ storage: storage });

//route
router.get("/users/:userId",tokenMiddleware.verifyToken,auth.getDataUser)
router.put("/users/:userId",tokenMiddleware.verifyToken,auth.updateDataUser)
router.post("/upload/:userId",tokenMiddleware.verifyToken,upload.single("image"),auth.uploadImage)
router.post("/register",auth.createUsers)
router.post("/login",auth.login)

// router.post("/refresh",tokenMiddleware.token,auth.refreshToken)
router.post("/logout",auth.logout)





module.exports = router;