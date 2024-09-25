CREATE TABLE Donos (
  DonoID INT PRIMARY KEY,
  Nome VARCHAR(100),
  Endereco VARCHAR(255),
  Telefone VARCHAR(15)
);

CREATE TABLE Medicamentos (
  MedicaID INT PRIMARY KEY,
  MedicaName VARCHAR(100),
  Description TEXT,
  custo DECIMAL(10, 2)
);

create table tratamentos (
  id_tratamento int primary key auto_increment,
  descricao varchar(255),
  custo DECIMAL(10, 2)
);

delimiter $$
create trigger verificar_custo_medicamento before insert on medicamentos
for each row
begin
  if new.custo < 0 then
    signal sqlstate '45000' set message_text = 'O custo do medicamento deve ser positivo.';
  end if;
end; $$
delimiter //

delimiter $$
create trigger verificar_custo_tratamento before insert on tratamentos
for each row
begin
  if new.custo < 0 then
    signal sqlstate '45000' set message_text = 'O custo do tratamento deve ser positivo.';
  end if;
end; $$
delimiter //

delimiter $$
create trigger logar_alteracao_custo_medicamento after update on Medicamentos
for each row
begin
  if old.custo <> new.custo then
    insert into Log_consultas(id_consulta, custo_antigo, custo_novo)
    values(new.MedicaID, old.custo, new.custo);
  end if;
end; $$
delimiter //

delimiter $$
create trigger logar_alteracao_custo_tratamento after update on tratamentos
for each row
begin
  if old.custo <> new.custo then
    insert into Log_consultas(id_consulta, custo_antigo, custo_novo)
    values(new.id_tratamento, old.custo, new.custo);
  end if;
end; $$
delimiter //


delimiter $$
create trigger atualizar_custo_medicamento after
update on Medicamentos for each row 
begin 
  if old.custo <> new.custo then
    insert into Log_medicamentos(MedicaID, custo_antigo, custo_novo)
    values(new.MedicaID, old.custo, new.custo);
  end if;
end; $$
delimiter //


DELIMITER $$
CREATE PROCEDURE adicionar_dono (
  IN p_nome VARCHAR(100),
  IN p_endereco VARCHAR(255),
  IN p_telefone VARCHAR(15)
)
BEGIN
  INSERT INTO Donos (Nome, Endereco, Telefone)
  VALUES (p_nome, p_endereco, p_telefone);
END; $$
DELIMITER //

DELIMITER $$
CREATE PROCEDURE adicionar_medicamento (
  IN p_medica_name VARCHAR(100),
  IN p_description TEXT,
  IN p_custo DECIMAL(10, 2)
)
BEGIN
  INSERT INTO Medicamentos (MedicaName, Description, custo)
  VALUES (p_medica_name, p_description, p_custo);
END; $$
DELIMITER //

DELIMITER $$
CREATE PROCEDURE adicionar_tratamento (
  IN p_descricao VARCHAR(255),
  IN p_custo DECIMAL(10, 2)
)
BEGIN
  INSERT INTO tratamentos (descricao, custo)
  VALUES (p_descricao, p_custo);
END; $$
DELIMITER //

DELIMITER $$
CREATE PROCEDURE atualizar_dono (
  IN p_dono_id INT,
  IN p_novo_nome VARCHAR(100),
  IN p_novo_endereco VARCHAR(255),
  IN p_novo_telefone VARCHAR(15)
)
BEGIN
  UPDATE Donos
  SET Nome = p_novo_nome, Endereco = p_novo_endereco, Telefone = p_novo_telefone
  WHERE DonoID = p_dono_id;
END; $$
DELIMITER //

DELIMITER $$
CREATE PROCEDURE remover_medicamento (
  IN p_medica_id INT
)
BEGIN
  DELETE FROM Medicamentos
  WHERE MedicaID = p_medica_id;
END; $$
DELIMITER //
