USE FabiaNatura;

-- POST Telefonos_Personas --
DELIMITER $$
CREATE PROCEDURE IF NOT EXISTS AgregarTelefonoPersona(
    IN p_dni CHAR(8),
    IN p_telefono CHAR(9)
)
BEGIN
    -- Validar que el DNI no esté vacío ni sea NULL
    IF p_dni IS NULL OR p_dni = '' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El DNI no puede estar vacío';
    END IF;

    -- Validar que el teléfono no esté vacío ni sea NULL
    IF p_telefono IS NULL OR p_telefono = '' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El número de teléfono no puede estar vacío';
    END IF;

    -- Validar que el DNI exista en la tabla Personas
    IF NOT EXISTS (SELECT 1 FROM Personas WHERE dni = p_dni) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El DNI proporcionado no existe en la base de datos';
    END IF;

    -- Validar que no exista ya el teléfono
    IF EXISTS (
        SELECT 1 FROM Telefonos_Personas 
        WHERE telefono = p_telefono
    ) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El teléfono ya existe';
    END IF;

    -- Insertar el nuevo teléfono
    INSERT INTO Telefonos_Personas (telefono, dni)
    VALUES (p_telefono, p_dni);
END $$
DELIMITER ;

-- GET Telefonos_Personas --
DELIMITER $$
CREATE PROCEDURE IF NOT EXISTS ObtenerTelefonosPersona(
    IN p_dni CHAR(8)
)
BEGIN
    -- Declarar variables
    DECLARE v_telefonos_count INT;

    -- Validar que el DNI no esté vacío ni sea NULL
    IF p_dni IS NULL OR p_dni = '' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El DNI no puede estar vacío';
    END IF;

    -- Validar que el DNI exista en la tabla Personas
    IF NOT EXISTS (SELECT 1 FROM Personas WHERE dni = p_dni) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El DNI proporcionado no existe en la base de datos';
    END IF;

    -- Verificar si la persona tiene teléfonos registrados
    SELECT COUNT(*) INTO v_telefonos_count
    FROM Telefonos_Personas
    WHERE dni = p_dni;

    -- Si no tiene teléfonos, lanzar un error
    IF v_telefonos_count = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No se encontraron teléfonos para este DNI';
    END IF;

    -- Obtener todos los teléfonos de la persona
    SELECT telefono, dni
    FROM Telefonos_Personas
    WHERE dni = p_dni;
END $$
DELIMITER ;

-- PUT Telefonos_Personas --
DELIMITER $$
CREATE PROCEDURE IF NOT EXISTS ActualizarTelefonoPersona(
    IN p_dni CHAR(8),
    IN p_telefono_antiguo CHAR(9),
    IN p_telefono_nuevo CHAR(9)
)
BEGIN
    -- Validar que el DNI no esté vacío ni sea NULL
    IF p_dni IS NULL OR p_dni = '' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El DNI no puede estar vacío';
    END IF;

    -- Validar que el teléfono antiguo no esté vacío ni sea NULL
    IF p_telefono_antiguo IS NULL OR p_telefono_antiguo = '' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El teléfono antiguo no puede estar vacío';
    END IF;

    -- Validar que el teléfono nuevo no esté vacío ni sea NULL
    IF p_telefono_nuevo IS NULL OR p_telefono_nuevo = '' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El número de teléfono nuevo no puede estar vacío';
    END IF;

    -- Validar que el DNI exista en la tabla Personas
    IF NOT EXISTS (SELECT 1 FROM Personas WHERE dni = p_dni) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El DNI proporcionado no existe en la base de datos';
    END IF;

    -- Verificar si existe el teléfono antiguo para este DNI
    IF NOT EXISTS (
        SELECT 1 FROM Telefonos_Personas 
        WHERE telefono = p_telefono_antiguo AND dni = p_dni
    ) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No se encontró el teléfono especificado para este DNI';
    END IF;

    -- Verificar que el nuevo teléfono no exista ya
    IF EXISTS (
        SELECT 1 FROM Telefonos_Personas 
        WHERE telefono = p_telefono_nuevo
    ) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El nuevo número de teléfono ya existe';
    END IF;

    -- Actualizar el teléfono
    UPDATE Telefonos_Personas
    SET telefono = p_telefono_nuevo
    WHERE telefono = p_telefono_antiguo AND dni = p_dni;
END $$
DELIMITER ;
