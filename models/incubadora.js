const { DataTypes } = require("sequelize");
const sequelize = require("../database");

exports.Incubadora = sequelize.define(
  "incubadora",
  {
    id_inc: {
      type: DataTypes.INTEGER,
      autoIncrement: true,
      primaryKey: true,
    },
    disponible: {
      type: DataTypes.BOOLEAN,
      defaultValue: true,
    },
  },
  {
    tableName: "incubadora",
    timestamps: false,
  }
);

exports.Incubacion = sequelize.define(
  "Incubacion",
  {
    id_incub: {
      type: DataTypes.INTEGER,
      autoIncrement: true,
      primaryKey: true,
    },
    inicio: DataTypes.DATE,
    finalizacion: DataTypes.DATE,
    nro_huevos: DataTypes.INTEGER,
    nro_eclosionado: DataTypes.INTEGER,
    finalizado: {
      type: DataTypes.BOOLEAN,
      defaultValue: false,
    },
    id_inc: {
      type: DataTypes.INTEGER,
    },
  },
  {
    tableName: "incubacion",
    timestamps: false,
  }
);

this.Incubadora.hasMany(this.Incubacion, {
  foreignKey: "id_inc",
});
this.Incubacion.belongsTo(this.Incubadora, {
  foreignKey: "id_inc",
});
