USE FabiaNatura;

DELIMITER $$
CREATE PROCEDURE IF NOT EXISTS AgregarContrato(
    IN p_cod_empleado INT,       
    IN p_fecha_inicio DATE,        
    IN p_fecha_fin DATE,            
    IN p_salario_men FLOAT,      
    IN p_observaciones TEXT 
)
BEGIN
    DECLARE v_empleado_count INT;
    DECLARE v_estado_empleado ENUM('activo', 'inactivo');

    -- Verificar si el empleado con el código proporcionado existe
    SELECT COUNT(*) INTO v_empleado_count
    FROM Empleados
    WHERE cod_empleado = p_cod_empleado;

    -- Si no existe el empleado, lanzar un error
    IF v_empleado_count = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No se encontró un empleado con ese código';
    END IF;

    -- Obtener el estado actual del empleado
    SELECT estado INTO v_estado_empleado
    FROM Empleados
    WHERE cod_empleado = p_cod_empleado;

    -- Si el empleado está inactivo, actualizar su estado a 'activo'
    IF v_estado_empleado = 'inactivo' THEN
        UPDATE Empleados
        SET estado = 'activo'
        WHERE cod_empleado = p_cod_empleado;
    END IF;

    -- Validar que el salario mensual sea mayor que 0
    IF p_salario_men <= 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El salario mensual debe ser mayor que 0';
    END IF;

    -- Insertar el contrato en la tabla Contratos
    INSERT INTO Contratos (
        cod_empleado, 
        fecha_inicio, 
        fecha_fin, 
        salario_men, 
        observaciones, 
        estado
    )
    VALUES (
        p_cod_empleado, 
        p_fecha_inicio, 
        p_fecha_fin, 
        p_salario_men, 
        p_observaciones, 
        'activo' -- El contrato se marca como activo por defecto
    );
END $$
DELIMITER ;

-- GET Contratos --
DELIMITER $$
CREATE PROCEDURE IF NOT EXISTS ObtenerTodosLosContratos()
BEGIN
    DECLARE v_contrato_count INT;

    -- Verificar si existen contratos en la base de datos
    SELECT COUNT(*) INTO v_contrato_count
    FROM Contratos;

    -- Si no hay contratos, lanzar un error
    IF v_contrato_count = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No hay contratos registrados';
    END IF;

    -- Obtener todos los contratos con los detalles del empleado
    SELECT 
        c.cod_contrato,
        e.cod_empleado,
        CONCAT(p.nombre, ' ', p.apellido_paterno, ' ', p.apellido_materno) AS nombre_completo,
        c.fecha_inicio,
        c.fecha_fin,
        c.salario_men,
        c.observaciones,
        c.estado
    FROM Contratos c
    JOIN Empleados e ON c.cod_empleado = e.cod_empleado
    JOIN Personas p ON e.dni = p.dni
    ORDER BY c.fecha_inicio;
END $$
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE IF NOT EXISTS ObtenerContratoPorCodigo(
    IN p_cod_contrato INT
)
BEGIN
    DECLARE v_contrato_count INT;

    -- Verificar si el contrato con el código proporcionado existe
    SELECT COUNT(*) INTO v_contrato_count
    FROM Contratos
    WHERE cod_contrato = p_cod_contrato;

    -- Si no existe el contrato, lanzar un error
    IF v_contrato_count = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No se encontró un contrato con ese código';
    END IF;

    -- Obtener los detalles del contrato con la información del empleado y persona
    SELECT 
        c.cod_contrato,
        e.cod_empleado,
        CONCAT(p.nombre, ' ', p.apellido_paterno, ' ', p.apellido_materno) AS nombre_completo,
        c.fecha_inicio,
        c.fecha_fin,
        c.salario_men,
        c.observaciones,
        c.estado
    FROM Contratos c
    JOIN Empleados e ON c.cod_empleado = e.cod_empleado
    JOIN Personas p ON e.dni = p.dni
    WHERE c.cod_contrato = p_cod_contrato;
END $$
DELIMITER ;

-- PUT Contratos --
DELIMITER $$
CREATE PROCEDURE IF NOT EXISTS ActualizarContrato(
    IN p_cod_contrato INT,           
    IN p_fecha_inicio DATE,        
    IN p_fecha_fin DATE,              
    IN p_salario_men FLOAT,      
    IN p_observaciones TEXT,        
    IN p_estado ENUM('activo', 'inactivo')  
)
BEGIN
    DECLARE v_contrato_count INT;

    -- Verificar si el contrato con el código proporcionado existe
    SELECT COUNT(*) INTO v_contrato_count
    FROM Contratos
    WHERE cod_contrato = p_cod_contrato;

    -- Si no existe el contrato, lanzar un error
    IF v_contrato_count = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No se encontró un contrato con ese código';
    END IF;

    -- Validar que el salario mensual sea mayor que 0
    IF p_salario_men <= 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El salario mensual debe ser mayor que 0';
    END IF;

    -- Validar que la fecha de inicio no sea posterior a la fecha de fin
    IF p_fecha_inicio > p_fecha_fin AND p_fecha_fin IS NOT NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La fecha de inicio no puede ser posterior a la fecha de fin';
    END IF;

    -- Actualizar el contrato con los nuevos valores
    UPDATE Contratos
    SET 
        fecha_inicio = p_fecha_inicio,
        fecha_fin = p_fecha_fin,
        salario_men = p_salario_men,
        observaciones = p_observaciones,
        estado = p_estado
    WHERE cod_contrato = p_cod_contrato;
END $$
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE IF NOT EXISTS DesactivarContrato(
    IN p_cod_contrato INT
)
BEGIN
    DECLARE v_contrato_count INT;
    DECLARE v_estado_contrato ENUM('activo', 'inactivo');
    DECLARE v_cod_empleado INT;

    -- Verificar si el contrato con el código proporcionado existe
    SELECT COUNT(*) INTO v_contrato_count
    FROM Contratos
    WHERE cod_contrato = p_cod_contrato;

    -- Si no existe el contrato, lanzar un error
    IF v_contrato_count = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No se encontró un contrato con ese código';
    END IF;

    -- Obtener el estado actual del contrato y el cod_empleado asociado
    SELECT estado, cod_empleado INTO v_estado_contrato, v_cod_empleado
    FROM Contratos
    WHERE cod_contrato = p_cod_contrato;

    -- Si el contrato ya está inactivo, lanzar un error
    IF v_estado_contrato = 'inactivo' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El contrato ya está desactivado';
    END IF;

    -- Desactivar el contrato
    UPDATE Contratos
    SET estado = 'inactivo'
    WHERE cod_contrato = p_cod_contrato;

    -- Desactivar el empleado asociado al contrato
    UPDATE Empleados
    SET estado = 'inactivo'
    WHERE cod_empleado = v_cod_empleado;
END $$
DELIMITER ;