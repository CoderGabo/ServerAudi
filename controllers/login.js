const bcrypt = require("bcryptjs");
const jwt = require("jsonwebtoken");
const moment = require("moment");
const Usuario = require("../models/usuario");
const { config } = require("../config");
const Rol = require("../models/rol");
const { registerLog } = require("./bitacora");

exports.postLogin = async (req, res) => {
  const { nombre_usuario, contraseña } = req.body;

  try {
    let user = await Usuario.findOne({
      where: { nombre_usuario },
    });

    if (user) {
      // usuario bloqueado
      if (user.bloqueado) {
        return res.send({
          status: 1,
          msg: "Usuario bloqueado. Por favor, contactarse con el administrador.",
        });
      }
      const fechaFin = moment();

      const result = bcrypt.compareSync(contraseña, user.contraseña);
      if (!result) {
        const fechaInicio = moment(user.hora);
        // Calcular la diferencia en milisegundos
        const diferenciaMs = fechaFin.diff(fechaInicio);
        // Convertir la diferencia a la unidad de tiempo deseada (minuto)
        const diferenciaMinutes = moment.duration(diferenciaMs).asMinutes();

        if (user.hora === null || diferenciaMinutes > 30) {
          user.error = 1;
          user.hora = fechaFin.format("YYYY-MM-DD HH:mm:ss");
        } else {
          user.error += 1;
        }
        await user.save();
        return res.send({
          status: 1,
          msg: "Si ingresa incorrectamente su contraseña de tres veces en un lapso de 30 minutos, su cuenta quedará bloqueada.",
        });
      }

      user.error = 0;
      user.hora = null;
      await user.save();

      user.contraseña = null;
      let rol = await Rol.findOne({
        attributes: ["permisos"],
        where: { id_rol: user.id_rol },
      });

      const tokenStr = jwt.sign(user.toJSON(), config.jwtSecretKey, {
        expiresIn: config.expiresIn,
      });
      user.dataValues.token = "Bearer " + tokenStr;
      user = {
        id_user: user.dataValues.id_user,
        nombre_usuario: user.dataValues.nombre_usuario,
        id_rol: user.dataValues.id_rol,
        permisos: rol.permisos,
        token: user.dataValues.token,
      };
      await registerLog(nombre_usuario, "Iniciar Sesion");

      res.send({ status: 0, data: user });
    } else {
      res.send({ status: 1, msg: "No existe el usuario introducido" });
    }
  } catch (error) {
    console.log(error);
    res.send({ status: 1, msg: error.name });
  }
};

exports.postRegister = async (req, res) => {
  const { nombre_usuario, contraseña, id_rol, username } = req.body;
  // console.log(req.body);
  try {
    const user = await Usuario.findOne({
      where: {
        nombre_usuario,
      },
    });
    if (user) {
      res.send({
        status: 1,
        msg: "Este nombre de usuario ya esta en uso o ya esta registrado. Prueba otro.",
      });
    } else {
      const u = await Usuario.create({
        nombre_usuario,
        contraseña: bcrypt.hashSync(contraseña, 10),
        id_rol,
      });
      u.contraseña = null;
      await registerLog(username, `Crear nuevo usuario ${nombre_usuario}`);
      res.send({ status: 0, msg: "Se creo el usuario exitosamente", data: u });
    }
  } catch (error) {
    console.log(error);
    res.send({ status: 1, msg: error });
  }
};

exports.changePwd = async (req, res) => {
  const { nombre_usuario, contraseña, newPwd } = req.body;

  try {
    const user = await Usuario.findOne({
      where: {
        nombre_usuario,
      },
    });
    if (user) {
      // usuario bloqueado
      if (user.bloqueado) {
        return res.send({
          status: 1,
          msg: "Usuario bloqueado. Por favor, contactarse con el administrador.",
        });
      }
      const fechaFin = moment();

      const result = bcrypt.compareSync(contraseña, user.contraseña);
      if (!result) {
        const fechaInicio = moment(user.hora);
        // Calcular la diferencia en milisegundos
        const diferenciaMs = fechaFin.diff(fechaInicio);
        // Convertir la diferencia a la unidad de tiempo deseada (minuto)
        const diferenciaMinutes = moment.duration(diferenciaMs).asMinutes();

        if (user.hora === null || diferenciaMinutes > 30) {
          user.error = 1;
          user.hora = fechaFin.format("YYYY-MM-DD HH:mm:ss");
        } else {
          user.error += 1;
        }
        await user.save();
        return res.send({
          status: 1,
          msg: "Si ingresa incorrectamente su contraseña de tres veces en un lapso de 30 minutos, su cuenta quedará bloqueada.",
        });
      }
      user.error = 0;
      user.hora = null;
      user.contraseña = bcrypt.hashSync(newPwd, 10);
      await user.save();
      await registerLog(nombre_usuario, "Cambio de contraseña");
    } else {
      res.send({ status: 1, msg: "No existe el usuario ingresado", data: u });
    }
  } catch (error) {
    console.log(error);
    res.send({ status: 1, msg: error });
  }
};

exports.logout = async (req, res) => {
  const { nombre_usuario } = req.query;
  console.log("cierre sesion", nombre_usuario);
  await registerLog(nombre_usuario, "Cerrar Sesion");
  res.send({ status: 0 });
};
