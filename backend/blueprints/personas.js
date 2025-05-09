const express = require('express');
const router = express.Router();
const db = require('../../db'); // Asegúrate de tener un archivo db.js con la configuración de la base de datos

// Ruta para obtener todas las personas
router.get('/', (req, res) => {
  db.query('SELECT * FROM Personas', (err, results) => {
    if (err) return res.status(500).json({ error: err.message });
    res.json(results);
  });
});

// Ruta para crear una persona
router.post('/', (req, res) => {
  const { dni, nombre, apellido_paterno, apellido_materno, fecha_nacimiento } = req.body;
  const query = 'INSERT INTO Personas (dni, nombre, apellido_paterno, apellido_materno, fecha_nacimiento) VALUES (?, ?, ?, ?, ?)';
  db.query(query, [dni, nombre, apellido_paterno, apellido_materno, fecha_nacimiento], (err, results) => {
    if (err) return res.status(500).json({ error: err.message });
    res.status(201).json({ message: 'Persona creada' });
  });
});

// Otros endpoints de CRUD (PUT, DELETE) seguirían el mismo patrón

module.exports = router;
