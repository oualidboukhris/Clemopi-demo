const express = require("express");
const router = express.Router();

//middlewares
const tokenMiddleware = require("../middlewares/token.midllewares");

//controller
const kickscootersController = require("../controller/kickscooters.controller");

// TEST ROUTE - completely public
router.get("/test-public-route", (req, res) => {
  console.log("✅ TEST ROUTE HIT!");
  return res.json({ message: "Public route works!" });
});

// Public QR Code routes (no authentication required) - MUST be before :idScooter route
console.log("🔓 Registering public QR code routes...");
router.get(
  "/kickscooter/:qrCode/qrcode/download",
  (req, res, next) => {
    console.log("📥 Download QR route hit for:", req.params.qrCode);
    next();
  },
  kickscootersController.downloadQRCode
);

router.get(
  "/kickscooter/:qrCode/qrcode",
  (req, res, next) => {
    console.log("📄 Generate QR route hit for:", req.params.qrCode);
    next();
  },
  kickscootersController.generateQRCode
);

console.log("🔒 Applying authentication middleware...");
// Protected routes (require authentication)
router.use(tokenMiddleware.verifyToken);

//routes
router.get("/kickscooters", kickscootersController.readKickscooters);
router.put("/kickscooters", kickscootersController.updateKickscooters);
router.put(
  "/kickscooter/key-state",
  kickscootersController.updateKeyStateKickscooter
);
router.get("/downloadExcel", kickscootersController.exportKickscooter);
router.get("/kickscooter/:idScooter", kickscootersController.readKickscooter);

// MQTT Lock/Unlock routes (protected - prevent unauthorized locking/unlocking)
router.post("/kickscooter/lock", kickscootersController.lockScooter);
router.post("/kickscooter/unlock", kickscootersController.unlockScooter);
router.post("/kickscooter/station-unlock", kickscootersController.unlockStation);
router.post("/kickscooter/station-lock", kickscootersController.lockStation);
router.post("/kickscooter/scooter-lock", kickscootersController.lockScooterOnly);
router.post("/kickscooter/scooter-unlock", kickscootersController.unlockScooterOnly);
router.post("/kickscooter/info", kickscootersController.getScooterInfo);

// Get all scooters with QR codes (protected - internal use)
router.get(
  "/kickscooters/qrcodes/all",
  kickscootersController.getScootersWithQRCodes
);

//router.put("/kickscooter/:idScooter",tokenMiddleware.token,tokenMiddleware.verifyToken,kickscootersController.updateKickscooters)

module.exports = router;
