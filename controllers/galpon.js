const { Lote } = require("../models");
const Alimentacion = require("../models/alimentacion");
const Galpon = require("../models/galpon");
const { registerLog } = require("./bitacora");

exports.getShedList = async (req, res) => {
  try {
    const galpones = await Galpon.findAll({
      order: ["id_galpon"],
      include: [
        {
          model: Lote,
          attributes: ["id_lote", "nombre", "cantidad", "mortalidad"],
        },
      ],
    });
    res.send({ status: 0, data: galpones });
  } catch (error) {
    console.log("galpon list", error);
    res.send({ status: 1, msg: error });
  }
};

exports.getShedId = async (req, res) => {
  try {
    const galpones = await Galpon.findAll({
      attributes: ["id_galpon"],
      order: ["id_galpon"],
    });
    res.send({ status: 0, data: galpones });
  } catch (error) {
    console.log("galpon id", error);
    res.send({ status: 1, msg: error });
  }
};

exports.getShedIdQuar = async (req, res) => {
  try {
    const galpones = await Galpon.findAll({
      attributes: ["id_galpon"],
      order: ["id_galpon"],
      where: { en_cuar: false },
    });
    res.send({ status: 0, data: galpones });
  } catch (error) {
    console.log("galpon id cuarentena", error);
    res.send({ status: 1, msg: error });
  }
};

exports.addShed = async (req, res) => {
  const { dimension, capacidad, nombre_usuario } = req.body;
  try {
    const galpon = await Galpon.create({
      dimension,
      capacidad,
    });
    galpon.capacidad_libre = capacidad;
    await galpon.save();
    await registerLog(
      nombre_usuario,
      `Añadir nuevo galpon ${galpon.id_galpon}`
    );
    res.send({ status: 0, data: galpon, msg: "Galpon añadido exitosamente" });
  } catch (error) {
    console.log("galpon add", error);
    res.send({ status: 1, msg: error });
  }
};

exports.updateShed = async (req, res) => {
  const { id_galpon, dimension, capacidad, nombre_usuario } = req.body;
  //   console.log(req.body);
  try {
    const galpon = await Galpon.findByPk(id_galpon);
    if (galpon) {
      galpon.dimension = dimension;
      galpon.capacidad = capacidad;
      await galpon.save();
      await registerLog(nombre_usuario, `Modificar galpon ${galpon.id_galpon}`);
    } else {
      return res.send({
        status: 1,
        msg: `No se ha encontrado el galpon ${id_galpon}`,
      });
    }
    res.send({ status: 0, data: galpon, msg: "Galpon modificado con exito" });
  } catch (error) {
    console.log("galpon update", error);
    res.send({ status: 1, msg: error });
  }
};

exports.getFeedingList = async (req, res) => {
  try {
    const alim = await Alimentacion.findAll({
      order: [["id_alim", "DESC"]],
    });
    res.send({ status: 0, data: alim });
  } catch (error) {
    console.log("feeding list", error);
    res.send({ status: 1, msg: error });
  }
};

exports.addFeedingRec = async (req, res) => {
  const { fecha, alimento, cantidad, nombre_usuario, id_galpon } = req.body;
  try {
    const alim = await Alimentacion.create({
      fecha,
      alimento,
      cantidad,
      id_galpon,
    });

    res.send({ status: 0, data: alim, msg: "Registrar exitosamente" });
    await registerLog(nombre_usuario, "Registrar nueva alimentacion");
  } catch (error) {
    console.log("feeding add", error);
    res.send({ status: 1, msg: error });
  }
};

exports.updateFeedingRec = async (req, res) => {
  const { fecha, alimento, cantidad, nombre_usuario, id_galpon, id_alim } =
    req.body;
  try {
    const alim = await Alimentacion.findByPk(id_alim);
    if (alim) {
      await Alimentacion.update(
        {
          fecha,
          alimento,
          cantidad,
          id_galpon,
        },
        {
          where: { id_alim },
        }
      );
      res.send({ status: 0, msg: "modificado con exito" });
      await registerLog(nombre_usuario, `Modificar registro de alimentacion`);
    } else {
      return res.send({
        status: 1,
        msg: `No se ha encontrado el galpon ${id_galpon}`,
      });
    }
  } catch (error) {
    console.log("galpon update", error);
    res.send({ status: 1, msg: error });
  }
};
