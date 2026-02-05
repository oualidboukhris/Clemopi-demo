const express = require("express");
const router = express.Router();

//middlewares
const tokenMiddleware = require("../middlewares/token.midllewares");

//controllers
const users = require("../controller/clients.controller");
const { readKickscooter } = require("../controller/kickscooters.controller");

// Public routes (no token required) - client registration & login
router.post("/client/register", users.registerClient);
router.post("/client/login", users.loginClient);

// Protected routes (token required)
router.use(tokenMiddleware.verifyToken);

router.get("/users", users.readClients);
router.get("/user/:userId", users.readClient);
router.put("/balanceUpdate", users.updateBalanceClient);
router.put("/accountStatus/:userId", users.updateAccountStatus);
router.put("/disbaleStatus/:userId", users.updateDisableStatus);
router.delete("/user/:userId", users.updateDisableStatus);

module.exports = router;
