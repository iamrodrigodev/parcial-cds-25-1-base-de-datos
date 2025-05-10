USE FabiaNatura;

DELIMITER $$
CREATE PROCEDURE IF NOT EXISTS VerificarPersonaPorDni(
    IN p_dni CHAR(8)
)
BEGIN
    DECLARE v_persona_count INT;

    SELECT COUNT(*) INTO v_persona_count
    FROM Personas
    WHERE dni = p_dni;

    IF v_persona_count > 0 THEN
        SELECT 1 AS existe;
    ELSE
        SELECT 0 AS existe;
    END IF;
END $$
DELIMITER ;

-- POST Clientes --
DELIMITER $$
CREATE PROCEDURE IF NOT EXISTS AgregarCliente(
    IN p_dni CHAR(8),
    IN p_nombre VARCHAR(50),
    IN p_apellido_paterno VARCHAR(50),
    IN p_apellido_materno VARCHAR(50),
    IN p_fecha_nacimiento DATE
)
BEGIN
    DECLARE v_persona_count INT;
    DECLARE v_cliente_count INT;

    -- Verificar si la persona ya existe en la tabla Personas
    SELECT COUNT(*) INTO v_persona_count
    FROM Personas
    WHERE dni = p_dni;

    -- Insertar la persona en la tabla Personas
    INSERT INTO Personas (dni, nombre, apellido_paterno, apellido_materno, fecha_nacimiento)
    VALUES (p_dni, p_nombre, p_apellido_paterno, p_apellido_materno, p_fecha_nacimiento);

    -- Ahora agregar la persona como cliente
    INSERT INTO Clientes (dni, tipo_cliente)
    VALUES (p_dni, 'regular');  -- Asignar un tipo de cliente por defecto (regular)
END $$
DELIMITER ;

-- GET Clientes --
DELIMITER $$
CREATE PROCEDURE IF NOT EXISTS ObtenerTodosLosClientes()
BEGIN
    DECLARE v_cliente_count INT;

    -- Verificar si existen clientes en la base de datos
    SELECT COUNT(*) INTO v_cliente_count
    FROM Clientes;

    -- Si no existen clientes, lanzar un error
    IF v_cliente_count = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No hay clientes registrados en la base de datos';
    END IF;

    -- Obtener todos los clientes con los detalles de la persona
    SELECT 
        c.dni, 
        c.tipo_cliente, 
        p.nombre, 
        p.apellido_paterno, 
        p.apellido_materno, 
        p.fecha_nacimiento
    FROM Clientes c
    JOIN Personas p ON c.dni = p.dni;
END $$
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE IF NOT EXISTS ObtenerClientePorDni(
    IN p_dni CHAR(8)
)
BEGIN
    DECLARE v_cliente_count INT;

    -- Verificar si el cliente con el DNI proporcionado existe
    SELECT COUNT(*) INTO v_cliente_count
    FROM Clientes
    WHERE dni = p_dni;

    -- Si no existe el cliente, lanzar un error
    IF v_cliente_count = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No se encontró un cliente con ese DNI';
    END IF;

    -- Obtener los detalles del cliente
    SELECT 
        c.dni, 
        c.tipo_cliente, 
        p.nombre, 
        p.apellido_paterno, 
        p.apellido_materno, 
        p.fecha_nacimiento
    FROM Clientes c
    JOIN Personas p ON c.dni = p.dni
    WHERE c.dni = p_dni;
END $$
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE IF NOT EXISTS ObtenerProductosCompradosPorCliente(
    IN p_dni CHAR(8)
)
BEGIN
    DECLARE v_cliente_count INT;
    DECLARE v_producto_count INT;

    -- Verificar si el cliente con el DNI proporcionado existe
    SELECT COUNT(*) INTO v_cliente_count
    FROM Clientes
    WHERE dni = p_dni;

    -- Si no existe el cliente, lanzar un error
    IF v_cliente_count = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No se encontró un cliente con ese DNI';
    END IF;

    -- Verificar si el cliente ha comprado productos
    SELECT COUNT(DISTINCT df.cod_producto) INTO v_producto_count
    FROM Detalle_Facturas df
    JOIN Facturas f ON df.cod_factura = f.cod_factura
    WHERE f.dni = p_dni;

    -- Si no hay productos comprados, lanzar un error
    IF v_producto_count = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Este cliente no ha comprado productos';
    END IF;

    -- Obtener todos los productos comprados por el cliente
    SELECT 
        p.cod_producto, 
        p.nombre, 
        p.descripcion, 
        p.precio_venta, 
        df.cantidad
    FROM Detalle_Facturas df
    JOIN Facturas f ON df.cod_factura = f.cod_factura
    JOIN Productos p ON df.cod_producto = p.cod_producto
    WHERE f.dni = p_dni;
END $$
DELIMITER ;