const sequelize = require("../database");
const { DataTypes } = require("sequelize");

const Enfermedad = sequelize.define(
  "enfermedad",
  {
    id_enf: {
      type: DataTypes.INTEGER,
      autoIncrement: true,
      primaryKey: true,
    },
    nombre: {
      type: DataTypes.STRING,
      allowNull: false,
      unique: true,
    },
    sintoma: DataTypes.TEXT,
  },
  {
    tableName: "enfermedad",
    timestamps: false,
  }
);

module.exports = Enfermedad;
