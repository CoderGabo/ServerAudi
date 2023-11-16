const { DataTypes } = require("sequelize");
const sequelize = require("../database");

const Galpon = sequelize.define(
  "galpon",
  {
    id_galpon: {
      type: DataTypes.INTEGER,
      autoIncrement: true,
      primaryKey: true,
    },
    dimension: {
      type: DataTypes.STRING,
      allowNull: false,
    },
    capacidad: {
      type: DataTypes.INTEGER,
      allowNull: false,
    },
    capacidad_libre: {
      type: DataTypes.INTEGER,
    },
    en_cuar: {
      type: DataTypes.BOOLEAN,
      defaultValue: false,
    },
  },
  {
    tableName: "galpon",
    timestamps: false,
  }
);

module.exports = Galpon;
