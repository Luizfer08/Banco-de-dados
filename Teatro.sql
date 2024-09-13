create schema teatro;

use teatro;

create table pecas_teatro(
id_peca integer primary key, 
nome_peca varchar(100),
descricao varchar(100),
duracao integer,
autor varchar(100),
dia date
);

INSERT INTO
pecas_teatro (
id_peca,
nome_peca,
descricao,
duracao,
autor,
dia
  )
VALUES
  (
    1,
    'Hamlet',
    'Tragedia de Shakespeare',
    180,
    'William Shakespeare',
    '2024-06-10'
  ),
  (
    2,
    'O Fantasma da Ópera',
    'Musical de Andrew Lloyd Webber',
    160,
    'Gastono',
    '2024-06-11'
  ),
  (
    3,
    'A Gaivota',
    'Drama de Anton',
    120,
    'Antonio',
    '2024-06-12'
  ),
  (
    4,
    'Esperando Godot',
    'Samuel Beckett',
    140,
    'Samuel',
    '2024-06-13'
  ),
  (
    5,
    'A Casa de Bernarda Alba',
    'Drama de Federico',
    130,
    'Federicoa',
    '2024-06-14'
  );

delimiter $$

CREATE FUNCTION calcular_media_duracao(p_id_peca integer)
returns float begin declare
    media_duracao FLOAT;
    SELECT AVG(duracao) INTO media_duracao
    FROM teatro
    WHERE id_peca = p_id_peca;
    
    RETURN media_duracao;
END; $$

delimiter //

delimiter $$

CREATE FUNCTION verificar_disponibilidade(data_hora time)
RETURNS BOOLEAN begin declare 
    disponibilidade boolean;
if exists(
select 1 from pecas_teatro 
where data_peca = date(data_hora))
then set disponibilidade = false;
else set disponibilidade = true;
end if;
return disponibilidade;
END; $$ 
delimiter //

delimiter $$
CREATE PROCEDURE agendar_peca(
  IN nome_peca VARCHAR(100),
  IN descricao TEXT,
  IN duracao INT,
  IN data_estreia date,
  IN diretor VARCHAR(100),
  IN elenco TEXT
)
BEGIN
  DECLARE disponibilidade BOOLEAN;
  DECLARE media_duracao FLOAT;
 
  SET disponibilidade = verificar_disponibilidade(data_estreia);
 
  IF disponibilidade THEN
 
    INSERT INTO pecas_teatro (nome_peca, descricao, duracao, data_estreia, diretor, elenco)
    VALUES (nome_peca, descricao, duracao, data_estreia, diretor, elenco);
 
    SET media_duracao = (SELECT AVG(duracao) FROM pecas_teatro);
    SELECT
      nome_peca AS Nome,
      descricao AS Descricao,
      duracao AS Duracao,
      data_estreia AS data_Estreia,
      diretor AS Diretor,
      elenco AS Elenco,
      media_duracao AS Media_Duracao
    FROM
      pecas_teatro
    WHERE
      id_peca = LAST_INSERT_ID();
  ELSE
    SIGNAL SQLSTATE '50000' SET MESSAGE_TEXT = 'Data não disponível.';
  END IF;
END;$$
 
DELIMITER //

INSERT INTO
  pecas_teatro (
    id_peca,
    nome_peca,
    descricao,
    duracao,
    autor,
    dia
  )
VALUES
  (
    16,
    'Romeu e Julieta',
    'Tragédia de Shakespeare',
    150,
    'William Shakespeare',
    '2024-06-15'
  ),
  (
    17,
    'O Rei Leão',
    'Musical da Broadway',
    130,
    'Elton John',
    '2024-06-16'
  ),
  (
    18,
    'Les Misérables',
    'Musical baseado no romance de Victor Hugo',
    180,
    'Victor Hugo',
    '2024-06-17'
  );

CALL agendar_peca (
  'A Morte de um Caixeiro Viajante',
  'Drama de Arthur Miller',
  135,
  '2024-06-25',
  'Arthur Miller',
  'Elenco Fictício'
);

SELECT
  *
FROM
  pecas_teatro;

