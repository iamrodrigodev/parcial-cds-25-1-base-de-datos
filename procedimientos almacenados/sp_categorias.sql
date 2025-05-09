USE FabiaNatura;
-- Stored Procedures for Categorias Management

DELIMITER $$

-- Insertar una nueva categoria
CREATE PROCEDURE IF NOT EXISTS sp_insertar_categoria(
    IN p_nombre VARCHAR(50),
    IN p_descripcion TEXT
)
BEGIN
    -- Validate input parameters
    IF p_nombre IS NULL OR p_nombre = '' THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'Error: El nombre de la categoría no puede ser nulo o vacío';
    END IF;

    -- Use empty string if description is NULL
    IF p_descripcion IS NULL THEN
        SET p_descripcion = '';
    END IF;

    -- Check if categoria already exists (case-sensitive)
    IF EXISTS (SELECT 1 FROM Categorias WHERE nombre = p_nombre) THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'Error: Ya existe una categoría con este nombre';
    END IF;

    -- Insert new categoria
    INSERT INTO Categorias (nombre, descripcion)
    VALUES (p_nombre, p_descripcion);
    
    SELECT LAST_INSERT_ID() AS cod_categoria;
END $$

-- Listar todas las categorias
CREATE PROCEDURE IF NOT EXISTS sp_listar_categorias()
BEGIN
    DECLARE v_total_categorias INT;

    -- Count total number of categorias
    SELECT COUNT(*) INTO v_total_categorias FROM Categorias;

    -- Check if no categorias exist
    IF v_total_categorias = 0 THEN
        SIGNAL SQLSTATE '02000'
        SET MESSAGE_TEXT = 'Información: No hay categorías registradas en el sistema';
    END IF;

    -- List all categorias
    SELECT 
        *, 
        v_total_categorias AS total_categorias 
    FROM Categorias 
    ORDER BY nombre;
END $$

-- Obtener una categoria por su ID específico
CREATE PROCEDURE IF NOT EXISTS sp_obtener_categoria_por_id(
    IN p_cod_categoria INT
)
BEGIN
    -- Validate input parameter
    IF p_cod_categoria IS NULL OR p_cod_categoria <= 0 THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'Error: Código de categoría inválido';
    END IF;

    -- Check if categoria exists
    IF NOT EXISTS (SELECT 1 FROM Categorias WHERE cod_categoria = p_cod_categoria) THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'Error: La categoría especificada no existe';
    END IF;

    -- Retrieve categoria details
    SELECT * FROM Categorias 
    WHERE cod_categoria = p_cod_categoria;
END $$

-- Mostrar todos los productos de una categoría específica
CREATE PROCEDURE IF NOT EXISTS sp_listar_productos_por_categoria(
    IN p_cod_categoria INT
)
BEGIN
    DECLARE v_nombre_categoria VARCHAR(50);

    -- Validate input parameter
    IF p_cod_categoria IS NULL OR p_cod_categoria <= 0 THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'Error: Código de categoría inválido';
    END IF;

    -- Check if categoria exists and get categoria name
    SELECT nombre  INTO v_nombre_categoria 
    FROM Categorias 
    WHERE cod_categoria = p_cod_categoria;

    -- Check if categoria exists (will raise an error if not found)
    IF v_nombre_categoria IS NULL THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'Error: La categoría especificada no existe';
    END IF;

    -- Check if any products exist for this categoria
    IF NOT EXISTS (SELECT 1 FROM Productos WHERE cod_categoria = p_cod_categoria) THEN
        SIGNAL SQLSTATE '02000' 
        SET MESSAGE_TEXT = 'Información: No hay productos asignados a esta categoría';
    END IF;

    SELECT 
        p.cod_producto,
        p.nombre_producto,
        p.descripcion,
        p.precio,
        p.stock,
        c.nombre
    FROM 
        Productos p
    JOIN 
        Categorias c ON p.cod_categoria = c.cod_categoria
    WHERE 
        p.cod_categoria = p_cod_categoria;
END $$

-- Actualizar una categoria existente
CREATE PROCEDURE IF NOT EXISTS sp_actualizar_categoria(
    IN p_cod_categoria INT,
    IN p_nombre VARCHAR(50),
    IN p_descripcion TEXT
)
BEGIN
    -- Validate input parameters
    IF p_cod_categoria IS NULL OR p_cod_categoria <= 0 THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'Error: Código de categoría inválido';
    END IF;

    IF p_nombre IS NULL OR p_nombre = '' THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'Error: El nombre de la categoría no puede ser nulo o vacío';
    END IF;

    -- Use empty string if description is NULL
    IF p_descripcion IS NULL THEN
        SET p_descripcion = '';
    END IF;

    -- Check if categoria exists
    IF NOT EXISTS (SELECT 1 FROM Categorias WHERE cod_categoria = p_cod_categoria) THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'Error: La categoría especificada no existe';
    END IF;

    -- Check if new categoria name conflicts (case-sensitive)
    IF EXISTS (SELECT 1 FROM Categorias 
               WHERE nombre = p_nombre AND cod_categoria != p_cod_categoria) THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'Error: Ya existe otra categoría con este nombre';
    END IF;

    UPDATE Categorias 
    SET nombre = p_nombre, 
        descripcion = p_descripcion
    WHERE cod_categoria = p_cod_categoria;
    
    SELECT ROW_COUNT() AS filas_actualizadas;
END $$

DELIMITER ;
