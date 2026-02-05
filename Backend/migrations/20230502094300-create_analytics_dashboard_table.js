'use strict';

/** @type {import('sequelize-cli').Migration} */
module.exports = {
  async up (queryInterface, Sequelize) {
    queryInterface.createTable("dashboard_analytics",
    {
      id: {
          type:Sequelize.INTEGER,
          allowNull:false,
          autoIncrement:true,
          primaryKey : true
      },
      name: {
        type:Sequelize.STRING,
      },
      axisX: {
        type:Sequelize.STRING,
      },
      verify_count: {
        type: Sequelize.INTEGER,
        allowNull: false,
      },
      register_count: {
        type: Sequelize.INTEGER,
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
 //  await queryInterface.dropTable('analytics_dashboard')
  }
};
