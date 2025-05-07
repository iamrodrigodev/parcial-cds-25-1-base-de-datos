const express = require('express');
const router = express.Router();
const db = require('../db');
const verificarToken = require('../middleware/auth');

// Obtener todas las líneas
router.get('/', verificarToken, (req, res) => {
  db.query('SELECT * FROM Lineas', (err, results) => {
    if (err) return res.status(500).json({ error: err.message });
    res.json(results);
  });
});

// Crear una nueva línea
router.post('/', verificarToken, (req, res) => {
  const { ruc, nombre_linea } = req.body;
  const query = 'INSERT INTO Lineas (ruc, nombre_linea) VALUES (?, ?)';
  db.query(query, [ruc, nombre_linea], (err, results) => {
    if (err) return res.status(500).json({ error: err.message });
    res.status(201).json({ message: 'Línea creada' });
  });
});

// Eliminar línea
router.delete('/:cod_linea', verificarToken, (req, res) => {
  const { cod_linea } = req.params;
  const query = 'DELETE FROM Lineas WHERE cod_linea = ?';
  db.query(query, [cod_linea], (err, results) => {
    if (err) return res.status(500).json({ error: err.message });
    res.json({ message: 'Línea eliminada' });
  });
});

module.exports = router;
