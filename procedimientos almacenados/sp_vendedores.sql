USE FabiaNatura;

-- POST Vendedores --
DELIMITER $$
CREATE PROCEDURE IF NOT EXISTS AgregarVendedor(
    IN p_dni CHAR(8),       
    IN p_nombre VARCHAR(50),    
    IN p_apellido_paterno VARCHAR(50), 
    IN p_apellido_materno VARCHAR(50), 
    IN p_fecha_nacimiento DATE,   
    IN p_estado ENUM('activo', 'inactivo'), 
    IN p_contraseña VARCHAR(30),
    IN p_es_administrador BOOLEAN, 
    IN p_cod_rol INT     
)
BEGIN
    DECLARE v_persona_count INT;
    DECLARE v_empleado_count INT;
    DECLARE v_vendedor_count INT;
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

    -- Obtener el cod_empleado del empleado con el DNI proporcionado
    SELECT cod_empleado INTO v_cod_empleado
    FROM Empleados
    WHERE dni = p_dni;

    -- Verificar si el empleado ya está asignado como vendedor
    SELECT COUNT(*) INTO v_vendedor_count
    FROM Vendedores
    WHERE cod_empleado = v_cod_empleado;

    -- Si el empleado ya es vendedor, lanzar un error
    IF v_vendedor_count > 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El empleado ya está asignado como vendedor';
    END IF;

    -- Insertar el nuevo vendedor
    INSERT INTO Vendedores (cod_empleado, cod_rol)
    VALUES (v_cod_empleado, p_cod_rol);
END $$
DELIMITER ;

-- GET Vendedores --
DELIMITER $$
CREATE PROCEDURE IF NOT EXISTS ObtenerTodosLosVendedores()
BEGIN
    DECLARE v_vendedor_count INT;

    -- Verificar si existen vendedores en la base de datos
    SELECT COUNT(*) INTO v_vendedor_count
    FROM Vendedores;

    -- Si no hay vendedores, lanzar un error
    IF v_vendedor_count = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No hay vendedores registrados';
    END IF;

    -- Obtener todos los vendedores con sus datos de empleado y persona
    SELECT 
        v.cod_vendedor,
        CONCAT(p.nombre, ' ', p.apellido_paterno, ' ', p.apellido_materno) AS nombre_completo,
        p.dni,
        e.estado,
        e.es_administrador
    FROM Vendedores v
    JOIN Empleados e ON v.cod_empleado = e.cod_empleado
    JOIN Personas p ON e.dni = p.dni
    ORDER BY p.apellido_paterno, p.apellido_materno, p.nombre;
END $$
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE IF NOT EXISTS ObtenerVendedorPorCodigo(
    IN p_cod_vendedor INT
)
BEGIN
    DECLARE v_vendedor_count INT;

    -- Verificar si el vendedor con el código proporcionado existe
    SELECT COUNT(*) INTO v_vendedor_count
    FROM Vendedores
    WHERE cod_vendedor = p_cod_vendedor;

    -- Si no existe el vendedor, lanzar un error
    IF v_vendedor_count = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No se encontró un vendedor con ese código';
    END IF;

    -- Obtener los datos del vendedor con su información de empleado y persona
    SELECT 
        v.cod_vendedor,
        CONCAT(p.nombre, ' ', p.apellido_paterno, ' ', p.apellido_materno) AS nombre_completo,
        p.dni,
        e.estado,
        e.es_administrador
    FROM Vendedores v
    JOIN Empleados e ON v.cod_empleado = e.cod_empleado
    JOIN Personas p ON e.dni = p.dni
    WHERE v.cod_vendedor = p_cod_vendedor;
END $$
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE IF NOT EXISTS ActualizarVendedor(
    IN p_cod_vendedor INT,               
    IN p_dni CHAR(8),              
    IN p_nombre VARCHAR(50),        
    IN p_apellido_paterno VARCHAR(50),  
    IN p_apellido_materno VARCHAR(50),
    IN p_fecha_nacimiento DATE,    
    IN p_estado ENUM('activo', 'inactivo'),  
    IN p_contraseña VARCHAR(30),       
    IN p_es_administrador BOOLEAN,       
    IN p_cod_rol INT               
)
BEGIN
    DECLARE v_vendedor_count INT;
    DECLARE v_empleado_count INT;
    DECLARE v_persona_count INT;
    DECLARE v_cod_empleado INT;

    -- Verificar si el vendedor con el código proporcionado existe
    SELECT COUNT(*) INTO v_vendedor_count
    FROM Vendedores
    WHERE cod_vendedor = p_cod_vendedor;

    -- Si no existe el vendedor, lanzar un error
    IF v_vendedor_count = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No se encontró un vendedor con ese código';
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

    -- Si no existe el empleado, insertarlo en la tabla Empleados
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

    -- Actualizar los datos del vendedor (rol)
    UPDATE Vendedores
    SET cod_rol = p_cod_rol
    WHERE cod_vendedor = p_cod_vendedor;
END $$
DELIMITER ;