-- CRIAÇÃO DO BANCO
CREATE DATABASE ProjetoBD;
USE ProjetoBD;

-- TABELAS

CREATE TABLE Produto (
    codProduto INT NOT NULL PRIMARY KEY,
    nome VARCHAR(100),
    unidade VARCHAR(10),
    descricao TEXT
);

CREATE TABLE Fornecedor (
    Cnpj CHAR(14) PRIMARY KEY,
    nome VARCHAR(100)
);

CREATE TABLE Entrada (
    idEntrada INT PRIMARY KEY,
    data DATE,
    quantidade INT,
    valor DECIMAL(10,2),
    codProduto INT,
    Cnpj CHAR(14),
    FOREIGN KEY (codProduto) REFERENCES Produto(codProduto),
    FOREIGN KEY (Cnpj) REFERENCES Fornecedor(Cnpj)
);

CREATE TABLE Lote (
    codLote INT PRIMARY KEY,
    dataFabricacao DATE,
    dataValidade DATE,
    quantidade INT
);

CREATE TABLE Pertence_Lote_Produto (
    codLote INT,
    codProduto INT,
    PRIMARY KEY (codLote, codProduto),
    FOREIGN KEY (codLote) REFERENCES Lote(codLote),
    FOREIGN KEY (codProduto) REFERENCES Produto(codProduto)
);

CREATE TABLE Saida (
    idSaida INT PRIMARY KEY,
    quantidade INT,
    valor DECIMAL(10,2),
    codProduto INT,
    FOREIGN KEY (codProduto) REFERENCES Produto(codProduto)
);

CREATE TABLE Venda (
    numeroVenda INT PRIMARY KEY,
    tipoPagamento ENUM('pix', 'dinheiro', 'cartao'),
    desconto DECIMAL(10,2),
    dataVenda DATE,
    valorTotal DECIMAL(10,2),
    usoInterno BOOLEAN
);

CREATE TABLE Saida_Venda (
    numeroVenda INT,
    idSaida INT,
    PRIMARY KEY (numeroVenda, idSaida),
    FOREIGN KEY (numeroVenda) REFERENCES Venda(numeroVenda),
    FOREIGN KEY (idSaida) REFERENCES Saida(idSaida)
);

CREATE TABLE Cliente (
    codCliente INT PRIMARY KEY,
    nome VARCHAR(100),
    email VARCHAR(100),
    tipo ENUM('F', 'J')
);

CREATE TABLE Telefone (
    idTelefone INT PRIMARY KEY,
    codCliente INT,
    telefone VARCHAR(20),
    FOREIGN KEY (codCliente) REFERENCES Cliente(codCliente)
);

CREATE TABLE Fisica (
    codCliente INT PRIMARY KEY,
    Cpf CHAR(14),
    FOREIGN KEY (codCliente) REFERENCES Cliente(codCliente)
);

CREATE TABLE Juridica (
    codCliente INT PRIMARY KEY,
    Cnpj VARCHAR(18),
    razaoSocial VARCHAR(100),
    FOREIGN KEY (codCliente) REFERENCES Cliente(codCliente)
);

CREATE TABLE Venda_Cliente (
    numeroVenda INT,
    codCliente INT,
    PRIMARY KEY (numeroVenda, codCliente),
    FOREIGN KEY (numeroVenda) REFERENCES Venda(numeroVenda),
    FOREIGN KEY (codCliente) REFERENCES Cliente(codCliente)
);

-- INSERÇÕES

-- Produto
INSERT INTO Produto VALUES
(1, "Ração Premium", "kg", "Ração para peixes"),
(2, "Filtro Externo", "und", "Filtro para aquário de 60L"),
(3, "Termômetro Digital", "und", "Com sensor externo"),
(4, "Aquário 100L", "und", "Aquário de vidro"),
(5, "Sal Marinho", "kg", "Sal sintético para aquário"),
(6, "Substrato Fino", "kg", "Substrato para plantas");

-- Fornecedor
INSERT INTO Fornecedor VALUES
("12345678000199", "Pet Distribuidora"),
("98765432000155", "Aquarismo LTDA");

-- Entrada
INSERT INTO Entrada VALUES
(101, '2025-07-01', 50, 20.00, 1, "12345678000199"),
(102, '2025-07-05', 10, 200.00, 2, "98765432000155"),
(103, '2025-06-25', 100, 8.50, 5, "12345678000199"),
(104, '2025-07-10', 15, 60.00, 3, "98765432000155"),
(105, '2025-06-15', 20, 15.00, 1, "12345678000199");

-- Lote
INSERT INTO Lote VALUES
(500, '2025-05-01', '2025-08-01', 30),
(501, '2025-06-01', '2025-07-20', 50),
(502, '2025-04-10', '2025-07-25', 100);

-- Pertence_Lote_Produto
INSERT INTO Pertence_Lote_Produto VALUES
(500, 1),
(501, 5),
(502, 3);

-- Saida
INSERT INTO Saida VALUES
(201, 10, 25.00, 1),
(202, 2, 250.00, 2),
(203, 5, 10.00, 5),
(204, 1, 300.00, 4);

-- Venda
INSERT INTO Venda VALUES
(301, "pix", 0.00, '2025-07-05', 275.00, false),
(302, "cartao", 10.00, '2025-07-10', 540.00, false),
(303, "dinheiro", 5.00, '2025-01-20', 320.00, false);

-- Saida_Venda
INSERT INTO Saida_Venda VALUES
(301, 201),
(301, 203),
(302, 202),
(302, 204);

-- Cliente
INSERT INTO Cliente VALUES
(1, "João Silva", "joao@email.com", "F"),
(2, "Pet Shop do Bairro", "contato@petshop.com", "J");

-- Telefone
INSERT INTO Telefone VALUES
(1, 1, "(11)91234-5678"),
(2, 2, "(11)99876-4321");

-- Fisica
INSERT INTO Fisica VALUES
(1, "111.222.333-44");

-- Juridica
INSERT INTO Juridica VALUES
(2, "22.333.444/0001-55", "Pet Shop do Bairro");

-- Venda_Cliente
INSERT INTO Venda_Cliente VALUES
(301, 1),
(302, 2),
(303, 2);

-- Consultas

-- Top 5 produtos com maior volume de entrada no último mês e os contatos dos seus fornecedores

SELECT 
    p.nome AS produto,
    f.nome AS fornecedor,
    f.Cnpj,
    SUM(e.quantidade) AS total_recebida
FROM Entrada e
JOIN Produto p ON e.codProduto = p.codProduto
JOIN Fornecedor f ON e.Cnpj = f.Cnpj
WHERE MONTH(e.data) = MONTH(CURDATE() - INTERVAL 1 MONTH)
  AND YEAR(e.data) = YEAR(CURDATE())
GROUP BY p.codProduto, f.Cnpj
ORDER BY total_recebida DESC
LIMIT 5;

-- Faturamento por mês no ano X (substitua 2025 pelo ano desejado)

SELECT 
    MONTH(v.dataVenda) AS mes,
    SUM(v.valorTotal) AS faturamento
FROM Venda v
WHERE YEAR(v.dataVenda) = 2025
GROUP BY MONTH(v.dataVenda)
ORDER BY mes;

-- Clientes com maior volume de compras nos últimos 6 meses

SELECT 
    c.nome AS cliente,
    SUM(s.quantidade) AS total_comprada
FROM Venda v
JOIN Venda_Cliente vc ON v.numeroVenda = vc.numeroVenda
JOIN Cliente c ON vc.codCliente = c.codCliente
JOIN Saida_Venda sv ON v.numeroVenda = sv.numeroVenda
JOIN Saida s ON sv.idSaida = s.idSaida
WHERE v.dataVenda >= CURDATE() - INTERVAL 6 MONTH
GROUP BY c.codCliente
ORDER BY total_comprada DESC;

-- Produtos com validade nos próximos 30 dias

SELECT 
    p.nome AS produto,
    l.codLote,
    l.dataValidade
FROM Lote l
JOIN Pertence_Lote_Produto plp ON l.codLote = plp.codLote
JOIN Produto p ON plp.codProduto = p.codProduto
WHERE l.dataValidade BETWEEN CURDATE() AND CURDATE() + INTERVAL 30 DAY
ORDER BY l.dataValidade;

-- Produto mais vendido (por quantidade) entre duas datas específicas

SELECT 
    p.nome AS produto,
    SUM(s.quantidade) AS total_vendida
FROM Venda v
JOIN Saida_Venda sv ON v.numeroVenda = sv.numeroVenda
JOIN Saida s ON sv.idSaida = s.idSaida
JOIN Produto p ON s.codProduto = p.codProduto
WHERE v.dataVenda BETWEEN '2025-01-01' AND '2025-12-31'
GROUP BY p.codProduto
ORDER BY total_vendida DESC
LIMIT 1;



