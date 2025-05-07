const express = require('express');
const router = express.Router();
const db = require('../db');
const verificarToken = require('../middleware/auth');

// Obtener todas las personas
router.get('/', verificarToken, (req, res) => {
  db.query('SELECT * FROM Personas', (err, results) => {
    if (err) return res.status(500).json({ error: err.message });
    res.json(results);
  });
});

// Crear una nueva persona
router.post('/', verificarToken, (req, res) => {
  const { dni, nombre, apellido_paterno, apellido_materno, fecha_nacimiento } = req.body;
  const query = 'INSERT INTO Personas (dni, nombre, apellido_paterno, apellido_materno, fecha_nacimiento) VALUES (?, ?, ?, ?, ?)';
  db.query(query, [dni, nombre, apellido_paterno, apellido_materno, fecha_nacimiento], (err, results) => {
    if (err) return res.status(500).json({ error: err.message });
    res.status(201).json({ message: 'Persona creada' });
  });
});

// Actualizar persona
router.put('/:dni', verificarToken, (req, res) => {
  const { dni } = req.params;
  const { nombre, apellido_paterno, apellido_materno, fecha_nacimiento } = req.body;
  const query = 'UPDATE Personas SET nombre = ?, apellido_paterno = ?, apellido_materno = ?, fecha_nacimiento = ? WHERE dni = ?';
  db.query(query, [nombre, apellido_paterno, apellido_materno, fecha_nacimiento, dni], (err, results) => {
    if (err) return res.status(500).json({ error: err.message });
    res.json({ message: 'Persona actualizada' });
  });
});

// Eliminar persona
router.delete('/:dni', verificarToken, (req, res) => {
  const { dni } = req.params;
  const query = 'DELETE FROM Personas WHERE dni = ?';
  db.query(query, [dni], (err, results) => {
    if (err) return res.status(500).json({ error: err.message });
    res.json({ message: 'Persona eliminada' });
  });
});

module.exports = router;
