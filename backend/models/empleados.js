const mysqlPool = require('../db/mysqlConnectionPool');

class EmpleadosModel {
    constructor() {
        this.mysqlPool = mysqlPool;
    }

    async agregarEmpleado(id_persona, cargo) {
        try {
            const conn = await this.mysqlPool.getConnection();
            await conn.query('CALL AgregarEmpleado(?, ?)', [id_persona, cargo]);
            conn.release();
            return true;
        } catch (e) {
            throw e;
        }
    }

}

module.exports = new EmpleadosModel();
