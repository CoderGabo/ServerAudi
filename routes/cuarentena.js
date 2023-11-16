const express = require("express");
const router = express.Router();
const QuarController = require("../controllers/cuarentena");

router.get("", QuarController.getQuarList);

router.post("", QuarController.addQuar);

router.put("", QuarController.updateQuar);

router.put("/end", QuarController.setEndDate);

module.exports = router;
