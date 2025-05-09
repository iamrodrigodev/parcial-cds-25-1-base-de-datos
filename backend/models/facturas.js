const mysqlPool = require('../db/mysqlConnectionPool');

class FacturasModel {
    constructor() {
        this.mysqlPool = mysqlPool;
    }

    async crearFactura(id_cliente, monto_total) {
        try {
            const conn = await this.mysqlPool.getConnection();
            await conn.query('CALL CrearFactura(?, ?)', [id_cliente, monto_total]);
            conn.release();
            return true;
        } catch (e) {
            throw e;
        }
    }

}

module.exports = new FacturasModel();
