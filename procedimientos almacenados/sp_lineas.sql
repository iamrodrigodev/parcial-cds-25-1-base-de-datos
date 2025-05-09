USE FabiaNatura;

-- POST Lineas --
DELIMITER $$
CREATE PROCEDURE IF NOT EXISTS AgregarLinea(
    IN p_ruc CHAR(11),
    IN p_nombre_linea VARCHAR(100)
)
BEGIN
    -- Validación de que el nombre de la línea no esté vacío
    IF p_nombre_linea IS NULL OR p_nombre_linea = '' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El nombre de la línea no puede estar vacío';
    END IF;

    -- Validación de que el RUC y el nombre no estén vacíos
    IF (p_ruc IS NOT NULL AND p_ruc != '') THEN
        -- Verificar que el RUC tenga exactamente 11 caracteres
        IF LENGTH(p_ruc) != 11 THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El RUC debe tener exactamente 11 caracteres';
        END IF;

        -- Verificar si el RUC existe en la tabla Proveedores
        IF NOT EXISTS (SELECT 1 FROM Proveedores WHERE ruc = p_ruc) THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El RUC no existe en la base de datos';
        END IF;
    END IF;

    -- Verificar si el nombre de la línea es único en la tabla Lineas
    IF EXISTS (SELECT 1 FROM Lineas WHERE nombre_linea = p_nombre_linea) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El nombre de la línea ya existe en la base de datos';
    END IF;

    -- Insertar la nueva línea en la tabla Lineas
    INSERT INTO Lineas (ruc, nombre_linea, fecha_registro)
    VALUES (p_ruc, p_nombre_linea, CURRENT_TIMESTAMP);
END $$
DELIMITER ;

-- GET Lineas --
DELIMITER $$
CREATE PROCEDURE IF NOT EXISTS ObtenerTodasLasLineas()
BEGIN
    -- Declarar una variable para contar el número de líneas encontradas
    DECLARE v_lineas_count INT;

    -- Contar el número total de líneas en la tabla
    SELECT COUNT(*) INTO v_lineas_count FROM Lineas;

    -- Si no se encuentran líneas, lanzar un error
    IF v_lineas_count = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No se encontraron líneas en la base de datos';
    END IF;

    -- Si hay líneas, obtenerlas en orden alfabético por nombre_linea
    SELECT cod_linea, ruc, nombre_linea, fecha_registro
    FROM Lineas
    ORDER BY nombre_linea ASC;
END $$
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE IF NOT EXISTS ObtenerLineaPorId(
    IN p_cod_linea INT
)
BEGIN
    -- Declarar una variable para contar el número de registros encontrados
    DECLARE v_linea_count INT;

    -- Contar el número de líneas con el ID proporcionado
    SELECT COUNT(*) INTO v_linea_count
    FROM Lineas
    WHERE cod_linea = p_cod_linea;

    -- Si no se encuentra la línea con ese ID, lanzar un error
    IF v_linea_count = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No se encontró una línea con ese identificador';
    END IF;

    -- Si la línea existe, obtener la información de la línea
    SELECT cod_linea, ruc, nombre_linea, fecha_registro
    FROM Lineas
    WHERE cod_linea = p_cod_linea;
END $$
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE IF NOT EXISTS ObtenerProductosPorLinea(
    IN p_cod_linea INT
)
BEGIN
    -- Verificar si la línea existe
    DECLARE v_linea_count INT;

    -- Contar el número de productos asociados con la línea proporcionada
    SELECT COUNT(*) INTO v_linea_count
    FROM Productos
    WHERE cod_linea = p_cod_linea;

    -- Si no se encuentran productos para esa línea, lanzar un error
    IF v_linea_count = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No se encontraron productos para esta línea';
    END IF;

    -- Si la línea existe, obtener todos los productos de esa línea
    SELECT cod_producto, nombre, descripcion, precio_compra, precio_venta, stock, estado, fecha_registro
    FROM Productos
    WHERE cod_linea = p_cod_linea
    ORDER BY nombre ASC; -- Ordenar alfabéticamente por nombre
END $$
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE IF NOT EXISTS ObtenerFacturasPorLinea(
    IN p_cod_linea INT
)
BEGIN
    -- Verificar si hay productos en la línea especificada
    DECLARE v_productos_count INT;

    -- Contar el número de productos asociados con la línea proporcionada
    SELECT COUNT(*) INTO v_productos_count
    FROM Productos
    WHERE cod_linea = p_cod_linea;

    -- Si no se encuentran productos para esa línea, lanzar un error
    IF v_productos_count = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No se encontraron productos para esta línea';
    END IF;

    -- Obtener las facturas que contienen productos de la línea especificada
    SELECT DISTINCT f.cod_factura, f.dni, f.cod_vendedor, f.cod_asesor, f.fecha_registro
    FROM Facturas f
    JOIN Detalle_Facturas df ON f.cod_factura = df.cod_factura
    JOIN Productos p ON df.cod_producto = p.cod_producto
    WHERE p.cod_linea = p_cod_linea
    ORDER BY f.fecha_registro DESC; -- Ordenar las facturas por fecha de registro, descendente
END $$
DELIMITER ;

-- PUT Lineas --
DELIMITER $$
CREATE PROCEDURE IF NOT EXISTS ActualizarNombreLinea(
    IN p_cod_linea INT,
    IN p_nuevo_nombre_linea VARCHAR(100)
)
BEGIN
    -- Declarar las variables al principio
    DECLARE v_linea_count INT;
    DECLARE v_nombre_count INT;
    DECLARE v_ruc_count INT;

    -- Verificar si la línea con el cod_linea existe
    SELECT COUNT(*) INTO v_linea_count
    FROM Lineas
    WHERE cod_linea = p_cod_linea;

    -- Si no existe la línea, lanzar un error
    IF v_linea_count = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No se encontró la línea con ese ID';
    END IF;

    -- Verificar si el nuevo nombre de la línea es único
    SELECT COUNT(*) INTO v_nombre_count
    FROM Lineas
    WHERE nombre_linea = p_nuevo_nombre_linea;

    -- Si ya existe el nombre de la línea, lanzar un error
    IF v_nombre_count > 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El nombre de la línea ya existe';
    END IF;

    -- Verificar si el RUC asociado a la línea existe
    SELECT COUNT(*) INTO v_ruc_count
    FROM Lineas l
    JOIN Proveedores p ON l.ruc = p.ruc
    WHERE l.cod_linea = p_cod_linea;

    -- Si no existe el RUC de la línea, lanzar un error
    IF v_ruc_count = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El RUC de la línea no existe en la base de datos';
    END IF;

    -- Actualizar el nombre de la línea
    UPDATE Lineas
    SET nombre_linea = p_nuevo_nombre_linea
    WHERE cod_linea = p_cod_linea;
END $$
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE IF NOT EXISTS ActualizarRucLinea(
    IN p_cod_linea INT,
    IN p_nuevo_ruc CHAR(11)
)
BEGIN
    -- Declarar todas las variables al principio
    DECLARE v_linea_count INT;
    DECLARE v_proveedor_count INT;

    -- Verificar si la línea con el cod_linea existe
    SELECT COUNT(*) INTO v_linea_count
    FROM Lineas
    WHERE cod_linea = p_cod_linea;

    -- Si no existe la línea, lanzar un error
    IF v_linea_count = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No se encontró la línea con ese ID en la base de datos';
    END IF;

    -- Verificar que el nuevo RUC no esté vacío o sea NULL
    IF p_nuevo_ruc IS NULL OR p_nuevo_ruc = '' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El RUC no puede estar vacío';
    END IF;

    -- Verificar si el nuevo RUC existe en la tabla Proveedores
    SELECT COUNT(*) INTO v_proveedor_count
    FROM Proveedores
    WHERE ruc = p_nuevo_ruc;

    -- Si el RUC no existe en la tabla Proveedores, lanzar un error
    IF v_proveedor_count = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El RUC proporcionado no existe en la base de datos';
    END IF;

    -- Actualizar el RUC de la línea
    UPDATE Lineas
    SET ruc = p_nuevo_ruc
    WHERE cod_linea = p_cod_linea;
END $$
DELIMITER ;