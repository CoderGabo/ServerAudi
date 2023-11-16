const moment = require("moment");
const fs = require("fs");
const path = require("path");

const { spawn } = require("child_process");
require("dotenv").config();

const fileName = `${moment().format("YYYY_MM_DD")}.sql`;
const BACKUP_PATH = path.join(__dirname, "public", "backup", fileName);

// const dump = spawn(
//   "pg_dump",
//   [
//     "-U",
//     `${process.env.DB_USER}`,
//     `-p${process.env.DB_PORT}`,
//     `${process.env.DB_NAME}`,
//   ],
//   {
//     env: {
//       ...process.env,
//       PGPASSWORD: process.env.DB_PASSWORD,
//     },
//   }
// );

function backup() {
  const wstream = fs.createWriteStream(BACKUP_PATH);

  const dump = spawn(
    "pg_dump",
    [
      "--format=c",
      "-U",
      `${process.env.DB_USER}`,
      `-p${process.env.DB_PORT}`,
      `${process.env.DB_NAME}`,
    ],
    {
      env: {
        ...process.env,
        PGPASSWORD: process.env.DB_PASSWORD,
      },
    }
  );
  dump.stdout
    .pipe(wstream)
    .on("finish", () => {
      console.log("DB Backup Completed!");
    })
    .on("error", (err) => {
      console.error(err);
    });
  // dump.stderr.on("data", (data) => {
  //   console.error(`stderr: ${data}`);
  // });

  // dump.on("close", (code) => {
  //   console.log(`child process exited with code ${code}`);
  // });

  // dump.stdout.on("data", (data) => {
  //   console.log("----", data);
  // });
}

function restore(backup_file) {
  let backup_path = path.join(__dirname, "public", "backup", backup_file);
  const fileContent = fs.readFileSync(backup_path);
  if (fileContent.length === 0) return 1;
  // console.log(backup_path);

  const restoreCommand = spawn(
    "pg_restore",
    ["-U", process.env.DB_USER, "-d", process.env.DB_NAME, "-c", backup_path],
    {
      env: {
        ...process.env,
        PGPASSWORD: process.env.DB_PASSWORD,
      },
    }
  );

  // Maneja eventos de salida, error y finalización del proceso hijo
  restoreCommand.stdout.on("data", (data) => {
    console.log(`Salida: ${data}`);
  });

  restoreCommand.stderr.on("data", (data) => {
    console.error(`Error: ${data}`);
  });

  let flag = 0;
  restoreCommand.on("close", (code) => {
    if (code === 0) {
      console.log("Restauración de la base de datos completada con éxito");
      flag = 0;
    } else {
      console.error(
        `Error al restaurar la base de datos. Código de salida: ${code}`
      );
      flag = 1;
    }
  });
  return flag;
}

module.exports = {
  backup,
  restore,
};
