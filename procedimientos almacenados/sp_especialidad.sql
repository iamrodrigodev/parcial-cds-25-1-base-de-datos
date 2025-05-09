USE FabiaNatura;

-- POST Especialidades --
DELIMITER $$
CREATE PROCEDURE IF NOT EXISTS AgregarEspecialidad(
    IN p_nombre VARCHAR(50)
)
BEGIN
    -- Validar que el nombre no esté vacío ni sea NULL
    IF p_nombre IS NULL OR p_nombre = '' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El nombre de la especialidad no puede estar vacío';
    END IF;

    -- Validar que no exista ya la especialidad
    IF EXISTS (
        SELECT 1 FROM Especialidades 
        WHERE nombre = p_nombre
    ) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La especialidad ya existe';
    END IF;

    -- Insertar la nueva especialidad
    INSERT INTO Especialidades (nombre)
    VALUES (p_nombre);
END $$
DELIMITER ;

-- GET Especialidades --
DELIMITER $$
CREATE PROCEDURE IF NOT EXISTS ObtenerEspecialidades()
BEGIN
    -- Verificar si hay especialidades registradas
    DECLARE v_especialidades_count INT;
    
    SELECT COUNT(*) INTO v_especialidades_count
    FROM Especialidades;

    -- Si no hay especialidades, lanzar un error
    IF v_especialidades_count = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No se encontraron especialidades registradas';
    END IF;

    -- Obtener todas las especialidades
    SELECT id_especialidad, nombre
    FROM Especialidades
    ORDER BY nombre;
END $$
DELIMITER ;

-- GET Especialidad por ID --
DELIMITER $$
CREATE PROCEDURE IF NOT EXISTS ObtenerEspecialidadPorId(
    IN p_id_especialidad INT
)
BEGIN
    -- Validar que el ID no sea NULL o negativo
    IF p_id_especialidad IS NULL OR p_id_especialidad <= 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El ID de especialidad no es válido';
    END IF;

    -- Verificar si la especialidad existe
    IF NOT EXISTS (
        SELECT 1 FROM Especialidades 
        WHERE id_especialidad = p_id_especialidad
    ) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No se encontró la especialidad especificada';
    END IF;

    -- Obtener la especialidad
    SELECT id_especialidad, nombre
    FROM Especialidades
    WHERE id_especialidad = p_id_especialidad;
END $$
DELIMITER ;

-- PUT Especialidades --
DELIMITER $$
CREATE PROCEDURE IF NOT EXISTS ActualizarEspecialidad(
    IN p_id_especialidad INT,
    IN p_nombre_nuevo VARCHAR(50)
)
BEGIN
    -- Validar que el ID no sea NULL o negativo
    IF p_id_especialidad IS NULL OR p_id_especialidad <= 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El ID de especialidad no es válido';
    END IF;

    -- Validar que el nombre nuevo no esté vacío ni sea NULL
    IF p_nombre_nuevo IS NULL OR p_nombre_nuevo = '' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El nombre de la especialidad no puede estar vacío';
    END IF;

    -- Verificar si la especialidad existe
    IF NOT EXISTS (
        SELECT 1 FROM Especialidades 
        WHERE id_especialidad = p_id_especialidad
    ) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No se encontró la especialidad a actualizar';
    END IF;

    -- Verificar que el nuevo nombre no exista ya
    IF EXISTS (
        SELECT 1 FROM Especialidades 
        WHERE nombre = p_nombre_nuevo AND id_especialidad != p_id_especialidad
    ) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Ya existe otra especialidad con este nombre';
    END IF;

    -- Actualizar la especialidad
    UPDATE Especialidades
    SET nombre = p_nombre_nuevo
    WHERE id_especialidad = p_id_especialidad;
END $$
DELIMITER ;
