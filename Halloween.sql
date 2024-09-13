create schema Halloween;

use halloween;

create table usuarios(
nome varchar(100),
email varchar(100),
idade int
);

DELIMITER $$
CREATE PROCEDURE InsereUsuariosAleatorios()
BEGIN
    DECLARE i INT DEFAULT 0;
    WHILE i < 10000 DO
        SET @nome := CONCAT('Usuario', i);
        SET @email := CONCAT('usuario', i, '@exemplo.com');
        SET @idade := FLOOR(RAND() * 80) + 18;  
        INSERT INTO usuarios (nome, email, idade) VALUES (@nome, @email, @idade);
        SET i = i + 1;
    END WHILE;
END$$ 
DELIMITER ;

call halloween.InsereUsuariosAleatorios();





