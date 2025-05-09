const express = require('express');
const router = express.Router();
const db = require('../../db');
const verificarToken = require('../../middleware/auth');

// Obtener todos los roles
router.get('/', verificarToken, (req, res) => {
  db.query('SELECT * FROM Roles', (err, results) => {
    if (err) return res.status(500).json({ error: err.message });
    res.json(results);
  });
});

// Crear un nuevo rol
router.post('/', verificarToken, (req, res) => {
  const { nombre_rol, descripcion } = req.body;
  const query = 'INSERT INTO Roles (nombre_rol, descripcion) VALUES (?, ?)';
  db.query(query, [nombre_rol, descripcion], (err, results) => {
    if (err) return res.status(500).json({ error: err.message });
    res.status(201).json({ message: 'Rol creado' });
  });
});

// Actualizar rol
router.put('/:cod_rol', verificarToken, (req, res) => {
  const { cod_rol } = req.params;
  const { nombre_rol, descripcion } = req.body;
  const query = 'UPDATE Roles SET nombre_rol = ?, descripcion = ? WHERE cod_rol = ?';
  db.query(query, [nombre_rol, descripcion, cod_rol], (err, results) => {
    if (err) return res.status(500).json({ error: err.message });
    res.json({ message: 'Rol actualizado' });
  });
});

// Eliminar rol
router.delete('/:cod_rol', verificarToken, (req, res) => {
  const { cod_rol } = req.params;
  const query = 'DELETE FROM Roles WHERE cod_rol = ?';
  db.query(query, [cod_rol], (err, results) => {
    if (err) return res.status(500).json({ error: err.message });
    res.json({ message: 'Rol eliminado' });
  });
});

module.exports = router;
