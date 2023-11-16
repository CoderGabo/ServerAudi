const { Incubadora, Incubacion } = require("../models/incubadora");
const { QueryTypes } = require("sequelize");
const sequelize = require("../database");
const Huevo = require("../models/huevo");
const { registerLog } = require("./bitacora");
const { Lote } = require("../models");

exports.getEggsList = async (req, res) => {
  try {
    const eggs = await Huevo.findAll({
      order: [
        ["fec_coleccion", "DESC"],
        ["id_huevo", "DESC"],
      ],
      include: [
        {
          model: Lote,
          attributes: ["id_lote", "nombre"],
        },
      ],
    });
    res.send({ status: 0, data: eggs });
  } catch (error) {
    console.log("eggs list ", error);
    res.send({ status: 1, msg: error });
  }
};

exports.addEggRec = async (req, res) => {
  const { id_lote, podrido, bueno, fec_coleccion, nombre_usuario } = req.body;
  try {
    const rec = await Huevo.create({
      id_lote,
      podrido,
      bueno,
      fec_coleccion,
    });

    res.send({ status: 0, data: rec });
    await registerLog(nombre_usuario, "Nueva coleccion de huevos");
  } catch (error) {
    console.log("add egg ", error);
    res.send({ status: 1, msg: error });
  }
};

exports.UpdateEggRec = async (req, res) => {
  const { id_huevo, id_lote, podrido, bueno, fec_coleccion, nombre_usuario } =
    req.body;
  try {
    const rec = await Huevo.findByPk(id_huevo);
    if (rec) {
      rec.id_lote = id_lote;
      rec.podrido = podrido;
      rec.bueno = bueno;
      rec.fec_coleccion = fec_coleccion;
      await rec.save();
      res.send({ status: 0, data: rec, msg: "Modificado con exito" });
      await registerLog(nombre_usuario, "Modificar coleccion de huevos");
    } else {
      res.send({ status: 1, msg: "No se ha encontrado el registro" });
    }
  } catch (error) {
    console.log("update egg ", error);
    res.send({ status: 1, msg: error });
  }
};

exports.getIncubatorList = async (req, res) => {
  let sql =
    "SELECT ira.id_inc, ira.disponible, ion.inicio, ion.nro_huevos, ion.id_incub " +
    "FROM incubadora ira " +
    "LEFT JOIN (SELECT id_inc, id_incub, inicio,nro_huevos FROM incubacion WHERE finalizado = false) ion " +
    "ON ira.id_inc = ion.id_inc " +
    // "WHERE ion.finalizado = false " +
    "ORDER BY ira.id_inc";
  try {
    const records = await sequelize.query(sql, { type: QueryTypes.SELECT });
    res.send({ status: 0, data: records });
  } catch (error) {
    console.log("incubator list", error);
    res.send({ status: 1, msg: error });
  }
};

exports.getIncubatorDetailsById = async (req, res) => {
  const { id_inc } = req.query;
  try {
    const inc = await Incubacion.findAll({
      order: [["inicio", "DESC"]],
      where: {
        id_inc,
      },
    });
    res.send({ status: 0, data: inc });
  } catch (error) {
    console.log("incubadora id", error);
    res.send({ status: 1, msg: error });
  }
};

exports.addIncubator = async (req, res) => {
  const { nombre_usuario } = req.body;
  try {
    const inc = await Incubadora.create({});
    res.send({ status: 0, data: inc });
    await registerLog(nombre_usuario, "Agregar nueva incubadora");
  } catch (error) {
    console.log("incubadora add", error);
    res.send({ status: 1, msg: error });
  }
};

exports.startIncub = async (req, res) => {
  const { inicio, nro_huevos, id_inc, nombre_usuario } = req.body;
  try {
    const disponible = await Incubadora.findByPk(id_inc, {
      where: {
        disponible: true,
      },
    });
    if (disponible) {
      const inc = await Incubacion.create({
        inicio,
        nro_huevos,
        id_inc,
      });
      res.send({ status: 0, data: inc });
      await registerLog(
        nombre_usuario,
        `Incubadora ${id_inc}: Iniciar incubacion`
      );
    } else {
      res.send({ status: 1, msg: "Incubadora en uso" });
    }
  } catch (error) {
    console.log("incubacion start", error);
    res.send({ status: 1, msg: error });
  }
};

exports.stopIncub = async (req, res) => {
  const { finalizacion, nro_eclosionado, id_incub, id_inc, nombre_usuario } =
    req.body;
  try {
    const inc = await Incubacion.findByPk(id_incub);
    if (inc) {
      inc.finalizacion = finalizacion;
      inc.nro_eclosionado = nro_eclosionado;
      inc.finalizado = true;
      await inc.save();
      res.send({ status: 0, data: inc });
      await registerLog(
        nombre_usuario,
        `Incubadora ${id_inc}: Finalizar incubacion`
      );
    } else {
      res.send({ status: 1, msg: "No se ha encontrado el registro" });
    }
  } catch (error) {
    console.log("incubacion end ", error);
    res.send({ status: 1, msg: error });
  }
};
