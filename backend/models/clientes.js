const mysqlPool = require('../db/mysqlConnectionPool');

class ClientesModel {
    constructor() {
        this.mysqlPool = mysqlPool;
    }

    async agregarCliente(id_persona, tipo_cliente) {
        try {
            const conn = await this.mysqlPool.getConnection();
            await conn.query('CALL AgregarCliente(?, ?)', [id_persona, tipo_cliente]);
            conn.release();
            return true;
        } catch (e) {
            throw e;
        }
    }

}

module.exports = new ClientesModel();
