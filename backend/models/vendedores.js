const mysqlPool = require('../db/mysqlConnectionPool');

class VendedoresModel {
    constructor() {
        this.mysqlPool = mysqlPool;
    }

    async agregarVendedor(id_empleado, zona) {
        try {
            const conn = await this.mysqlPool.getConnection();
            await conn.query('CALL AgregarVendedor(?, ?)', [id_empleado, zona]);
            conn.release();
            return true;
        } catch (e) {
            throw e;
        }
    }

}

module.exports = new VendedoresModel();
