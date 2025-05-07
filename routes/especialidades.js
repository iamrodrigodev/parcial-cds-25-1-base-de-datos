const express = require('express');
const router = express.Router();
const db = require('../db');
const verificarToken = require('../middleware/auth');

// Obtener todas las especialidades
router.get('/', verificarToken, (req, res) => {
  db.query('SELECT * FROM Especialidades', (err, results) => {
    if (err) return res.status(500).json({ error: err.message });
    res.json(results);
  });
});

// Crear una nueva especialidad
router.post('/', verificarToken, (req, res) => {
  const { nombre_especialidad, descripcion } = req.body;
  const query = 'INSERT INTO Especialidades (nombre_especialidad, descripcion) VALUES (?, ?)';
  db.query(query, [nombre_especialidad, descripcion], (err, results) => {
    if (err) return res.status(500).json({ error: err.message });
    res.status(201).json({ message: 'Especialidad creada' });
  });
});

// Eliminar especialidad
router.delete('/:cod_especialidad', verificarToken, (req, res) => {
  const { cod_especialidad } = req.params;
  const query = 'DELETE FROM Especialidades WHERE cod_especialidad = ?';
  db.query(query, [cod_especialidad], (err, results) => {
    if (err) return res.status(500).json({ error: err.message });
    res.json({ message: 'Especialidad eliminada' });
  });
});

module.exports = router;
