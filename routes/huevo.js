const express = require("express");
const router = express.Router();
const eggsController = require("../controllers/huevo");

router.get("", eggsController.getEggsList);
router.post("", eggsController.addEggRec);
router.put("", eggsController.UpdateEggRec);

router.get("/incu", eggsController.getIncubatorList);
router.get("/incu/id", eggsController.getIncubatorDetailsById);
router.post("/incu", eggsController.addIncubator);
router.post("/incu/start", eggsController.startIncub);
router.post("/incu/end", eggsController.stopIncub);

module.exports = router;
