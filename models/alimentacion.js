const sequelize = require("../database");
const { DataTypes } = require("sequelize");

const Alimentacion = sequelize.define(
  "alimentacion",
  {
    id_alim: {
      type: DataTypes.INTEGER,
      autoIncrement: true,
      primaryKey: true,
    },
    fecha: {
      type: DataTypes.DATEONLY,
      allowNull: false,
    },
    alimento: {
      type: DataTypes.STRING,
      allowNull: false,
    },
    cantidad: {
      type: DataTypes.INTEGER,
      allowNull: false,
    },
    id_galpon: {
      type: DataTypes.INTEGER,
    },
  },
  {
    tableName: "alimentacion",
    timestamps: false,
  }
);

module.exports = Alimentacion;
