USE FabiaNatura;

-- ==============================================
--        Funcion: ExisteProductoPorNombre
-- ==============================================
-- Esta función se utiliza para verificar si un producto con el nombre dado ya existe en la base de datos.
-- Devuelve 1 si el producto existe, de lo contrario devuelve 0
-- ==============================================
DELIMITER $$
CREATE FUNCTION IF NOT EXISTS ExisteProductoPorNombre(p_nombre VARCHAR(100))
RETURNS BOOLEAN
DETERMINISTIC
BEGIN
    RETURN EXISTS (
        SELECT 1 
        FROM Productos 
        WHERE nombre = p_nombre
    );
END $$
DELIMITER ;

-- ==============================================
--                POST Productos
-- ==============================================
-- En el Frontend:
-- Se debe validar que el stock no sea mayor a 0
-- Se debe validar que el precio de compra y venta sean mayores a 0
-- Se debe validar que el precio de venta sea mayor al precio de compra
-- Se debe validar que no exista un producto con el mismo nombre con la función ExisteProductoPorNombre
-- Se debe hacer un seleccionador para las categorías y líneas: el producto solo puede contener 1 categoría y 1 línea
-- Campos obligatorios: nombre, precio_compra, precio_venta, stock
-- Campos opcionales: descripcion, cod_categoria, cod_linea (null)
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

-- ==============================================
--                Funcion Producto por ID
-- ==============================================
-- En el Frontend:
-- Este procedimiento se utiliza para obtener un producto por su ID
-- Devuelve 1 si el producto existe, de lo contrario devuelve 0
-- ==============================================
DELIMITER $$
CREATE FUNCTION IF NOT EXISTS ExisteProducto(p_cod_producto INT)
RETURNS BOOLEAN
DETERMINISTIC
BEGIN
    RETURN EXISTS (
        SELECT 1 
        FROM Productos 
        WHERE cod_producto = p_cod_producto
    );
END $$
DELIMITER ;

-- ==============================================
--                GET Producto por ID
-- ==============================================
-- En el Frontend:
-- Se debe consultar con la funcion ExisteProducto antes de llamar a este procedimiento
-- Si el producto no existe, se debe mostrar un mensaje de error en el cliente
-- ==============================================
DELIMITER $$
CREATE PROCEDURE IF NOT EXISTS ObtenerProductoPorId(
    IN p_cod_producto INT
)
BEGIN
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
-- En el Frontend:
-- Se debe validar que el precio de compra y venta sean mayores a 0
-- Se debe validar que el precio de venta sea mayor al precio de compra
-- Se debe validar que no exista un producto con el mismo nombre con la funcion ExisteProductoPorNombre (excepto si el nombre no ha cambiado)
-- Se debe hacer un seleccionador para las categorías y líneas: el producto solo puede contener 1 categoría y 1 línea
-- Se debe consultar con la funcion ExisteProducto antes de llamar a este procedimiento: si el producto no existe, se debe mostrar un mensaje de error en el cliente
-- Campos obligatorios: nombre, precio_compra, precio_venta, stock, estado
-- Campos opcionales: descripcion, cod_categoria, cod_linea (null)
-- Si se marca el producto como agotado, la casilla de stock debe ser 0 (se bloquea a 0)
-- Si se marca el producto como disponible, la casilla de stock debe ser mayor a 0
-- ==============================================
DELIMITER $$
CREATE PROCEDURE IF NOT EXISTS ActualizarProducto(
    IN p_cod_producto INT,
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
    UPDATE Productos
    SET
        nombre = p_nombre,
        descripcion = p_descripcion,
        precio_compra = p_precio_compra,
        precio_venta = p_precio_venta,
        stock = p_stock,
        estado = p_estado,
        cod_categoria = p_cod_categoria,
        cod_linea = p_cod_linea
    WHERE cod_producto = p_cod_producto;
END $$
DELIMITER ;