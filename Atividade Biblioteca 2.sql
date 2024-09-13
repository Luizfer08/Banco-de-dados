create schema biblioteca;
 
use biblioteca;
 
create table autor (
id integer primary key,
nome varchar(50),
sobrenome varchar(50));
 
create table livro (
id integer primary key,
titulo varchar (100),
ISBN integer,
ano_publicacao integer,
constraint id_autor foreign key (id) references autor(id)
);
 
create table usuario (
id integer primary key,
nome varchar (100),
situacao boolean ,
dt_cod date
);
 
create table reserva (
id integer primary key,
constraint id_livro foreign key (id) references livro(id),
constraint id_usuario foreign key (id) references usuario(id),
dt_reserva date,
dt_devolucao date,
situacao varchar (50)
);
 
create table devolucoes (
id int auto_increment primary key,
id_livro int,
id_usuario int,
data_devolucao date,
data_devolucao_esperada date,
foreign key (id_livro) references livro(id),
foreign key (id_usuario) references usuario(id)
);
 
create table multas (
id int auto_increment primary key,
id_usuario int,
valor_multa decimal (10, 2),
data_multa date,
foreign key (id_usuario) references usuario(id)
);
 
delimiter $$
 
create trigger trigger_VerificarAtrasos
before insert on devolucoes
for each row 
begin
	declare atraso int;
    set atraso = datediff(new.data_devolucao_esperada,
    new.data_devolucao);
    if atraso > 0 then
    insert into mensagens (destinatario, assunto, corpo)
    values ('Bibliotecário', 'Alerta de Atraso', concat('O Livro com ID',
    new.id_livro,'não foi devolvido na data de devolução esperada.'));
    end if;
    end;$$ 
    delimiter //
    
 
create table mensagens ( 
id int auto_increment primary key,
destinatario varchar(225) not null,
assunto varchar(225) not null, 
corpo text, 
data_envio datetime default 
current_timestamp);

use biblioteca;

delimiter $$
create trigger trigger_gerar_multa2 after insert on devolucoes for each row
begin
	declare atraso int;
    declare valor_multa decimal (10, 2);
    set atraso = datediff(new.data_devolucao_esperada, new.data_devolucao);
	if atraso > 0 then 
		set valor_multa = atraso * 2.00;
		insert into multas (id_usuario, valor_multa, data_multa)
		values (new.id_usuario, valor_multa, now());
	end if;
end;$$
delimiter //

create table emprestimo (
id int auto_increment primary key,
status_livro varchar (20),
id_livro int,
id_usuario int,
foreign key (id_livro) references livro(id),
foreign key (id_usuario) references usuario(id)
);

delimiter $$
create trigger trigger_atualizar_status_emprestado after insert on emprestimo for each row 
begin
	update livro 
    set status_livro = "Emprestado"
    where id = new.id_livro;
end;$$
delimiter //

delimiter $$
create trigger trigger_atualizar_total_exemplares after insert on livro for each row
begin
	update livro 
    set total_exemplares = total_exemplares + 1
    where id = new.id;
    end;$$
delimiter // 

create table livros_atualizados(
id int auto_increment primary key,
id_livro int not null,
titulo varchar (100) not null,
autor varchar (100) not null,
data_atualizacao datetime default current_timestamp,
foreign key (id_livro) references livro(id)
);

create table autor_livro(
id_livro int,
id_autor int,
foreign key (id_livro) references livro(id),
foreign key (id_autor) references autor(id)
);

delimiter //
create trigger trigger_registrar_atualizacao_livro after update on livro for each row
begin 
 
insert into livros_atualizados (id_livro, titulo, autor, data_atualizacao)

values( old.id, old.titulo,  now());

end;
//
delimiter ;

delimiter //
create trigger trigger_registrar_exclusao_livro after delete on livro for each row
begin
 
insert into livros_excluidos (id_livro, titulo, autor, data_exclusao)

values( old.id, old.titulo,now());

end;

delimiter $$

CREATE PROCEDURE adicionar_livro(
    IN p_titulo VARCHAR(50),
    IN p_ISBN integer,
    IN p_ano_publicacao integer,
    IN p_autor_id integer
)
BEGIN
    INSERT INTO livro(titulo, ISBN, ano_publicacao, id_autor)
    VALUES (p_titulo, p_ISBN, p_ano_publicacao, p_autor_id);
END; $$

delimiter ;


delimiter $$

CREATE PROCEDURE remover_livro(
    IN p_id INT
)
BEGIN
    DELETE FROM livro WHERE id = p_id;
END; $$

delimiter ;

delimiter $$

CREATE PROCEDURE adicionar_reserva(
    IN p_id_livro INT,
    IN p_id_usuario INT,
    IN p_dt_reserva DATE,
    IN p_dt_devolucao DATE,
    IN p_situacao VARCHAR(50)
)
BEGIN
    INSERT INTO reserva (id_livro, id_usuario, dt_reserva, dt_devolucao, situacao)
    VALUES (p_id_livro, p_id_usuario, p_dt_reserva, p_dt_devolucao, p_situacao);
END; $$

delimiter ;

delimiter $$

CREATE PROCEDURE cancelar_reserva(
    IN p_id INT
)
BEGIN
    DELETE FROM reserva WHERE id = p_id;
END; $$

delimiter ;

delimiter $$

CREATE FUNCTION verificar_status_livro(
    p_id INT
) RETURNS VARCHAR(20)
BEGIN
    DECLARE p_status VARCHAR(20);

    SELECT status_livro INTO p_status
    FROM livro
    WHERE id = p_id;

    RETURN p_status;
END; $$

delimiter ;

delimiter $$

CREATE FUNCTION calcular_valor_multa_usuario(
    p_id_usuario INT
) RETURNS DECIMAL(10,2)
BEGIN
    DECLARE p_valor DECIMAL(10,2);

    SELECT SUM(valor_multa) INTO p_valor
    FROM multas
    WHERE id_usuario = p_id_usuario;

    RETURN IFNULL(p_valor, 0);
END; $$

delimiter ;

delimiter $$

CREATE PROCEDURE adicionar_autor(
    IN p_nome VARCHAR(50),
    IN p_sobrenome VARCHAR(50)
)
BEGIN
    INSERT INTO autor (nome, sobrenome)
    VALUES (p_nome, p_sobrenome);
END; $$

delimiter ;
