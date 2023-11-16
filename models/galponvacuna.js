const { DataTypes } = require("sequelize");
const sequelize = require("../database");

const GalponVacuna = sequelize.define(
  "galponvacuna",
  {
    id: {
      type: DataTypes.INTEGER,
      primaryKey: true,
      autoIncrement: true,
    },
    id_galpon: {
      type: DataTypes.INTEGER,
      allowNull: false,
    },
    id_vac: {
      type: DataTypes.INTEGER,
      allowNull: false,
    },
    fecha: {
      type: DataTypes.DATEONLY,
      allowNull: false,
    },
  },
  {
    tableName: "galpon_vacuna",
    timestamps: false,
  }
);

module.exports = GalponVacuna;
