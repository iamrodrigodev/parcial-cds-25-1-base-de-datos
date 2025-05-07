const express = require('express');
const router = express.Router();
const db = require('../db');
const verificarToken = require('../middleware/auth');

// Obtener todos los clientes
router.get('/', verificarToken, (req, res) => {
  db.query('SELECT * FROM Clientes', (err, results) => {
    if (err) return res.status(500).json({ error: err.message });
    res.json(results);
  });
});

// Crear un nuevo cliente
router.post('/', verificarToken, (req, res) => {
  const { dni, tipo_cliente } = req.body;
  const query = 'INSERT INTO Clientes (dni, tipo_cliente) VALUES (?, ?)';
  db.query(query, [dni, tipo_cliente], (err, results) => {
    if (err) return res.status(500).json({ error: err.message });
    res.status(201).json({ message: 'Cliente creado' });
  });
});

// Actualizar cliente
router.put('/:dni', verificarToken, (req, res) => {
  const { dni } = req.params;
  const { tipo_cliente } = req.body;
  const query = 'UPDATE Clientes SET tipo_cliente = ? WHERE dni = ?';
  db.query(query, [tipo_cliente, dni], (err, results) => {
    if (err) return res.status(500).json({ error: err.message });
    res.json({ message: 'Cliente actualizado' });
  });
});

// Eliminar cliente
router.delete('/:dni', verificarToken, (req, res) => {
  const { dni } = req.params;
  const query = 'DELETE FROM Clientes WHERE dni = ?';
  db.query(query, [dni], (err, results) => {
    if (err) return res.status(500).json({ error: err.message });
    res.json({ message: 'Cliente eliminado' });
  });
});

module.exports = router;
