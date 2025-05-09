USE FabiaNatura;
-- Stored Procedures for Roles Management

DELIMITER $$

-- Insertar un nuevo rol
CREATE PROCEDURE IF NOT EXISTS sp_insertar_rol(
    IN p_nombre_rol VARCHAR(50),
    IN p_descripcion TEXT
)
BEGIN
    -- Validate input parameters
    IF p_nombre_rol IS NULL OR p_nombre_rol = '' THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'Error: El nombre del rol no puede ser nulo o vacío';
    END IF;

    -- Use empty string if description is NULL
    IF p_descripcion IS NULL THEN
        SET p_descripcion = '';
    END IF;

    -- Check if role already exists (case-sensitive)
    IF EXISTS (SELECT 1 FROM Roles WHERE nombre_rol = p_nombre_rol) THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'Error: Ya existe un rol con este nombre';
    END IF;

    -- Insert new role
    INSERT INTO Roles (nombre_rol, descripcion)
    VALUES (p_nombre_rol, p_descripcion);
    
    SELECT LAST_INSERT_ID() AS cod_rol;
END $$

-- Listar todos los roles
CREATE PROCEDURE IF NOT EXISTS sp_listar_roles()
BEGIN
    DECLARE v_total_roles INT;

    -- Count total number of roles
    SELECT COUNT(*) INTO v_total_roles FROM Roles;

    -- Check if no roles exist
    IF v_total_roles = 0 THEN
        SIGNAL SQLSTATE '02000'
        SET MESSAGE_TEXT = 'Información: No hay roles registrados en el sistema';
    END IF;

    -- List all roles
    SELECT 
        *, 
        v_total_roles AS total_roles 
    FROM Roles 
    ORDER BY nombre_rol;
END $$

-- Obtener un rol por su ID específico
CREATE PROCEDURE IF NOT EXISTS sp_obtener_rol_por_id(
    IN p_cod_rol INT
)
BEGIN
    -- Validate input parameter
    IF p_cod_rol IS NULL OR p_cod_rol <= 0 THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'Código de rol inválido';
    END IF;

    -- Check if role exists
    IF NOT EXISTS (SELECT 1 FROM Roles WHERE cod_rol = p_cod_rol) THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'El rol especificado no existe';
    END IF;

    -- Retrieve role details
    SELECT * FROM Roles 
    WHERE cod_rol = p_cod_rol;
END $$

-- Mostrar todos los vendedores de un rol específico
CREATE PROCEDURE IF NOT EXISTS sp_listar_vendedores_por_rol(
    IN p_cod_rol INT
)
BEGIN
    DECLARE v_nombre_rol VARCHAR(50);

    -- Validate input parameter
    IF p_cod_rol IS NULL OR p_cod_rol <= 0 THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'Error: Código de rol inválido';
    END IF;

    -- Check if role exists and get role name
    SELECT nombre_rol INTO v_nombre_rol 
    FROM Roles 
    WHERE cod_rol = p_cod_rol;

    -- Check if role exists (will raise an error if not found)
    IF v_nombre_rol IS NULL THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'Error: El rol especificado no existe';
    END IF;

    -- Check if any vendors exist for this role
    IF NOT EXISTS (SELECT 1 FROM Vendedores WHERE rol = v_nombre_rol) THEN
        SIGNAL SQLSTATE '02000' 
        SET MESSAGE_TEXT = 'Información: No hay vendedores asignados a este rol';
    END IF;

    SELECT 
        v.cod_vendedor,
        p.dni,
        p.nombre,
        p.apellido_paterno,
        p.apellido_materno,
        v.rol
    FROM 
        Vendedores v
    JOIN 
        Empleados e ON v.cod_empleado = e.cod_empleado
    JOIN 
        Personas p ON e.dni = p.dni
    WHERE 
        v.rol = v_nombre_rol;
END $$

-- Actualizar un rol existente
CREATE PROCEDURE IF NOT EXISTS sp_actualizar_rol(
    IN p_cod_rol INT,
    IN p_nombre_rol VARCHAR(50),
    IN p_descripcion TEXT
)
BEGIN
    -- Validate input parameters
    IF p_cod_rol IS NULL OR p_cod_rol <= 0 THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'Error: Código de rol inválido';
    END IF;

    IF p_nombre_rol IS NULL OR p_nombre_rol = '' THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'Error: El nombre del rol no puede ser nulo o vacío';
    END IF;

    -- Use empty string if description is NULL
    IF p_descripcion IS NULL THEN
        SET p_descripcion = '';
    END IF;

    -- Check if role exists
    IF NOT EXISTS (SELECT 1 FROM Roles WHERE cod_rol = p_cod_rol) THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'Error: El rol especificado no existe';
    END IF;

    -- Check if new role name conflicts (case-sensitive)
    IF EXISTS (SELECT 1 FROM Roles 
               WHERE nombre_rol = p_nombre_rol AND cod_rol != p_cod_rol) THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'Error: Ya existe otro rol con este nombre';
    END IF;

    UPDATE Roles 
    SET nombre_rol = p_nombre_rol, 
        descripcion = p_descripcion
    WHERE cod_rol = p_cod_rol;
    
    SELECT ROW_COUNT() AS filas_actualizadas;
END $$

DELIMITER ;
