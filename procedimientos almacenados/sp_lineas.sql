USE FabiaNatura;

DELIMITER $$
CREATE PROCEDURE AgregarLinea(
    IN p_ruc CHAR(11),
    IN p_nombre_linea VARCHAR(100)
)
BEGIN
    IF NOT EXISTS (SELECT 1 FROM Proveedores WHERE ruc = p_ruc) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El RUC no existe en la base de datos';
    END IF;
    IF EXISTS (SELECT 1 FROM Lineas WHERE nombre_linea = p_nombre_linea) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El nombre de la línea ya existe en la base de datos';
    END IF;
    INSERT INTO Lineas (ruc, nombre_linea, fecha_registro)
    VALUES (p_ruc, p_nombre_linea, CURRENT_TIMESTAMP);
END $$
DELIMITER ;

