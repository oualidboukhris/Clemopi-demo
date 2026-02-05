'use strict';

/** @type {import('sequelize-cli').Migration} */
module.exports = {
  async up (queryInterface, Sequelize) {
    queryInterface.createTable("clients",
    {
      id: {
          type:Sequelize.INTEGER,
          allowNull:false,
          autoIncrement:true,
          primaryKey : true
      },
      userId: {
        type:Sequelize.STRING,
      },
      username: {
        type: Sequelize.STRING,
        allowNull: false,
      },
      email: {
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
      incompletePenalty: {
        type: Sequelize.STRING,
      },
      unlockingWay: {
        type: Sequelize.STRING,
      },
      photos: {
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
   // await queryInterface.dropTable('clients')
  }
};
