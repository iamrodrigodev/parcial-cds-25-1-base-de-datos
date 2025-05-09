const express = require('express');
const router = express.Router();
const db = require('../../db');
const verificarToken = require('../../middleware/auth');

// Obtener direcciones de una persona
router.get('/:dni', verificarToken, (req, res) => {
  const { dni } = req.params;
  db.query('SELECT * FROM Direcciones_Personas WHERE dni = ?', [dni], (err, results) => {
    if (err) return res.status(500).json({ error: err.message });
    res.json(results);
  });
});

// Agregar direccion a una persona
router.post('/:dni', verificarToken, (req, res) => {
  const { dni } = req.params;
  const { direccion } = req.body;
  const query = 'INSERT INTO Direcciones_Personas (direccion, dni) VALUES (?, ?)';
  db.query(query, [direccion, dni], (err, results) => {
    if (err) return res.status(500).json({ error: err.message });
    res.status(201).json({ message: 'Dirección agregada' });
  });
});

// Eliminar direccion
router.delete('/:dni/:id_direccion', verificarToken, (req, res) => {
  const { dni, id_direccion } = req.params;
  const query = 'DELETE FROM Direcciones_Personas WHERE dni = ? AND id_direccion = ?';
  db.query(query, [dni, id_direccion], (err, results) => {
    if (err) return res.status(500).json({ error: err.message });
    res.json({ message: 'Dirección eliminada' });
  });
});

module.exports = router;
