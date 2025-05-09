USE FabiaNatura;

-- POST Personas --
DELIMITER $$
CREATE PROCEDURE IF NOT EXISTS AgregarPersona(
    IN p_dni CHAR(8),
    IN p_nombre VARCHAR(20),
    IN p_apellido_paterno VARCHAR(20),
    IN p_apellido_materno VARCHAR(20),
    IN p_fecha_nacimiento DATE
)
BEGIN
    -- Validar que el DNI no esté vacío ni sea NULL
    IF p_dni IS NULL OR p_dni = '' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El DNI no puede estar vacío';
    END IF;

    -- Validar longitud del DNI
    IF LENGTH(p_dni) != 8 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El DNI debe tener 8 caracteres';
    END IF;

    -- Validar que el nombre no esté vacío ni sea NULL
    IF p_nombre IS NULL OR p_nombre = '' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El nombre no puede estar vacío';
    END IF;

    -- Validar que el apellido paterno no esté vacío ni sea NULL
    IF p_apellido_paterno IS NULL OR p_apellido_paterno = '' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El apellido paterno no puede estar vacío';
    END IF;

    -- Validar que el apellido materno no esté vacío ni sea NULL
    IF p_apellido_materno IS NULL OR p_apellido_materno = '' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El apellido materno no puede estar vacío';
    END IF;

    -- Validar fecha de nacimiento
    IF p_fecha_nacimiento IS NULL OR p_fecha_nacimiento > CURDATE() THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Fecha de nacimiento inválida';
    END IF;

    -- Validar que el DNI no exista ya
    IF EXISTS (SELECT 1 FROM Personas WHERE dni = p_dni) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Ya existe una persona con este DNI';
    END IF;

    -- Insertar la nueva persona
    INSERT INTO Personas (dni, nombre, apellido_paterno, apellido_materno, fecha_nacimiento)
    VALUES (p_dni, p_nombre, p_apellido_paterno, p_apellido_materno, p_fecha_nacimiento);
END $$
DELIMITER ;

-- GET Personas --
DELIMITER $$
CREATE PROCEDURE IF NOT EXISTS ObtenerPersonas()
BEGIN
    -- Obtener todas las personas
    SELECT dni, nombre, apellido_paterno, apellido_materno, fecha_nacimiento, fecha_registro
    FROM Personas
    ORDER BY apellido_paterno, apellido_materno, nombre;
END $$
DELIMITER ;

-- GET Persona por DNI --
DELIMITER $$
CREATE PROCEDURE IF NOT EXISTS ObtenerPersonaPorDNI(
    IN p_dni CHAR(8)
)
BEGIN
    -- Validar que el DNI no esté vacío ni sea NULL
    IF p_dni IS NULL OR p_dni = '' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El DNI no puede estar vacío';
    END IF;

    -- Validar longitud del DNI
    IF LENGTH(p_dni) != 8 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El DNI debe tener 8 caracteres';
    END IF;

    -- Verificar si la persona existe
    IF NOT EXISTS (SELECT 1 FROM Personas WHERE dni = p_dni) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No se encontró una persona con este DNI';
    END IF;

    -- Obtener la persona
    SELECT dni, nombre, apellido_paterno, apellido_materno, fecha_nacimiento, fecha_registro
    FROM Personas
    WHERE dni = p_dni;
END $$
DELIMITER ;

-- PUT Personas --
DELIMITER $$
CREATE PROCEDURE IF NOT EXISTS ActualizarPersona(
    IN p_dni CHAR(8),
    IN p_nombre VARCHAR(20),
    IN p_apellido_paterno VARCHAR(20),
    IN p_apellido_materno VARCHAR(20),
    IN p_fecha_nacimiento DATE
)
BEGIN
    -- Validar que el DNI no esté vacío ni sea NULL
    IF p_dni IS NULL OR p_dni = '' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El DNI no puede estar vacío';
    END IF;

    -- Validar longitud del DNI
    IF LENGTH(p_dni) != 8 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El DNI debe tener 8 caracteres';
    END IF;

    -- Validar que el nombre no esté vacío ni sea NULL
    IF p_nombre IS NULL OR p_nombre = '' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El nombre no puede estar vacío';
    END IF;

    -- Validar que el apellido paterno no esté vacío ni sea NULL
    IF p_apellido_paterno IS NULL OR p_apellido_paterno = '' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El apellido paterno no puede estar vacío';
    END IF;

    -- Validar que el apellido materno no esté vacío ni sea NULL
    IF p_apellido_materno IS NULL OR p_apellido_materno = '' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El apellido materno no puede estar vacío';
    END IF;

    -- Validar fecha de nacimiento
    IF p_fecha_nacimiento IS NULL OR p_fecha_nacimiento > CURDATE() THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Fecha de nacimiento inválida';
    END IF;

    -- Verificar si la persona existe
    IF NOT EXISTS (SELECT 1 FROM Personas WHERE dni = p_dni) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No se encontró una persona con este DNI';
    END IF;

    -- Actualizar la persona
    UPDATE Personas
    SET 
        nombre = p_nombre, 
        apellido_paterno = p_apellido_paterno, 
        apellido_materno = p_apellido_materno, 
        fecha_nacimiento = p_fecha_nacimiento
    WHERE dni = p_dni;
END $$
DELIMITER ;

-- DELETE Personas --
DELIMITER $$
CREATE PROCEDURE IF NOT EXISTS EliminarPersona(
    IN p_dni CHAR(8)
)
BEGIN
    -- Validar que el DNI no esté vacío ni sea NULL
    IF p_dni IS NULL OR p_dni = '' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El DNI no puede estar vacío';
    END IF;

    -- Validar longitud del DNI
    IF LENGTH(p_dni) != 8 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El DNI debe tener 8 caracteres';
    END IF;

    -- Verificar si la persona existe
    IF NOT EXISTS (SELECT 1 FROM Personas WHERE dni = p_dni) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No se encontró una persona con este DNI';
    END IF;

    -- Verificar que no tenga direcciones asociadas
    IF EXISTS (SELECT 1 FROM Direcciones_Personas WHERE dni = p_dni) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No se puede eliminar la persona. Primero elimine sus direcciones';
    END IF;

    -- Verificar que no tenga teléfonos asociados
    IF EXISTS (SELECT 1 FROM Telefonos_Personas WHERE dni = p_dni) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No se puede eliminar la persona. Primero elimine sus teléfonos';
    END IF;

    -- Eliminar la persona
    DELETE FROM Personas WHERE dni = p_dni;
END $$
DELIMITER ;
