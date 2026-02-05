const { Sequelize, DataTypes } = require("sequelize");
const sequelize = require("../config/database");
const DashboardAnalytics = sequelize.define(
  "dashboard_analytics",
  {
    id: {
      type: Sequelize.INTEGER,
      allowNull: false,
      autoIncrement: true,
      primaryKey: true,
    },
    name: {
      type: Sequelize.STRING,
    },
    axisX: {
      type: Sequelize.STRING,
    },
    verify_count: {
      type: Sequelize.INTEGER,
      allowNull: false,
    },
    register_count: {
      type: Sequelize.INTEGER,
    },
  
  },
  {
    timestamps: true,
  },
  { freezeTableName: true }
);

module.exports = DashboardAnalytics;
