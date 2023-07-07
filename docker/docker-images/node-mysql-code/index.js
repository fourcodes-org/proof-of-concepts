const express = require("express");
const cors = require("cors");
const cookieParser = require("cookie-parser");
const morgan = require("morgan");
const helmet = require("helmet");

const app = express();
app.use(express.json());
app.use(cookieParser());
app.use(morgan("combined"));
app.use(cors());
app.use(helmet());
app.use(cors(corsOptions));

const sequelize = require("./config/db");
sequelize.sync();

var corsOptions = {
  origin: "http://localhost:8081",
};

app.get("/", (req, res) =>
  res.json({ message: "Welcome to testing application." })
);

const test_route = require("./route/test_route");
app.use("/testing", test_route);

const PORT = process.env.PORT || 3000;

app.listen(PORT, () => {
  console.log(`Server is running on port ${PORT}.`);
});
