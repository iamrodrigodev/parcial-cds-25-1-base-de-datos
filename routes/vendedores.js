const express = require('express');
const router = express.Router();
const db = require('../db');
const verificarToken = require('../middleware/auth');

// Obtener todos los vendedores
router.get('/', verificarToken, (req, res) => {
  db.query('SELECT * FROM Vendedores', (err, results) => {
    if (err) return res.status(500).json({ error: err.message });
    res.json(results);
  });
});

// Crear un nuevo vendedor
router.post('/', verificarToken, (req, res) => {
  const { cod_empleado, cod_rol } = req.body;
  const query = 'INSERT INTO Vendedores (cod_empleado, cod_rol) VALUES (?, ?)';
  db.query(query, [cod_empleado, cod_rol], (err, results) => {
    if (err) return res.status(500).json({ error: err.message });
    res.status(201).json({ message: 'Vendedor creado' });
  });
});

// Eliminar vendedor
router.delete('/:cod_vendedor', verificarToken, (req, res) => {
  const { cod_vendedor } = req.params;
  const query = 'DELETE FROM Vendedores WHERE cod_vendedor = ?';
  db.query(query, [cod_vendedor], (err, results) => {
    if (err) return res.status(500).json({ error: err.message });
    res.json({ message: 'Vendedor eliminado' });
  });
});

module.exports = router;
