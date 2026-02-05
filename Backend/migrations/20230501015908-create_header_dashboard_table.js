'use strict';

/** @type {import('sequelize-cli').Migration} */
module.exports = {
  async up (queryInterface, Sequelize) {
    queryInterface.createTable("dashboard_header",
    {
      id: {
          type:Sequelize.INTEGER,
          allowNull:false,
          autoIncrement:true,
          primaryKey : true
      },
      title: {
        type:Sequelize.STRING,
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
   // await queryInterface.dropTable('header_dashboard')
  }
};
