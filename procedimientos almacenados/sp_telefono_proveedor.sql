USE FabiaNatura;

-- POST Telefonos_Proveedores --
DELIMITER $$
CREATE PROCEDURE IF NOT EXISTS AgregarTelefonoProveedor(
    IN p_ruc CHAR(11),
    IN p_telefono CHAR(9)
)
BEGIN
    -- Validar que el RUC no esté vacío ni sea NULL
    IF p_ruc IS NULL OR p_ruc = '' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El RUC no puede estar vacío';
    END IF;

    -- Validar que el teléfono no esté vacío ni sea NULL
    IF p_telefono IS NULL OR p_telefono = '' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El número de teléfono no puede estar vacío';
    END IF;

    -- Validar que el RUC exista en la tabla Proveedores
    IF NOT EXISTS (SELECT 1 FROM Proveedores WHERE ruc = p_ruc) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El RUC proporcionado no existe en la base de datos';
    END IF;

    -- Validar que no exista ya el teléfono
    IF EXISTS (
        SELECT 1 FROM Telefonos_Proveedores 
        WHERE telefono = p_telefono
    ) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El teléfono ya existe';
    END IF;

    -- Insertar el nuevo teléfono
    INSERT INTO Telefonos_Proveedores (telefono, ruc)
    VALUES (p_telefono, p_ruc);
END $$
DELIMITER ;

-- GET Telefonos_Proveedores --
DELIMITER $$
CREATE PROCEDURE IF NOT EXISTS ObtenerTelefonosProveedor(
    IN p_ruc CHAR(11)
)
BEGIN
    -- Declarar variables
    DECLARE v_telefonos_count INT;

    -- Validar que el RUC no esté vacío ni sea NULL
    IF p_ruc IS NULL OR p_ruc = '' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El RUC no puede estar vacío';
    END IF;

    -- Validar que el RUC exista en la tabla Proveedores
    IF NOT EXISTS (SELECT 1 FROM Proveedores WHERE ruc = p_ruc) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El RUC proporcionado no existe en la base de datos';
    END IF;

    -- Verificar si el proveedor tiene teléfonos registrados
    SELECT COUNT(*) INTO v_telefonos_count
    FROM Telefonos_Proveedores
    WHERE ruc = p_ruc;

    -- Si no tiene teléfonos, lanzar un error
    IF v_telefonos_count = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No se encontraron teléfonos para este RUC';
    END IF;

    -- Obtener todos los teléfonos del proveedor
    SELECT telefono, ruc
    FROM Telefonos_Proveedores
    WHERE ruc = p_ruc;
END $$
DELIMITER ;

-- PUT Telefonos_Proveedores --
DELIMITER $$
CREATE PROCEDURE IF NOT EXISTS ActualizarTelefonoProveedor(
    IN p_ruc CHAR(11),
    IN p_telefono_antiguo CHAR(9),
    IN p_telefono_nuevo CHAR(9)
)
BEGIN
    -- Validar que el RUC no esté vacío ni sea NULL
    IF p_ruc IS NULL OR p_ruc = '' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El RUC no puede estar vacío';
    END IF;

    -- Validar que el teléfono antiguo no esté vacío ni sea NULL
    IF p_telefono_antiguo IS NULL OR p_telefono_antiguo = '' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El teléfono antiguo no puede estar vacío';
    END IF;

    -- Validar que el teléfono nuevo no esté vacío ni sea NULL
    IF p_telefono_nuevo IS NULL OR p_telefono_nuevo = '' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El número de teléfono nuevo no puede estar vacío';
    END IF;

    -- Validar que el RUC exista en la tabla Proveedores
    IF NOT EXISTS (SELECT 1 FROM Proveedores WHERE ruc = p_ruc) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El RUC proporcionado no existe en la base de datos';
    END IF;

    -- Verificar si existe el teléfono antiguo para este RUC
    IF NOT EXISTS (
        SELECT 1 FROM Telefonos_Proveedores 
        WHERE telefono = p_telefono_antiguo AND ruc = p_ruc
    ) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No se encontró el teléfono especificado para este RUC';
    END IF;

    -- Verificar que el nuevo teléfono no exista ya
    IF EXISTS (
        SELECT 1 FROM Telefonos_Proveedores 
        WHERE telefono = p_telefono_nuevo
    ) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El nuevo número de teléfono ya existe';
    END IF;

    -- Actualizar el teléfono
    UPDATE Telefonos_Proveedores
    SET telefono = p_telefono_nuevo
    WHERE telefono = p_telefono_antiguo AND ruc = p_ruc;
END $$
DELIMITER ;


