USE FabiaNatura;

-- POST Facturas --
DELIMITER $$
CREATE PROCEDURE IF NOT EXISTS AgregarFactura(
    IN p_dni_cliente CHAR(8),    -- DNI del cliente
    IN p_cod_vendedor INT,       -- Código del vendedor
    IN p_cod_asesor INT          -- Código del asesor (opcional)
)
BEGIN
    DECLARE v_cliente_count INT;
    DECLARE v_vendedor_count INT;
    DECLARE v_asesor_count INT;
    DECLARE v_cod_factura INT;

    -- Iniciar la transacción
    START TRANSACTION;

    -- Verificar si el cliente existe
    SELECT COUNT(*) INTO v_cliente_count
    FROM Clientes
    WHERE dni = p_dni_cliente;

    IF v_cliente_count = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El cliente con el DNI proporcionado no existe.';
    END IF;

    -- Verificar si el vendedor existe
    SELECT COUNT(*) INTO v_vendedor_count
    FROM Vendedores
    WHERE cod_vendedor = p_cod_vendedor;

    IF v_vendedor_count = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El vendedor con el código proporcionado no existe.';
    END IF;

    -- Si se proporciona un asesor, verificar si existe
    IF p_cod_asesor IS NOT NULL THEN
        SELECT COUNT(*) INTO v_asesor_count
        FROM Asesores
        WHERE cod_asesor = p_cod_asesor;

        IF v_asesor_count = 0 THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El asesor con el código proporcionado no existe.';
        END IF;
    END IF;

    -- Insertar la nueva factura
    INSERT INTO Facturas (dni, cod_vendedor, cod_asesor, fecha_registro)
    VALUES (p_dni_cliente, p_cod_vendedor, p_cod_asesor, CURRENT_TIMESTAMP);

    -- Obtener el código de la factura recién insertada
    SELECT LAST_INSERT_ID() INTO v_cod_factura;

    -- Confirmar la transacción si todo está bien
    COMMIT;
END $$
DELIMITER ;

-- GET Facturas --
DELIMITER $$
CREATE PROCEDURE IF NOT EXISTS ObtenerTodasLasFacturas()
BEGIN
    DECLARE v_factura_count INT;

    -- Verificar si existen facturas en la base de datos
    SELECT COUNT(*) INTO v_factura_count
    FROM Facturas;

    -- Si no hay facturas, lanzar un error
    IF v_factura_count = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No hay facturas registradas en la base de datos.';
    END IF;

    -- Obtener todas las facturas
    SELECT 
        f.cod_factura,
        f.dni,
        CONCAT(p.nombre, ' ', p.apellido_paterno) AS nombre_cliente,
        f.cod_vendedor,
        CONCAT(v.nombre, ' ', v.apellido_paterno) AS nombre_vendedor,
        f.cod_asesor,
        CONCAT(a.nombre, ' ', a.apellido_paterno) AS nombre_asesor,
        f.fecha_registro,
        f.estado
    FROM Facturas f
    LEFT JOIN Personas p ON f.dni = p.dni
    LEFT JOIN Vendedores v ON f.cod_vendedor = v.cod_vendedor
    LEFT JOIN Asesores a ON f.cod_asesor = a.cod_asesor
    ORDER BY f.fecha_registro DESC;
END $$
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE IF NOT EXISTS ObtenerDetallesDeFactura(
    IN p_cod_factura INT  -- Código de la factura
)
BEGIN
    DECLARE v_factura_count INT;

    -- Verificar si la factura existe
    SELECT COUNT(*) INTO v_factura_count
    FROM Facturas
    WHERE cod_factura = p_cod_factura;

    IF v_factura_count = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No se encontró una factura con ese código.';
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

-- DETELE Facturas --
DELIMITER $$
CREATE PROCEDURE IF NOT EXISTS EliminarFactura(
    IN p_cod_factura INT  -- Código de la factura a eliminar
)
BEGIN
    DECLARE v_cod_producto INT;
    DECLARE v_cantidad INT;
    DECLARE v_stock INT;
    DECLARE v_estado_producto VARCHAR(10);
    DECLARE v_detalle_count INT;
    DECLARE done INT DEFAULT 0;
    
    -- Declarar el cursor para obtener los detalles de la factura
    DECLARE detalle_cursor CURSOR FOR
        SELECT cod_producto, cantidad
        FROM Ventas.Detalle_Facturas
        WHERE cod_factura = p_cod_factura;
    
    -- Declarar un handler para terminar el cursor cuando no haya más filas
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;
    
    -- Iniciar la transacción
    START TRANSACTION;
    
    -- Verificar si la factura existe
    SELECT COUNT(*) INTO v_detalle_count
    FROM Ventas.Facturas
    WHERE cod_factura = p_cod_factura;
    
    IF v_detalle_count = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La factura con el código proporcionado no existe.';
    END IF;
    
    -- Abrir el cursor para procesar los productos de la factura
    OPEN detalle_cursor;
    
    -- Revertir el stock de cada producto
    read_loop: LOOP
        FETCH detalle_cursor INTO v_cod_producto, v_cantidad;
        
        IF done THEN
            LEAVE read_loop;
        END IF;
        
        -- Obtener el stock actual del producto y su estado
        SELECT stock, estado INTO v_stock, v_estado_producto
        FROM Inventario.Productos
        WHERE cod_producto = v_cod_producto;
        
        -- Restaurar el stock del producto (sumar la cantidad vendida)
        UPDATE Inventario.Productos
        SET stock = stock + v_cantidad
        WHERE cod_producto = v_cod_producto;
        
        -- Si el stock se restablece a mayor que 0 y estaba agotado, actualizar el estado a "disponible"
        IF v_stock + v_cantidad > 0 AND v_estado_producto = 'agotado' THEN
            UPDATE Inventario.Productos
            SET estado = 'disponible'
            WHERE cod_producto = v_cod_producto;
        END IF;
    END LOOP;
    
    -- Cerrar el cursor
    CLOSE detalle_cursor;
    
    -- Eliminar los detalles de la factura
    DELETE FROM Ventas.Detalle_Facturas
    WHERE cod_factura = p_cod_factura;
    
    -- Eliminar la factura
    DELETE FROM Ventas.Facturas
    WHERE cod_factura = p_cod_factura;
    
    -- Confirmar la transacción
    COMMIT;
END $$
DELIMITER ;