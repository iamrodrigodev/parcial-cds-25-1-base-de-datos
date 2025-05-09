const mysqlPool = require('../db/mysqlConnectionPool');

class AsesoresModel {
    constructor() {
        this.mysqlPool = mysqlPool;
    }

    async agregarAsesor(id_empleado, especialidad) {
        try {
            const conn = await this.mysqlPool.getConnection();
            await conn.query('CALL AgregarAsesor(?, ?)', [id_empleado, especialidad]);
            conn.release();
            return true;
        } catch (e) {
            throw e;
        }
    }

}

module.exports = new AsesoresModel();
