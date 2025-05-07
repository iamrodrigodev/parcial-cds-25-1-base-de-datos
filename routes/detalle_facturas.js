const express = require('express');
const router = express.Router();
const db = require('../db');
const verificarToken = require('../middleware/auth');

// Obtener detalles de facturas
router.get('/', verificarToken, (req, res) => {
  db.query('SELECT * FROM Detalle_Facturas', (err, results) => {
    if (err) return res.status(500).json({ error: err.message });
    res.json(results);
  });
});

// Crear un nuevo detalle de factura
router.post('/', verificarToken, (req, res) => {
  const { cod_factura, cod_producto, cantidad } = req.body;
  const query = 'INSERT INTO Detalle_Facturas (cod_factura, cod_producto, cantidad) VALUES (?, ?, ?)';
  db.query(query, [cod_factura, cod_producto, cantidad], (err, results) => {
    if (err) return res.status(500).json({ error: err.message });
    res.status(201).json({ message: 'Detalle de factura creado' });
  });
});

// Eliminar detalle de factura
router.delete('/:cod_factura/:cod_producto', verificarToken, (req, res) => {
  const { cod_factura, cod_producto } = req.params;
  const query = 'DELETE FROM Detalle_Facturas WHERE cod_factura = ? AND cod_producto = ?';
  db.query(query, [cod_factura, cod_producto], (err, results) => {
    if (err) return res.status(500).json({ error: err.message });
    res.json({ message: 'Detalle de factura eliminado' });
  });
});

module.exports = router;
