const mysqlPool = require('../db/mysqlConnectionPool');

class TelefonosPersonasModel {
    constructor() {
        this.mysqlPool = mysqlPool;
    }

    async agregarTelefonoPersona(id_persona, telefono) {
        try {
            const conn = await this.mysqlPool.getConnection();
            await conn.query('CALL AgregarTelefonoPersona(?, ?)', [id_persona, telefono]);
            conn.release();
            return true;
        } catch (e) {
            throw e;
        }
    }

    
}

module.exports = new TelefonosPersonasModel();
