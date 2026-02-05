const {Sequelize} = require("sequelize")
require("dotenv").config()

const database = new Sequelize(
    process.env.DATABASE_NAME,
    process.env.DATABASE_USER,
    process.env.DATABASE_PASSWORD,{
    host:process.env.DATABASE_HOST ,
    dialect:'mysql',
    define: {
      timestamps: false
  }
  });

module.exports = database;


