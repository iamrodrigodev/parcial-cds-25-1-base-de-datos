USE FabiaNatura;

DELIMITER $$
CREATE PROCEDURE IF NOT EXISTS VerificarPersonaPorDni(
    IN p_dni CHAR(8)
)
BEGIN
    DECLARE v_persona_count INT;

    SELECT COUNT(*) INTO v_persona_count
    FROM Personas
    WHERE dni = p_dni;

    IF v_persona_count > 0 THEN
        SELECT 1 AS existe;
    ELSE
        SELECT 0 AS existe;
    END IF;
END $$
DELIMITER ;