const sequelize = require("../database");
const { DataTypes } = require("sequelize");

const Bitacora = sequelize.define(
  "bitacora",
  {
    id_log: {
      type: DataTypes.INTEGER,
      autoIncrement: true,
      primaryKey: true,
    },
    username: {
      type: DataTypes.STRING,
      allowNull: false,
    },
    fecha: DataTypes.DATE,
    operacion: DataTypes.STRING,
  },
  {
    tableName: "bitacora",
    timestamps: false,
  }
);

module.exports = Bitacora;
