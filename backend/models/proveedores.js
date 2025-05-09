const mysqlPool = require('../db/mysqlConnectionPool');

class ProveedoresModel {
    constructor() {
        this.mysqlPool = mysqlPool;
    }

    async agregarProveedor(nombre, direccion) {
        try {
            const conn = await this.mysqlPool.getConnection();
            await conn.query('CALL AgregarProveedor(?, ?)', [nombre, direccion]);
            conn.release();
            return true;
        } catch (e) {
            throw e;
        }
    }

}

module.exports = new ProveedoresModel();
