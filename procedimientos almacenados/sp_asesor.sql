USE FabiaNatura;

-- POST Asesores --
DELIMITER $$
CREATE PROCEDURE IF NOT EXISTS AgregarAsesor(
    IN p_dni CHAR(8),
    IN p_nombre VARCHAR(20),
    IN p_apellido_paterno VARCHAR(20),
    IN p_apellido_materno VARCHAR(20),
    IN p_fecha_nacimiento DATE,
    IN p_experiencia INT,
    IN p_contraseña VARCHAR(30),
    IN p_es_administrador BOOLEAN
)
BEGIN
    DECLARE v_cod_empleado INT;
    DECLARE v_cod_asesor INT;

    -- Validar DNI
    IF p_dni IS NULL OR p_dni = '' OR LENGTH(p_dni) != 8 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'DNI inválido. Debe tener 8 caracteres.';
    END IF;

    -- Validar nombre de persona
    IF p_nombre IS NULL OR p_nombre = '' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El nombre no puede estar vacío';
    END IF;

    -- Validar apellidos de persona
    IF p_apellido_paterno IS NULL OR p_apellido_paterno = '' OR
       p_apellido_materno IS NULL OR p_apellido_materno = '' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Los apellidos no pueden estar vacíos';
    END IF;

    -- Validar fecha de nacimiento
    IF p_fecha_nacimiento IS NULL OR p_fecha_nacimiento > CURDATE() THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Fecha de nacimiento inválida';
    END IF;

    -- Validar experiencia
    IF p_experiencia IS NULL OR p_experiencia < 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La experiencia debe ser un número no negativo';
    END IF;

    -- Validar contraseña
    IF p_contraseña IS NULL OR LENGTH(p_contraseña) < 6 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La contraseña debe tener al menos 6 caracteres';
    END IF;

    -- Verificar que el DNI no exista ya como persona
    IF EXISTS (SELECT 1 FROM Personas WHERE dni = p_dni) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Ya existe una persona con este DNI';
    END IF;

    IF EXISTS (SELECT 1 FROM Empleados WHERE dni = p_dni) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Ya existe un empleado con este DNI';
    END IF;

    -- Iniciar transacción
    START TRANSACTION;

    -- Insertar persona
    INSERT INTO Personas (dni, nombre, apellido_paterno, apellido_materno, fecha_nacimiento)
    VALUES (p_dni, p_nombre, p_apellido_paterno, p_apellido_materno, p_fecha_nacimiento);

    -- Insertar empleado
    INSERT INTO Empleados (dni, estado, contraseña, es_administrador)
    VALUES (p_dni, 'activo', p_contraseña, p_es_administrador);

    -- Obtener el código de empleado
    SET v_cod_empleado = LAST_INSERT_ID();

    -- Insertar asesor
    INSERT INTO Asesores (cod_empleado, experiencia)
    VALUES (v_cod_empleado, p_experiencia);

    -- Confirmar transacción
    COMMIT;

    -- Devolver los códigos generados
    SELECT v_cod_empleado AS cod_empleado, LAST_INSERT_ID() AS cod_asesor;
END $$
DELIMITER ;

-- GET Asesores --
DELIMITER $$
CREATE PROCEDURE IF NOT EXISTS ObtenerAsesores()
BEGIN
    -- Obtener todos los asesores con sus datos de empleado
    SELECT 
        a.cod_asesor,
        CONCAT(p.nombre, ' ', p.apellido_paterno, ' ', p.apellido_materno) AS nombre_completo,
        p.dni,
        e.estado,
        e.es_administrador
    FROM Asesores a
    JOIN Empleados e ON a.cod_empleado = e.cod_empleado
    JOIN Personas p ON e.dni = p.dni
    ORDER BY p.apellido_paterno, p.apellido_materno, p.nombre;
END $$
DELIMITER ;

-- GET Asesor por DNI --
DELIMITER $$
CREATE PROCEDURE IF NOT EXISTS ObtenerAsesorPorCodigo(
    IN p_cod_asesor INT
)
BEGIN
    -- Validar que el código de asesor no sea NULL
    IF p_cod_asesor IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El código de asesor no puede ser nulo';
    END IF;

    -- Verificar si el asesor existe
    IF NOT EXISTS (SELECT 1 FROM Asesores WHERE cod_asesor = p_cod_asesor) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No se encontró un asesor con este código';
    END IF;

    -- Obtener el asesor con sus datos de empleado
    SELECT 
        a.cod_asesor,
        a.cod_empleado,
        a.experiencia,
        CONCAT(p.nombre, ' ', p.apellido_paterno, ' ', p.apellido_materno) AS nombre_completo
    FROM Asesores a 
    JOIN Empleados e ON a.cod_empleado = e.cod_empleado     
    JOIN Personas p ON e.dni = p.dni
    WHERE a.cod_asesor = p_cod_asesor;
END $$  
DELIMITER ;

-- PUT Asesores --
DELIMITER $$
CREATE PROCEDURE IF NOT EXISTS ActualizarAsesor(
    IN p_dni CHAR(8),
    IN p_nombre VARCHAR(20),
    IN p_apellido_paterno VARCHAR(20),
    IN p_apellido_materno VARCHAR(20),
    IN p_fecha_nacimiento DATE,
    IN p_experiencia INT,
    IN p_contraseña VARCHAR(30),
    IN p_es_administrador BOOLEAN
)
BEGIN
    -- Validar DNI
    IF p_dni IS NULL OR p_dni = '' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El DNI no puede estar vacío';
    END IF;

    IF LENGTH(p_dni) != 8 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El DNI debe tener 8 caracteres';
    END IF;

    -- Validar nombre y apellidos
    IF p_nombre IS NULL OR p_nombre = '' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El nombre no puede estar vacío';
    END IF;

    IF p_apellido_paterno IS NULL OR p_apellido_paterno = '' OR
       p_apellido_materno IS NULL OR p_apellido_materno = '' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Los apellidos no pueden estar vacíos';
    END IF;

    -- Validar fecha de nacimiento
    IF p_fecha_nacimiento IS NULL OR p_fecha_nacimiento > CURDATE() THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Fecha de nacimiento inválida';
    END IF;

    -- Validar experiencia
    IF p_experiencia IS NULL OR p_experiencia < 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La experiencia debe ser un número no negativo';
    END IF;

    -- Validar contraseña
    IF p_contraseña IS NULL OR LENGTH(p_contraseña) < 6 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La contraseña debe tener al menos 6 caracteres';
    END IF;

    -- Verificar existencia del asesor
    IF NOT EXISTS (
        SELECT 1
        FROM Asesores a
        JOIN Empleados e ON a.cod_empleado = e.cod_empleado
        WHERE e.dni = p_dni
    ) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No se encontró un asesor con este DNI';
    END IF;

    -- Actualizar registros
    UPDATE Asesores a
    JOIN Empleados e ON a.cod_empleado = e.cod_empleado
    JOIN Personas p ON e.dni = p.dni
    SET p.nombre = p_nombre,
        p.apellido_paterno = p_apellido_paterno,
        p.apellido_materno = p_apellido_materno,
        p.fecha_nacimiento = p_fecha_nacimiento,
        e.clave = p_contraseña,
        e.es_administrador = p_es_administrador,
        a.experiencia = p_experiencia
    WHERE e.dni = p_dni;
END $$
DELIMITER ;
