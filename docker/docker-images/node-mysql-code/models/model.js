const Sequelize = require("sequelize");
const sequelize = require("../config/db");

const testing_details = sequelize.define("testing_details", {
  id: {
    type: Sequelize.INTEGER,
    autoIncrement: true,
    primaryKey: true,
  },
  name: {
    type: Sequelize.STRING,
    allowNull: false,
  },
  email: {
    type: Sequelize.STRING,
    allowNull: false,
  },
  mobile: {
    type: Sequelize.BIGINT(11),
    allowNull: false,
  },

  createdAt: {
    type: Sequelize.DATEONLY,
  },

  updatedAt: {
    type: Sequelize.DATE,
  },
});

module.exports = testing_details;
