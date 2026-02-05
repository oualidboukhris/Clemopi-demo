const firebase = require("../config/firebase");
const DashboardHeader = require("../models/header_dashboard.model");
const DashboardAnalytics = require("../models/analytics_dashboard.model");

const dataAnalytics = [
    {
        "name": "order",
        "axisX":new Date(),
        "verify_count": 5,
        "register_count": 10,

    },
    {
        "name": "order",
        "axisX":new Date(),
        "verify_count": 9,
        "register_count": 7,

    },
    {
        "name": "order",
        "axisX": new Date(),
        "verify_count": 10,
        "register_count": 2,

    },
    {
        "name": "order",
        "axisX": new Date(),
        "verify_count": 6,
        "register_count": 2,

    },
    {
        "name": "order",
        "axisX": new Date(),
        "verify_count": 11,
        "register_count": 6,

    },
    {
        "name": "order",
        "axisX": new Date(),
        "verify_count": 10,
        "register_count": 7,

    },
    {
        "name": "order",
        "axisX": new Date(),
        "verify_count": 2,
        "register_count": 4,

    },
    {
        "name": "order",
        "axisX": new Date(),
        "verify_count": 20,
        "register_count": 8,

    },
    {
        "name": "order",
        "axisX": new Date(),
        "verify_count": 19,
        "register_count": 2,

    },
    {
        "name": "order",
        "axisX": new Date(),
        "verify_count": 5,
        "register_count": 15,

    },
    {
        "name": "order",
        "axisX": new Date(),
        "verify_count": 8,
        "register_count": 15,

    },
    {
        "name": "order",
        "axisX": new Date(),
        "verify_count": 8,
        "register_count": 12,

    },]

const createDataAnalyticsAccount = async (req, res) => {
    
    const createdUsers = await DashboardAnalytics.bulkCreate(dataAnalytics);
 

//   const { name, axisX, verify_count, register_count } = req.body;
//   const newData = await DashboardAnalytics.create({
//     name: name,
//     axisX: axisX,
//     verify_count: verify_count,
//     register_count: register_count,
//   });

//   if (newData) {
//     return res
//       .status(200)
//       .json({ message: "Data have been created", error: "false" });
//   } else {
//     return res
//       .status(400)
//       .json({ message: "Data is not created", error: "false" });
//   }

};

//Read
const getDataAnalyticsHeader = async (req, res) => {
  try {
    const data = await DashboardHeader.findAll();
    if (data) {
      return res.json(data).status(200);
    } else {
      return res.json({ error: true, message: "Data not exist" }).status(202); //202 (No content)
    }
  } catch (err) {
    return res.json({ error: true, message: "Server internal" }).status(400); //202 (No content)
  }
};

const getDataAnalyticsAccount = async (req, res) => {
  const name = req.params["name"];
  const dataPieChart = [];
  try {
    const data = await DashboardAnalytics.findAll(
      {
        where: {
          name: name,
        },
      },
      { attributes: ["axisX", "verify_count", "register_count"] }
    );
 
    if (data.length !== 0) {
      const register_count = await DashboardAnalytics.sum("register_count", {
        where: { name: name },
      });
      const verify_count = await DashboardAnalytics.sum("verify_count", {
        where: { name: name },
      });
      dataPieChart.push(
        { name: "Register count", value: register_count },
        { name: "Verify count", value: verify_count }
      );

      if (name === "account") {
        return res
          .json({ areaChart: data, pieChart: dataPieChart, barChart: data })
          .status(200);
      } else if (name === "order") {
        return res
          .json({ areaChart: data, pieChart: dataPieChart, barChart: data })
          .status(200);
      } else if (name === "payment") {
        return res
          .json({ areaChart: data, pieChart: dataPieChart, barChart: data })
          .status(200);
      }
    } else {
      return res.json({ error: true, message: "Data not exist" }).status(202); //202 (No content)
    }
  } catch (err) {
    return res.json({ error: true, message: "Server internal" }).status(400); //202 (No content)
  }
};

//Update
const updateDataAnalytics = async (req, res) => {
  //const querySnapshot = await getDocs(collection(firebase.db, "users"))
};

const updateDataHeader = async (req, res) => {};

//Delete
const deleteAnalytics = (req, res) => {};

module.exports = {
  createDataAnalyticsAccount,
  getDataAnalyticsHeader,
  getDataAnalyticsAccount,
  updateDataAnalytics,
  updateDataHeader,
  deleteAnalytics,
};
