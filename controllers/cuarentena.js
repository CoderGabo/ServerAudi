const { Op } = require("sequelize");
const Cuarentena = require("../models/cuarentena");
const { registerLog } = require("./bitacora");
const Galpon = require("../models/galpon");
const moment = require("moment");

exports.getQuarList = async (req, res) => {
  try {
    const cuar = await Cuarentena.findAll({
      order: [["fecha_ingreso", "DESC"]],
    });
    res.send({ status: 0, data: cuar });
  } catch (error) {
    console.log(error);
    res.send({ status: 1, msg: error });
  }
};

exports.addQuar = async (req, res) => {
  const { id_galpon, fecha_ingreso, razon, nombre_usuario } = req.body;
  try {
    const es = await Galpon.findOne({
      where: {
        id_galpon,
        en_cuar: true,
      },
    });
    if (es) {
      res.send({ status: 1, msg: "Galpon en cuarentena" });
    } else {
      const cuars = await Cuarentena.findAll({
        where: {
          id_galpon,
          fecha_salida: {
            [Op.not]: null,
          },
        },
      });
      //   console.log(JSON.stringify(cuars));

      for (let i = 0; i < cuars.length; i++) {
        // console.log(JSON.stringify(cua));
        const fi = moment(cuars[i].fecha_ingreso);
        const ff = moment(cuars[i].fecha_salida);
        const f = moment(fecha_ingreso);
        if (f.isSameOrAfter(fi) && f.isBefore(ff)) {
          return res.send({ status: 1, msg: "Galpon en cuarentena" });
        }
      }
      const nueva = await Cuarentena.create({
        id_galpon,
        fecha_ingreso,
        razon,
      });
      await registerLog(nombre_usuario, "Meter galpon a cuarentena");
      res.send({ status: 0, data: nueva });
    }
  } catch (error) {
    console.log(error);
    res.send({ status: 1, msg: error });
  }
};

exports.setEndDate = async (req, res) => {
  const { id_cuar, fecha_salida, nombre_usuario } = req.body;

  try {
    const cuar = await Cuarentena.findByPk(id_cuar);
    // console.log(cuar);
    if (cuar) {
      const fi = moment(cuar.fecha_ingreso, "YYYY-MM-DD");
      // console.log(fi.isAfter(fecha_salida));
      if (fi.isAfter(fecha_salida)) {
        return res.send({ status: 1, msg: "Fecha de salida incorrecta" });
      }
      cuar.fecha_salida = fecha_salida;
      await cuar.save();
      await registerLog(
        nombre_usuario,
        `Finalizar cuarentena del galpon ${cuar.id_galpon}`
      );
      res.send({ status: 0, msg: "Cuarentena finalizada" });
    } else {
      res.send({ status: 1, msg: "Error al modificar..." });
    }
  } catch (error) {
    console.log(error);
    res.send({ status: 1, msg: "Se produjo un error..." });
  }
};

exports.updateQuar = async (req, res) => {
  const { id_cuar, id_galpon, fecha_ingreso, razon, nombre_usuario } = req.body;
  try {
    const cuar = await Cuarentena.findByPk(id_cuar);
    if (cuar) {
      const cuars = await Cuarentena.findAll({
        where: {
          id_galpon,
          fecha_salida: {
            [Op.not]: null,
          },
        },
      });
      cuars.forEach((cua) => {
        // console.log(JSON.stringify(cua));
        const fi = moment(cua.fecha_ingreso);
        const ff = moment(cua.fecha_salida);
        const f = moment(fecha_ingreso);
        if (f.isSameOrAfter(fi) && f.isBefore(ff)) {
          return res.send({ status: 1, msg: "Galpon en cuarentena" });
        }
      });
      cuar.fecha_ingreso = fecha_ingreso;
      cuar.razon = razon;
      await cuar.save();
      await registerLog(nombre_usuario, "Modificar registro de cuarentena");
      res.send({ status: 0, msg: "Modificacion con exito" });
    } else {
      res.send({ status: 1, data: "Error al modificar..." });
    }
  } catch (error) {
    console.log(error);
    res.send({ status: 1, msg: error });
  }
};
