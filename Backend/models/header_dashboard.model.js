

const { Sequelize, DataTypes } = require('sequelize');
const sequelize = require("../config/database")
const DashboardHeader = sequelize.define('dashboard_header', {

    id: {
        type: Sequelize.INTEGER,
        allowNull: false,
        autoIncrement: true,
        primaryKey: true
    },
    title: {
        type: Sequelize.STRING,
    },
    icon: {
        type: Sequelize.STRING,
        allowNull: false,
    },
    color: {
        type: Sequelize.STRING,
    },
    bgColor: {
        type: Sequelize.STRING,
    },
    today: {
        type: Sequelize.STRING,
    },
    total: {
        type: Sequelize.STRING,
    },



}, { freezeTableName: true, });

module.exports = DashboardHeader;
