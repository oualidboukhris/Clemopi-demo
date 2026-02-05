const express = require("express")
const router = express.Router();


//middlewares
const tokenMiddleware = require("../middlewares/token.midllewares")

//controllers
const dashboard = require("../controller/dashboard.controller");


router.use(tokenMiddleware.verifyToken)

router.get("/dataAnalyticsHeader",dashboard.getDataAnalyticsHeader)
router.get("/dataAnalyticsAccount/:name",dashboard.getDataAnalyticsAccount)
router.post("/dataAnalyticsAccount",dashboard.createDataAnalyticsAccount)




module.exports = router;