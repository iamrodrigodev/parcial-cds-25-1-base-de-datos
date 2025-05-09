const express = require('express');
const router = express.Router();
const db = require('../../db');
const verificarToken = require('../../middleware/auth');

// Obtener todos los empleados
router.get('/', verificarToken, (req, res) => {
  db.query('SELECT * FROM Empleados', (err, results) => {
    if (err) return res.status(500).json({ error: err.message });
    res.json(results);
  });
});

// Crear un nuevo empleado
router.post('/', verificarToken, (req, res) => {
  const { dni, estado, contraseña, es_administrador } = req.body;
  const query = 'INSERT INTO Empleados (dni, estado, contraseña, es_administrador) VALUES (?, ?, ?, ?)';
  db.query(query, [dni, estado, contraseña, es_administrador], (err, results) => {
    if (err) return res.status(500).json({ error: err.message });
    res.status(201).json({ message: 'Empleado creado' });
  });
});

// Actualizar empleado
router.put('/:cod_empleado', verificarToken, (req, res) => {
  const { cod_empleado } = req.params;
  const { dni, estado, contraseña, es_administrador } = req.body;
  const query = 'UPDATE Empleados SET dni = ?, estado = ?, contraseña = ?, es_administrador = ? WHERE cod_empleado = ?';
  db.query(query, [dni, estado, contraseña, es_administrador, cod_empleado], (err, results) => {
    if (err) return res.status(500).json({ error: err.message });
    res.json({ message: 'Empleado actualizado' });
  });
});

// Eliminar empleado
router.delete('/:cod_empleado', verificarToken, (req, res) => {
  const { cod_empleado } = req.params;
  const query = 'DELETE FROM Empleados WHERE cod_empleado = ?';
  db.query(query, [cod_empleado], (err, results) => {
    if (err) return res.status(500).json({ error: err.message });
    res.json({ message: 'Empleado eliminado' });
  });
});

module.exports = router;
