const express = require("express");
const router = express.Router();
const userController = require("../controllers/usuario");

router.get("", userController.getUserList);

router.put("/pwd", userController.putPwd);

router.get("/log", userController.getLogList);

router.put("/role", userController.putRole);

router.get("/search", userController.SearchLogs);

module.exports = router;
