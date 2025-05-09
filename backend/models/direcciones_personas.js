const mysqlPool = require('../db/mysqlConnectionPool');

class DireccionesPersonasModel {
    constructor() {
        this.mysqlPool = mysqlPool;
    }

    async agregarDireccionPersona(id_persona, direccion) {
        try {
            const conn = await this.mysqlPool.getConnection();
            await conn.query('CALL AgregarDireccionPersona(?, ?)', [id_persona, direccion]);
            conn.release();
            return true;
        } catch (e) {
            throw e;
        }
    }

}

module.exports = new DireccionesPersonasModel();
