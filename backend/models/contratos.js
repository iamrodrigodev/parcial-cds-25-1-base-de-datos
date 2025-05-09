const mysqlPool = require('../db/mysqlConnectionPool');

class ContratosModel {
    constructor() {
        this.mysqlPool = mysqlPool;
    }

    async crearContrato(id_cliente, fecha_inicio, fecha_fin) {
        try {
            const conn = await this.mysqlPool.getConnection();
            await conn.query('CALL CrearContrato(?, ?, ?)', [id_cliente, fecha_inicio, fecha_fin]);
            conn.release();
            return true;
        } catch (e) {
            throw e;
        }
    }

}

module.exports = new ContratosModel();
