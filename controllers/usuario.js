const { Op, or } = require("sequelize");
const Usuario = require("../models/usuario");
const Rol = require("../models/rol");
const bcrypt = require("bcryptjs");
const { registerLog } = require("./bitacora");
const Bitacora = require("../models/bitacora");

exports.getUserList = async (req, res) => {
  const { id_rol } = req.query;
  try {
    let users;
    if (id_rol == 1) {
      users = await Usuario.findAll({
        attributes: { exclude: ["contraseña"] },
        include: {
          model: Rol,
          attributes: ["nombre"],
        },
        order: ["id_user"],
      });
    } else {
      users = await Usuario.findAll({
        attributes: { exclude: ["contraseña"] },
        where: {
          [Op.not]: [{ id_rol: 1 }],
        },
        include: {
          model: Rol,
          attributes: ["nombre"],
        },
        order: ["id_user"],
      });
    }

    // console.log(users);
    res.send({ status: 0, data: users });
  } catch (error) {
    console.log(error);
    res.send({ status: 1, msg: error });
  }
};

exports.putPwd = async (req, res) => {
  const { id_user, newpwd, username } = req.body;

  try {
    const user = await Usuario.findByPk(id_user);

    if (user) {
      user.contraseña = bcrypt.hashSync(newpwd, 10);
      // user.bloqueado = false;
      // user.error = 0;
      // user.hora = null;

      await user.save();

      await registerLog(
        username,
        `Cambio de contraseña del usuario ${user.nombre_usuario}`
      );

      res.send({
        status: 0,
        msg: "La contraseña ha sido modificada exitosamente.",
      });
    } else {
      res.send({ status: 1, msg: "Error al cambiar contraseña." });
    }
  } catch (error) {
    console.log(error);
    res.send({ status: 1, msg: error });
  }
};

exports.putRole = async (req, res) => {
  const { id_user, id_rol, username } = req.body;
  try {
    const user = await Usuario.findByPk(id_user);

    if (user) {
      user.id_rol = id_rol;
      await user.save();

      await registerLog(
        username,
        `Cambio de rol del usuario ${user.nombre_usuario}`
      );

      res.send({
        status: 0,
        msg: `Rol del usuario ${user.nombre_usuario} ha sido modificado con exito`,
      });
    } else {
      res.send({ status: 1, msg: "Error al cambiar contraseña." });
    }
  } catch (error) {
    console.log(error);
    res.send({ status: 1, msg: error });
  }
};

exports.getLogList = async (req, res) => {
  try {
    const logs = await Bitacora.findAll({ order: [["id_log", "DESC"]] });
    if (logs) {
      // console.log(JSON.stringify(logs));
      res.send({ status: 0, data: logs });
    } else {
      res.send({
        status: 1,
        msg: "No se pudo encontrar ninguno registro de bitacora",
      });
    }
  } catch (error) {
    res.send({ status: 1, msg: error });
  }
};

exports.SearchLogs = async (req, res) => {
  const { str } = req.query;
  // console.log(str);
  let regex = `%${str}%`;
  // console.log(regex);
  try {
    const logs = await Bitacora.findAll({
      where: {
        [Op.or]: [
          { username: { [Op.like]: regex } },
          { operacion: { [Op.like]: regex } },
          // { fecha: { [Op.like]: regex } },
        ],
      },
      order: [["id_log", "DESC"]],
    });
    res.send({ status: 0, data: logs });
  } catch (error) {
    console.log(error);
    res.send({ status: 1, msg: error });
  }
};
