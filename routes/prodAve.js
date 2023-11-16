const express = require("express");
const router = express.Router();
const batchesController = require("../controllers/prodAve");

router.get("", batchesController.getBatchList);

router.get("/ids", batchesController.getBatchId);

router.post("", batchesController.addBatch);

router.put("", batchesController.editBatch);

router.put("/end", batchesController.endBatch);

router.delete("", batchesController.deleteBatch);

router.get("/search", batchesController.searchBatches);

router.put("/shed", batchesController.updateShed);

router.get("/descarte", batchesController.getDescarteList);
router.post("/descarte", batchesController.addDescarte);
router.put("/descarte", batchesController.updateDescarte);
router.delete("/descarte", batchesController.deleteDescarte);

module.exports = router;
