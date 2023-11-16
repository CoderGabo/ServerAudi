const express = require("express");

const router = express.Router();

const rolController = require("../controllers/rol");

//obtener todos los tipos de usuarios
router.get("", rolController.getRoleList);

// crear un nuevo tipo de usuario
router.post("/addRole", rolController.postAddRole);

//modificar permisos de usuario
router.put("/updateRole", rolController.updatePerm);

module.exports = router;
