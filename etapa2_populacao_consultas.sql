-- ============================================================================
-- ETAPA 2: POPULAÇÃO DE DADOS E CONSULTAS SQL
-- Inserção de dados de teste (mínimo 10 registros por tabela) e consultas complexas
-- ============================================================================

\c agencia_turismo;

-- ============================================================================
-- 1. POPULAÇÃO DE DADOS (DML - INSERT)
-- ============================================================================

-- 1.1 INSERÇÃO DE CLIENTES (10 registros)
-- Objetivo: Popular tabela de clientes com dados fictícios variados
INSERT INTO tb_clientes (nome_completo, cpf, data_nascimento, email, telefone, endereco, cidade, estado, cep) VALUES
('Ana Paula Silva Santos', '12345678901', '1985-03-15', 'ana.silva@email.com', '61987654321', 'QNN 12 Casa 5', 'Brasília', 'DF', '72210120'),
('Carlos Eduardo Oliveira', '23456789012', '1990-07-22', 'carlos.oliveira@email.com', '11976543210', 'Rua das Flores, 123', 'São Paulo', 'SP', '01234567'),
('Maria Fernanda Costa', '34567890123', '1988-11-30', 'maria.costa@email.com', '21965432109', 'Av. Atlântica, 456', 'Rio de Janeiro', 'RJ', '22021001'),
('João Pedro Almeida', '45678901234', '1995-01-10', 'joao.almeida@email.com', '85954321098', 'Rua Dragão do Mar, 789', 'Fortaleza', 'CE', '60060000'),
('Juliana Rodrigues Lima', '56789012345', '1982-05-18', 'juliana.lima@email.com', '71943210987', 'Av. Sete de Setembro, 321', 'Salvador', 'BA', '40060000'),
('Ricardo Henrique Souza', '67890123456', '1993-09-25', 'ricardo.souza@email.com', '81932109876', 'Rua da Aurora, 654', 'Recife', 'PE', '50050000'),
('Fernanda Beatriz Martins', '78901234567', '1987-12-08', 'fernanda.martins@email.com', '31921098765', 'Av. Afonso Pena, 987', 'Belo Horizonte', 'MG', '30130000'),
('Lucas Gabriel Pereira', '89012345678', '1991-04-03', 'lucas.pereira@email.com', '41910987654', 'Rua XV de Novembro, 147', 'Curitiba', 'PR', '80020000'),
('Patricia Helena Ribeiro', '90123456789', '1986-08-14', 'patricia.ribeiro@email.com', '51909876543', 'Av. Borges de Medeiros, 258', 'Porto Alegre', 'RS', '90020000'),
('Marcelo Augusto Ferreira', '01234567890', '1994-02-28', 'marcelo.ferreira@email.com', '27998765432', 'Praia do Canto, 369', 'Vitória', 'ES', '29055000');

-- 1.2 INSERÇÃO DE FUNCIONÁRIOS (10 registros)
-- Cargos: Vendedor, Gerente, Atendente, Supervisor, Diretor
INSERT INTO tb_funcionarios (nome_completo, cpf, email_corporativo, telefone, cargo, salario, data_admissao, status) VALUES
('Roberto Silva Menezes', '10101010101', 'roberto.menezes@viagenseaventuras.com.br', '61991234567', 'DIRETOR', 15000.00, '2020-01-10', 'ATIVO'),
('Sandra Maria Oliveira', '20202020202', 'sandra.oliveira@viagenseaventuras.com.br', '61991234568', 'GERENTE', 8000.00, '2020-03-15', 'ATIVO'),
('Felipe Augusto Santos', '30303030303', 'felipe.santos@viagenseaventuras.com.br', '61991234569', 'SUPERVISOR', 5500.00, '2021-05-20', 'ATIVO'),
('Larissa Fernandes Costa', '40404040404', 'larissa.costa@viagenseaventuras.com.br', '61991234570', 'VENDEDOR', 3500.00, '2021-08-01', 'ATIVO'),
('Thiago Rodrigues Lima', '50505050505', 'thiago.lima@viagenseaventuras.com.br', '61991234571', 'VENDEDOR', 3500.00, '2021-09-10', 'ATIVO'),
('Beatriz Almeida Souza', '60606060606', 'beatriz.souza@viagenseaventuras.com.br', '61991234572', 'VENDEDOR', 3800.00, '2022-01-15', 'ATIVO'),
('Anderson Pereira Martins', '70707070707', 'anderson.martins@viagenseaventuras.com.br', '61991234573', 'VENDEDOR', 4000.00, '2022-03-20', 'ATIVO'),
('Carla Beatriz Ribeiro', '80808080808', 'carla.ribeiro@viagenseaventuras.com.br', '61991234574', 'ATENDENTE', 2800.00, '2022-06-01', 'ATIVO'),
('Gustavo Henrique Ferreira', '90909090909', 'gustavo.ferreira@viagenseaventuras.com.br', '61991234575', 'ATENDENTE', 2800.00, '2022-07-15', 'ATIVO'),
('Isabela Cristina Araújo', '11111111111', 'isabela.araujo@viagenseaventuras.com.br', '61991234576', 'VENDEDOR', 3600.00, '2023-02-10', 'ATIVO');

-- 1.3 INSERÇÃO DE DESTINOS (12 registros)
-- Categorias: PRAIA, MONTANHA, URBANO, AVENTURA, CULTURAL, ECOLOGICO
INSERT INTO tb_destinos (nome_destino, pais, estado, cidade, descricao, categoria, clima, idioma_principal, moeda_local, status) VALUES
('Praias de Porto de Galinhas', 'Brasil', 'Pernambuco', 'Ipojuca', 'Praias paradisíacas com piscinas naturais', 'PRAIA', 'Tropical', 'Português', 'Real (BRL)', 'ATIVO'),
('Fernando de Noronha', 'Brasil', 'Pernambuco', 'Fernando de Noronha', 'Arquipélago com praias preservadas', 'ECOLOGICO', 'Tropical', 'Português', 'Real (BRL)', 'ATIVO'),
('Gramado e Canela', 'Brasil', 'Rio Grande do Sul', 'Gramado', 'Serra Gaúcha com clima europeu', 'MONTANHA', 'Subtropical', 'Português', 'Real (BRL)', 'ATIVO'),
('Chapada Diamantina', 'Brasil', 'Bahia', 'Lençóis', 'Cachoeiras e grutas em cenários únicos', 'AVENTURA', 'Tropical de Altitude', 'Português', 'Real (BRL)', 'ATIVO'),
('Bonito', 'Brasil', 'Mato Grosso do Sul', 'Bonito', 'Ecoturismo com rios cristalinos', 'ECOLOGICO', 'Tropical', 'Português', 'Real (BRL)', 'ATIVO'),
('Foz do Iguaçu', 'Brasil', 'Paraná', 'Foz do Iguaçu', 'Cataratas do Iguaçu', 'ECOLOGICO', 'Subtropical', 'Português', 'Real (BRL)', 'ATIVO'),
('Ouro Preto', 'Brasil', 'Minas Gerais', 'Ouro Preto', 'Cidade histórica com arquitetura barroca', 'CULTURAL', 'Tropical de Altitude', 'Português', 'Real (BRL)', 'ATIVO'),
('Cancún', 'México', NULL, 'Cancún', 'Praias caribenhas e ruínas maias', 'PRAIA', 'Tropical', 'Espanhol', 'Peso Mexicano (MXN)', 'ATIVO'),
('Paris', 'França', NULL, 'Paris', 'Cidade Luz com monumentos icônicos', 'URBANO', 'Temperado', 'Francês', 'Euro (EUR)', 'ATIVO'),
('Nova York', 'Estados Unidos', 'Nova York', 'Nova York', 'Metrópole cosmopolita', 'URBANO', 'Continental', 'Inglês', 'Dólar (USD)', 'ATIVO'),
('Machu Picchu', 'Peru', NULL, 'Cusco', 'Ruínas incas nas montanhas dos Andes', 'CULTURAL', 'Tropical de Altitude', 'Espanhol', 'Sol Peruano (PEN)', 'ATIVO'),
('Dubai', 'Emirados Árabes', NULL, 'Dubai', 'Cidade futurista com luxo e modernidade', 'URBANO', 'Desértico', 'Árabe', 'Dirham (AED)', 'ATIVO');

-- 1.4 INSERÇÃO DE HOTÉIS (12 registros)
-- Relacionamento: Cada hotel vinculado a um destino
INSERT INTO tb_hoteis (id_destino, nome_hotel, endereco, classificacao_estrelas, descricao, comodidades, valor_diaria_minima, telefone, email, status) VALUES
(1, 'Nannai Resort & Spa', 'Praia de Muro Alto, s/n', 5, 'Resort All Inclusive de luxo', 'Wi-Fi, Piscina, Spa, Restaurante', 1200.00, '8135526000', 'reservas@nannai.com.br', 'ATIVO'),
(2, 'Pousada Maravilha', 'BR-363, Sueste', 5, 'Pousada boutique com vista panorâmica', 'Wi-Fi, Piscina Infinity', 2500.00, '8136191888', 'reservas@pousadamaravilha.com.br', 'ATIVO'),
(3, 'Hotel Casa da Montanha', 'Av. Borges de Medeiros, 3166', 5, 'Hotel de luxo estilo alpino', 'Wi-Fi, Piscina Aquecida, Spa', 800.00, '5432868000', 'reservas@casadamontanha.com.br', 'ATIVO'),
(4, 'Canto das Águas', 'Rua do Rosário, s/n', 3, 'Hotel rústico no centro histórico', 'Wi-Fi, Piscina', 280.00, '7533341154', 'contato@cantodasaguas.com.br', 'ATIVO'),
(5, 'Zagaia Eco Resort', 'Rodovia Bonito-Três Morros, Km 5', 4, 'Resort ecológico', 'Wi-Fi, Piscina, Trilhas', 650.00, '6732551500', 'reservas@zagaiaecoresort.com.br', 'ATIVO'),
(6, 'Hotel das Cataratas', 'Parque Nacional do Iguaçu', 5, 'Único hotel dentro do Parque', 'Wi-Fi, Vista Cataratas', 1800.00, '4535212100', 'reservas@hoteldascataratas.com.br', 'ATIVO'),
(7, 'Pousada do Mondego', 'Largo de Coimbra, 38', 3, 'Pousada histórica colonial', 'Wi-Fi, Centro Histórico', 320.00, '3135514040', 'reservas@pousadadomondego.com.br', 'ATIVO'),
(8, 'Grand Fiesta Americana', 'Blvd. Kukulcan Km 9.5', 5, 'Resort All Inclusive', 'Wi-Fi, Praia Privativa, Spa', 2800.00, '+529988815000', 'reservas@grandfiesta.com', 'ATIVO'),
(9, 'Hotel Le Meurice', 'Rue de Rivoli, 228', 5, 'Hotel de luxo', 'Wi-Fi, Restaurante Michelin', 4500.00, '+33144581010', 'reservations@lemeurice.com', 'ATIVO'),
(10, 'The Plaza Hotel', 'Fifth Avenue, 768', 5, 'Hotel histórico icônico', 'Wi-Fi, Spa, Concierge', 5000.00, '+12127595000', 'reservations@theplaza.com', 'ATIVO'),
(11, 'Belmond Sanctuary Lodge', 'Machu Picchu Pueblo', 5, 'Ao lado das ruínas', 'Wi-Fi, Acesso Exclusivo', 3500.00, '+5184211039', 'reservations@belmond.com', 'ATIVO'),
(12, 'Burj Al Arab', 'Jumeirah Street', 5, 'Hotel mais luxuoso do mundo', 'Wi-Fi, Heliporto, Praia', 8000.00, '+97143017777', 'reservations@burjalarab.com', 'ATIVO');

-- 1.5 INSERÇÃO DE TRANSPORTES (10 registros)
-- Tipos: AEREO, ONIBUS, VAN, NAVIO
INSERT INTO tb_transportes (tipo_transporte, empresa_parceira, modelo, capacidade_passageiros, classe, preco_base, status) VALUES
('AEREO', 'LATAM Airlines', 'Boeing 737-800', 180, 'ECONOMICA', 800.00, 'ATIVO'),
('AEREO', 'GOL Linhas Aéreas', 'Boeing 737 MAX', 176, 'ECONOMICA', 750.00, 'ATIVO'),
('AEREO', 'Azul Linhas Aéreas', 'Airbus A320neo', 174, 'ECONOMICA', 820.00, 'ATIVO'),
('AEREO', 'Emirates Airlines', 'Boeing 777-300ER', 354, 'EXECUTIVA', 4500.00, 'ATIVO'),
('AEREO', 'Air France', 'Airbus A380', 516, 'PRIMEIRA_CLASSE', 8000.00, 'ATIVO'),
('ONIBUS', 'Viação Cometa', 'Mercedes-Benz O-500', 46, 'LEITO', 250.00, 'ATIVO'),
('ONIBUS', 'Viação Itapemirim', 'Scania K410', 42, 'SEMI_LEITO', 180.00, 'ATIVO'),
('VAN', 'Turismo Executivo', 'Mercedes Sprinter', 18, 'EXECUTIVA', 120.00, 'ATIVO'),
('NAVIO', 'MSC Cruzeiros', 'MSC Seaside', 4140, 'SUITE', 3500.00, 'ATIVO'),
('TREM', 'Serra Verde Express', 'Trem Turístico', 200, 'PANORAMICA', 350.00, 'ATIVO');

-- 1.6 INSERÇÃO DE PACOTES TURÍSTICOS (12 registros)
-- Combinando destino + hotel + transporte
INSERT INTO tb_pacotes_turisticos (nome_pacote, id_destino, id_hotel, id_transporte, descricao_completa, duracao_dias, data_inicio, data_fim, preco_total, vagas_disponiveis, regime_alimentar, incluso, nao_incluso, status) VALUES
('Porto de Galinhas Premium 5 dias', 1, 1, 1, 'Resort all inclusive em Porto de Galinhas', 5, '2025-01-15', '2025-01-20', 7500.00, 20, 'ALL_INCLUSIVE', 'Passagem, transfers, hospedagem, refeições', 'Passeios opcionais', 'DISPONIVEL'),
('Fernando de Noronha Exclusivo', 2, 2, 3, 'Experiência única no paraíso', 7, '2025-02-10', '2025-02-17', 15000.00, 8, 'CAFE_MANHA', 'Passagem, transfers, hospedagem', 'Refeições, taxa', 'DISPONIVEL'),
('Gramado Romântico - Inverno', 3, 3, 2, 'Pacote romântico na serra gaúcha', 4, '2025-07-01', '2025-07-05', 4200.00, 30, 'MEIA_PENSAO', 'Passagem, hospedagem, café e jantar', 'Ingressos', 'DISPONIVEL'),
('Aventura na Chapada Diamantina', 4, 4, 6, 'Trekking e cachoeiras', 6, '2025-03-20', '2025-03-26', 3500.00, 25, 'PENSAO_COMPLETA', 'Transporte, hospedagem, refeições', 'Equipamentos', 'DISPONIVEL'),
('Bonito Ecoturismo Completo', 5, 5, 2, 'Imersão na natureza', 5, '2025-04-10', '2025-04-15', 5200.00, 18, 'MEIA_PENSAO', 'Passagem, hospedagem, 3 passeios', 'Passeios extras', 'DISPONIVEL'),
('Cataratas do Iguaçu Luxo', 6, 6, 1, 'Experiência premium no Parque', 4, '2025-05-05', '2025-05-09', 8500.00, 15, 'PENSAO_COMPLETA', 'Passagem, hospedagem, refeições', 'Compras', 'DISPONIVEL'),
('Ouro Preto Histórico', 7, 7, 7, 'Imersão na história mineira', 3, '2025-08-15', '2025-08-18', 2100.00, 35, 'CAFE_MANHA', 'Transporte, hospedagem, city tour', 'Museus', 'DISPONIVEL'),
('Cancún All Inclusive 7 dias', 8, 8, 4, 'Resort all inclusive no Caribe', 7, '2025-12-20', '2025-12-27', 12500.00, 40, 'ALL_INCLUSIVE', 'Passagem, hospedagem, tudo incluso', 'Compras', 'DISPONIVEL'),
('Paris Cidade Luz - 6 dias', 9, 9, 5, 'Roteiro clássico', 6, '2025-09-10', '2025-09-16', 18000.00, 12, 'CAFE_MANHA', 'Passagem, hospedagem, city tour', 'Museus', 'DISPONIVEL'),
('Nova York Inesquecível', 10, 10, 5, 'A cidade que nunca dorme', 5, '2025-10-15', '2025-10-20', 22000.00, 10, 'SEM_ALIMENTACAO', 'Passagem, hospedagem', 'Refeições', 'DISPONIVEL'),
('Machu Picchu Místico', 11, 11, 1, 'Descobrindo os Incas', 5, '2025-11-05', '2025-11-10', 9800.00, 16, 'PENSAO_COMPLETA', 'Passagem, trem, hospedagem, refeições', 'Compras', 'DISPONIVEL'),
('Dubai Luxury Experience', 12, 12, 4, 'Luxo nos Emirados Árabes', 5, '2025-04-20', '2025-04-25', 28000.00, 8, 'MEIA_PENSAO', 'Passagem executiva, hospedagem, city tour', 'Compras', 'DISPONIVEL');

-- 1.7 INSERÇÃO DE RESERVAS (15 registros)
-- Cálculo: valor_total = valor_unitario × numero_passageiros × (1 - desconto/100)
INSERT INTO tb_reservas (id_cliente, id_pacote, id_funcionario, numero_passageiros, valor_unitario, desconto_percentual, valor_total, observacoes, status_reserva) VALUES
(1, 1, 4, 2, 7500.00, 10.00, 13500.00, 'Cliente VIP', 'CONFIRMADA'),
(2, 3, 5, 2, 4200.00, 5.00, 7980.00, 'Lua de mel', 'CONFIRMADA'),
(3, 8, 4, 4, 12500.00, 15.00, 42500.00, 'Família', 'CONFIRMADA'),
(4, 4, 6, 1, 3500.00, 0.00, 3500.00, 'Viajante solo', 'CONFIRMADA'),
(5, 5, 7, 3, 5200.00, 8.00, 14352.00, 'Grupo de amigos', 'CONFIRMADA'),
(6, 6, 4, 2, 8500.00, 5.00, 16150.00, 'Aniversário', 'CONFIRMADA'),
(7, 7, 5, 4, 2100.00, 10.00, 7560.00, 'Excursão cultural', 'CONFIRMADA'),
(8, 9, 6, 2, 18000.00, 0.00, 36000.00, 'Viagem dos sonhos', 'CONFIRMADA'),
(9, 2, 7, 2, 15000.00, 12.00, 26400.00, 'Cliente fidelidade', 'CONFIRMADA'),
(10, 10, 4, 1, 22000.00, 0.00, 22000.00, 'Viagem negócios', 'CONFIRMADA'),
(1, 11, 5, 2, 9800.00, 7.00, 18228.00, 'Aventura histórica', 'CONFIRMADA'),
(2, 12, 6, 2, 28000.00, 5.00, 53200.00, 'Bodas de ouro', 'CONFIRMADA'),
(3, 1, 5, 3, 7500.00, 12.00, 19800.00, 'Férias família', 'CONFIRMADA'),
(4, 3, 6, 2, 4200.00, 5.00, 7980.00, 'Feriado prolongado', 'CONFIRMADA'),
(5, 8, 4, 5, 12500.00, 18.00, 51250.00, 'Grupo grande', 'CONFIRMADA');

-- 1.8 INSERÇÃO DE PAGAMENTOS (15 registros)
-- Relacionamento: Pagamentos vinculados a reservas
INSERT INTO tb_pagamentos (id_reserva, forma_pagamento, numero_parcela, total_parcelas, valor_parcela, data_vencimento, status_pagamento, numero_transacao) VALUES
(1, 'CREDITO', 1, 3, 4500.00, '2024-11-15', 'PAGO', 'TXN001234567890'),
(1, 'CREDITO', 2, 3, 4500.00, '2024-12-15', 'PAGO', 'TXN001234567891'),
(1, 'CREDITO', 3, 3, 4500.00, '2025-01-15', 'PENDENTE', NULL),
(2, 'PIX', 1, 1, 7980.00, '2024-11-20', 'PAGO', 'PIX20241120001'),
(3, 'CREDITO', 1, 5, 8500.00, '2024-11-10', 'PAGO', 'TXN002345678901'),
(3, 'CREDITO', 2, 5, 8500.00, '2024-12-10', 'PAGO', 'TXN002345678902'),
(4, 'DEBITO', 1, 1, 3500.00, '2024-11-25', 'PAGO', 'DEB20241125001'),
(5, 'CREDITO', 1, 2, 7176.00, '2024-11-30', 'PAGO', 'TXN003456789012'),
(6, 'CREDITO', 1, 4, 4037.50, '2024-12-01', 'PAGO', 'TXN004567890123'),
(7, 'PIX', 1, 1, 7560.00, '2024-12-05', 'PAGO', 'PIX20241205001'),
(8, 'CREDITO', 1, 6, 6000.00, '2024-11-15', 'PAGO', 'TXN006789012345'),
(9, 'TRANSFERENCIA', 1, 1, 26400.00, '2024-12-01', 'PAGO', 'TRANSF20241201001'),
(10, 'CREDITO', 1, 10, 2200.00, '2024-11-20', 'PAGO', 'TXN007890123456'),
(11, 'CREDITO', 1, 3, 6076.00, '2024-12-10', 'PAGO', 'TXN008901234567'),
(12, 'PIX', 1, 1, 53200.00, '2024-12-15', 'PAGO', 'PIX20241215001');

-- 1.9 INSERÇÃO DE AVALIAÇÕES (10 registros)
-- Feedback dos clientes (nota de 1 a 5 estrelas)
INSERT INTO tb_avaliacoes (id_cliente, id_pacote, nota, comentario) VALUES
(1, 1, 5, 'Experiência incrível! Resort maravilhoso. Recomendo!'),
(2, 3, 5, 'Gramado é encantadora. Hotel perfeito para lua de mel.'),
(3, 8, 4, 'Cancún superou expectativas. Voo lotado foi único ponto negativo.'),
(4, 4, 5, 'Chapada Diamantina espetacular! Guias competentes.'),
(5, 5, 5, 'Bonito é paraíso ecológico. Flutuação inesquecível!'),
(6, 6, 5, 'Hotel das Cataratas sensacional! Vista não tem preço.'),
(7, 7, 5, 'Ouro Preto é cultura pura. Cidade belíssima.'),
(8, 9, 5, 'Paris é mágica! Hotel incrível, localização perfeita.'),
(9, 2, 5, 'Fernando de Noronha é surreal! Mar cristalino.'),
(1, 11, 5, 'Machu Picchu místico e energizante. Merece título de maravilha!');

-- ============================================================================
-- 2. CONSULTAS SQL COMPLEXAS
-- Demonstração de queries avançadas com JOINs, subconsultas e agregações
-- ============================================================================

-- CONSULTA 1: Relatório de Vendas por Funcionário
-- Objetivo: Analisar performance dos vendedores
-- Técnicas: INNER JOIN, GROUP BY, agregações
SELECT
    f.nome_completo AS vendedor, f.cargo,
    COUNT(r.id_reserva) AS total_vendas,
    SUM(r.numero_passageiros) AS total_passageiros,
    SUM(r.valor_total) AS faturamento_total,
    ROUND(AVG(r.valor_total), 2) AS ticket_medio,
    ROUND(AVG(r.desconto_percentual), 2) AS desconto_medio
FROM tb_funcionarios f
INNER JOIN tb_reservas r ON f.id_funcionario = r.id_funcionario
WHERE r.status_reserva IN ('CONFIRMADA', 'FINALIZADA')
GROUP BY f.id_funcionario, f.nome_completo, f.cargo
ORDER BY faturamento_total DESC;

-- CONSULTA 2: Top 5 Pacotes Mais Vendidos
-- Objetivo: Identificar pacotes mais populares
-- Técnicas: Multiple JOINs, GROUP BY, HAVING, LIMIT
SELECT
    p.nome_pacote, d.nome_destino, d.pais,
    COUNT(r.id_reserva) AS quantidade_vendas,
    SUM(r.numero_passageiros) AS total_passageiros,
    SUM(r.valor_total) AS receita_total,
    ROUND(AVG(av.nota), 2) AS avaliacao_media
FROM tb_pacotes_turisticos p
INNER JOIN tb_destinos d ON p.id_destino = d.id_destino
LEFT JOIN tb_reservas r ON p.id_pacote = r.id_pacote AND r.status_reserva = 'CONFIRMADA'
LEFT JOIN tb_avaliacoes av ON p.id_pacote = av.id_pacote
GROUP BY p.id_pacote, p.nome_pacote, d.nome_destino, d.pais
HAVING COUNT(r.id_reserva) > 0
ORDER BY quantidade_vendas DESC, receita_total DESC
LIMIT 5;

-- CONSULTA 3: Análise Financeira de Pagamentos
-- Objetivo: Controle financeiro - valores recebidos vs pendentes
-- Técnicas: CASE, agregações condicionais
SELECT
    DATE_TRUNC('month', p.data_pagamento) AS mes_ano,
    COUNT(DISTINCT p.id_reserva) AS total_reservas,
    SUM(CASE WHEN p.status_pagamento = 'PAGO' THEN p.valor_parcela ELSE 0 END) AS valor_recebido,
    SUM(CASE WHEN p.status_pagamento = 'PENDENTE' THEN p.valor_parcela ELSE 0 END) AS valor_pendente,
    SUM(p.valor_parcela) AS valor_total,
    ROUND(100.0 * SUM(CASE WHEN p.status_pagamento = 'PAGO' THEN p.valor_parcela ELSE 0 END) / NULLIF(SUM(p.valor_parcela), 0), 2) AS percentual_recebido
FROM tb_pagamentos p
GROUP BY DATE_TRUNC('month', p.data_pagamento)
ORDER BY mes_ano DESC;

-- CONSULTA 4: Clientes VIP (Mais Gastaram)
-- Objetivo: Identificar clientes de maior valor
-- Técnicas: Window Functions (ROW_NUMBER)
WITH ranking_clientes AS (
    SELECT
        c.nome_completo, c.email, c.cidade, c.estado,
        COUNT(r.id_reserva) AS total_compras,
        SUM(r.valor_total) AS valor_total_gasto,
        ROUND(AVG(r.valor_total), 2) AS ticket_medio,
        MAX(r.data_reserva) AS ultima_compra,
        ROW_NUMBER() OVER (ORDER BY SUM(r.valor_total) DESC) AS ranking
    FROM tb_clientes c
    INNER JOIN tb_reservas r ON c.id_cliente = r.id_cliente
    WHERE r.status_reserva IN ('CONFIRMADA', 'FINALIZADA')
    GROUP BY c.id_cliente, c.nome_completo, c.email, c.cidade, c.estado
)
SELECT ranking AS posicao, nome_completo, email,
    cidade || ' - ' || estado AS localizacao,
    total_compras,
    TO_CHAR(valor_total_gasto, 'L999G999G999D99') AS valor_gasto
FROM ranking_clientes
WHERE ranking <= 10
ORDER BY ranking;

-- CONSULTA 5: Ocupação de Pacotes
-- Objetivo: Controle de disponibilidade de vagas
-- Técnicas: Subconsulta, cálculo percentual
SELECT
    p.nome_pacote, d.nome_destino, p.data_inicio, p.vagas_disponiveis,
    COALESCE(SUM(r.numero_passageiros), 0) AS vagas_vendidas,
    p.vagas_disponiveis - COALESCE(SUM(r.numero_passageiros), 0) AS vagas_restantes,
    ROUND(100.0 * COALESCE(SUM(r.numero_passageiros), 0) / NULLIF(p.vagas_disponiveis, 0), 2) AS percentual_ocupacao,
    CASE
        WHEN p.vagas_disponiveis - COALESCE(SUM(r.numero_passageiros), 0) <= 0 THEN 'ESGOTADO'
        WHEN p.vagas_disponiveis - COALESCE(SUM(r.numero_passageiros), 0) <= 5 THEN 'ÚLTIMAS VAGAS'
        ELSE 'DISPONÍVEL'
    END AS status_disponibilidade
FROM tb_pacotes_turisticos p
INNER JOIN tb_destinos d ON p.id_destino = d.id_destino
LEFT JOIN tb_reservas r ON p.id_pacote = r.id_pacote AND r.status_reserva IN ('CONFIRMADA', 'PENDENTE')
WHERE p.data_inicio >= CURRENT_DATE
GROUP BY p.id_pacote, p.nome_pacote, d.nome_destino, p.data_inicio, p.vagas_disponiveis
ORDER BY percentual_ocupacao DESC;

-- CONSULTA 6: Destinos Mais Procurados por Categoria
-- Objetivo: Análise de preferências por tipo de turismo
SELECT
    d.categoria, d.nome_destino, d.pais,
    COUNT(r.id_reserva) AS total_reservas,
    SUM(r.numero_passageiros) AS total_turistas,
    SUM(r.valor_total) AS receita_total
FROM tb_destinos d
LEFT JOIN tb_pacotes_turisticos p ON d.id_destino = p.id_destino
LEFT JOIN tb_reservas r ON p.id_pacote = r.id_pacote AND r.status_reserva = 'CONFIRMADA'
GROUP BY d.categoria, d.nome_destino, d.pais
ORDER BY d.categoria, total_reservas DESC;

-- CONSULTA 7: Formas de Pagamento Preferidas
-- Objetivo: Entender comportamento de pagamento
SELECT
    pg.forma_pagamento,
    COUNT(DISTINCT pg.id_reserva) AS total_reservas,
    ROUND(AVG(pg.total_parcelas), 2) AS media_parcelas,
    SUM(pg.valor_parcela) AS valor_total,
    ROUND(100.0 * COUNT(pg.id_pagamento) / SUM(COUNT(pg.id_pagamento)) OVER (), 2) AS percentual_uso
FROM tb_pagamentos pg
GROUP BY pg.forma_pagamento
ORDER BY total_reservas DESC;

-- CONSULTA 8: Pacotes com Melhor Custo-Benefício
-- Objetivo: Ranquear pacotes por preço/dia e avaliação
SELECT
    p.nome_pacote, d.nome_destino, h.nome_hotel, h.classificacao_estrelas,
    p.duracao_dias, p.preco_total,
    ROUND(p.preco_total / p.duracao_dias, 2) AS preco_por_dia,
    (SELECT ROUND(AVG(av.nota), 2) FROM tb_avaliacoes av WHERE av.id_pacote = p.id_pacote) AS avaliacao_media,
    p.vagas_disponiveis - COALESCE((SELECT SUM(r.numero_passageiros) FROM tb_reservas r WHERE r.id_pacote = p.id_pacote AND r.status_reserva IN ('CONFIRMADA', 'PENDENTE')), 0) AS vagas_restantes
FROM tb_pacotes_turisticos p
INNER JOIN tb_destinos d ON p.id_destino = d.id_destino
INNER JOIN tb_hoteis h ON p.id_hotel = h.id_hotel
WHERE p.data_inicio >= CURRENT_DATE AND p.status = 'DISPONIVEL'
ORDER BY preco_por_dia ASC, avaliacao_media DESC NULLS LAST;

-- CONSULTA 9: Análise de Descontos Concedidos
-- Objetivo: Avaliar impacto dos descontos na receita
SELECT
    CASE
        WHEN r.desconto_percentual = 0 THEN 'Sem desconto'
        WHEN r.desconto_percentual <= 5 THEN '1% a 5%'
        WHEN r.desconto_percentual <= 10 THEN '5% a 10%'
        WHEN r.desconto_percentual <= 15 THEN '10% a 15%'
        ELSE 'Acima de 15%'
    END AS faixa_desconto,
    COUNT(r.id_reserva) AS quantidade_vendas,
    SUM(r.valor_unitario * r.numero_passageiros) AS valor_sem_desconto,
    SUM(r.valor_total) AS valor_com_desconto,
    SUM(r.valor_unitario * r.numero_passageiros) - SUM(r.valor_total) AS valor_descontado
FROM tb_reservas r
WHERE r.status_reserva IN ('CONFIRMADA', 'FINALIZADA')
GROUP BY faixa_desconto
ORDER BY MIN(r.desconto_percentual);

-- CONSULTA 10: Dashboard Executivo
-- Objetivo: Visão consolidada do negócio
SELECT
    (SELECT COUNT(*) FROM tb_clientes) AS total_clientes,
    (SELECT COUNT(*) FROM tb_funcionarios WHERE status = 'ATIVO') AS total_funcionarios_ativos,
    (SELECT COUNT(*) FROM tb_destinos WHERE status = 'ATIVO') AS total_destinos,
    (SELECT COUNT(*) FROM tb_pacotes_turisticos WHERE status = 'DISPONIVEL') AS total_pacotes,
    (SELECT COUNT(*) FROM tb_reservas WHERE status_reserva = 'CONFIRMADA') AS total_reservas_confirmadas,
    (SELECT TO_CHAR(SUM(valor_total), 'L999G999G999D99') FROM tb_reservas WHERE status_reserva IN ('CONFIRMADA', 'FINALIZADA')) AS receita_total,
    (SELECT TO_CHAR(SUM(valor_parcela), 'L999G999G999D99') FROM tb_pagamentos WHERE status_pagamento = 'PAGO') AS valor_recebido,
    (SELECT ROUND(AVG(nota), 2) FROM tb_avaliacoes) AS avaliacao_media;

-- ============================================================================
-- RESUMO DA ETAPA 2
-- DADOS INSERIDOS: 10+ registros por tabela
-- CONSULTAS: 10 consultas SQL complexas demonstrando JOINs, agregações,
-- subconsultas, window functions e análises gerenciais
-- ============================================================================

SELECT 'Etapa 2 concluída! Dados inseridos e consultas criadas.' AS status;
