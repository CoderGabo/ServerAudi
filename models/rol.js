const { DataTypes } = require("sequelize");
const sequelize = require("../database");

const Rol = sequelize.define(
  "Rol",
  {
    id_rol: {
      type: DataTypes.INTEGER,
      autoIncrement: true,
      primaryKey: true,
    },
    nombre: {
      type: DataTypes.STRING,
      allowNull: false,
    },
    permisos: DataTypes.ARRAY(DataTypes.STRING),
  },
  {
    tableName: "rol",
    timestamps: false,
  }
);

module.exports = Rol;
