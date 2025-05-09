USE FabiaNatura;

-- POST Lineas --
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
        SET MESSAGE_TEXT = 'El precio de compra debe ser un valor no negativo';
    END IF;

    IF p_precio_venta IS NULL OR p_precio_venta < 0 THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'El precio de venta debe ser un valor no negativo';
    END IF;

    -- Validar cantidad de stock
    IF p_stock IS NULL OR p_stock < 0 THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'El stock debe ser un valor no negativo';
    END IF;

    IF p_precio_venta IS NULL OR p_precio_venta > p_precio_compra THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'El precio de venta debe ser un valor no negativo';
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

-- Listar todos los productos del sistema
CREATE PROCEDURE IF NOT EXISTS sp_listar_productos()
BEGIN
    DECLARE v_total_productos INT;

    -- Contar número total de productos en la base de datos
    SELECT COUNT(*) INTO v_total_productos FROM Productos;

    -- Verificar si no existen productos en la base de datos
    IF v_total_productos = 0 THEN
        SIGNAL SQLSTATE '02000'
        SET MESSAGE_TEXT = 'Información: No hay productos registrados en el sistema';
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

-- Obtener un producto por su ID específico
CREATE PROCEDURE IF NOT EXISTS sp_obtener_producto_por_id(
    IN p_cod_producto INT
)
BEGIN
    -- Validar parámetro de entrada
    IF p_cod_producto IS NULL OR p_cod_producto <= 0 THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'Error: Código de producto inválido';
    END IF;

    -- Verificar si el producto existe en la base de datos
    IF NOT EXISTS (SELECT 1 FROM Productos WHERE cod_producto = p_cod_producto) THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'Error: El producto especificado no existe';
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

-- Actualizar un producto existente en el sistema
CREATE PROCEDURE IF NOT EXISTS sp_actualizar_producto(
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
        SET MESSAGE_TEXT = 'Error: Código de producto inválido';
    END IF;

    IF p_nombre IS NULL OR p_nombre = '' THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'Error: El nombre del producto no puede ser nulo o vacío';
    END IF;

    -- Validar precios de compra y venta
    IF p_precio_compra IS NULL OR p_precio_compra < 0 THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'Error: El precio de compra debe ser un valor no negativo';
    END IF;

    IF p_precio_venta IS NULL OR p_precio_venta < 0 THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'Error: El precio de venta debe ser un valor no negativo';
    END IF;

    -- Validar cantidad de stock
    IF p_stock IS NULL OR p_stock < 0 THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'Error: El stock debe ser un valor no negativo';
    END IF;

    -- Validar código de categoría
    IF p_cod_categoria IS NULL OR p_cod_categoria <= 0 THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'Error: Código de categoría inválido';
    END IF;

    -- Validar código de línea (opcional)
    IF p_cod_linea IS NOT NULL AND p_cod_linea <= 0 THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'Error: Código de línea inválido';
    END IF;

    -- Usar cadena vacía si la descripción es NULA
    IF p_descripcion IS NULL THEN
        SET p_descripcion = '';
    END IF;

    -- Verificar si el producto existe en la base de datos
    IF NOT EXISTS (SELECT 1 FROM Productos WHERE cod_producto = p_cod_producto) THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'Error: El producto especificado no existe';
    END IF;

    -- Verificar si la categoría existe en la base de datos
    IF NOT EXISTS (SELECT 1 FROM Categorias WHERE cod_categoria = p_cod_categoria) THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'Error: La categoría especificada no existe';
    END IF;

    -- Verificar si la línea existe si se proporciona
    IF p_cod_linea IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Lineas WHERE cod_linea = p_cod_linea) THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'Error: La línea especificada no existe';
    END IF;

    -- Verificar si el nuevo nombre del producto ya existe en la base de datos
    IF EXISTS (SELECT 1 FROM Productos 
               WHERE nombre = p_nombre AND cod_producto != p_cod_producto) THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'Error: Ya existe otro producto con este nombre';
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
    
    SELECT ROW_COUNT() AS filas_actualizadas;
END $$

-- Buscar productos por nombre
CREATE PROCEDURE IF NOT EXISTS sp_buscar_producto_por_nombre(
    IN p_nombre_producto VARCHAR(100)
)
BEGIN
    DECLARE v_total_productos INT;

    -- Validar parámetro de entrada
    IF p_nombre_producto IS NULL OR p_nombre_producto = '' THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'Error: El nombre del producto no puede ser nulo o vacío';
    END IF;

    -- Contar número total de productos que coinciden con el nombre
    SELECT COUNT(*) INTO v_total_productos
    FROM Productos
    WHERE nombre LIKE CONCAT('%', p_nombre_producto, '%');

    -- Verificar si no existen productos en la base de datos
    IF v_total_productos = 0 THEN
        SIGNAL SQLSTATE '02000'
        SET MESSAGE_TEXT = 'Información: No se encontraron productos con el nombre especificado';
    END IF;

    -- Buscar productos con información de categoría
    SELECT 
        p.*,
        c.nombre AS nombre_categoria,
        v_total_productos AS total_productos
    FROM 
        Productos p
    JOIN 
        Categorias c ON p.cod_categoria = c.cod_categoria
    WHERE 
        p.nombre LIKE CONCAT('%', p_nombre_producto, '%')
    ORDER BY 
        p.nombre;
END $$

DELIMITER ;
