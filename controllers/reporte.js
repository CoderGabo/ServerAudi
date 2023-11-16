const { QueryTypes } = require("sequelize");
const sequelize = require("../database");

exports.getDeathByDate = async (req, res) => {
  const { start, end } = req.query;
  let sql =
    "SELECT g.id_galpon, SUM(lote.cantidad) cantidad,SUM(ml.cantidad_defuncion) mortalidad " +
    "FROM mort_lote ml " +
    "INNER JOIN lote " +
    "ON ml.id_lote = lote.id_lote " +
    "INNER JOIN galpon g " +
    "ON g.id_galpon = lote.id_galpon " +
    `WHERE ml.fecha BETWEEN '${start}' AND '${end}' ` +
    "GROUP BY g.id_galpon " +
    "ORDER BY g.id_galpon;";
  try {
    const records = await sequelize.query(sql, { type: QueryTypes.SELECT });

    res.send({ status: 0, data: records });
  } catch (error) {
    console.log(error);
    res.send({ status: 1, msg: "Tiempo de espera agotado de conexión" });
  }
};

exports.getReportByDate = async (req, res) => {
  const { start, end, tipo } = req.query;
  console.log(start, end, tipo);
  let sql;

  if (tipo === "M") {
    sql =
      "SELECT g.id_galpon, SUM(lote.cantidad) cantidad,SUM(ml.cantidad_defuncion) mortalidad " +
      "FROM mort_lote ml " +
      "INNER JOIN lote " +
      "ON ml.id_lote = lote.id_lote " +
      "INNER JOIN galpon g " +
      "ON g.id_galpon = lote.id_galpon " +
      `WHERE ml.fecha BETWEEN '${start}' AND '${end}' ` +
      "GROUP BY g.id_galpon " +
      "ORDER BY g.id_galpon;";
  } else if (tipo === "H") {
    sql =
      "SELECT g.id_galpon, SUM(huevo.bueno) bueno,SUM(huevo.podrido) podrido " +
      "FROM huevo " +
      "INNER JOIN lote " +
      "ON huevo.id_lote = lote.id_lote " +
      "INNER JOIN galpon g " +
      "ON g.id_galpon = lote.id_galpon " +
      `WHERE huevo.fec_coleccion BETWEEN '${start}' AND '${end}' ` +
      "GROUP BY g.id_galpon " +
      "ORDER BY g.id_galpon;";
  } else if (tipo === "I") {
    sql =
      "SELECT incu.id_inc, SUM(incn.nro_huevos) inicial,SUM(incn.nro_eclosionado) eclosionados " +
      "FROM incubadora incu " +
      "INNER JOIN incubacion incn " +
      "ON incu.id_inc = incn.id_inc " +
      `WHERE incn.finalizacion BETWEEN '${start}' AND '${end}' ` +
      "AND incn.finalizado = TRUE " +
      "GROUP BY incu.id_inc " +
      "ORDER BY incu.id_inc;";
  }

  try {
    const records = await sequelize.query(sql, { type: QueryTypes.SELECT });

    res.send({ status: 0, data: records });
  } catch (error) {
    console.log(error);
    res.send({ status: 1, msg: "Tiempo de espera agotado de conexión" });
  }
};
