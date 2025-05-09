const express = require('express');
const router = express.Router();
const db = require('../../db');
const verificarToken = require('../../middleware/auth');

// Obtener todas las facturas
router.get('/', verificarToken, (req, res) => {
  db.query('SELECT * FROM Facturas', (err, results) => {
    if (err) return res.status(500).json({ error: err.message });
    res.json(results);
  });
});

// Crear una nueva factura
router.post('/', verificarToken, (req, res) => {
  const { dni, cod_vendedor, cod_asesor } = req.body;
  const query = 'INSERT INTO Facturas (dni, cod_vendedor, cod_asesor) VALUES (?, ?, ?)';
  db.query(query, [dni, cod_vendedor, cod_asesor], (err, results) => {
    if (err) return res.status(500).json({ error: err.message });
    res.status(201).json({ message: 'Factura creada' });
  });
});

// Eliminar factura
router.delete('/:cod_factura', verificarToken, (req, res) => {
  const { cod_factura } = req.params;
  const query = 'DELETE FROM Facturas WHERE cod_factura = ?';
  db.query(query, [cod_factura], (err, results) => {
    if (err) return res.status(500).json({ error: err.message });
    res.json({ message: 'Factura eliminada' });
  });
});

module.exports = router;
