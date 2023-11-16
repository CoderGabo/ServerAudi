const express = require("express");
const router = express.Router();
const speciesController = require("../controllers/ave");

router.get("", speciesController.getSpeciesList);

router.post("", speciesController.addSpecies);

router.put("", speciesController.UpdateSpecies);

module.exports = router;
