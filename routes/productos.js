const express = require('express');
const router = express.Router();
const db = require('../db');
const verificarToken = require('../middleware/auth');

// Obtener todos los productos
router.get('/', verificarToken, (req, res) => {
  db.query('SELECT * FROM Productos', (err, results) => {
    if (err) return res.status(500).json({ error: err.message });
    res.json(results);
  });
});

// Crear un nuevo producto
router.post('/', verificarToken, (req, res) => {
  const { cod_categoria, cod_linea, nombre, descripcion, precio_compra, precio_venta, stock, estado } = req.body;
  const query = 'INSERT INTO Productos (cod_categoria, cod_linea, nombre, descripcion, precio_compra, precio_venta, stock, estado) VALUES (?, ?, ?, ?, ?, ?, ?, ?)';
  db.query(query, [cod_categoria, cod_linea, nombre, descripcion, precio_compra, precio_venta, stock, estado], (err, results) => {
    if (err) return res.status(500).json({ error: err.message });
    res.status(201).json({ message: 'Producto creado' });
  });
});

// Actualizar producto
router.put('/:cod_producto', verificarToken, (req, res) => {
  const { cod_producto } = req.params;
  const { cod_categoria, cod_linea, nombre, descripcion, precio_compra, precio_venta, stock, estado } = req.body;
  const query = 'UPDATE Productos SET cod_categoria = ?, cod_linea = ?, nombre = ?, descripcion = ?, precio_compra = ?, precio_venta = ?, stock = ?, estado = ? WHERE cod_producto = ?';
  db.query(query, [cod_categoria, cod_linea, nombre, descripcion, precio_compra, precio_venta, stock, estado, cod_producto], (err, results) => {
    if (err) return res.status(500).json({ error: err.message });
    res.json({ message: 'Producto actualizado' });
  });
});

// Eliminar producto
router.delete('/:cod_producto', verificarToken, (req, res) => {
  const { cod_producto } = req.params;
  const query = 'DELETE FROM Productos WHERE cod_producto = ?';
  db.query(query, [cod_producto], (err, results) => {
    if (err) return res.status(500).json({ error: err.message });
    res.json({ message: 'Producto eliminado' });
  });
});

module.exports = router;
