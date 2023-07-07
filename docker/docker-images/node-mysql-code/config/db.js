const Sequelize = require("sequelize");

var MYSQL_HOSTNAME = process.env.MYSQL_HOSTNAME;
var MYSQL_DBNAME = process.env.MYSQL_DBNAME;
var MYSQL_USERNAME = process.env.MYSQL_USERNAME;
var MYSQL_PASSWORD = process.env.MYSQL_PASSWORD;

const sequelize = new Sequelize(MYSQL_DBNAME, MYSQL_USERNAME, MYSQL_PASSWORD, {
  host: MYSQL_HOSTNAME,
  logging: false,
  dialect: "mysql",
  pool: {
    max: 5,
    min: 0,
    acquire: 30000,
    idle: 10000,
  },
});

const auth = sequelize.authenticate();
auth
  .then(() => console.log("Connection has been established successfully."))
  .catch((err) => console.error("Unable to connect to the database:", err));

module.exports = sequelize;
