const mysqlPool = require('../db/mysqlConnectionPool');

class LineasModel {
    constructor() {
        this.mysqlPool = mysqlPool;
    }

    async agregarLinea(id_producto, nombre_linea) {
        try {
            const conn = await this.mysqlPool.getConnection();
            await conn.query('CALL AgregarLinea(?, ?)', [id_producto, nombre_linea]);
            conn.release();
            return true;
        } catch (e) {
            throw e;
        }
    }

}

module.exports = new LineasModel();
