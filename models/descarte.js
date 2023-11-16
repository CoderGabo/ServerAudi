const sequelize = require("../database");
const { DataTypes } = require("sequelize");
const Lote = require("./lote");

const Descarte = sequelize.define(
  "descarte",
  {
    id_des: {
      type: DataTypes.INTEGER,
      autoIncrement: true,
      primaryKey: true,
    },
    cantidad: {
      type: DataTypes.INTEGER,
      allowNull: false,
    },
    id_lote: {
      type: DataTypes.INTEGER,
    },
  },
  {
    tableName: "descarte",
    timestamps: false,
  }
);

Lote.hasOne(Descarte, {
  foreignKey: "id_lote",
});

Descarte.belongsTo(Lote, {
  foreignKey: "id_lote",
});

module.exports = Descarte;
