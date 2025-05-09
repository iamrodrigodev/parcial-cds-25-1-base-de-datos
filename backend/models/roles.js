const mysqlPool = require('../db/mysqlConnectionPool');

class RolesModel {
    constructor() {
        this.mysqlPool = mysqlPool;
    }

    async agregarRol(id_empleado, rol) {
        try {
            const conn = await this.mysqlPool.getConnection();
            await conn.query('CALL AgregarRol(?, ?)', [id_empleado, rol]);
            conn.release();
            return true;
        } catch (e) {
            throw e;
        }
    }

}

module.exports = new RolesModel();
