const Rol = require("../models/rol");
const { registerLog } = require("./bitacora");

//obtener todos los tipos de usuarios menos
exports.getRoleList = async (req, res) => {
  try {
    const roles = await Rol.findAll({ order: ["id_rol"] });

    if (roles) {
      res.send({ status: 0, data: roles });
    } else {
      res.send({
        status: 1,
        msg: "No se pudo obtener la lista de tipos de usuario",
      });
    }
  } catch (error) {
    res.send({ status: 1, msg: error });
  }
};

// crear un nuevo tipo de usuario
exports.postAddRole = async (req, res) => {
  const { nombre, nombre_usuario } = req.body;
  try {
    const rol = await Rol.create({
      nombre,
    });
    if (rol) {
      await registerLog(nombre_usuario, "Añadir nuevo rol");
      res.send({ status: 0, data: rol });
    } else {
      res.send({
        status: 1,
        msg: "No se pudo crear el tipo de usuario introducido",
      });
    }
  } catch (error) {
    res.send({ status: 1, msg: error });
  }
};

//modificar permisos de usuario
exports.updatePerm = async (req, res) => {
  const { id_rol, permisos, nombre_usuario } = req.body;
  try {
    const rol = await Rol.findByPk(id_rol);
    if (rol) {
      rol.permisos = permisos;
      await rol.save();
      await registerLog(
        nombre_usuario,
        `Modificar permisos de rol ${rol.nombre}`
      );
      res.send({ status: 0, msg: "permisos actualizados exitosamente" });
    } else {
      res.send({ status: 1, msg: "no existe este tipo de usuario" });
    }
  } catch (error) {
    console.log(error);
    res.send({ status: 1, msg: error });
  }
};
