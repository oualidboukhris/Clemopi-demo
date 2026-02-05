const express = require("express");
const router = express.Router();
const kickscootersController = require("../controller/kickscooters.controller");

console.log("📦 Loading PUBLIC kickscooter routes (no auth)");

// Public QR Code generation routes
router.get(
  "/kickscooter/:qrCode/qrcode/download",
  kickscootersController.downloadQRCode
);
router.get(
  "/kickscooter/:qrCode/qrcode",
  kickscootersController.generateQRCode
);

// Public lock/unlock routes for clients (mobile app) and dashboard
router.post("/kickscooter/unlock", kickscootersController.unlockScooter);
router.post("/kickscooter/lock", kickscootersController.lockScooter);
router.post("/kickscooter/info", kickscootersController.getScooterInfo);

module.exports = router;
