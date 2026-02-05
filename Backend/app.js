const express = require("express");
const cookieParser = require("cookie-parser");
const app = express();
const cors = require("cors");

const pathApi = "/api/v1";

// --- FIXED CORS CONFIGURATION ---
const allowedOrigins = ["http://localhost:3000", "http://localhost"];

app.use(
  cors({
    origin: function (origin, callback) {
      // Allow requests with no origin (like mobile apps or curl)
      if (!origin) return callback(null, true);
      if (allowedOrigins.indexOf(origin) === -1) {
        // Create a specific error for debugging
        const msg =
          "The CORS policy for this site does not allow access from the specified Origin.";
        return callback(new Error(msg), false);
      }
      return callback(null, true);
    },
    credentials: true,
  })
);

app.use(express.json());
app.use(cookieParser());
app.use("/uploads", express.static("uploads"));
app.use("/public", express.static("public"));

//router
const users = require("./routes/users.router");
const kickscootersPublic = require("./routes/kickscooters.public.router");
const kickscooters = require("./routes/kickscooters.router");
const clients = require("./routes/clients.router");
const dashboard = require("./routes/dashboard.router");

// initialisation router
// IMPORTANT: Public routes MUST come first!
app.use(pathApi, kickscootersPublic); // Public QR routes (no auth)
app.use(pathApi, users);
app.use(pathApi, clients);
app.use(pathApi, kickscooters);
app.use(pathApi, dashboard);

module.exports = app;
