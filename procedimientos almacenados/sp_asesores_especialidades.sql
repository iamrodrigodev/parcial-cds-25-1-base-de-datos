USE FabiaNatura;

-- POST Asesores_Especialidades --
DELIMITER $$
CREATE PROCEDURE AgregarEspecialidadAAsesor(
    IN p_cod_asesor INT,         -- Código del asesor
    IN p_cod_especialidad INT    -- Código de la especialidad
)
BEGIN
    DECLARE v_asesor_count INT;
    DECLARE v_especialidad_count INT;
    DECLARE v_relacion_count INT;

    -- Verificar si el asesor con el código proporcionado existe
    SELECT COUNT(*) INTO v_asesor_count
    FROM Asesores
    WHERE cod_asesor = p_cod_asesor;

    -- Si no existe el asesor, lanzar un error
    IF v_asesor_count = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No se encontró un asesor con ese código';
    END IF;

    -- Verificar si la especialidad con el código proporcionado existe
    SELECT COUNT(*) INTO v_especialidad_count
    FROM Especialidades
    WHERE cod_especialidad = p_cod_especialidad;

    -- Si no existe la especialidad, lanzar un error
    IF v_especialidad_count = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No se encontró una especialidad con ese código';
    END IF;

    -- Verificar si la relación asesor-especialidad ya existe
    SELECT COUNT(*) INTO v_relacion_count
    FROM Asesores_Especialidades
    WHERE cod_asesor = p_cod_asesor
    AND cod_especialidad = p_cod_especialidad;

    -- Si ya existe la relación, lanzar un error
    IF v_relacion_count > 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El asesor ya tiene esta especialidad asignada';
    END IF;

    -- Insertar la especialidad al asesor
    INSERT INTO Asesores_Especialidades (cod_asesor, cod_especialidad)
    VALUES (p_cod_asesor, p_cod_especialidad);
END $$
DELIMITER ;

-- GET Asesores_Especialidades --
DELIMITER $$
CREATE PROCEDURE ObtenerEspecialidadesDeAsesor(
    IN p_cod_asesor INT  -- Código del asesor
)
BEGIN
    DECLARE v_asesor_count INT;

    -- Verificar si el asesor con el código proporcionado existe
    SELECT COUNT(*) INTO v_asesor_count
    FROM Asesores
    WHERE cod_asesor = p_cod_asesor;

    -- Si no existe el asesor, lanzar un error
    IF v_asesor_count = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No se encontró un asesor con ese código';
    END IF;

    -- Obtener todas las especialidades del asesor
    SELECT 
        e.cod_especialidad,
        e.nombre_especialidad,
        e.descripcion
    FROM Asesores_Especialidades ae
    JOIN Especialidades e ON ae.cod_especialidad = e.cod_especialidad
    WHERE ae.cod_asesor = p_cod_asesor;
END $$
DELIMITER ;