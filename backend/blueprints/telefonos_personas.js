const express = require('express');
const router = express.Router();
const db = require('../../db');
const verificarToken = require('../../middleware/auth');

// Obtener teleonos de una persona
router.get('/:dni', verificarToken, (req, res) => {
  const { dni } = req.params;
  db.query('SELECT * FROM Telefonos_Personas WHERE dni = ?', [dni], (err, results) => {
    if (err) return res.status(500).json({ error: err.message });
    res.json(results);
  });
});

// Agregar telefono a una persona
router.post('/:dni', verificarToken, (req, res) => {
  const { dni } = req.params;
  const { telefono } = req.body;
  const query = 'INSERT INTO Telefonos_Personas (telefono, dni) VALUES (?, ?)';
  db.query(query, [telefono, dni], (err, results) => {
    if (err) return res.status(500).json({ error: err.message });
    res.status(201).json({ message: 'Teléfono agregado' });
  });
});

// Eliminar telefono
router.delete('/:dni/:telefono', verificarToken, (req, res) => {
  const { dni, telefono } = req.params;
  const query = 'DELETE FROM Telefonos_Personas WHERE dni = ? AND telefono = ?';
  db.query(query, [dni, telefono], (err, results) => {
    if (err) return res.status(500).json({ error: err.message });
    res.json({ message: 'Teléfono eliminado' });
  });
});

module.exports = router;
