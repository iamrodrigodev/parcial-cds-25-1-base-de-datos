const mysqlPool = require('../db/mysqlConnectionPool');

class ProductosModel {
    constructor() {
        this.mysqlPool = mysqlPool;
    }

    async agregarProducto(nombre, descripcion) {
        try {
            const conn = await this.mysqlPool.getConnection();
            await conn.query('CALL AgregarProducto(?, ?)', [nombre, descripcion]);
            conn.release();
            return true;
        } catch (e) {
            throw e;
        }
    }

}

module.exports = new ProductosModel();
