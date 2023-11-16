const { DataTypes } = require("sequelize");
const sequelize = require("../database");

const Vacuna = sequelize.define(
  "Vacuna",
  {
    id_vac: {
      type: DataTypes.INTEGER,
      primaryKey: true,
      autoIncrement: true,
    },
    nombre: {
      type: DataTypes.STRING,
      unique: true,
      allowNull: false,
    },
    descripcion: DataTypes.STRING,
  },
  {
    tableName: "vacuna",
    timestamps: false,
  }
);

module.exports = Vacuna;
