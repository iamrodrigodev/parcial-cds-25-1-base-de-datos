USE FabiaNatura;

-- POST Proveedores --
DELIMITER $$
CREATE PROCEDURE IF NOT EXISTS AgregarProveedor (
    IN p_ruc CHAR(11),        
    IN p_nombre VARCHAR(50) 
)
BEGIN
    DECLARE v_existente INT;

    -- Validar que el RUC tenga exactamente 11 caracteres
    IF p_ruc IS NULL OR CHAR_LENGTH(p_ruc) != 11 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El RUC debe tener exactamente 11 caracteres.';
    END IF;

    -- Validar que el nombre no sea nulo o vacío
    IF p_nombre IS NULL OR TRIM(p_nombre) = '' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El nombre del proveedor no puede estar vacío.';
    END IF;

    -- Verificar si ya existe un proveedor con ese RUC o nombre
    SELECT COUNT(*) INTO v_existente
    FROM Proveedores
    WHERE ruc = p_ruc OR nombre = p_nombre;

    IF v_existente > 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Ya existe un proveedor con ese RUC o nombre.';
    END IF;
    -- Insertar el nuevo proveedor
    INSERT INTO Proveedores (ruc, nombre)
    VALUES (p_ruc, p_nombre);
END $$
DELIMITER ;

-- GET Proveedores --
DELIMITER $$
CREATE PROCEDURE IF NOT EXISTS ObtenerProveedores()
BEGIN
    DECLARE v_proveedores_count INT;

    -- Verificar si hay proveedores registrados en la base de datos
    SELECT COUNT(*) INTO v_proveedores_count
    FROM Proveedores;

    -- Si no hay proveedores, lanzar un error
    IF v_proveedores_count = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No hay proveedores registrados';
    END IF;

    -- Si hay proveedores, seleccionar todos
    SELECT ruc, nombre, fecha_registro
    FROM Proveedores;
END $$
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE IF NOT EXISTS ObtenerProveedorPorRuc(
    IN p_ruc CHAR(11)
)
BEGIN
    DECLARE v_proveedor_count INT;

    -- Verificar si el proveedor con el RUC proporcionado existe
    SELECT COUNT(*) INTO v_proveedor_count
    FROM Proveedores
    WHERE ruc = p_ruc;

    -- Si no existe el proveedor, lanzar un error
    IF v_proveedor_count = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No se encontró un proveedor con ese RUC';
    END IF;

    -- Si el proveedor existe, seleccionar los detalles del proveedor
    SELECT ruc, nombre, fecha_registro
    FROM Proveedores
    WHERE ruc = p_ruc;
END $$
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE IF NOT EXISTS ObtenerProductosDeProveedor(
    IN p_ruc CHAR(11)
)
BEGIN
    DECLARE v_proveedor_count INT;
    DECLARE v_producto_count INT;

    -- Verificar si el proveedor con el RUC proporcionado existe
    SELECT COUNT(*) INTO v_proveedor_count
    FROM Proveedores
    WHERE ruc = p_ruc;

    -- Si no existe el proveedor, lanzar un error
    IF v_proveedor_count = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No se encontró un proveedor con ese RUC';
    END IF;

    -- Verificar si el proveedor tiene productos
    SELECT COUNT(*) INTO v_producto_count
    FROM Productos p
    JOIN Lineas l ON p.cod_linea = l.cod_linea
    JOIN Proveedores pr ON l.ruc = pr.ruc
    WHERE pr.ruc = p_ruc;

    -- Si no hay productos, lanzar un error
    IF v_producto_count = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No hay productos asociados a este proveedor';
    END IF;

    -- Obtener los productos del proveedor
    SELECT p.cod_producto, p.nombre, p.descripcion, p.precio_venta, p.stock, p.estado
    FROM Productos p
    JOIN Lineas l ON p.cod_linea = l.cod_linea
    JOIN Proveedores pr ON l.ruc = pr.ruc
    WHERE pr.ruc = p_ruc;
END $$
DELIMITER ;


DELIMITER $$
CREATE PROCEDURE IF NOT EXISTS ObtenerProductosMasVendidosPorProveedor(
    IN p_ruc CHAR(11)
)
BEGIN
    DECLARE v_proveedor_count INT;
    DECLARE v_linea_count INT;
    DECLARE v_producto_count INT;

    -- Verificar si el proveedor con el RUC proporcionado existe
    SELECT COUNT(*) INTO v_proveedor_count
    FROM Proveedores
    WHERE ruc = p_ruc;

    -- Si no existe el proveedor, lanzar un error
    IF v_proveedor_count = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No se encontró un proveedor con ese RUC';
    END IF;

    -- Verificar si el proveedor tiene al menos una línea asociada
    SELECT COUNT(*) INTO v_linea_count
    FROM Lineas
    WHERE ruc = p_ruc;

    -- Si no existe ninguna línea asociada al proveedor, lanzar un error
    IF v_linea_count = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El proveedor no tiene líneas asociadas';
    END IF;

    -- Verificar si hay productos vendidos en la tabla Detalle_Facturas
    SELECT COUNT(DISTINCT df.cod_producto) INTO v_producto_count
    FROM Detalle_Facturas df
    JOIN Productos p ON df.cod_producto = p.cod_producto
    JOIN Lineas l ON p.cod_linea = l.cod_linea
    WHERE l.ruc = p_ruc;

    -- Si no hay productos vendidos, lanzar un error
    IF v_producto_count = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No se han vendido productos para este proveedor';
    END IF;

    -- Obtener los productos más vendidos del proveedor
    SELECT 
        pr.ruc, 
        p.cod_producto, 
        p.nombre, 
        SUM(df.cantidad) AS total_vendido
    FROM 
        Detalle_Facturas df
    JOIN 
        Productos p ON df.cod_producto = p.cod_producto
    JOIN 
        Lineas l ON p.cod_linea = l.cod_linea
    JOIN 
        Proveedores pr ON l.ruc = pr.ruc
    WHERE 
        pr.ruc = p_ruc
    GROUP BY 
        pr.ruc, p.cod_producto, p.nombre
    ORDER BY 
        total_vendido DESC;
END $$
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE IF NOT EXISTS ObtenerLineasDeProveedor(
    IN p_ruc CHAR(11)
)
BEGIN
    DECLARE v_proveedor_count INT;
    DECLARE v_linea_count INT;

    -- Verificar si el proveedor con el RUC proporcionado existe
    SELECT COUNT(*) INTO v_proveedor_count
    FROM Proveedores
    WHERE ruc = p_ruc;

    -- Si no existe el proveedor, lanzar un error
    IF v_proveedor_count = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No se encontró un proveedor con ese RUC';
    END IF;

    -- Verificar si el proveedor tiene líneas asociadas
    SELECT COUNT(*) INTO v_linea_count
    FROM Lineas l
    JOIN Proveedores pr ON l.ruc = pr.ruc
    WHERE pr.ruc = p_ruc;

    -- Si no tiene líneas, lanzar un error
    IF v_linea_count = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No hay líneas asociadas a este proveedor';
    END IF;

    -- Obtener todas las líneas asociadas al proveedor
    SELECT l.cod_linea, l.nombre_linea, l.fecha_registro
    FROM Lineas l
    JOIN Proveedores pr ON l.ruc = pr.ruc
    WHERE pr.ruc = p_ruc; 
END $$
DELIMITER ;

-- PUT Proveedores --
DELIMITER $$
CREATE PROCEDURE IF NOT EXISTS ActualizarProveedor(
    IN p_ruc CHAR(11),
    IN p_nuevo_nombre VARCHAR(50)
)
BEGIN
    DECLARE v_existente INT;

    -- Verificar si el proveedor con el RUC proporcionado existe
    SELECT COUNT(*) INTO v_existente
    FROM Proveedores
    WHERE ruc = p_ruc;

    -- Si no existe el proveedor, lanzar un error
    IF v_existente = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No se encontró un proveedor con ese RUC';
    END IF;

    -- Validar que el nuevo nombre no sea nulo ni vacío
    IF p_nuevo_nombre IS NULL OR TRIM(p_nuevo_nombre) = '' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El nombre del proveedor no puede estar vacío';
    END IF;

    -- Actualizar el nombre del proveedor
    UPDATE Proveedores
    SET nombre = p_nuevo_nombre
    WHERE ruc = p_ruc;
END $$
DELIMITER ;