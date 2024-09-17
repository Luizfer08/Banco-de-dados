create schema clinica_veterinaria;

use clinica_veterinaria;

create table pacientes(
id_paciente int primary key auto_increment,
nome varchar(100),
idade int
);

create table Veterinarios(
id_veterinarios int primary key auto_increment,
nome varchar(100),
especialidade varchar(100)
);

create table consultas (
  id_consulta int primary key auto_increment,
  id_paciente int,
  id_veterinarios int,
  data_consulta date,
  custo DECIMAL(10, 2),
  FOREIGN KEY (id_paciente) REFERENCES pacientes (id_paciente),
  FOREIGN KEY (id_veterinarios) REFERENCES Veterinarios (id_veterinarios)
);

DELIMITER $$
CREATE PROCEDURE agendar_consulta (
IN p_id_paciente INT,
IN p_id_veterinario INT,
IN p_data_consulta DATE,
IN p_custo DECIMAL(10, 2)
)BEGIN
INSERT INTO
consultas(
id_paciente,
id_veterinarios,
data_consulta,
custo
)
VALUES(
p_id_paciente,
p_id_veterinario,
p_data_consulta,
p_custo
);
END; $$
 DELIMITER //
 
 
 DELIMITER $$ 
 CREATE PROCEDURE atualizar_paciente (
  IN p_id_paciente INT,
  IN p_novo_nome VARCHAR(100),
  IN p_nova_especie VARCHAR(50),
  IN p_nova_idade INT
) BEGIN
UPDATE pacientes
SET
  nome = p_novo_nome,
  especie = p_nova_especie,
  idade = p_nova_idade
WHERE
  id_paciente = p_id_paciente;
END; $$
 DELIMITER //
 
 delimiter $$
 create procedure remover_consulta(
  in id_consulta int
 ) begin delete from consultas 
 where id_consulta = consulta_id;
 end; $$
 delimiter //
 
 delimiter $$
 create function total_gasto_paciente(
 p_id_paciente int) returns decimal(10,2)
 deterministic begin declare total_gasto
 decimal (10,2);
 select
  sum(custo) into total_gasto
  from
  consultas
  where
  id_paciente = p_id_paciente;
  return ifnull (total_gasto, 0);
  end; $$
  delimiter //

delimiter $$
create trigger verificar_idade_paciente before
insert on pacientes for each row 
begin if new.idade < 0 
then signal sqlstate '45000'
set message_text = 'Idade do paciente deve ser positiva.';
end if;
end; $$
delimiter //

create table Log_consultas(
id_log int primary key auto_increment,
id_consulta int,
custo_antigo decimal(10,2),
custo_novo decimal(10,2)
);

delimiter $$
create trigger atulizar_custo_consulta after
update on consultas for each row 
begin if old.custo <> new.custo then
insert into
Log_consultas(id_consulta, custo_antigo, custo_novo)
values(new.id_consulta, old.custo, new.custo);
end if;
end; $$
delimiter //



