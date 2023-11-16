const express = require("express");
const cors = require("cors");
const sequelize = require("./database/index");
const app = express();
const cron = require("node-cron");
// const { config } = require("./config");
// const { expressjwt: expressJWT } = require("express-jwt");
const { backup } = require("./backup");
require("dotenv").config();

const PORT = process.env.PORT || 5000;

app.use(express.static("public"));

app.use(express.json());
app.use(express.urlencoded({ extended: false }));

// app.use(
//   expressJWT({ secret: config.jwtSecretKey, algorithms: ["HS256"] }).unless({
//     path: [/^\/api\//],
//   })
// );
app.use(cors());

app.use("/api", require("./routes/login"));
app.use("/prod/aves", require("./routes/prodAve"));
app.use("/prod/eggs", require("./routes/huevo"));
app.use("/galpon", require("./routes/galpon.js"));
app.use("/user", require("./routes/usuario"));
app.use("/role", require("./routes/rol"));
app.use("/poultry", require("./routes/ave"));
app.use("/weather", require("./routes/ambiente"));
app.use("/health", require("./routes/salud"));
app.use("/quar", require("./routes/cuarentena"));
app.use("/report", require("./routes/reporte"));
app.use("/back", require("./routes/back_up"));

// Ruta para recibir la petición de cambio de horario
app.post("/schedule", (req, res) => {
  const { min, hour, auto } = req.body;

  // Actualiza el horario de respaldo
  scheduleBackup(min, hour, auto);

  res.send({ status: 0, msg: "Horario de backup actualizado con éxito" });
});

app.get("/schedule", (req, res) => {
  res.send({ data: obj });
});

let backupTask = null;

let obj = null;

// Función para programar la tarea de respaldo
function scheduleBackup(newMinute, newHour, auto) {
  console.log(newHour, newMinute, auto);

  let userHour;
  let userMinute;
  let flag;
  if (auto === undefined || auto) {
    userHour = process.env.BACKUP_HOUR;
    userMinute = process.env.BACKUP_MIN;
    flag = true;
  } else {
    userHour = newHour;
    userMinute = newMinute;
    flag = false;
  }
  obj = {
    hour: userHour,
    min: userMinute,
    auto: flag,
  };
  const schedule = `${userMinute} ${userHour} * * *`;

  // Cancela la tarea de respaldo anterior
  if (backupTask) {
    backupTask.destroy();
  }

  // Programa la nueva tarea de respaldo
  backupTask = cron.schedule(schedule, backup);

  console.log(`Programación de respaldo actualizada: ${schedule}`);
}

// Programa la tarea de respaldo inicial
scheduleBackup();

//Error-handling middleware
// app.use((err, req, res, next) => {
//   if (err.name === "UnauthorizedError") res.status(401).send("token invalido");
//   //unknown error
//   else res.send({ status: 1, msg: "unknown error" });
//   console.log(err);
// });

(async () => {
  try {
    await sequelize.authenticate();
    console.log("Connection has been established successfully.");

    app.listen(PORT, () => {
      console.log(`server running on port ${PORT}`);
    });
  } catch (error) {
    console.error("Unable to connect to the database:", error);
  }
})();
