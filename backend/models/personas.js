const mysqlPool = require('../db/mysqlConnectionPool');

class PersonasModel {
    constructor() {
        this.mysqlPool = mysqlPool;
    }

    async crearPersona(nombre, fecha_nacimiento) {
        try {
            const conn = await this.mysqlPool.getConnection();
            await conn.query('CALL CrearPersona(?, ?)', [nombre, fecha_nacimiento]);
            conn.release();
            return true;
        } catch (e) {
            throw e;
        }
    }

    async obtenerPersonaPorId(id_persona) {
        try {
            const conn = await this.mysqlPool.getConnection();
            const [result] = await conn.query('CALL ObtenerPersonaPorId(?)', [id_persona]);
            conn.release();
            return result[0];
        } catch (e) {
            throw e;
        }
    }

    
}

module.exports = new PersonasModel();
