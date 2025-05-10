USE FabiaNatura;

-- POST Asesores --
DELIMITER $$
CREATE PROCEDURE IF NOT EXISTS AgregarAsesor(
    IN p_dni CHAR(8),    
    IN p_nombre VARCHAR(50), 
    IN p_apellido_paterno VARCHAR(50),  
    IN p_apellido_materno VARCHAR(50), 
    IN p_fecha_nacimiento DATE, 
    IN p_estado ENUM('activo', 'inactivo'), 
    IN p_contraseña VARCHAR(30),  
    IN p_es_administrador BOOLEAN, 
    IN p_experiencia INT   
)
BEGIN
    DECLARE v_persona_count INT;
    DECLARE v_empleado_count INT;
    DECLARE v_asesor_count INT;
    DECLARE v_cod_empleado INT;

    -- Verificar si la persona con el DNI proporcionado existe en la tabla Personas
    SELECT COUNT(*) INTO v_persona_count
    FROM Personas
    WHERE dni = p_dni;

    -- Si la persona no existe, insertarla en la tabla Personas
    IF v_persona_count = 0 THEN
        INSERT INTO Personas (dni, nombre, apellido_paterno, apellido_materno, fecha_nacimiento)
        VALUES (p_dni, p_nombre, p_apellido_paterno, p_apellido_materno, p_fecha_nacimiento);
    END IF;

    -- Verificar si el empleado con el DNI proporcionado existe en la tabla Empleados
    SELECT COUNT(*) INTO v_empleado_count
    FROM Empleados
    WHERE dni = p_dni;

    -- Si no existe el empleado, insertarlo en la tabla Empleados
    IF v_empleado_count = 0 THEN
        INSERT INTO Empleados (dni, estado, contraseña, es_administrador)
        VALUES (p_dni, p_estado, p_contraseña, p_es_administrador);
    END IF;

    -- Obtener el cod_empleado del empleado recién insertado o existente
    SELECT cod_empleado INTO v_cod_empleado
    FROM Empleados
    WHERE dni = p_dni;

    -- Verificar si el empleado ya está asignado como asesor
    SELECT COUNT(*) INTO v_asesor_count
    FROM Asesores
    WHERE cod_empleado = v_cod_empleado;

    -- Si el empleado ya es asesor, lanzar un error
    IF v_asesor_count > 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El empleado ya está asignado como asesor';
    END IF;

    -- Validar que la experiencia sea positiva
    IF p_experiencia < 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La experiencia del asesor no puede ser negativa';
    END IF;

    -- Insertar el nuevo asesor
    INSERT INTO Asesores (cod_empleado, experiencia)
    VALUES (v_cod_empleado, p_experiencia);
END $$
DELIMITER ;

-- GET Asesores --
DELIMITER $$
CREATE PROCEDURE IF NOT EXISTS ObtenerAsesores()
BEGIN
    DECLARE v_asesor_count INT;

    -- Verificar si hay asesores en la base de datos
    SELECT COUNT(*) INTO v_asesor_count
    FROM Asesores;

    -- Si no hay asesores, lanzar un error
    IF v_asesor_count = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No hay asesores registrados';
    END IF;

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
    IN p_cod_asesor INT,        
    IN p_dni CHAR(8),            
    IN p_nombre VARCHAR(50),   
    IN p_apellido_paterno VARCHAR(50),
    IN p_apellido_materno VARCHAR(50), 
    IN p_fecha_nacimiento DATE,  
    IN p_estado ENUM('activo', 'inactivo'), 
    IN p_contraseña VARCHAR(30), 
    IN p_es_administrador BOOLEAN,   
    IN p_experiencia INT             
)
BEGIN
    DECLARE v_asesor_count INT;
    DECLARE v_empleado_count INT;
    DECLARE v_persona_count INT;
    DECLARE v_cod_empleado INT;

    -- Verificar si el asesor con el código proporcionado existe
    SELECT COUNT(*) INTO v_asesor_count
    FROM Asesores
    WHERE cod_asesor = p_cod_asesor;

    -- Si no existe el asesor, lanzar un error
    IF v_asesor_count = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No se encontró un asesor con ese código';
    END IF;

    -- Verificar si la persona con el DNI proporcionado existe en la tabla Personas
    SELECT COUNT(*) INTO v_persona_count
    FROM Personas
    WHERE dni = p_dni;

    -- Si la persona no existe, actualizar los datos de la persona
    IF v_persona_count = 0 THEN
        UPDATE Personas
        SET nombre = p_nombre, apellido_paterno = p_apellido_paterno, 
            apellido_materno = p_apellido_materno, fecha_nacimiento = p_fecha_nacimiento
        WHERE dni = p_dni;
    END IF;

    -- Verificar si el empleado con el DNI proporcionado existe en la tabla Empleados
    SELECT COUNT(*) INTO v_empleado_count
    FROM Empleados
    WHERE dni = p_dni;

    -- Si el empleado no existe, insertar el nuevo empleado
    IF v_empleado_count = 0 THEN
        INSERT INTO Empleados (dni, estado, contraseña, es_administrador)
        VALUES (p_dni, p_estado, p_contraseña, p_es_administrador);
    ELSE
        -- Si ya existe el empleado, actualizar los datos del empleado
        UPDATE Empleados
        SET estado = p_estado, contraseña = p_contraseña, es_administrador = p_es_administrador
        WHERE dni = p_dni;
    END IF;

    -- Obtener el cod_empleado del empleado con el DNI proporcionado
    SELECT cod_empleado INTO v_cod_empleado
    FROM Empleados
    WHERE dni = p_dni;

    -- Actualizar la experiencia del asesor
    UPDATE Asesores
    SET experiencia = p_experiencia
    WHERE cod_asesor = p_cod_asesor;
END $$
DELIMITER ;