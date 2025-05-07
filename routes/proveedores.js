const express = require('express');
const router = express.Router();
const db = require('../db');
const verificarToken = require('../middleware/auth');

// Obtener todos los proveedores
router.get('/', verificarToken, (req, res) => {
  db.query('SELECT * FROM Proveedores', (err, results) => {
    if (err) return res.status(500).json({ error: err.message });
    res.json(results);
  });
});

// Crear un nuevo proveedor
router.post('/', verificarToken, (req, res) => {
  const { ruc, nombre } = req.body;
  const query = 'INSERT INTO Proveedores (ruc, nombre) VALUES (?, ?)';
  db.query(query, [ruc, nombre], (err, results) => {
    if (err) return res.status(500).json({ error: err.message });
    res.status(201).json({ message: 'Proveedor creado' });
  });
});

// Eliminar proveedor
router.delete('/:ruc', verificarToken, (req, res) => {
  const { ruc } = req.params;
  const query = 'DELETE FROM Proveedores WHERE ruc = ?';
  db.query(query, [ruc], (err, results) => {
    if (err) return res.status(500).json({ error: err.message });
    res.json({ message: 'Proveedor eliminado' });
  });
});

module.exports = router;
