const { Sequelize, DataTypes } = require("sequelize");
const sequelize = require("../config/database");
const Clients = sequelize.define(
  "clients",
  {
    id: {
      type: Sequelize.INTEGER,
      allowNull: false,
      autoIncrement: true,
      primaryKey: true,
    },
    userId: {
      type: Sequelize.STRING,
    },
    username: {
      type: Sequelize.STRING,
      allowNull: false,
    },
    email: {
      type: Sequelize.STRING,
      unique: true,
    },
    password: {
      type: Sequelize.STRING,
    },
    phoneNumber: {
      type: Sequelize.STRING,
    },
    firstName: {
      type: Sequelize.STRING,
    },
    lastName: {
      type: Sequelize.STRING,
    },
    gender: {
      type: Sequelize.STRING,
    },
    age: {
      type: Sequelize.STRING,
    },
    birthday: {
      type: Sequelize.STRING,
    },
    region: {
      type: Sequelize.STRING,
    },
    balance: {
      type: Sequelize.STRING,
    },
    totalMinutes: {
      type: Sequelize.STRING,
    },
    totalMeters: {
      type: Sequelize.STRING,
    },
    totalOrders: {
      type: Sequelize.STRING,
    },
    registerChannel: {
      type: Sequelize.STRING,
    },
    status: {
      type: Sequelize.STRING,
    },
    registerTime: {
      type: Sequelize.STRING,
    },
    lastOrders: {
      type: Sequelize.STRING,
    },
    lastOrderTime: {
      type: Sequelize.STRING,
    },
    accountStatus: {
      type: Sequelize.STRING,
    },
    unlockingWay: {
      type: Sequelize.STRING,
    },
    photos: {
      type: Sequelize.STRING,
    },
    deleted: {
      type: Sequelize.STRING,
      allowNull: false,
      defaultValue: "false",
    },
  },
  { freezeTableName: true }
);

module.exports = Clients;
