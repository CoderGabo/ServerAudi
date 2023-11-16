const sequelize = require("../database");
const { DataTypes } = require("sequelize");
const Lote = require("./lote");

const Huevo = sequelize.define(
  "huevo",
  {
    id_huevo: {
      type: DataTypes.INTEGER,
      autoIncrement: true,
      primaryKey: true,
    },
    fec_coleccion: {
      type: DataTypes.DATEONLY,
      allowNull: false,
    },
    bueno: {
      type: DataTypes.INTEGER,
      defaultValue: 0,
    },
    podrido: {
      type: DataTypes.INTEGER,
      defaultValue: 0,
    },
    id_lote: DataTypes.INTEGER,
  },
  {
    tableName: "huevo",
    timestamps: false,
  }
);

Lote.hasMany(Huevo, {
  foreignKey: "id_lote",
});
Huevo.belongsTo(Lote, {
  foreignKey: "id_lote",
});
module.exports = Huevo;
