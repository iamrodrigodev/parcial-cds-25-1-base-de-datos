const express = require('express');
const router = express.Router();
const db = require('../db');
const verificarToken = require('../middleware/auth');

// Obtener todos los contratos
router.get('/', verificarToken, (req, res) => {
  db.query('SELECT * FROM Contratos', (err, results) => {
    if (err) return res.status(500).json({ error: err.message });
    res.json(results);
  });
});

// Crear un nuevo contrato
router.post('/', verificarToken, (req, res) => {
  const { cod_empleado, fecha_inicio, fecha_fin, salario_men, observaciones, estado } = req.body;
  const query = 'INSERT INTO Contratos (cod_empleado, fecha_inicio, fecha_fin, salario_men, observaciones, estado) VALUES (?, ?, ?, ?, ?, ?)';
  db.query(query, [cod_empleado, fecha_inicio, fecha_fin, salario_men, observaciones, estado], (err, results) => {
    if (err) return res.status(500).json({ error: err.message });
    res.status(201).json({ message: 'Contrato creado' });
  });
});

// Actualizar contrato
router.put('/:cod_contrato', verificarToken, (req, res) => {
  const { cod_contrato } = req.params;
  const { cod_empleado, fecha_inicio, fecha_fin, salario_men, observaciones, estado } = req.body;
  const query = 'UPDATE Contratos SET cod_empleado = ?, fecha_inicio = ?, fecha_fin = ?, salario_men = ?, observaciones = ?, estado = ? WHERE cod_contrato = ?';
  db.query(query, [cod_empleado, fecha_inicio, fecha_fin, salario_men, observaciones, estado, cod_contrato], (err, results) => {
    if (err) return res.status(500).json({ error: err.message });
    res.json({ message: 'Contrato actualizado' });
  });
});

// Eliminar contrato
router.delete('/:cod_contrato', verificarToken, (req, res) => {
  const { cod_contrato } = req.params;
  const query = 'DELETE FROM Contratos WHERE cod_contrato = ?';
  db.query(query, [cod_contrato], (err, results) => {
    if (err) return res.status(500).json({ error: err.message });
    res.json({ message: 'Contrato eliminado' });
  });
});

module.exports = router;
