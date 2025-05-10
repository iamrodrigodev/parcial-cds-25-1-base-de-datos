USE FabiaNatura;

-- POST Especialidades --
DELIMITER $$
CREATE PROCEDURE IF NOT EXISTS AgregarEspecialidad(
    IN p_nombre_especialidad VARCHAR(100),
    IN p_descripcion TEXT
)
BEGIN
    DECLARE v_existente INT;

    -- Validar que el nombre de la especialidad no sea nulo ni vacío
    IF p_nombre_especialidad IS NULL OR TRIM(p_nombre_especialidad) = '' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El nombre de la especialidad no puede estar vacío';
    END IF;

    -- Verificar si ya existe una especialidad con el mismo nombre
    SELECT COUNT(*) INTO v_existente
    FROM Especialidades
    WHERE nombre_especialidad = p_nombre_especialidad;

    IF v_existente > 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Ya existe una especialidad con ese nombre';
    END IF;

    -- Insertar la nueva especialidad
    INSERT INTO Especialidades (nombre_especialidad, descripcion)
    VALUES (p_nombre_especialidad, p_descripcion);
END $$
DELIMITER ;

-- GET Especialidades --
DELIMITER $$
CREATE PROCEDURE IF NOT EXISTS ObtenerTodasLasEspecialidades()
BEGIN
    DECLARE v_especialidad_count INT;

    -- Verificar si existen especialidades en la base de datos
    SELECT COUNT(*) INTO v_especialidad_count
    FROM Especialidades;

    -- Si no hay especialidades, lanzar un error
    IF v_especialidad_count = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No hay especialidades registradas';
    END IF;

    -- Obtener todas las especialidades
    SELECT cod_especialidad, nombre_especialidad, descripcion, fecha_registro
    FROM Especialidades;
END $$
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE IF NOT EXISTS ObtenerEspecialidadPorCod(
    IN p_cod_especialidad INT
)
BEGIN
    DECLARE v_especialidad_count INT;

    -- Verificar si la especialidad con el código proporcionado existe
    SELECT COUNT(*) INTO v_especialidad_count
    FROM Especialidades
    WHERE cod_especialidad = p_cod_especialidad;

    -- Si no existe la especialidad, lanzar un error
    IF v_especialidad_count = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No se encontró una especialidad con ese código';
    END IF;

    -- Obtener los detalles de la especialidad
    SELECT cod_especialidad, nombre_especialidad, descripcion, fecha_registro
    FROM Especialidades
    WHERE cod_especialidad = p_cod_especialidad; 
END $$
DELIMITER ;

-- PUT Especialidades --
DELIMITER $$
CREATE PROCEDURE IF NOT EXISTS ActualizarEspecialidad(
    IN p_cod_especialidad INT,
    IN p_nuevo_nombre VARCHAR(100),
    IN p_nueva_descripcion TEXT
)
BEGIN
    DECLARE v_especialidad_count INT;

    -- Verificar si la especialidad con el código proporcionado existe
    SELECT COUNT(*) INTO v_especialidad_count
    FROM Especialidades
    WHERE cod_especialidad = p_cod_especialidad;

    -- Si no existe la especialidad, lanzar un error
    IF v_especialidad_count = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No se encontró la especialidad con ese código';
    END IF;

    -- Validar que el nuevo nombre no sea nulo ni vacío
    IF p_nuevo_nombre IS NULL OR TRIM(p_nuevo_nombre) = '' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El nombre de la especialidad no puede estar vacío';
    END IF;

    -- Actualizar la especialidad con los nuevos valores
    UPDATE Especialidades
    SET nombre_especialidad = p_nuevo_nombre, descripcion = p_nueva_descripcion
    WHERE cod_especialidad = p_cod_especialidad;
    
END $$
DELIMITER ;