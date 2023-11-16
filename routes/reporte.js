const express = require("express");
const router = express.Router();
const ReportController = require("../controllers/reporte");

router.get("", ReportController.getDeathByDate);
router.get("/type", ReportController.getReportByDate);

module.exports = router;
