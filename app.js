// Requerir los módulos necesarios
const express = require('express');
const mysql = require('mysql');
const cors = require('cors');
const bodyParser = require('body-parser');
const dotenv = require('dotenv');

// Cargar variables de entorno (si usas un archivo .env)
dotenv.config();

// Crear la aplicación Express
const app = express();

// Middleware para parsear el cuerpo de las solicitudes
app.use(bodyParser.json());
app.use(cors()); // Habilitar CORS para todas las solicitudes

// Conectar a la base de datos MySQL
const db = mysql.createConnection({
  host: process.env.DB_HOST || 'localhost',
  user: process.env.DB_USER || 'root',
  password: process.env.DB_PASSWORD || '',
  database: process.env.DB_NAME || 'FabiaNatura',
});

db.connect((err) => {
  if (err) {
    console.error('Error al conectar a la base de datos:', err.message);
    process.exit(1); // Terminar el proceso si hay un error de conexion
  }
  console.log('Conexión exitosa a la base de datos MySQL');
});

// Rutas (Importar los blueprints de las rutas)
const personasRoutes = require('./blueprints/personas');
const telefonosPersonasRoutes = require('./blueprints/telefonos_personas');
const direccionesPersonasRoutes = require('./blueprints/direcciones_personas');
const empleadosRoutes = require('./blueprints/empleados');
const rolesRoutes = require('./blueprints/roles');
const vendedoresRoutes = require('./blueprints/vendedores');
const especialidadesRoutes = require('./blueprints/especialidades');
const asesoresRoutes = require('./blueprints/asesores');
const asesoresEspecialidadesRoutes = require('./blueprints/asesores');
const clientesRoutes = require('./blueprints/clientes');
const contratosRoutes = require('./blueprints/contratos');
const proveedoresRoutes = require('./blueprints/proveedores');
const lineasRoutes = require('./blueprints/lineas');
const productosRoutes = require('./blueprints/productos');
const facturasRoutes = require('./blueprints/facturas');
const detalleFacturasRoutes = require('./blueprints/detalle_facturas');

// Usar las rutas en la aplicacion
app.use('/api/personas', personasRoutes);
app.use('/api/telefonos_personas', telefonosPersonasRoutes);
app.use('/api/direcciones_personas', direccionesPersonasRoutes);
app.use('/api/empleados', empleadosRoutes);
app.use('/api/roles', rolesRoutes);
app.use('/api/vendedores', vendedoresRoutes);
app.use('/api/especialidades', especialidadesRoutes);
app.use('/api/asesores', asesoresRoutes);
app.use('/api/asesores_especialidades', asesoresEspecialidadesRoutes);
app.use('/api/clientes', clientesRoutes);
app.use('/api/contratos', contratosRoutes);
app.use('/api/proveedores', proveedoresRoutes);
app.use('/api/lineas', lineasRoutes);
app.use('/api/productos', productosRoutes);
app.use('/api/facturas', facturasRoutes);
app.use('/api/detalle_facturas', detalleFacturasRoutes);

// Ruta raiz
app.get('/', (req, res) => {
  res.send('¡Bienvenido a la API de FabiaNatura!');
});

// Escuchar en el puerto especificado
const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(`Servidor corriendo en http://localhost:${PORT}`);
});

module.exports = db; // Exportar la conexion a la base de datos para su uso en otros modulos
