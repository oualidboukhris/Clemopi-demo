
const { Sequelize, DataTypes } = require('sequelize');
const sequelize = require("../config/database")


const User = sequelize.define('users', {

    id: {
        type:DataTypes.INTEGER,
        allowNull:false,
        autoIncrement:true,
        primaryKey : true
    },
    firstName: {
      type:DataTypes.STRING,
    },
    lastName: {
      type:DataTypes.STRING,
    },
    email: {
      type: DataTypes.STRING,
      allowNull: false
    },
    password: {
      type: DataTypes.STRING,
      allowNull: false
    },
    image_url: {
      type: DataTypes.STRING,
      allowNull: false
    },
    phone: {
      type: DataTypes.STRING,
      allowNull: false
    },
},{ freezeTableName: true, });

module.exports = User;
