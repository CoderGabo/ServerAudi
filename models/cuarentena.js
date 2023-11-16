const sequelize = require("../database");
const { DataTypes } = require("sequelize");

const Cuarentena = sequelize.define(
  "cuarentena",
  {
    id_cuar: {
      type: DataTypes.INTEGER,
      autoIncrement: true,
      primaryKey: true,
    },
    fecha_ingreso: {
      type: DataTypes.DATEONLY,
      allowNull: false,
    },
    fecha_salida: DataTypes.DATEONLY,
    razon: {
      type: DataTypes.STRING,
      allowNull: false,
    },
    id_galpon: {
      type: DataTypes.INTEGER,
      allowNull: false,
    },
  },
  {
    tableName: "cuarentena",
    timestamps: false,
  }
);

module.exports = Cuarentena;
