USE FabiaNatura;

-- ==============================================
--                POST Productos
-- ==============================================
DELIMITER $$
CREATE PROCEDURE IF NOT EXISTS AgregarProducto(
    IN p_nombre VARCHAR(100),
    IN p_descripcion TEXT,
    IN p_precio_compra FLOAT,
    IN p_precio_venta FLOAT,
    IN p_stock INT,
    IN p_cod_categoria INT,
    IN p_cod_linea INT
)
BEGIN
    IF p_precio_compra IS NULL OR p_precio_compra <= 0 THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'El precio de compra debe ser mayor que 0';
    END IF;
    IF p_precio_venta IS NULL OR p_precio_venta <= 0 THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'El precio de venta debe ser mayor que 0';
    END IF;
    IF p_stock IS NULL OR p_stock <= 0 THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'El stock no debe ser mayor a 0';
    END IF;
    IF p_precio_venta <= p_precio_compra THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'El precio de venta debe ser mayor al precio de compra';
    END IF;
    IF EXISTS (SELECT 1 FROM Productos WHERE nombre = p_nombre) THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'Ya existe un producto con este nombre';
    END IF;
    INSERT INTO Productos (
        nombre, 
        descripcion, 
        precio_compra,
        precio_venta,
        stock, 
        cod_categoria,
        cod_linea
    ) VALUES (
        p_nombre, 
        p_descripcion, 
        p_precio_compra,
        p_precio_venta,
        p_stock, 
        p_cod_categoria,
        p_cod_linea
    );
END $$
DELIMITER ;

-- ==============================================
--                GET Productos
-- ==============================================
DELIMITER $$
CREATE PROCEDURE IF NOT EXISTS ObtenerTodosLosProductos()
BEGIN
    SELECT 
        p.cod_producto,
        p.nombre,
        p.descripcion,
        p.precio_compra,
        p.precio_venta,
        p.stock,
        p.estado,
        c.nombre AS categoria,
        l.nombre_linea AS linea,
        p.fecha_registro
    FROM Productos p
    LEFT JOIN Categorias c ON p.cod_categoria = c.cod_categoria
    LEFT JOIN Lineas l ON p.cod_linea = l.cod_linea
    WHERE p.estado = 'disponible';
END $$
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE IF NOT EXISTS ObtenerTodosLosProductosNoDisponibles()
BEGIN
    SELECT 
        p.cod_producto,
        p.nombre,
        p.descripcion,
        p.precio_compra,
        p.precio_venta,
        p.stock,
        p.estado,
        c.nombre AS categoria,
        l.nombre_linea AS linea,
        p.fecha_registro
    FROM Productos p
    LEFT JOIN Categorias c ON p.cod_categoria = c.cod_categoria
    LEFT JOIN Lineas l ON p.cod_linea = l.cod_linea
    WHERE p.estado = 'agotado';
END $$
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE IF NOT EXISTS ObtenerProductoPorId(
    IN p_cod_producto INT
)
BEGIN
    IF NOT EXISTS (SELECT 1 FROM Productos WHERE cod_producto = p_cod_producto) THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'El producto especificado no existe';
    END IF;
    SELECT 
        p.cod_producto,
        p.nombre,
        p.descripcion,
        p.precio_compra,
        p.precio_venta,
        p.stock,
        p.estado,
        c.nombre AS nombre_categoria,
        l.nombre_linea AS nombre_linea,
        p.fecha_registro
    FROM 
        Productos p
    LEFT JOIN Categorias c ON p.cod_categoria = c.cod_categoria
    LEFT JOIN Lineas l ON p.cod_linea = l.cod_linea
    WHERE 
        p.cod_producto = p_cod_producto;
END $$
DELIMITER ;

-- ==============================================
--                PUT Productos
-- ==============================================
DELIMITER $$
CREATE PROCEDURE IF NOT EXISTS ActualizarProducto(
    IN p_nombre VARCHAR(100),
    IN p_descripcion TEXT,
    IN p_precio_compra FLOAT,
    IN p_precio_venta FLOAT,
    IN p_stock INT,
    IN p_estado ENUM('disponible', 'agotado'),
    IN p_cod_categoria INT,
    IN p_cod_linea INT
)
BEGIN
    IF p_precio_compra IS NULL OR p_precio_compra <= 0 THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'El precio de compra debe ser mayor que 0';
    END IF;
    IF p_precio_venta IS NULL OR p_precio_venta <= 0 THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'El precio de venta debe ser mayor que 0';
    END IF;
    IF p_stock IS NULL OR p_stock <= 0 THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'El stock no debe ser mayor a 0';
    END IF;
    IF p_precio_venta <= p_precio_compra THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'El precio de venta debe ser mayor al precio de compra';
    END IF;
    UPDATE Productos
    SET
        descripcion = p_descripcion,
        precio_compra = p_precio_compra,
        precio_venta = p_precio_venta,
        stock = p_stock,
        estado = p_estado,
        cod_categoria = p_cod_categoria,
        cod_linea = p_cod_linea
    WHERE nombre = p_nombre;
END $$
DELIMITER ;