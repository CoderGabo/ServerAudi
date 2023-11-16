const { DataTypes } = require("sequelize");
const sequelize = require("../database");
const Lote = require("./lote");

const MortLote = sequelize.define(
  "mort_lote",
  {
    fecha: {
      type: DataTypes.DATE,
      primaryKey: true,
      allowNull: false,
    },
    id_lote: {
      type: DataTypes.INTEGER,
      primaryKey: true,
      allowNull: false,
    },
    cantidad_defuncion: {
      type: DataTypes.INTEGER,
      defaultValue: 0,
    },
  },
  {
    tableName: "mort_lote",
    timestamps: false,
  }
);

Lote.hasMany(MortLote, {
  foreignKey: "id_lote",
});

MortLote.belongsTo(Lote, {
  foreignKey: "id_lote",
});

module.exports = MortLote;
