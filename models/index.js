const Lote = require("./lote");
const Rol = require("./rol");
const Usuario = require("./usuario");
const Galpon = require("./galpon");
const Ave = require("./ave");

// rol --- usuario
Rol.hasMany(Usuario, {
  foreignKey: "id_rol",
});

Usuario.belongsTo(Rol, {
  foreignKey: "id_rol",
});

// galpon ---- lote
Galpon.hasMany(Lote, {
  foreignKey: "id_galpon",
});
Lote.belongsTo(Galpon, {
  foreignKey: "id_galpon",
});

// lote--- ave
Ave.hasMany(Lote, {
  foreignKey: "id_ave",
});
Lote.belongsTo(Ave, {
  foreignKey: "id_ave",
});

module.exports = {
  Rol,
  Usuario,
  Galpon,
  Lote,
  // Ave,
};
