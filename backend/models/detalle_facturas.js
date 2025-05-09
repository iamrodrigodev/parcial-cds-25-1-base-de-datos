const mysqlPool = require('../db/mysqlConnectionPool');

class DetalleFacturasModel {
    constructor() {
        this.mysqlPool = mysqlPool;
    }

    async agregarDetalleFactura(id_factura, id_producto, cantidad, precio) {
        try {
            const conn = await this.mysqlPool.getConnection();
            await conn.query('CALL AgregarDetalleFactura(?, ?, ?, ?)', [id_factura, id_producto, cantidad, precio]);
            conn.release();
            return true;
        } catch (e) {
            throw e;
        }
    }

}