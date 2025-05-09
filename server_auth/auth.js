const jwt = require('jwt-simple');

function verificarToken(req, res, next) {
  const token = req.headers['authorization'];

  if (!token) {
    return res.status(403).json({ message: 'No se proporciono token' });
  }

  try {
    const decoded = jwt.decode(token, 'mi_clave_secreta');
    req.user = decoded; // Almacenar los datos del usuario en el objeto `req`
    next(); // Continuar con la siguiente funcion de middleware o controlador
  } catch (err) {
    return res.status(403).json({ message: 'Token inválido' });
  }
}

module.exports = verificarToken;
