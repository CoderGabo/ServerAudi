const { DataTypes } = require("sequelize");
const sequelize = require("../database/index");

const Lote = sequelize.define(
  "lote",
  {
    id_lote: {
      type: DataTypes.INTEGER,
      primaryKey: true,
      autoIncrement: true,
    },
    nombre: {
      type: DataTypes.STRING,
      allowNull: false,
    },
    cantidad: {
      type: DataTypes.INTEGER,
      allowNull: false,
    },
    mortalidad: {
      type: DataTypes.INTEGER,
      defaultValue: 0,
    },
    fecha_ingreso: {
      type: DataTypes.DATEONLY,
      allowNull: false,
    },
    origen: DataTypes.CHAR,
    fecha_salida: DataTypes.DATEONLY,
    destino: DataTypes.CHAR,
    archivado: {
      type: DataTypes.BOOLEAN,
      defaultValue: false,
    },
    descripcion: DataTypes.STRING,
    calidad: DataTypes.CHAR,
    id_galpon: {
      type: DataTypes.INTEGER,
    },
    id_ave: {
      type: DataTypes.INTEGER,
    },
  },
  {
    tableName: "lote",
    timestamps: false,
  }
);

module.exports = Lote;
