const { getDocs, collection } = require("firebase/firestore");
const firebase = require("../config/firebase");
const KickscootersModel = require("../models/kickScooters.model");
const mqttService = require("../config/mqtt");
const QRCode = require("qrcode");
const excelJS = require("exceljs");
const workbook = new excelJS.Workbook();
const worksheet = workbook.addWorksheet("Kickscooter-List");

//Create
const createKickscotters = (req, res) => {};

//Read
const readKickscooters = async (req, res) => {
  const querySnapshot = await getDocs(collection(firebase.db, "scooters"));
  querySnapshot.forEach(async (value) => {
    const data = value.data();
    if (
      data.isScanned != false ||
      data.isReserved != false ||
      data.rider != ""
    ) {
      const dataScanned = data.isScanned == 1 ? "Scanned" : "";
      const dataReserved = data.isReserved == 1 ? "Reserved" : "";
      const updateStatusKickScooter = await KickscootersModel.update(
        { scanStatus: dataScanned, reserveStatus: dataReserved },
        { where: { qrCode: value.id } }
      );
    } else {
      const updateStatusKickScooter = await KickscootersModel.update(
        { scanStatus: "", reserveStatus: "" },
        { where: { qrCode: value.id } }
      );
    }
  });
  const kickscooters = await KickscootersModel.findAll();
  const newArray = kickscooters.map((value) => ({
    ...value.toJSON(),
    checked: false,
  }));

  if (kickscooters) {
    return res.json(newArray).status(200);
  } else {
    return res.json({ error: true, message: "Table is empty" }).status(202); //202 (No content)
  }
};

const readKickscooter = async (req, res) => {
  try {
    const idScooter = req.params.idScooter;
    const kickscooterData = await KickscootersModel.findOne({
      where: { qrCode: idScooter },
    });
    if (kickscooterData) {
      return res.json(kickscooterData).status(200);
    } else {
      return res
        .json({ error: true, message: "kickScooter not exist" })
        .status(202); //202 (No content)
    }
  } catch (err) {
    return res.json({ error: true, message: "Internal Server" }).status(500); //202 (No content)
  }
};

const exportKickscooter = async (req, res) => {
  const kickscooters = await KickscootersModel.findAll({
    attributes: [
      "qrCode",
      "speed",
      "head_lamp",
      "visible_state",
      "disable_state",
      "alarm_state",
      "order_state",
      "battery",
      "coords",
      "lock_state",
      "scanStatus",
      "register_time",
    ],
  });
  if (kickscooters) {
    const headerRow = worksheet.addRow([
      "QR code",
      "Speed",
      "Head Lamp",
      "Visible state",
      "Disable state",
      "Alarm state",
      "Order state",
      "Battery",
      "Location",
      "Lock state",
      "Status",
      "Register time",
    ]);
    headerRow.font = { bold: true };
    worksheet.columns = [
      { key: "qrCode", width: 25 },
      { key: "speed", width: 25 },
      { key: "head_lamp", width: 25 },
      { key: "visible_state", width: 25 },
      { key: "disable_state", width: 25 },
      { key: "alarm_state", width: 25 },
      { key: "order_state", width: 25 },
      { key: "battery", width: 25 },
      { key: "coords", width: 25 },
      { key: "lock_state", width: 25 },
      { key: "scanStatus", width: 25 },
      { key: "register_time", width: 25 },
    ];
    kickscooters.forEach((kickscooter) => {
      worksheet.addRow(kickscooter);
    });

    res.setHeader(
      "Content-Type",
      "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
    );
    res.setHeader(
      "Content-Disposition",
      "attachment; filename=" + "KickScooter.xlsx"
    );
    workbook.xlsx.write(res).then(() => res.end());
  } else {
    return res.json({ error: true, message: "Data not exist" }).stats(202); //202 (No content)
  }
};

//Update
const updateKickscooters = async (req, res) => {
  const { idScooters, disable_state } = req.body;
  const updateStateKickScooter = await KickscootersModel.update(
    { disable_state: disable_state },
    { where: { id: idScooters } }
  );
  if (updateStateKickScooter) {
    return res
      .json({ error: false, message: "The kickscooters have been updated" })
      .status(200);
  } else {
    return res
      .json({ error: true, message: "The kickscooters not updating" })
      .status(400);
  }
};
const updateKeyStateKickscooter = async (req, res) => {
  const { idScooters, key_state } = req.body;
  const updateStateKickScooter = await KickscootersModel.update(
    { key_state: key_state },
    { where: { id: idScooters } }
  );
  if (updateStateKickScooter) {
    return res
      .json({ error: false, message: "The kickscooters have been updated" })
      .status(200);
  } else {
    return res
      .json({ error: true, message: "The kickscooters not updating" })
      .status(400);
  }
};

//Delete
const deleteKickscooters = (req, res) => {};

// Lock scooter via MQTT
const lockScooter = async (req, res) => {
  try {
    const { qrCode } = req.body;

    if (!qrCode) {
      return res
        .status(400)
        .json({ error: true, message: "QR Code is required" });
    }

    // Verify scooter exists
    const scooter = await KickscootersModel.findOne({ where: { qrCode } });
    if (!scooter) {
      return res
        .status(404)
        .json({ error: true, message: "Scooter not found" });
    }

    // Send MQTT lock commands for both station and scooter
    await mqttService.stationLock(qrCode);
    await mqttService.scooterLock(qrCode);

    // Update lock state in database (including station_lock_state and scooter_lock_state for dashboard sync)
    await KickscootersModel.update(
      { lock_state: "true", station_lock_state: "true", scooter_lock_state: "true" },
      { where: { qrCode } }
    );

    return res.status(200).json({
      error: false,
      message: "Scooter locked successfully",
      qrCode: qrCode,
    });
  } catch (error) {
    console.error("Lock scooter error:", error);
    return res.status(500).json({
      error: true,
      message: "Failed to lock scooter",
      details: error.message,
    });
  }
};

// Unlock scooter via MQTT
const unlockScooter = async (req, res) => {
  try {
    const { qrCode } = req.body;

    if (!qrCode) {
      return res
        .status(400)
        .json({ error: true, message: "QR Code is required" });
    }

    // Verify scooter exists
    const scooter = await KickscootersModel.findOne({ where: { qrCode } });
    if (!scooter) {
      return res.status(404).json({
        error: true,
        message: "❌ Invalid QR Code - Scooter not found",
        isValid: false,
      });
    }

    // Send MQTT unlock commands for both station and scooter
    await mqttService.stationUnlock(qrCode);
    await mqttService.scooterUnlock(qrCode);

    // Update lock state in database (including station_lock_state and scooter_lock_state for dashboard sync)
    await KickscootersModel.update(
      { lock_state: "false", station_lock_state: "false", scooter_lock_state: "false" },
      { where: { qrCode } }
    );

    return res.status(200).json({
      error: false,
      message: "✅ Scooter unlocked successfully",
      isValid: true,
      qrCode: qrCode,
      scooter: {
        id: scooter.id,
        qrCode: scooter.qrCode,
        battery: scooter.battery,
        lock_state: "false",
        coords: scooter.coords,
        region: scooter.region,
      },
    });
  } catch (error) {
    console.error("Unlock scooter error:", error);
    return res.status(500).json({
      error: true,
      message: "Failed to unlock scooter",
      details: error.message,
    });
  }
};

// Unlock station only via MQTT
const unlockStation = async (req, res) => {
  try {
    const { qrCode } = req.body;

    if (!qrCode) {
      return res
        .status(400)
        .json({ error: true, message: "QR Code is required" });
    }

    // Verify scooter exists
    const scooter = await KickscootersModel.findOne({ where: { qrCode } });
    if (!scooter) {
      return res
        .status(404)
        .json({ error: true, message: "Scooter not found" });
    }

    // Send MQTT STATION_UNLOCK command only
    await mqttService.stationUnlock(qrCode);

    // Update station_lock_state in database
    await KickscootersModel.update(
      { station_lock_state: "false" },
      { where: { qrCode } }
    );

    return res.status(200).json({
      error: false,
      message: "✅ Station unlocked successfully",
      qrCode: qrCode,
    });
  } catch (error) {
    console.error("Unlock station error:", error);
    return res.status(500).json({
      error: true,
      message: "Failed to unlock station",
      details: error.message,
    });
  }
};

// Lock station only via MQTT
const lockStation = async (req, res) => {
  try {
    const { qrCode } = req.body;

    if (!qrCode) {
      return res
        .status(400)
        .json({ error: true, message: "QR Code is required" });
    }

    // Verify scooter exists
    const scooter = await KickscootersModel.findOne({ where: { qrCode } });
    if (!scooter) {
      return res
        .status(404)
        .json({ error: true, message: "Scooter not found" });
    }

    // Send MQTT STATION_LOCK command only
    await mqttService.stationLock(qrCode);

    // Update station_lock_state in database
    await KickscootersModel.update(
      { station_lock_state: "true" },
      { where: { qrCode } }
    );

    return res.status(200).json({
      error: false,
      message: "✅ Station locked successfully",
      qrCode: qrCode,
    });
  } catch (error) {
    console.error("Lock station error:", error);
    return res.status(500).json({
      error: true,
      message: "Failed to lock station",
      details: error.message,
    });
  }
};

// Lock scooter only via MQTT
const lockScooterOnly = async (req, res) => {
  try {
    const { qrCode } = req.body;

    if (!qrCode) {
      return res
        .status(400)
        .json({ error: true, message: "QR Code is required" });
    }

    // Verify scooter exists
    const scooter = await KickscootersModel.findOne({ where: { qrCode } });
    if (!scooter) {
      return res
        .status(404)
        .json({ error: true, message: "Scooter not found" });
    }

    // Send MQTT SCOOTER_LOCK command only
    await mqttService.scooterLock(qrCode);

    // Update scooter_lock_state in database
    await KickscootersModel.update(
      { scooter_lock_state: "true" },
      { where: { qrCode } }
    );

    return res.status(200).json({
      error: false,
      message: "✅ Scooter locked successfully",
      qrCode: qrCode,
    });
  } catch (error) {
    console.error("Lock scooter error:", error);
    return res.status(500).json({
      error: true,
      message: "Failed to lock scooter",
      details: error.message,
    });
  }
};

// Unlock scooter only via MQTT
const unlockScooterOnly = async (req, res) => {
  try {
    const { qrCode } = req.body;

    if (!qrCode) {
      return res
        .status(400)
        .json({ error: true, message: "QR Code is required" });
    }

    // Verify scooter exists
    const scooter = await KickscootersModel.findOne({ where: { qrCode } });
    if (!scooter) {
      return res
        .status(404)
        .json({ error: true, message: "Scooter not found" });
    }

    // Send MQTT SCOOTER_UNLOCK command only
    await mqttService.scooterUnlock(qrCode);

    // Update scooter_lock_state in database
    await KickscootersModel.update(
      { scooter_lock_state: "false" },
      { where: { qrCode } }
    );

    return res.status(200).json({
      error: false,
      message: "✅ Scooter unlocked successfully",
      qrCode: qrCode,
    });
  } catch (error) {
    console.error("Unlock scooter error:", error);
    return res.status(500).json({
      error: true,
      message: "Failed to unlock scooter",
      details: error.message,
    });
  }
};


// Get scooter info via MQTT
const getScooterInfo = async (req, res) => {
  try {
    const { qrCode } = req.body;

    if (!qrCode) {
      return res
        .status(400)
        .json({ error: true, message: "QR Code is required" });
    }

    // Verify scooter exists
    const scooter = await KickscootersModel.findOne({ where: { qrCode } });
    if (!scooter) {
      return res
        .status(404)
        .json({ error: true, message: "Scooter not found" });
    }

    // Send MQTT SCOOTER_INFO command
    await mqttService.scooterInfo(qrCode);

    return res.status(200).json({
      error: false,
      message: "✅ Scooter info request sent",
      qrCode: qrCode,
      scooter: {
        id: scooter.id,
        qrCode: scooter.qrCode,
        battery: scooter.battery,
        lock_state: scooter.lock_state,
        coords: scooter.coords,
        region: scooter.region,
        speed: scooter.speed,
        total_meters: scooter.total_meters,
        total_minutes: scooter.total_minutes,
      },
    });
  } catch (error) {
    console.error("Get scooter info error:", error);
    return res.status(500).json({
      error: true,
      message: "Failed to get scooter info",
      details: error.message,
    });
  }
};

// Generate QR code for a scooter
const generateQRCode = async (req, res) => {
  try {
    const { qrCode } = req.params;

    // Verify scooter exists
    const scooter = await KickscootersModel.findOne({ where: { qrCode } });
    if (!scooter) {
      return res
        .status(404)
        .json({ error: true, message: "Scooter not found" });
    }

    // Generate QR code as data URL (base64 image)
    const qrCodeDataURL = await QRCode.toDataURL(qrCode, {
      width: 300,
      margin: 2,
      color: {
        dark: "#000000",
        light: "#FFFFFF",
      },
    });

    return res.status(200).json({
      error: false,
      message: "QR code generated successfully",
      qrCode: qrCode,
      qrCodeImage: qrCodeDataURL,
      scooter: {
        id: scooter.id,
        qrCode: scooter.qrCode,
        battery: scooter.battery,
        coords: scooter.coords,
      },
    });
  } catch (error) {
    console.error("Generate QR code error:", error);
    return res.status(500).json({
      error: true,
      message: "Failed to generate QR code",
      details: error.message,
    });
  }
};

// Generate QR code image (PNG) for download/print
const downloadQRCode = async (req, res) => {
  try {
    const { qrCode } = req.params;

    // Verify scooter exists
    const scooter = await KickscootersModel.findOne({ where: { qrCode } });
    if (!scooter) {
      return res
        .status(404)
        .json({ error: true, message: "Scooter not found" });
    }

    // Generate QR code as PNG buffer
    const qrCodeBuffer = await QRCode.toBuffer(qrCode, {
      width: 500,
      margin: 4,
      color: {
        dark: "#000000",
        light: "#FFFFFF",
      },
    });

    // Set response headers for image download
    res.setHeader("Content-Type", "image/png");
    res.setHeader(
      "Content-Disposition",
      `attachment; filename=scooter-${qrCode}.png`
    );

    return res.send(qrCodeBuffer);
  } catch (error) {
    console.error("Download QR code error:", error);
    return res.status(500).json({
      error: true,
      message: "Failed to download QR code",
      details: error.message,
    });
  }
};

// Get all scooters with QR codes
const getScootersWithQRCodes = async (req, res) => {
  try {
    const scooters = await KickscootersModel.findAll();

    // Generate QR codes for all scooters
    const scootersWithQR = await Promise.all(
      scooters.map(async (scooter) => {
        try {
          const qrCodeDataURL = await QRCode.toDataURL(scooter.qrCode, {
            width: 200,
            margin: 1,
          });

          return {
            id: scooter.id,
            qrCode: scooter.qrCode,
            battery: scooter.battery,
            coords: scooter.coords,
            lock_state: scooter.lock_state,
            qrCodeImage: qrCodeDataURL,
          };
        } catch (err) {
          console.error(`Error generating QR for ${scooter.qrCode}:`, err);
          return {
            id: scooter.id,
            qrCode: scooter.qrCode,
            battery: scooter.battery,
            coords: scooter.coords,
            lock_state: scooter.lock_state,
            qrCodeImage: null,
          };
        }
      })
    );

    return res.status(200).json({
      error: false,
      message: "Scooters with QR codes retrieved successfully",
      count: scootersWithQR.length,
      scooters: scootersWithQR,
    });
  } catch (error) {
    console.error("Get scooters with QR codes error:", error);
    return res.status(500).json({
      error: true,
      message: "Failed to retrieve scooters",
      details: error.message,
    });
  }
};

module.exports = {
  createKickscotters,
  readKickscooters,
  readKickscooter,
  updateKickscooters,
  deleteKickscooters,
  exportKickscooter,
  updateKeyStateKickscooter,
  lockScooter,
  unlockScooter,
  unlockStation,
  lockStation,
  lockScooterOnly,
  unlockScooterOnly,
  getScooterInfo,
  generateQRCode,
  downloadQRCode,
  getScootersWithQRCodes,
};
