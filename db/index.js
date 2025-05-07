const mysql = require('mysql2');

const connection = mysql.createConnection({
  host: 'localhost',
  user: 'tu_usuario',
  password: 'tu_contraseña',
  database: 'nombre_base_datos'
});

connection.connect((err) => {
  if (err) throw err;
  console.log('Conectado a la base de datos');
});

module.exports = connection;
