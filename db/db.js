const mysql = require('mysql');
const dotenv = require('dotenv');

dotenv.config();

const db = mysql.createConnection({
  host: process.env.DB_HOST || 'localhost',
  user: process.env.DB_USER || 'root',
  password: process.env.DB_PASSWORD || '',
  database: process.env.DB_NAME || 'FabiaNatura',
});

db.connect((err) => {
  if (err) {
    console.error('Error de conexión: ', err.message);
    process.exit(1);
  }
  console.log('Conexión a la base de datos MySQL exitosa');
});

module.exports = db; // Exportar la conexión
