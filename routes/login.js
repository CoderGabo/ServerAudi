const express = require("express");
const router = express.Router();
const loginController = require("../controllers/login");

router.post("/login", loginController.postLogin);

router.post("/register", loginController.postRegister);

router.put("/pwd", loginController.changePwd);

router.get("/logout", loginController.logout);

module.exports = router;
