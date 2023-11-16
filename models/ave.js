const sequelize = require("../database");
const { DataTypes } = require("sequelize");

const Ave = sequelize.define(
  "ave",
  {
    id: {
      type: DataTypes.INTEGER,
      autoIncrement: true,
      primaryKey: true,
    },
    especie: {
      type: DataTypes.STRING,
      allowNull: false,
    },
  },
  {
    tableName: "ave",
    timestamps: false,
  }
);

module.exports = Ave;
