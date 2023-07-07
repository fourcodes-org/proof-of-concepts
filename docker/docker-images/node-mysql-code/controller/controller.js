const test_table = require("../models/model");

const postTesting = (req, res) => {
  const details = req.body;
  let events = test_table.create(details);
  events
    .then((data) => res.send(data))
    .catch((err) => {
      res.status(500).send({
        message: err,
      });
    });
};

const getTesting = async (req, res) => {
  await test_table
    .findAll()
    .then((result) => {
      res.send(result);
    })
    .catch((error) => {
      res.status(500).send({
        message: error.message || "Some error occurred while retrieving event.",
      });
    });
};

module.exports = {
  postTesting,
  getTesting,
};
