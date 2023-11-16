const { DataTypes } = require("sequelize");
const sequelize = require("../database");
const Rol = require("./rol");

const Usuario = sequelize.define(
  "Usuario",
  {
    id_user: {
      type: DataTypes.INTEGER,
      primaryKey: true,
      autoIncrement: true,
    },
    nombre_usuario: {
      type: DataTypes.STRING,
      unique: true,
      allowNull: false,
    },
    contraseña: {
      type: DataTypes.STRING,
      allowNull: false,
    },
    id_rol: {
      type: DataTypes.INTEGER,
    },
    error: {
      type: DataTypes.SMALLINT,
      defaultValue: 0,
    },
    hora: DataTypes.DATE,
    bloqueado: {
      type: DataTypes.BOOLEAN,
      defaultValue: false,
    },
  },
  {
    tableName: "usuario",
    timestamps: false,
  }
);

module.exports = Usuario;
