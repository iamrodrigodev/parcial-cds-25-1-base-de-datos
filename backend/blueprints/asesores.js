const express = require('express');
const router = express.Router();
const db = require('../../db');
const verificarToken = require('../../middleware/auth');

// Obtener todos los asesores
router.get('/', verificarToken, (req, res) => {
  db.query('SELECT * FROM Asesores', (err, results) => {
    if (err) return res.status(500).json({ error: err.message });
    res.json(results);
  });
});

// Crear un nuevo asesor
router.post('/', verificarToken, (req, res) => {
  const { cod_empleado, experiencia } = req.body;
  const query = 'INSERT INTO Asesores (cod_empleado, experiencia) VALUES (?, ?)';
  db.query(query, [cod_empleado, experiencia], (err, results) => {
    if (err) return res.status(500).json({ error: err.message });
    res.status(201).json({ message: 'Asesor creado' });
  });
});

// Eliminar asesor
router.delete('/:cod_asesor', verificarToken, (req, res) => {
  const { cod_asesor } = req.params;
  const query = 'DELETE FROM Asesores WHERE cod_asesor = ?';
  db.query(query, [cod_asesor], (err, results) => {
    if (err) return res.status(500).json({ error: err.message });
    res.json({ message: 'Asesor eliminado' });
  });
});

module.exports = router;
