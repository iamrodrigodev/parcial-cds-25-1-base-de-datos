USE FabiaNatura;

-- POST DetallesDeFacturas --
DELIMITER $$
CREATE PROCEDURE IF NOT EXISTS CrearDetalleFactura(
    IN p_cod_factura INT,       -- Código de la factura
    IN p_cod_producto INT,      -- Código del producto
    IN p_cantidad INT           -- Cantidad del producto
)
BEGIN
    DECLARE v_estado_producto VARCHAR(10);
    DECLARE v_stock INT;
    DECLARE v_precio_venta FLOAT;
    DECLARE v_nombre_producto VARCHAR(100);
    DECLARE v_factura_count INT;

    -- Iniciar la transacción
    START TRANSACTION;

    -- Verificar si la factura existe
    SELECT COUNT(*) INTO v_factura_count
    FROM Facturas
    WHERE cod_factura = p_cod_factura;

    IF v_factura_count = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La factura con el código proporcionado no existe.';
    END IF;

    -- Obtener información del producto
    SELECT 
        estado, 
        stock, 
        precio_venta, 
        nombre 
    INTO v_estado_producto, v_stock, v_precio_venta, v_nombre_producto
    FROM Productos
    WHERE cod_producto = p_cod_producto;

    -- Verificar si el producto existe
    IF v_estado_producto IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El producto con el código proporcionado no existe.';
    END IF;

    -- Verificar si el producto está agotado
    IF v_estado_producto = 'agotado' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El producto está agotado y no puede ser vendido.';
    END IF;

    -- Verificar si hay suficiente stock
    IF v_stock < p_cantidad THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No hay suficiente stock para el producto.';
    END IF;

    -- Insertar el detalle de la factura
    INSERT INTO Detalle_Facturas (cod_factura, cod_producto, cantidad)
    VALUES (p_cod_factura, p_cod_producto, p_cantidad);

    -- Actualizar el stock del producto
    UPDATE Productos
    SET stock = stock - p_cantidad
    WHERE cod_producto = p_cod_producto;

    -- Verificar si el stock es 0 y actualizar el estado del producto a "agotado"
    IF (SELECT stock FROM Productos WHERE cod_producto = p_cod_producto) = 0 THEN
        UPDATE Productos
        SET estado = 'agotado'
        WHERE cod_producto = p_cod_producto;
    END IF;

    -- Confirmar la transacción si todo está bien
    COMMIT;
END $$
DELIMITER ;


-- GET DetallesDeFacturas --
DELIMITER $$
CREATE PROCEDURE IF NOT EXISTS ObtenerTodosLosDetallesDeFacturas()
BEGIN
    DECLARE v_factura_count INT;

    -- Verificar si existen facturas en la base de datos
    SELECT COUNT(*) INTO v_factura_count
    FROM Facturas;

    -- Si no hay facturas, lanzar un error
    IF v_factura_count = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No hay facturas registradas';
    END IF;

    -- Obtener todos los detalles de las facturas
    SELECT 
        f.cod_factura,
        df.cod_producto,
        p.nombre AS nombre_producto,
        df.cantidad,
        (df.cantidad * p.precio_venta) AS total_producto,
        f.fecha_registro,
        f.estado AS estado_factura
    FROM Detalle_Facturas df
    JOIN Facturas f ON df.cod_factura = f.cod_factura
    JOIN Productos p ON df.cod_producto = p.cod_producto
    ORDER BY f.fecha_registro DESC;
END $$
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE IF NOT EXISTS ObtenerDetallesDeFactura(
    IN p_cod_factura INT  -- Código de la factura
)
BEGIN
    DECLARE v_factura_count INT;

    -- Verificar si la factura con el código proporcionado existe
    SELECT COUNT(*) INTO v_factura_count
    FROM Facturas
    WHERE cod_factura = p_cod_factura;

    -- Si no existe la factura, lanzar un error
    IF v_factura_count = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No se encontró una factura con ese código';
    END IF;

    -- Obtener los detalles de la factura
    SELECT 
        df.cod_factura,
        df.cod_producto,
        p.nombre AS nombre_producto,
        df.cantidad,
        (df.cantidad * p.precio_venta) AS total_producto
    FROM Detalle_Facturas df
    JOIN Productos p ON df.cod_producto = p.cod_producto
    WHERE df.cod_factura = p_cod_factura;
END $$
DELIMITER ;

-- DELETE DetallesDeFacturas --
DELIMITER $$
CREATE PROCEDURE IF NOT EXISTS EliminarDetalleFactura(
    IN p_cod_factura INT,     -- Código de la factura
    IN p_cod_producto INT     -- Código del producto
)
BEGIN
    DECLARE v_cantidad INT;
    DECLARE v_stock INT;
    DECLARE v_nombre_producto VARCHAR(100);
    DECLARE v_detalle_count INT;

    -- Iniciar la transacción
    START TRANSACTION;

    -- Obtener la cantidad del producto en el detalle de la factura
    SELECT cantidad INTO v_cantidad
    FROM Detalle_Facturas
    WHERE cod_factura = p_cod_factura AND cod_producto = p_cod_producto;

    -- Si no se encuentra el detalle de la factura, revertir la transacción
    IF v_cantidad IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El detalle de la factura no existe para este producto.';
    END IF;

    -- Obtener el stock actual del producto
    SELECT stock, nombre INTO v_stock, v_nombre_producto
    FROM Productos
    WHERE cod_producto = p_cod_producto;

    -- Restaurar el stock del producto
    UPDATE Productos
    SET stock = stock + v_cantidad
    WHERE cod_producto = p_cod_producto;

    -- Verificar si el stock es ahora mayor que 0 y actualizar el estado a "disponible" si es necesario
    IF (SELECT stock FROM Productos WHERE cod_producto = p_cod_producto) > 0 THEN
        UPDATE Productos
        SET estado = 'disponible'
        WHERE cod_producto = p_cod_producto;
    END IF;

    -- Eliminar el detalle de la factura
    DELETE FROM Detalle_Facturas
    WHERE cod_factura = p_cod_factura AND cod_producto = p_cod_producto;

    -- Confirmar la transacción
    COMMIT;
END $$
DELIMITER ;