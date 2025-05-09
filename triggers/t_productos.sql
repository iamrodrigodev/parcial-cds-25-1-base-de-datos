USE FabiaNatura;

DELIMITER $$
CREATE TRIGGER ActualizarEstadoProductoAgotado
AFTER UPDATE ON Productos
FOR EACH ROW
BEGIN
    -- Verificar si el stock del producto ha llegado a 0
    IF NEW.stock = 0 THEN
        -- Actualizar el estado del producto a "agotado"
        UPDATE Productos
        SET estado = 'agotado'
        WHERE cod_producto = NEW.cod_producto;
    END IF;
END $$
DELIMITER ;

DELIMITER $$
CREATE TRIGGER ActualizarEstadoProductoDisponible
AFTER UPDATE ON Productos
FOR EACH ROW
BEGIN
    -- Verificar si el stock del producto ha llegado a un valor mayor que 0
    IF NEW.stock > 0 THEN
        -- Actualizar el estado del producto a "disponible"
        UPDATE Productos
        SET estado = 'disponible'
        WHERE cod_producto = NEW.cod_producto;
    END IF;
END $$
DELIMITER ;


DELIMITER $$
CREATE TRIGGER ActualizarStockACeroCuandoAgotado
AFTER UPDATE ON Productos
FOR EACH ROW
BEGIN
    -- Verificar si el estado del producto ha cambiado a "agotado"
    IF NEW.estado = 'agotado' AND OLD.estado != 'agotado' THEN
        -- Actualizar el stock a 0 cuando el estado se actualice a "agotado"
        UPDATE Productos
        SET stock = 0
        WHERE cod_producto = NEW.cod_producto;
    END IF;
END $$
DELIMITER ;