const express = require("express");
const router = express.Router();
const healthController = require("../controllers/salud");

router.get("", healthController.getList);
router.put("", healthController.updateRecord);
router.post("", healthController.addRecord);
router.get("/vac", healthController.vaccList);
router.post("/vac", healthController.addVac);
router.put("/vac", healthController.updateVac);

router.get("/enf", healthController.getDiseaseList);
router.post("/enf", healthController.addDis);
router.put("/enf", healthController.UpdateDis);

module.exports = router;
