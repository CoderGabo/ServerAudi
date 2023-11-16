const Bitacora = require("../models/bitacora");
const moment = require("moment");

exports.registerLog = async (username, operacion) => {
  const fecha = moment().format("YYYY-MM-DD HH:mm:ss");
  console.log(fecha);
  const b = await Bitacora.create({
    username,
    operacion,
    fecha,
  });
  console.log(b.fecha);
};
