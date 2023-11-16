const express = require("express");
const router = express.Router();
const fs = require("fs");
const path = require("path");
const { restore } = require("../backup");
const { registerLog } = require("../controllers/bitacora");
require("dotenv").config();

const directoryPath = path.join(__dirname, "..", "public", "backup");

router.get("/list", (req, res) => {
  fs.readdir(directoryPath, (err, files) => {
    if (err) {
      console.error("Error al leer el directorio:", err);
      return;
    }
    const fileObjects = files.map((file, index) => {
      const filePath = path.join(directoryPath, file);
      const fileParsed = path.parse(filePath);
      return {
        index: index + 1,
        filename: fileParsed.name,
      };
    });
    // console.log(fileObjects);
    res.send({ status: 0, data: fileObjects });
  });
});

router.post("/restore", async (req, res) => {
  const { filename, nombre_usuario } = req.body;
  let suc = restore(`${filename}.sql`);
  //   console.log(suc);
  if (suc === 0) {
    res.send({ status: 0, msg: "Base restaurada con exito" });
    await registerLog(nombre_usuario, `Restaurar base de datos ${filename}`);
  } else {
    res.send({ status: 1, msg: "Se produjo error al restaurar la base" });
  }
});

module.exports = router;
