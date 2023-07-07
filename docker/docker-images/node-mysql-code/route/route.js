const express = require("express");
const router = express.Router();
const event_controller = require("../controller/controller");

router.get("/", event_controller.getTesting);

router.post("/create", event_controller.postTesting);

module.exports = router;
