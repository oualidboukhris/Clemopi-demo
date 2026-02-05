'use strict';

/** @type {import('sequelize-cli').Migration} */
module.exports = {
  async up(queryInterface, Sequelize) {
    queryInterface.createTable("kickcooters",
      {
        id: {
          type: Sequelize.INTEGER,
          allowNull: false,
          autoIncrement: true,
          primaryKey: true
        },
        qrCode: {
          type: Sequelize.STRING,
        },
        speed: {
          type: Sequelize.STRING,
        },
        head_lamp: {
          type: Sequelize.STRING,
        },
        disable_state: {
          type: Sequelize.STRING,
        },
        visible_state: {
          type: Sequelize.STRING,
        },
        alarm_state: {
          type: Sequelize.STRING,
        },
        order_state: {
          type: Sequelize.STRING,
        },
        lock_state: {
          type: Sequelize.STRING,
        },
        battery: {
          type: Sequelize.STRING,
        },
        coords: {
          type: Sequelize.STRING,
        },
        total_meters: {
          type: Sequelize.STRING,
        },
        total_minutes: {
          type: Sequelize.STRING,
        },
        total_amounts: {
          type: Sequelize.STRING,
        },
        total_orders: {
          type: Sequelize.STRING,
        },
        bleutooth_key: {
          type: Sequelize.STRING,
        },
        bleutooth_password: {
          type: Sequelize.STRING,

        },
        register_time: {
          type: Sequelize.STRING,

        },
        communication_time: {
          type: Sequelize.STRING,

        },
        authentication_code: {
          type: Sequelize.STRING,

        },
        key_state: {
          type: Sequelize.STRING,
        },
        region: {
          type: Sequelize.STRING,
        },
        unlocking_way: {
          type: Sequelize.STRING,
        },
        scanStatus: {
            type: Sequelize.STRING,
          },
        reserveStatus: {
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

  async down(queryInterface, Sequelize) {
   // await queryInterface.dropTable('kickcooters')
  }
};
