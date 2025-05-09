USE FabiaNatura;

-- POST Categorias --
DELIMITER $$
CREATE PROCEDURE IF NOT EXISTS AgregarCategoria(
    IN p_nombre_categoria VARCHAR(50),
    IN p_descripcion TEXT
)
BEGIN
    -- Validar que el nombre de la categoría no exista
    DECLARE v_categoria_count INT;

    -- Validar que el nombre de la categoría no esté vacío
    IF p_nombre_categoria IS NULL OR p_nombre_categoria = '' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El nombre de la categoría no puede estar vacío';
    END IF;

    SELECT COUNT(*) INTO v_categoria_count
    FROM Categorias
    WHERE nombre = p_nombre_categoria;

    -- Si ya existe una categoría con el mismo nombre, lanzar un error
    IF v_categoria_count > 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Ya existe una categoría con ese nombre';
    END IF;

    -- Insertar la nueva categoría en la tabla Categorias
    INSERT INTO Categorias (nombre, descripcion)
    VALUES (p_nombre_categoria, p_descripcion);
END $$
DELIMITER ;

-- GET Categorias --
DELIMITER $$
CREATE PROCEDURE IF NOT EXISTS ObtenerTodasLasCategorias()
BEGIN
    -- Verificar si existen categorías en la tabla Categorias
    DECLARE v_categorias_count INT;

    SELECT COUNT(*) INTO v_categorias_count
    FROM Categorias;

    -- Si no existen categorías, lanzar un error
    IF v_categorias_count = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No existen categorías en la base de datos';
    END IF;

    -- Si existen categorías, obtener la lista de todas las categorías
    SELECT cod_categoria, nombre, descripcion
    FROM Categorias;
END $$
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE IF NOT EXISTS ObtenerCategoriaPorId(
    IN p_cod_categoria INT  -- ID de la categoría que se quiere obtener
)
BEGIN
    -- Verificar si existe la categoría con el ID proporcionado
    DECLARE v_categoria_count INT;

    SELECT COUNT(*) INTO v_categoria_count
    FROM Categorias
    WHERE cod_categoria = p_cod_categoria;

    -- Si no existe la categoría, lanzar un error
    IF v_categoria_count = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No se encontró una categoría con ese ID';
    END IF;

    -- Si existe la categoría, obtener la información de la categoría
    SELECT cod_categoria, nombre, descripcion
    FROM Categorias
    WHERE cod_categoria = p_cod_categoria;

END $$
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE IF NOT EXISTS ObtenerProductosPorCategoria(
    IN p_cod_categoria INT
)
BEGIN
    -- Verificar si la categoría con el cod_categoria existe
    -- Verificar si existen productos en la categoría especificada
    DECLARE v_categoria_count INT;
    DECLARE v_productos_count INT;

    -- Verificar si la categoría con el cod_categoria existe
    SELECT COUNT(*) INTO v_categoria_count
    FROM Categorias
    WHERE cod_categoria = p_cod_categoria;

    -- Si no existe la categoría, lanzar un error
    IF v_categoria_count = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error: No se encontró una categoría con ese ID';
    END IF;

    -- Verificar si existen productos en la categoría especificada
    SELECT COUNT(*) INTO v_productos_count
    FROM Productos
    WHERE cod_categoria = p_cod_categoria;

    -- Si no hay productos en la categoría, lanzar un error
    IF v_productos_count = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error: No existen productos en esta categoría';
    END IF;

    -- Obtener todos los productos de la categoría especificada
    SELECT p.cod_producto, p.nombre, p.descripcion, p.precio_venta, p.stock
    FROM Productos p
    WHERE p.cod_categoria = p_cod_categoria;
END $$
DELIMITER ;

-- PUT Categorias --
DELIMITER $$
CREATE PROCEDURE IF NOT EXISTS ActualizarCategoria(
    IN p_cod_categoria INT,
    IN p_nuevo_nombre_categoria VARCHAR(50),  
    IN p_nueva_descripcion TEXT        
)
BEGIN
    -- Verificar si la categoría con el cod_categoria existe
    DECLARE v_categoria_count INT;

    -- Validar que el nuevo nombre de la categoría no esté vacío ni sea NULL
    IF p_nuevo_nombre_categoria IS NULL OR p_nuevo_nombre_categoria = '' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El nombre de la categoría no puede estar vacío';
    END IF;

    SELECT COUNT(*) INTO v_categoria_count
    FROM Categorias
    WHERE cod_categoria = p_cod_categoria;

    -- Si no existe la categoría, lanzar un error
    IF v_categoria_count = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No se encontró una categoría con ese ID';
    END IF;

    -- Actualizar el nombre y la descripción de la categoría
    UPDATE Categorias
    SET nombre = p_nuevo_nombre_categoria,
        descripcion = p_nueva_descripcion
    WHERE cod_categoria = p_cod_categoria;
END $$
DELIMITER ;