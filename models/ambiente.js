const { DataTypes } = require("sequelize");
const sequelize = require("../database");

const Ambiente = sequelize.define(
  "Ambiente",
  {
    id_galpon: {
      type: DataTypes.INTEGER,
      primaryKey: true,
      allowNull: false,
    },
    fecha: {
      type: DataTypes.DATE,
      primaryKey: true,
      allowNull: false,
    },
    temperatura: {
      type: DataTypes.REAL(4, 2),
    },
    humedad: {
      type: DataTypes.REAL(4, 2),
    },
  },
  {
    tableName: "ambiente",
    timestamps: false,
  }
);

module.exports = Ambiente;
