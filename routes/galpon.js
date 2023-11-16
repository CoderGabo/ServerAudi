const express = require("express");
const router = express.Router();
const shedController = require("../controllers/galpon");

router.get("", shedController.getShedList);

router.post("", shedController.addShed);

router.put("", shedController.updateShed);

router.get("/id", shedController.getShedId);

router.get("/cuar", shedController.getShedIdQuar);

router.get("/feeding", shedController.getFeedingList);
router.post("/feeding", shedController.addFeedingRec);
router.put("/feeding", shedController.updateFeedingRec);

module.exports = router;
