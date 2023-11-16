const { Lote } = require("../models");
const Ambiente = require("../models/ambiente");
const MortLote = require("../models/mortandadlote");
const { registerLog } = require("./bitacora");

async function getLotenombre(id_lote) {
  const lote = Lote.findByPk(id_lote, {
    attributes: ["nombre"],
  });
  return lote.nombre;
}
exports.getAmbienteList = async (req, res) => {
  const { id_galpon } = req.query;
  // console.log(id_galpon);
  try {
    const dates = await Ambiente.findAll({
      where: { id_galpon },
      order: [["fecha", "DESC"]],
    });
    res.send({ status: 0, data: dates });
  } catch (error) {
    console.log(error);
    res.send({ status: 1, msg: error });
  }
};

exports.getmortList = async (req, res) => {
  try {
    const mort = await MortLote.findAll({
      order: [["fecha", "DESC"]],
      include: [
        {
          model: Lote,
          attributes: ["id_lote", "nombre"],
        },
      ],
    });
    // console.log(mort);
    res.send({ status: 0, data: mort });
  } catch (error) {
    console.log(error);
    res.send({ status: 1, msg: error });
  }
};

exports.addAmbiente = async (req, res) => {
  const { id_galpon, fecha, humedad, temperatura, nombre_usuario } = req.body;
  try {
    const amb = await Ambiente.findOne({
      where: { id_galpon, fecha },
    });
    if (amb) {
      res.send({ status: 1, msg: "Ya existe el registro" });
    } else {
      const nuevo = await Ambiente.create({
        id_galpon,
        fecha,
        humedad,
        temperatura,
      });
      await registerLog(
        nombre_usuario,
        `Registrar cambios de temperatura y humedad 'Galpon ${id_galpon}'`
      );
      res.send({ status: 0, data: nuevo, msg: "Registro agregado con exito" });
    }
  } catch (error) {
    console.log(error);
    res.send({ status: 1, msg: error });
  }
};

exports.updateAmbiente = async (req, res) => {
  const { id_galpon, fecha, humedad, temperatura, nombre_usuario } = req.body;
  try {
    const amb = await Ambiente.findOne({
      where: { id_galpon, fecha },
    });
    if (amb) {
      //   amb.fecha = fecha;
      //   amb.hora = hora;
      amb.humedad = humedad;
      amb.temperatura = temperatura;
      await amb.save();
      await registerLog(
        nombre_usuario,
        `Modificar registro de temperatura y humedad 'Galpon ${id_galpon}'`
      );
      res.send({ status: 0, data: amb });
    } else {
      res.send({ status: 1, msg: "Ya existe el registro" });
    }
  } catch (error) {
    console.log(error);
    res.send({ status: 1, msg: error });
  }
};

exports.addMortality = async (req, res) => {
  const { fecha, id_lote, cantidad_defuncion, nombre_usuario } = req.body;
  try {
    const amb = await MortLote.findOne({
      where: { fecha, id_lote },
    });
    if (amb) {
      res.send({ status: 1, msg: "Ya existe el registro" });
    } else {
      const nuevo = await MortLote.create({
        fecha,
        id_lote,
        cantidad_defuncion,
      });
      const nombre = await getLotenombre(id_lote);
      // console.log(nuevo);
      await registerLog(
        nombre_usuario,
        `Registro de ${cantidad_defuncion} aves muertas en el  ${nombre}'`
      );

      res.send({
        status: 0,
        data: nuevo,
        msg: "Registro agregado exitosamente",
      });
    }
  } catch (error) {
    console.log(error);
    res.send({ status: 1, msg: error });
  }
};

exports.updateMortality = async (req, res) => {
  const { fecha, id_lote, cantidad_defuncion } = req.body;
  try {
    const amb = await MortLote.findOne({
      where: { fecha, id_lote },
    });
    if (!amb) {
      res.send({ status: 1, msg: "No se encontro el registro" });
    } else {
      await MortLote.update(
        {
          cantidad_defuncion,
        },
        {
          where: {
            fecha,
            id_lote,
          },
        }
      );
      const nombre = await getLotenombre(id_lote);
      if (amb.cantidad_defuncion > cantidad_defuncion) {
        await registerLog(
          nombre_usuario,
          `Disminución del número de aves muertas de ${amb.cantidad_defuncion} a ${cantidad_defuncion} en el '${nombre}`
        );
      } else if (amb.cantidad_defuncion < cantidad_defuncion) {
        await registerLog(
          nombre_usuario,
          `Incremento del número de aves muertas de ${amb.cantidad_defuncion} a ${cantidad_defuncion} en el '${nombre}'`
        );
      }
      res.send({ status: 0, msg: "Registro modificado exitosamente" });
    }
  } catch (error) {
    console.log(error);
    res.send({ status: 1, msg: error });
  }
};
