USE FabiaNatura;

-- POST Roles --
DELIMITER $$
CREATE PROCEDURE IF NOT EXISTS AgregarRol(
    IN p_nombre_rol VARCHAR(50),
    IN p_descripcion TEXT
)
BEGIN
    -- Verificar si el nombre del rol está vacío
    IF p_nombre_rol = '' THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'El nombre del rol no puede ser nulo o vacío';
    END IF;

    -- Verificar si ya existe un rol con el mismo nombre
    IF EXISTS (SELECT 1 FROM Roles WHERE nombre_rol = p_nombre_rol) THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'Error: Ya existe un rol con este nombre';
    END IF;

    -- Insertar el nuevo rol en la tabla Roles
    INSERT INTO Roles (nombre_rol, descripcion)
    VALUES (p_nombre_rol, p_descripcion);
END $$
DELIMITER ;

-- GET Roles --
DELIMITER $$
CREATE PROCEDURE IF NOT EXISTS ObtenerTodosRoles()
BEGIN
    -- Verificar si existen roles en la tabla Roles
    DECLARE v_roles_count INT;

    -- Contar el número de roles en la tabla
    SELECT COUNT(*) INTO v_roles_count
    FROM Roles;

    -- Si no existen roles, lanzar un error
    IF v_roles_count = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No existen roles en la base de datos';
    END IF;

    -- Si existen roles, obtener todos los roles
    SELECT cod_rol, nombre_rol, descripcion, fecha_registro
    FROM Roles;   
END $$
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE IF NOT EXISTS ObtenerRolPorId(
    IN p_cod_rol INT
)
BEGIN
    -- Verificar si el rol con el ID proporcionado existe
    DECLARE v_rol_count INT;

    SELECT COUNT(*) INTO v_rol_count
    FROM Roles
    WHERE cod_rol = p_cod_rol;

    -- Si no existe el rol, lanzar un error
    IF v_rol_count = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No se encontró un rol con ese ID';
    END IF;

    -- Si existe el rol, obtener la información del rol
    SELECT cod_rol, nombre_rol, descripcion, fecha_registro
    FROM Roles
    WHERE cod_rol = p_cod_rol; 
END $$
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE IF NOT EXISTS ObtenerEmpleadosPorRol(
    IN p_cod_rol INT
)
BEGIN
    -- Verificar si existen empleados con el rol proporcionado
    DECLARE v_empleados_count INT;

    SELECT COUNT(*) INTO v_empleados_count
    FROM Vendedores v
    JOIN Empleados e ON v.cod_empleado = e.cod_empleado
    WHERE v.cod_rol = p_cod_rol;

    -- Si no hay empleados asociados al rol, lanzar un error
    IF v_empleados_count = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No existen empleados con este rol';
    END IF;

    -- Si existen empleados, obtener la lista de empleados asociados con el rol
    SELECT e.cod_empleado, e.dni, e.estado, e.es_administrador
    FROM Empleados e
    JOIN Vendedores v ON e.cod_empleado = v.cod_empleado
    WHERE v.cod_rol = p_cod_rol;
END $$
DELIMITER ;

-- PUT Roles --
DELIMITER $$
CREATE PROCEDURE IF NOT EXISTS ActualizarRol(
    IN p_cod_rol INT,                -- ID del rol que se desea actualizar
    IN p_nuevo_nombre_rol VARCHAR(50),  -- Nuevo nombre para el rol
    IN p_nueva_descripcion TEXT       -- Nueva descripción del rol
)
BEGIN
    -- Declarar las variables al principio
    DECLARE v_rol_count INT;

    -- Validar que el nuevo nombre del rol no esté vacío
    IF p_nuevo_nombre_rol IS NULL OR p_nuevo_nombre_rol = '' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error: El nombre del rol no puede estar vacío';
    END IF;

    -- Verificar si el rol con el cod_rol existe
    SELECT COUNT(*) INTO v_rol_count
    FROM Roles
    WHERE cod_rol = p_cod_rol;

    -- Si no existe el rol, lanzar un error
    IF v_rol_count = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error: No se encontró el rol con ese ID';
    END IF;

    -- Actualizar el nombre y descripción del rol
    UPDATE Roles
    SET nombre_rol = p_nuevo_nombre_rol,
        descripcion = p_nueva_descripcion
    WHERE cod_rol = p_cod_rol;
END $$
DELIMITER ;