# INSTRUCOES PARA EXECUCAO
# Vá para o diretorio onde o arquivo teste3.sql está localizado através do prompt com o comando cd
# Inicie o MySQL: mysql --local-infile=1 -u root -p
# --local-infile=1 serve para habilitar acesso ao LOCAL
# ADICIONAL: set global local_infile=true;

CREATE DATABASE ans_data;
USE ans_data;

select registro_ans from dados_operadoras;

## 3.3 Criando tabelas para os arquivos csv
# Tabela para Relatorio_cadop.csv
CREATE TABLE dados_operadoras (
registro_ans INT PRIMARY KEY,
cnpj BIGINT,
razao_social VARCHAR(255),
nome_fantasia VARCHAR(255),
modalidade VARCHAR(255),
logradouro VARCHAR(255),
numero VARCHAR(255),
complemento VARCHAR(255),
bairro VARCHAR(255),
cidade VARCHAR(255),
uf VARCHAR(10),
cep BIGINT,
ddd INTEGER,
telefone BIGINT,
fax BIGINT,
endereco_eletronico VARCHAR(255),
representante VARCHAR(255),
cargo_representante VARCHAR(100),
regiao_de_comercializacao INTEGER,
data_registro_ans DATE);

# Tabela para os dados contabeis dos 2 últimos anos
CREATE TABLE dados_contabeis (
`data` DATE,
reg_ans INT,
cd_conta_contabil BIGINT,
descricao TEXT,
vl_saldo_inicial DOUBLE,
vl_saldo_final DOUBLE
);

## 3.4 Importando o conteúdo dos arquivos
# dados de Relatorio_cadop.csv
LOAD DATA LOCAL INFILE 'Relatorio_cadop.csv'
INTO TABLE dados_operadoras
CHARACTER SET UTF8MB4
FIELDS TERMINATED BY ';'
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(registro_ans, cnpj, razao_social, nome_fantasia, modalidade, logradouro, numero, complemento, bairro, cidade, uf, cep, @ddd, @telefone, @fax, endereco_eletronico, representante, cargo_representante, @regiao_de_comercializacao, data_registro_ans)
SET 
	ddd = NULLIF(@ddd, ""),
    telefone = NULLIF(@telefone, ""),
    fax = NULLIF(@fax, ""),
    regiao_de_comercializacao = NULLIF(@regiao_de_comercializacao, "");

# dados de 2024 1T2024.csv
LOAD DATA LOCAL INFILE './2024/1T2024.csv'
INTO TABLE dados_contabeis
CHARACTER SET UTF8MB4
FIELDS TERMINATED BY ';'
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(data, reg_ans, cd_conta_contabil, descricao, @vl_saldo_inicial, @vl_saldo_final)
SET vl_saldo_inicial = REPLACE(@vl_saldo_inicial, ',', '.'), vl_saldo_final = REPLACE(@vl_saldo_final, ',', '.');

# dados de 2024 2T2024.csv
LOAD DATA LOCAL INFILE './2024/2T2024.csv'
INTO TABLE dados_contabeis
CHARACTER SET UTF8MB4
FIELDS TERMINATED BY ';'
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(data, reg_ans, cd_conta_contabil, descricao, @vl_saldo_inicial, @vl_saldo_final)
SET vl_saldo_inicial = REPLACE(@vl_saldo_inicial, ',', '.'), vl_saldo_final = REPLACE(@vl_saldo_final, ',', '.');

# dados de 2024 3T2024.csv
LOAD DATA LOCAL INFILE './2024/3T2024.csv'
INTO TABLE dados_contabeis
CHARACTER SET UTF8MB4
FIELDS TERMINATED BY ';'
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(data, reg_ans, cd_conta_contabil, descricao, @vl_saldo_inicial, @vl_saldo_final)
SET vl_saldo_inicial = REPLACE(@vl_saldo_inicial, ',', '.'), vl_saldo_final = REPLACE(@vl_saldo_final, ',', '.');

# dados de 2023 1T2024.csv
LOAD DATA LOCAL INFILE './2023/1T2023.csv'
INTO TABLE dados_contabeis
CHARACTER SET UTF8MB4
FIELDS TERMINATED BY ';'
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(data, reg_ans, cd_conta_contabil, descricao, @vl_saldo_inicial, @vl_saldo_final)
SET vl_saldo_inicial = REPLACE(@vl_saldo_inicial, ',', '.'), vl_saldo_final = REPLACE(@vl_saldo_final, ',', '.');

# dados de 2023 2t2024.csv
LOAD DATA LOCAL INFILE './2023/2t2023.csv'
INTO TABLE dados_contabeis
CHARACTER SET UTF8MB4
FIELDS TERMINATED BY ';'
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(data, reg_ans, cd_conta_contabil, descricao, @vl_saldo_inicial, @vl_saldo_final)
SET vl_saldo_inicial = REPLACE(@vl_saldo_inicial, ',', '.'), vl_saldo_final = REPLACE(@vl_saldo_final, ',', '.');

# dados de 2023 3T2024.csv
LOAD DATA LOCAL INFILE './2023/3T2023.csv'
INTO TABLE dados_contabeis
CHARACTER SET UTF8MB4
FIELDS TERMINATED BY ';'
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(data, reg_ans, cd_conta_contabil, descricao, @vl_saldo_inicial, @vl_saldo_final)
SET vl_saldo_inicial = REPLACE(@vl_saldo_inicial, ',', '.'), vl_saldo_final = REPLACE(@vl_saldo_final, ',', '.');

# dados de 2023 4T2024.csv
LOAD DATA LOCAL INFILE './2023/4T2023.csv'
INTO TABLE dados_contabeis
CHARACTER SET UTF8MB4
FIELDS TERMINATED BY ';'
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(@data, reg_ans, cd_conta_contabil, descricao, @vl_saldo_inicial, @vl_saldo_final)
SET 
	data = STR_TO_DATE(@data, '%d/%m/%Y'),
	vl_saldo_inicial = REPLACE(@vl_saldo_inicial, ',', '.'),
    vl_saldo_final = REPLACE(@vl_saldo_final, ',', '.');

## 3.5 Queries analítica
# Quais as 10 operadoras com maiores despesas em "EVENTOS/ SINISTROS CONHECIDOS OU AVISADOS DE ASSISTÊNCIA A SAÚDE MEDICO HOSPITALAR" no último trimestre?
CREATE VIEW operadoras_maiores_despesas_tri AS
SELECT dados_operadoras.*, descricao, ROUND(SUM(vl_saldo_final) - SUM(vl_saldo_inicial), 2) AS despesas
FROM dados_contabeis
INNER JOIN dados_operadoras ON dados_operadoras.registro_ans = dados_contabeis.reg_ans
WHERE dados_contabeis.descricao = "EVENTOS/ SINISTROS CONHECIDOS OU AVISADOS  DE ASSISTÊNCIA A SAÚDE MEDICO HOSPITALAR "
AND `data` >= '2024-07-01'
GROUP BY reg_ans
ORDER BY despesas DESC
LIMIT 10;

# Quais as 10 operadoras com maiores despesas nessa categoria no último ano?
CREATE VIEW operadoras_maiores_despesas_ano AS
SELECT dados_operadoras.*, descricao, ROUND(SUM(vl_saldo_final) - SUM(vl_saldo_inicial), 2) AS despesas
FROM dados_contabeis
INNER JOIN dados_operadoras ON dados_operadoras.registro_ans = dados_contabeis.reg_ans
WHERE dados_contabeis.descricao = "EVENTOS/ SINISTROS CONHECIDOS OU AVISADOS  DE ASSISTÊNCIA A SAÚDE MEDICO HOSPITALAR "
AND `data` >= '2024-01-01'
GROUP BY reg_ans
ORDER BY despesas DESC
LIMIT 10;

# SELECT * FROM dados_contabeis;
# SELECT * FROM dados_operadoras;