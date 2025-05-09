const mysqlPool = require('../db/mysqlConnectionPool');

class EspecialidadesModel {
    constructor() {
        this.mysqlPool = mysqlPool;
    }

    async agregarEspecialidad(id_asesor, especialidad) {
        try {
            const conn = await this.mysqlPool.getConnection();
            await conn.query('CALL AgregarEspecialidad(?, ?)', [id_asesor, especialidad]);
            conn.release();
            return true;
        } catch (e) {
            throw e;
        }
    }

}

module.exports = new EspecialidadesModel();
