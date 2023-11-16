const express = require("express");
const router = express.Router();
const AmbController = require("../controllers/ambiente");

router.get("", AmbController.getAmbienteList);
router.post("", AmbController.addAmbiente);

router.get("/mort", AmbController.getmortList);
router.post("/mort", AmbController.addMortality);
router.put("/mort", AmbController.updateMortality);

module.exports = router;
