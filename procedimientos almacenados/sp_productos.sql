USE FabiaNatura;

-- POST Productos --
DELIMITER $$
CREATE PROCEDURE IF NOT EXISTS AgregarProducto(
    IN p_nombre VARCHAR(100),
    IN p_descripcion TEXT,
    IN p_precio_compra FLOAT,
    IN p_precio_venta FLOAT,
    IN p_stock INT,
    IN p_cod_categoria INT,
    IN p_cod_linea INT,
    IN p_estado ENUM('disponible', 'agotado')
)
BEGIN
    -- Establecer estado predeterminado si no se proporciona
    IF p_estado IS NULL THEN
        SET p_estado = 'disponible';
    END IF;
    -- Validar parámetros de entrada
    IF p_nombre IS NULL OR p_nombre = '' THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'El nombre del producto no puede ser nulo o vacío';
    END IF;

    -- Validar precios de compra y venta
    IF p_precio_compra IS NULL OR p_precio_compra < 0 THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'El precio de compra debe ser mayor que 0';
    END IF;

    IF p_precio_venta IS NULL OR p_precio_venta < 0 THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'El precio de venta debe ser mayor que 0';
    END IF;

    -- Validar cantidad de stock
    IF p_stock IS NULL OR p_stock < 0 THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'El stock debe ser mayor que 0';
    END IF;

    IF p_precio_venta IS NULL OR p_precio_venta > p_precio_compra THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'El precio de venta debe ser mayor al precio de compra';
    END IF;

    -- Validar código de categoría
    IF p_cod_categoria IS NULL OR p_cod_categoria <= 0 THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'Código de categoría inválido';
    END IF;

    -- Verificar si la categoría existe en la base de datos
    IF NOT EXISTS (SELECT 1 FROM Categorias WHERE cod_categoria = p_cod_categoria) THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'La categoría especificada no existe';
    END IF;

    -- Verificar si la línea existe si se proporciona
    IF p_cod_linea IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Lineas WHERE cod_linea = p_cod_linea) THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'La línea especificada no existe';
    END IF;

    -- Verificar si el producto ya existe
    IF EXISTS (SELECT 1 FROM Productos WHERE nombre = p_nombre) THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'Ya existe un producto con este nombre';
    END IF;

    -- Insertar nuevo producto en la base de datos
    INSERT INTO Productos (
        nombre, 
        descripcion, 
        precio_compra,
        precio_venta,
        stock, 
        cod_categoria,
        cod_linea,
        estado
    ) VALUES (
        p_nombre, 
        p_descripcion, 
        p_precio_compra,
        p_precio_venta,
        p_stock, 
        p_cod_categoria,
        p_cod_linea,
        p_estado
    );
END $$
DELIMITER ;

-- GET Productos --
DELIMITER $$
CREATE PROCEDURE IF NOT EXISTS ObtenerTodosLosProductos()
BEGIN
    DECLARE v_total_productos INT;

    -- Contar número total de productos en la base de datos
    SELECT COUNT(*) INTO v_total_productos FROM Productos;

    -- Verificar si no existen productos en la base de datos
    IF v_total_productos = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'No se encontraron productos en la base de datos';
    END IF;

    -- Listar todos los productos con información de categoría
    SELECT 
        p.*,
        c.nombre AS nombre_categoria,
        v_total_productos AS total_productos 
    FROM 
        Productos p
    JOIN 
        Categorias c ON p.cod_categoria = c.cod_categoria
    ORDER BY 
        p.nombre;
END $$
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE IF NOT EXISTS ObtenerProductoPorId(
    IN p_cod_producto INT
)
BEGIN
    -- Validar parámetro de entrada
    IF p_cod_producto IS NULL OR p_cod_producto <= 0 THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'Código de producto inválido';
    END IF;

    -- Verificar si el producto existe en la base de datos
    IF NOT EXISTS (SELECT 1 FROM Productos WHERE cod_producto = p_cod_producto) THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'El producto especificado no existe';
    END IF;

    -- Recuperar detalles del producto con información de categoría
    SELECT 
        p.*,
        c.nombre AS nombre_categoria
    FROM 
        Productos p
    JOIN 
        Categorias c ON p.cod_categoria = c.cod_categoria
    WHERE 
        p.cod_producto = p_cod_producto;
END $$
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE IF NOT EXISTS BuscarProductoPorNombre(
    IN p_nombre_producto VARCHAR(100)
)
BEGIN
    -- Verificar si existe un producto con el nombre proporcionado
    DECLARE v_producto_count INT;

    -- Validar que el nombre del producto no esté vacío ni sea NULL
    IF p_nombre_producto IS NULL OR p_nombre_producto = '' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El nombre del producto no puede estar vacío';
    END IF;

    SELECT COUNT(*) INTO v_producto_count
    FROM Productos
    WHERE nombre = p_nombre_producto;

    -- Si no existe el producto, lanzar un error
    IF v_producto_count = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No se encontró un producto con ese nombre';
    END IF;

    -- Obtener los detalles del producto
    SELECT cod_producto, nombre, descripcion, precio_compra, precio_venta, stock, estado, fecha_registro
    WHERE nombre = p_nombre_producto;
END $$
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE IF NOT EXISTS ObtenerStockPorId(
    IN p_cod_producto INT
)
BEGIN
    -- Verificar si existe un producto con el cod_producto proporcionado
    DECLARE v_producto_count INT;

    -- Validar que el ID del producto no sea nulo ni inválido
    IF p_cod_producto IS NULL OR p_cod_producto <= 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El ID del producto no puede ser nulo o inválido';
    END IF;

    SELECT COUNT(*) INTO v_producto_count
    FROM Productos
    WHERE cod_producto = p_cod_producto;

    -- Si no existe el producto, lanzar un error
    IF v_producto_count = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No se encontró un producto con ese ID';
    END IF;

    -- Obtener el stock del producto
    SELECT stock
    FROM Productos
    WHERE cod_producto = p_cod_producto;
END $$
DELIMITER ;

-- PUT Productos --
DELIMITER $$
CREATE PROCEDURE IF NOT EXISTS ActualizarProductos(
    IN p_cod_producto INT,
    IN p_nombre VARCHAR(100),
    IN p_descripcion TEXT,
    IN p_precio_compra FLOAT,
    IN p_precio_venta FLOAT,
    IN p_stock INT,
    IN p_cod_categoria INT,
    IN p_cod_linea INT,
    IN p_estado ENUM('disponible', 'agotado')
)
BEGIN
    -- Establecer estado predeterminado si no se proporciona
    IF p_estado IS NULL THEN
        SET p_estado = 'disponible';
    END IF;
    -- Validar parámetros de entrada
    IF p_cod_producto IS NULL OR p_cod_producto <= 0 THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'Código de producto inválido';
    END IF;

    IF p_nombre IS NULL OR p_nombre = '' THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'El nombre del producto no puede ser nulo o vacío';
    END IF;

    -- Validar precios de compra y venta
    IF p_precio_compra IS NULL OR p_precio_compra < 0 THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'El precio de compra debe ser mayor que 0';
    END IF;

    IF p_precio_venta IS NULL OR p_precio_venta < 0 THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'El precio de venta debe ser mayor que 0';
    END IF;

    IF p_precio_venta IS NULL OR p_precio_venta > p_precio_compra THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'El precio de venta debe ser mayor al precio de compra';
    END IF;

    -- Validar cantidad de stock
    IF p_stock IS NULL OR p_stock < 0 THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'El stock debe ser mayor que 0';
    END IF;

    -- Validar código de categoría
    IF p_cod_categoria IS NULL OR p_cod_categoria <= 0 THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'Código de categoría inválido';
    END IF;

    -- Verificar si el producto existe en la base de datos
    IF NOT EXISTS (SELECT 1 FROM Productos WHERE cod_producto = p_cod_producto) THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'El producto especificado no existe';
    END IF;

    -- Verificar si la categoría existe en la base de datos
    IF NOT EXISTS (SELECT 1 FROM Categorias WHERE cod_categoria = p_cod_categoria) THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'La categoría especificada no existe';
    END IF;

    -- Verificar si la línea existe si se proporciona
    IF p_cod_linea IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Lineas WHERE cod_linea = p_cod_linea) THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'La línea especificada no existe';
    END IF;

    -- Verificar si el nuevo nombre del producto ya existe en la base de datos
    IF EXISTS (SELECT 1 FROM Productos 
               WHERE nombre = p_nombre AND cod_producto != p_cod_producto) THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'Ya existe otro producto con este nombre';
    END IF;

    -- Actualizar producto en la base de datos
    UPDATE Productos 
    SET 
        nombre = p_nombre, 
        descripcion = p_descripcion,
        precio_compra = p_precio_compra,
        precio_venta = p_precio_venta,
        stock = p_stock,
        cod_categoria = p_cod_categoria,
        cod_linea = p_cod_linea,
        estado = p_estado
    WHERE 
        cod_producto = p_cod_producto;
END $$
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE IF NOT EXISTS ActualizarEstadoAgotado(
    IN p_cod_producto INT
)
BEGIN
    -- Verificar si el producto con el cod_producto existe
    DECLARE v_producto_count INT;
    DECLARE v_estado_actual VARCHAR(50);

    -- Contar cuántos productos existen con ese ID
    SELECT COUNT(*) INTO v_producto_count
    FROM Productos
    WHERE cod_producto = p_cod_producto;

    -- Si no existe el producto, lanzar un error
    IF v_producto_count = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No se encontró un producto con ese ID';
    END IF;

    -- Obtener el estado actual del producto
    SELECT estado INTO v_estado_actual
    FROM Productos
    WHERE cod_producto = p_cod_producto;

    -- Si el estado ya es "agotado", lanzar un error
    IF v_estado_actual = 'agotado' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El producto ya está marcado como agotado';
    END IF;

    -- Actualizar el estado del producto a "agotado"
    UPDATE Productos
    SET estado = 'agotado'
    WHERE cod_producto = p_cod_producto;
END $$
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE IF NOT EXISTS ActualizarStockProducto(
    IN p_cod_producto INT,
    IN p_nuevo_stock INT 
)
BEGIN
    -- Verificar si el producto con el cod_producto existe
    DECLARE v_producto_count INT;

    -- Validar que el nuevo stock no sea negativo
    IF p_nuevo_stock < 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El stock no puede ser negativo';
    END IF;

    SELECT COUNT(*) INTO v_producto_count
    FROM Productos
    WHERE cod_producto = p_cod_producto;

    -- Si no existe el producto, lanzar un error
    IF v_producto_count = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No se encontró un producto con ese ID';
    END IF;

    -- Actualizar el stock del producto
    UPDATE Productos
    SET stock = p_nuevo_stock
    WHERE cod_producto = p_cod_producto;
END $$
DELIMITER ;