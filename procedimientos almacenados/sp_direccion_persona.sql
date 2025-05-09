USE FabiaNatura;

-- POST Direcciones_Personas --
DELIMITER $$
CREATE PROCEDURE IF NOT EXISTS AgregarDireccionPersona(
    IN p_dni CHAR(8),
    IN p_direccion VARCHAR(100)
)
BEGIN
    -- Validar que el DNI no esté vacío ni sea NULL
    IF p_dni IS NULL OR p_dni = '' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El DNI no puede estar vacío';
    END IF;

    -- Validar que la dirección no esté vacía ni sea NULL
    IF p_direccion IS NULL OR p_direccion = '' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La dirección no puede estar vacía';
    END IF;

    -- Verificar si el DNI existe en la tabla Personas
    IF NOT EXISTS (SELECT 1 FROM Personas WHERE dni = p_dni) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El DNI proporcionado no existe en la base de datos';
    END IF;

    -- Verificar que no exista ya la dirección para este DNI
    IF EXISTS (
        SELECT 1 FROM Direcciones_Personas 
        WHERE dni = p_dni AND direccion = p_direccion
    ) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Ya existe esta dirección para esta persona';
    END IF;

    -- Insertar la nueva dirección
    INSERT INTO Direcciones_Personas (dni, direccion)
    VALUES (p_dni, p_direccion);
END $$
DELIMITER ;

-- GET Direcciones por Persona --
DELIMITER $$
CREATE PROCEDURE IF NOT EXISTS ObtenerDireccionesPersona(
    IN p_dni CHAR(8)
)
BEGIN
    -- Declarar variables
    DECLARE v_direcciones_count INT;

    -- Validar que el DNI no esté vacío ni sea NULL
    IF p_dni IS NULL OR p_dni = '' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El DNI no puede estar vacío';
    END IF;

    -- Verificar si el DNI existe en la tabla Personas
    IF NOT EXISTS (SELECT 1 FROM Personas WHERE dni = p_dni) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El DNI proporcionado no existe en la base de datos';
    END IF;

    -- Contar direcciones para este DNI
    SELECT COUNT(*) INTO v_direcciones_count
    FROM Direcciones_Personas
    WHERE dni = p_dni;

    -- Si no hay direcciones, lanzar un error
    IF v_direcciones_count = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No se encontraron direcciones para este DNI';
    END IF;

    -- Obtener todas las direcciones de la persona
    SELECT dni, direccion, tipo_direccion
    FROM Direcciones_Personas
    WHERE dni = p_dni;
END $$
DELIMITER ;

-- PUT Direcciones Personas --
DELIMITER $$
CREATE PROCEDURE IF NOT EXISTS ActualizarDireccionPersona(
    IN p_dni CHAR(8),
    IN p_direccion_antigua VARCHAR(100),
    IN p_nueva_direccion VARCHAR(100)
)
BEGIN
    -- Declarar variables
    DECLARE v_direccion_existe INT;

    -- Validar que el DNI no esté vacío ni sea NULL
    IF p_dni IS NULL OR p_dni = '' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El DNI no puede estar vacío';
    END IF;

    -- Validar que la dirección antigua no esté vacía ni sea NULL
    IF p_direccion_antigua IS NULL OR p_direccion_antigua = '' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La dirección antigua no puede estar vacía';
    END IF;

    -- Validar que la nueva dirección no esté vacía ni sea NULL
    IF p_nueva_direccion IS NULL OR p_nueva_direccion = '' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La nueva dirección no puede estar vacía';
    END IF;

    -- Verificar si el DNI existe en la tabla Personas
    IF NOT EXISTS (SELECT 1 FROM Personas WHERE dni = p_dni) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El DNI proporcionado no existe en la base de datos';
    END IF;

    -- Verificar si la dirección existe para este DNI
    SELECT COUNT(*) INTO v_direccion_existe
    FROM Direcciones_Personas
    WHERE dni = p_dni AND direccion = p_direccion_antigua;

    -- Si no existe la dirección, lanzar un error
    IF v_direccion_existe = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No se encontró la dirección para la persona';
    END IF;

    -- Verificar que la nueva dirección no sea igual a la antigua
    IF p_direccion_antigua = p_nueva_direccion THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La nueva dirección debe ser diferente a la dirección actual';
    END IF;

    -- Verificar que la nueva dirección no exista ya para este DNI
    IF EXISTS (
        SELECT 1 FROM Direcciones_Personas
        WHERE dni = p_dni AND direccion = p_nueva_direccion
    ) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La nueva dirección ya existe para esta persona';
    END IF;

    -- Actualizar la dirección
    UPDATE Direcciones_Personas
    SET direccion = p_nueva_direccion
    WHERE dni = p_dni AND direccion = p_direccion_antigua;
END $$
DELIMITER ;
