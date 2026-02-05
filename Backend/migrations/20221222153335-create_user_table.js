'use strict';

/** @type {import('sequelize-cli').Migration} */
module.exports = {
  async up (queryInterface, Sequelize) {
    queryInterface.createTable("users",
    {
      id: {
          type:Sequelize.INTEGER,
          allowNull:false,
          autoIncrement:true,
          primaryKey : true
      },
      fullname: {
        type:Sequelize.STRING,
      },
      username: {
        type: Sequelize.STRING,
        allowNull: false,
        unique:true
      },
      password: {
        type: Sequelize.STRING,
        allowNull: false
      },
      createdAt: {
        allowNull: false,
        defaultValue: Sequelize.fn('now'),
        type: Sequelize.DATE
      },
      updatedAt: {
        allowNull: false,
        defaultValue: Sequelize.fn('now'),
        type: Sequelize.DATE
      }
    })
  },

  async down (queryInterface, Sequelize) {
   // await queryInterface.dropTable('users')
  }
};
