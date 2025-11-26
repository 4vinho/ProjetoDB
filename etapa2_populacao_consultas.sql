-- ============================================================================
-- ETAPA 2: POPULAÇÃO DE DADOS E CONSULTAS SQL
-- ============================================================================
-- Descrição: Inserção de dados de teste (mínimo 10 registros por tabela)
--            e consultas SQL complexas para relatórios gerenciais
-- ============================================================================

-- Conectar ao banco de dados
\c agencia_turismo;

-- ============================================================================
-- 1. POPULAÇÃO DE DADOS (DML - INSERT)
-- ============================================================================

-- ----------------------------------------------------------------------------
-- 1.1 INSERÇÃO DE CLIENTES (15 registros)
-- ----------------------------------------------------------------------------
-- Objetivo: Popular tabela de clientes com dados fictícios variados
-- Regra: CPF e Email únicos, dados consistentes
-- ----------------------------------------------------------------------------
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
('Marcelo Augusto Ferreira', '01234567890', '1994-02-28', 'marcelo.ferreira@email.com', '27998765432', 'Praia do Canto, 369', 'Vitória', 'ES', '29055000'),
('Camila Cristina Araújo', '11223344556', '1989-06-17', 'camila.araujo@email.com', '62987654321', 'Av. T-9, 741', 'Goiânia', 'GO', '74063000'),
('Rafael Santos Mendes', '22334455667', '1992-10-21', 'rafael.mendes@email.com', '92976543210', 'Av. Eduardo Ribeiro, 852', 'Manaus', 'AM', '69010000'),
('Tatiana Moreira Gomes', '33445566778', '1984-03-09', 'tatiana.gomes@email.com', '91965432109', 'Av. Presidente Vargas, 963', 'Belém', 'PA', '66017000'),
('Bruno Henrique Castro', '44556677889', '1996-07-13', 'bruno.castro@email.com', '48954321098', 'Av. Beira Mar Norte, 159', 'Florianópolis', 'SC', '88015000'),
('Vanessa Aparecida Dias', '55667788990', '1983-11-27', 'vanessa.dias@email.com', '19943210987', 'Av. Andrade Neves, 357', 'Campinas', 'SP', '13013000');

COMMENT ON TABLE tb_clientes IS 'Tabela populada com 15 clientes de diversas regiões do Brasil';

-- ----------------------------------------------------------------------------
-- 1.2 INSERÇÃO DE FUNCIONÁRIOS (12 registros)
-- ----------------------------------------------------------------------------
-- Objetivo: Cadastrar funcionários com diferentes cargos e salários
-- Cargos: Vendedor, Gerente, Atendente, Supervisor, Diretor
-- ----------------------------------------------------------------------------
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
('Isabela Cristina Araújo', '11111111111', 'isabela.araujo@viagenseaventuras.com.br', '61991234576', 'VENDEDOR', 3600.00, '2023-02-10', 'ATIVO'),
('Diego Santos Mendes', '22222222222', 'diego.mendes@viagenseaventuras.com.br', '61991234577', 'VENDEDOR', 3500.00, '2023-05-01', 'ATIVO'),
('Priscila Moreira Gomes', '33333333333', 'priscila.gomes@viagenseaventuras.com.br', '61991234578', 'ATENDENTE', 2900.00, '2023-08-20', 'FERIAS');

-- ----------------------------------------------------------------------------
-- 1.3 INSERÇÃO DE DESTINOS (15 registros)
-- ----------------------------------------------------------------------------
-- Objetivo: Criar catálogo de destinos nacionais e internacionais
-- Categorias: PRAIA, MONTANHA, URBANO, AVENTURA, CULTURAL, ECOLOGICO
-- ----------------------------------------------------------------------------
INSERT INTO tb_destinos (nome_destino, pais, estado, cidade, descricao, categoria, clima, idioma_principal, moeda_local, status) VALUES
('Praias de Porto de Galinhas', 'Brasil', 'Pernambuco', 'Ipojuca', 'Praias paradisíacas com piscinas naturais e águas cristalinas', 'PRAIA', 'Tropical', 'Português', 'Real (BRL)', 'ATIVO'),
('Fernando de Noronha', 'Brasil', 'Pernambuco', 'Fernando de Noronha', 'Arquipélago com praias preservadas e vida marinha rica', 'ECOLOGICO', 'Tropical', 'Português', 'Real (BRL)', 'ATIVO'),
('Gramado e Canela', 'Brasil', 'Rio Grande do Sul', 'Gramado', 'Serra Gaúcha com clima europeu e arquitetura encantadora', 'MONTANHA', 'Subtropical', 'Português', 'Real (BRL)', 'ATIVO'),
('Chapada Diamantina', 'Brasil', 'Bahia', 'Lençóis', 'Cachoeiras, grutas e trilhas em cenários naturais únicos', 'AVENTURA', 'Tropical de Altitude', 'Português', 'Real (BRL)', 'ATIVO'),
('Bonito', 'Brasil', 'Mato Grosso do Sul', 'Bonito', 'Ecoturismo com rios cristalinos e grutas subaquáticas', 'ECOLOGICO', 'Tropical', 'Português', 'Real (BRL)', 'ATIVO'),
('Foz do Iguaçu', 'Brasil', 'Paraná', 'Foz do Iguaçu', 'Cataratas do Iguaçu e Parque das Aves', 'ECOLOGICO', 'Subtropical', 'Português', 'Real (BRL)', 'ATIVO'),
('Jericoacoara', 'Brasil', 'Ceará', 'Jijoca de Jericoacoara', 'Dunas, lagoas e praias ideais para kitesurf', 'PRAIA', 'Tropical', 'Português', 'Real (BRL)', 'ATIVO'),
('Ouro Preto', 'Brasil', 'Minas Gerais', 'Ouro Preto', 'Cidade histórica com arquitetura barroca e rica cultura', 'CULTURAL', 'Tropical de Altitude', 'Português', 'Real (BRL)', 'ATIVO'),
('Cancún', 'México', NULL, 'Cancún', 'Praias caribenhas, vida noturna e ruínas maias', 'PRAIA', 'Tropical', 'Espanhol', 'Peso Mexicano (MXN)', 'ATIVO'),
('Paris', 'França', NULL, 'Paris', 'Cidade Luz com monumentos icônicos e gastronomia refinada', 'URBANO', 'Temperado', 'Francês', 'Euro (EUR)', 'ATIVO'),
('Nova York', 'Estados Unidos', 'Nova York', 'Nova York', 'Metrópole cosmopolita com cultura, arte e entretenimento', 'URBANO', 'Continental', 'Inglês', 'Dólar (USD)', 'ATIVO'),
('Machu Picchu', 'Peru', NULL, 'Cusco', 'Ruínas incas nas montanhas dos Andes', 'CULTURAL', 'Tropical de Altitude', 'Espanhol/Quéchua', 'Sol Peruano (PEN)', 'ATIVO'),
('Patagônia Argentina', 'Argentina', NULL, 'El Calafate', 'Glaciares, montanhas e natureza selvagem', 'AVENTURA', 'Frio', 'Espanhol', 'Peso Argentino (ARS)', 'ATIVO'),
('Dubai', 'Emirados Árabes', NULL, 'Dubai', 'Cidade futurista com luxo e modernidade', 'URBANO', 'Desértico', 'Árabe', 'Dirham (AED)', 'ATIVO'),
('Santiago do Chile', 'Chile', NULL, 'Santiago', 'Capital chilena com vista para a Cordilheira dos Andes', 'URBANO', 'Mediterrâneo', 'Espanhol', 'Peso Chileno (CLP)', 'ATIVO');

-- ----------------------------------------------------------------------------
-- 1.4 INSERÇÃO DE HOTÉIS (18 registros)
-- ----------------------------------------------------------------------------
-- Objetivo: Cadastrar hotéis vinculados aos destinos
-- Relacionamento: Cada hotel pertence a um destino (FK)
-- ----------------------------------------------------------------------------
INSERT INTO tb_hoteis (id_destino, nome_hotel, endereco, classificacao_estrelas, descricao, comodidades, valor_diaria_minima, telefone, email, status) VALUES
-- Hotéis em Porto de Galinhas (id_destino = 1)
(1, 'Nannai Resort & Spa', 'Praia de Muro Alto, s/n', 5, 'Resort All Inclusive de luxo à beira-mar', 'Wi-Fi, Piscina, Spa, Academia, Restaurante', 1200.00, '8135526000', 'reservas@nannai.com.br', 'ATIVO'),
(1, 'Summerville Beach Resort', 'Praia de Muro Alto, s/n', 5, 'Resort com bangalôs e gastronomia premiada', 'Wi-Fi, Piscina, Spa, Kids Club', 1500.00, '8135268800', 'reservas@summerville.com.br', 'ATIVO'),

-- Hotéis em Fernando de Noronha (id_destino = 2)
(2, 'Pousada Maravilha', 'BR-363, Sueste', 5, 'Pousada boutique com vista panorâmica do mar', 'Wi-Fi, Piscina Infinity, Restaurante Gourmet', 2500.00, '8136191888', 'reservas@pousadamaravilha.com.br', 'ATIVO'),

-- Hotéis em Gramado (id_destino = 3)
(3, 'Hotel Casa da Montanha', 'Av. Borges de Medeiros, 3166', 5, 'Hotel de luxo no estilo alpino', 'Wi-Fi, Piscina Aquecida, Spa, Lareira', 800.00, '5432868000', 'reservas@casadamontanha.com.br', 'ATIVO'),
(3, 'Hotel Ritta Höppner', 'Rua Pedro Candiago, 305', 4, 'Hotel aconchegante com café colonial', 'Wi-Fi, Piscina, Café Colonial', 450.00, '5432951334', 'reservas@rittahoppner.com.br', 'ATIVO'),

-- Hotéis em Chapada Diamantina (id_destino = 4)
(4, 'Canto das Águas', 'Rua do Rosário, s/n', 3, 'Hotel rústico no centro histórico de Lençóis', 'Wi-Fi, Piscina, Restaurante Regional', 280.00, '7533341154', 'contato@cantodasaguas.com.br', 'ATIVO'),

-- Hotéis em Bonito (id_destino = 5)
(5, 'Zagaia Eco Resort', 'Rodovia Bonito-Três Morros, Km 5', 4, 'Resort ecológico com infraestrutura completa', 'Wi-Fi, Piscina, Trilhas Ecológicas, Spa', 650.00, '6732551500', 'reservas@zagaiaecoresort.com.br', 'ATIVO'),

-- Hotéis em Foz do Iguaçu (id_destino = 6)
(6, 'Hotel das Cataratas', 'Parque Nacional do Iguaçu', 5, 'Único hotel dentro do Parque Nacional', 'Wi-Fi, Piscina, Vista para as Cataratas', 1800.00, '4535212100', 'reservas@hoteldascataratas.com.br', 'ATIVO'),

-- Hotéis em Jericoacoara (id_destino = 7)
(7, 'Essenza Hotel', 'Rua das Dunas, 1', 4, 'Hotel boutique com design contemporâneo', 'Wi-Fi, Piscina, Bar, Restaurante', 550.00, '8836692222', 'reservas@essenzahotel.com.br', 'ATIVO'),

-- Hotéis em Ouro Preto (id_destino = 8)
(8, 'Pousada do Mondego', 'Largo de Coimbra, 38', 3, 'Pousada histórica em casarão colonial', 'Wi-Fi, Café da Manhã, Centro Histórico', 320.00, '3135514040', 'reservas@pousadadomondego.com.br', 'ATIVO'),

-- Hotéis em Cancún (id_destino = 9)
(9, 'Grand Fiesta Americana', 'Blvd. Kukulcan Km 9.5', 5, 'Resort All Inclusive na zona hoteleira', 'Wi-Fi, Praia Privativa, 5 Restaurantes, Spa', 2800.00, '+529988815000', 'reservas@grandfiesta.com', 'ATIVO'),

-- Hotéis em Paris (id_destino = 10)
(10, 'Hotel Le Meurice', 'Rue de Rivoli, 228', 5, 'Hotel de luxo com vista para o Jardim das Tulherias', 'Wi-Fi, Restaurante Estrelado Michelin, Spa', 4500.00, '+33144581010', 'reservations@lemeurice.com', 'ATIVO'),

-- Hotéis em Nova York (id_destino = 11)
(11, 'The Plaza Hotel', 'Fifth Avenue, 768', 5, 'Hotel histórico icônico de Manhattan', 'Wi-Fi, Spa, Restaurante, Concierge', 5000.00, '+12127595000', 'reservations@theplaza.com', 'ATIVO'),

-- Hotéis em Machu Picchu (id_destino = 12)
(12, 'Belmond Sanctuary Lodge', 'Machu Picchu Pueblo', 5, 'Único hotel ao lado das ruínas de Machu Picchu', 'Wi-Fi, Restaurante, Acesso Exclusivo', 3500.00, '+5184211039', 'reservations@belmond.com', 'ATIVO'),

-- Hotéis em Patagônia (id_destino = 13)
(13, 'Los Glaciares Hotel', 'Av. Libertador, 1355', 4, 'Hotel com vista para o Lago Argentino', 'Wi-Fi, Aquecimento, Restaurante', 1200.00, '+542902491792', 'info@losglaciareshotel.com', 'ATIVO'),

-- Hotéis em Dubai (id_destino = 14)
(14, 'Burj Al Arab', 'Jumeirah Street', 5, 'Hotel mais luxuoso do mundo com 7 estrelas', 'Wi-Fi, Heliporto, Praia Privativa, Spa', 8000.00, '+97143017777', 'reservations@burjalarab.com', 'ATIVO'),

-- Hotéis em Santiago (id_destino = 15)
(15, 'The Ritz-Carlton Santiago', 'Calle El Alcalde, 15', 5, 'Hotel de luxo no bairro Las Condes', 'Wi-Fi, Piscina, Spa, Rooftop', 1500.00, '+56224707000', 'reservations@ritzcarlton.com', 'ATIVO');

-- ----------------------------------------------------------------------------
-- 1.5 INSERÇÃO DE TRANSPORTES (10 registros)
-- ----------------------------------------------------------------------------
-- Objetivo: Cadastrar meios de transporte disponíveis
-- Tipos: AEREO, ONIBUS, VAN, NAVIO
-- ----------------------------------------------------------------------------
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

-- ----------------------------------------------------------------------------
-- 1.6 INSERÇÃO DE PACOTES TURÍSTICOS (15 registros)
-- ----------------------------------------------------------------------------
-- Objetivo: Criar pacotes completos combinando destino + hotel + transporte
-- Relacionamentos: FK para destinos, hotéis e transportes
-- ----------------------------------------------------------------------------
INSERT INTO tb_pacotes_turisticos (nome_pacote, id_destino, id_hotel, id_transporte, descricao_completa, duracao_dias, data_inicio, data_fim, preco_total, vagas_disponiveis, regime_alimentar, incluso, nao_incluso, status) VALUES
('Porto de Galinhas Premium 5 dias', 1, 1, 1, 'Pacote completo com resort all inclusive em Porto de Galinhas', 5, '2025-01-15', '2025-01-20', 7500.00, 20, 'ALL_INCLUSIVE', 'Passagem aérea, transfers, hospedagem, todas as refeições, bebidas', 'Passeios opcionais, seguro viagem', 'DISPONIVEL'),
('Fernando de Noronha Exclusivo', 2, 3, 3, 'Experiência única no paraíso de Noronha com pousada de luxo', 7, '2025-02-10', '2025-02-17', 15000.00, 8, 'CAFE_MANHA', 'Passagem aérea, transfers, hospedagem, café da manhã', 'Almoço, jantar, passeios, taxa de preservação', 'DISPONIVEL'),
('Gramado Romântico - Inverno', 3, 4, 2, 'Pacote romântico na serra gaúcha durante o inverno', 4, '2025-07-01', '2025-07-05', 4200.00, 30, 'MEIA_PENSAO', 'Passagem aérea, transfers, hospedagem, café e jantar', 'Almoço, ingressos para atrações', 'DISPONIVEL'),
('Aventura na Chapada Diamantina', 4, 6, 6, 'Trekking e cachoeiras na Chapada com guias especializados', 6, '2025-03-20', '2025-03-26', 3500.00, 25, 'PENSAO_COMPLETA', 'Transporte terrestre, hospedagem, todas as refeições, guias', 'Equipamentos especiais, bebidas', 'DISPONIVEL'),
('Bonito Ecoturismo Completo', 5, 7, 2, 'Imersão na natureza com flutuação e grutas', 5, '2025-04-10', '2025-04-15', 5200.00, 18, 'MEIA_PENSAO', 'Passagem aérea, hospedagem, café e jantar, 3 passeios', 'Passeios extras, almoço', 'DISPONIVEL'),
('Cataratas do Iguaçu Luxo', 6, 8, 1, 'Experiência premium no Parque Nacional do Iguaçu', 4, '2025-05-05', '2025-05-09', 8500.00, 15, 'PENSAO_COMPLETA', 'Passagem aérea, hospedagem, refeições, ingressos parques', 'Compras pessoais, bebidas extras', 'DISPONIVEL'),
('Jericoacoara Vento e Mar', 7, 9, 3, 'Praias paradisíacas e esportes aquáticos', 6, '2025-06-12', '2025-06-18', 4800.00, 22, 'CAFE_MANHA', 'Passagem aérea, transfers 4x4, hospedagem, café', 'Refeições principais, passeios', 'DISPONIVEL'),
('Ouro Preto Histórico', 8, 10, 7, 'Imersão na história e cultura mineira', 3, '2025-08-15', '2025-08-18', 2100.00, 35, 'CAFE_MANHA', 'Transporte, hospedagem, café, city tour', 'Almoço, jantar, museus', 'DISPONIVEL'),
('Cancún All Inclusive 7 dias', 9, 11, 4, 'Resort all inclusive no Caribe Mexicano', 7, '2025-12-20', '2025-12-27', 12500.00, 40, 'ALL_INCLUSIVE', 'Passagem aérea internacional, transfers, hospedagem, tudo incluso', 'Passeios externos, compras', 'DISPONIVEL'),
('Paris Cidade Luz - 6 dias', 10, 12, 5, 'Roteiro clássico pela capital francesa', 6, '2025-09-10', '2025-09-16', 18000.00, 12, 'CAFE_MANHA', 'Passagem aérea, hospedagem, café, city tour', 'Refeições principais, museus, compras', 'DISPONIVEL'),
('Nova York Inesquecível', 11, 13, 5, 'A cidade que nunca dorme com hospedagem no Plaza', 5, '2025-10-15', '2025-10-20', 22000.00, 10, 'SEM_ALIMENTACAO', 'Passagem aérea, hospedagem, transfers', 'Todas as refeições, ingressos, passeios', 'DISPONIVEL'),
('Machu Picchu Místico', 12, 14, 1, 'Descobrindo os segredos dos Incas', 5, '2025-11-05', '2025-11-10', 9800.00, 16, 'PENSAO_COMPLETA', 'Passagem aérea, trem panorâmico, hospedagem, refeições, ingressos', 'Compras, bebidas especiais', 'DISPONIVEL'),
('Patagônia Glaciares', 13, 15, 4, 'Expedição aos glaciares da Patagônia Argentina', 8, '2025-03-01', '2025-03-09', 14000.00, 14, 'PENSAO_COMPLETA', 'Passagem aérea, hospedagem, refeições, passeios glaciares', 'Equipamentos especiais, bebidas', 'DISPONIVEL'),
('Dubai Luxury Experience', 14, 16, 4, 'Luxo e modernidade nos Emirados Árabes', 5, '2025-04-20', '2025-04-25', 28000.00, 8, 'MEIA_PENSAO', 'Passagem executiva, hospedagem Burj Al Arab, café e jantar, city tour', 'Compras, passeios extras', 'DISPONIVEL'),
('Santiago + Vinícolas', 15, 17, 2, 'Chile: capital e rota dos vinhos', 6, '2025-05-15', '2025-05-21', 7500.00, 20, 'MEIA_PENSAO', 'Passagem aérea, hospedagem, café e jantar, tour vinícolas', 'Almoço, compras de vinhos', 'DISPONIVEL');

-- ----------------------------------------------------------------------------
-- 1.7 INSERÇÃO DE RESERVAS (20 registros)
-- ----------------------------------------------------------------------------
-- Objetivo: Simular vendas de pacotes realizadas pelos vendedores
-- Cálculo: valor_total = valor_unitario × numero_passageiros × (1 - desconto/100)
-- ----------------------------------------------------------------------------
INSERT INTO tb_reservas (id_cliente, id_pacote, id_funcionario, numero_passageiros, valor_unitario, desconto_percentual, valor_total, observacoes, status_reserva) VALUES
(1, 1, 4, 2, 7500.00, 10.00, 13500.00, 'Cliente VIP - desconto especial', 'CONFIRMADA'),
(2, 3, 5, 2, 4200.00, 5.00, 7980.00, 'Lua de mel', 'CONFIRMADA'),
(3, 9, 4, 4, 12500.00, 15.00, 42500.00, 'Família - desconto grupo', 'CONFIRMADA'),
(4, 4, 6, 1, 3500.00, 0.00, 3500.00, 'Viajante solo', 'CONFIRMADA'),
(5, 5, 7, 3, 5200.00, 8.00, 14352.00, 'Grupo de amigos', 'CONFIRMADA'),
(6, 6, 4, 2, 8500.00, 5.00, 16150.00, 'Aniversário de casamento', 'CONFIRMADA'),
(7, 7, 5, 2, 4800.00, 0.00, 9600.00, 'Praticantes de kitesurf', 'CONFIRMADA'),
(8, 8, 10, 4, 2100.00, 10.00, 7560.00, 'Excursão cultural', 'CONFIRMADA'),
(9, 10, 6, 2, 18000.00, 0.00, 36000.00, 'Viagem dos sonhos', 'CONFIRMADA'),
(10, 2, 7, 2, 15000.00, 12.00, 26400.00, 'Cliente fidelidade', 'CONFIRMADA'),
(11, 11, 4, 1, 22000.00, 0.00, 22000.00, 'Viagem de negócios + turismo', 'CONFIRMADA'),
(12, 12, 5, 2, 9800.00, 7.00, 18228.00, 'Aventura histórica', 'CONFIRMADA'),
(13, 13, 6, 2, 14000.00, 10.00, 25200.00, 'Fotógrafos profissionais', 'CONFIRMADA'),
(14, 14, 7, 2, 28000.00, 5.00, 53200.00, 'Celebração de bodas de ouro', 'CONFIRMADA'),
(15, 15, 10, 3, 7500.00, 8.00, 20700.00, 'Apreciadores de vinho', 'CONFIRMADA'),
(1, 6, 4, 2, 8500.00, 10.00, 15300.00, 'Segunda viagem do cliente', 'PENDENTE'),
(3, 1, 5, 3, 7500.00, 12.00, 19800.00, 'Férias em família', 'CONFIRMADA'),
(5, 3, 6, 2, 4200.00, 5.00, 7980.00, 'Feriado prolongado', 'CONFIRMADA'),
(7, 5, 7, 1, 5200.00, 0.00, 5200.00, 'Ecoturismo individual', 'CANCELADA'),
(10, 9, 4, 5, 12500.00, 18.00, 51250.00, 'Grupo grande - desconto especial', 'CONFIRMADA');

-- ----------------------------------------------------------------------------
-- 1.8 INSERÇÃO DE PAGAMENTOS (25 registros)
-- ----------------------------------------------------------------------------
-- Objetivo: Registrar pagamentos das reservas (parcelados ou à vista)
-- Relacionamento: Cada pagamento vinculado a uma reserva
-- ----------------------------------------------------------------------------
INSERT INTO tb_pagamentos (id_reserva, forma_pagamento, numero_parcela, total_parcelas, valor_parcela, data_vencimento, status_pagamento, numero_transacao) VALUES
-- Reserva 1: parcelado em 3x
(1, 'CREDITO', 1, 3, 4500.00, '2024-11-15', 'PAGO', 'TXN001234567890'),
(1, 'CREDITO', 2, 3, 4500.00, '2024-12-15', 'PAGO', 'TXN001234567891'),
(1, 'CREDITO', 3, 3, 4500.00, '2025-01-15', 'PENDENTE', NULL),

-- Reserva 2: à vista
(2, 'PIX', 1, 1, 7980.00, '2024-11-20', 'PAGO', 'PIX20241120001'),

-- Reserva 3: parcelado em 5x
(3, 'CREDITO', 1, 5, 8500.00, '2024-11-10', 'PAGO', 'TXN002345678901'),
(3, 'CREDITO', 2, 5, 8500.00, '2024-12-10', 'PAGO', 'TXN002345678902'),
(3, 'CREDITO', 3, 5, 8500.00, '2025-01-10', 'PENDENTE', NULL),
(3, 'CREDITO', 4, 5, 8500.00, '2025-02-10', 'PENDENTE', NULL),
(3, 'CREDITO', 5, 5, 8500.00, '2025-03-10', 'PENDENTE', NULL),

-- Reserva 4: à vista
(4, 'DEBITO', 1, 1, 3500.00, '2024-11-25', 'PAGO', 'DEB20241125001'),

-- Reserva 5: parcelado em 2x
(5, 'CREDITO', 1, 2, 7176.00, '2024-11-30', 'PAGO', 'TXN003456789012'),
(5, 'CREDITO', 2, 2, 7176.00, '2024-12-30', 'PAGO', 'TXN003456789013'),

-- Reserva 6: parcelado em 4x
(6, 'CREDITO', 1, 4, 4037.50, '2024-12-01', 'PAGO', 'TXN004567890123'),
(6, 'CREDITO', 2, 4, 4037.50, '2025-01-01', 'PENDENTE', NULL),
(6, 'CREDITO', 3, 4, 4037.50, '2025-02-01', 'PENDENTE', NULL),
(6, 'CREDITO', 4, 4, 4037.50, '2025-03-01', 'PENDENTE', NULL),

-- Reserva 7: à vista
(7, 'PIX', 1, 1, 9600.00, '2024-12-05', 'PAGO', 'PIX20241205001'),

-- Reserva 8: parcelado em 2x
(8, 'CREDITO', 1, 2, 3780.00, '2024-12-10', 'PAGO', 'TXN005678901234'),
(8, 'CREDITO', 2, 2, 3780.00, '2025-01-10', 'PENDENTE', NULL),

-- Reserva 9: parcelado em 6x
(9, 'CREDITO', 1, 6, 6000.00, '2024-11-15', 'PAGO', 'TXN006789012345'),
(9, 'CREDITO', 2, 6, 6000.00, '2024-12-15', 'PAGO', 'TXN006789012346'),
(9, 'CREDITO', 3, 6, 6000.00, '2025-01-15', 'PENDENTE', NULL),

-- Reserva 10: à vista com desconto
(10, 'TRANSFERENCIA', 1, 1, 26400.00, '2024-12-01', 'PAGO', 'TRANSF20241201001'),

-- Reserva 11: parcelado em 10x
(11, 'CREDITO', 1, 10, 2200.00, '2024-11-20', 'PAGO', 'TXN007890123456');

-- ----------------------------------------------------------------------------
-- 1.9 INSERÇÃO DE AVALIAÇÕES (12 registros)
-- ----------------------------------------------------------------------------
-- Objetivo: Feedback dos clientes sobre os pacotes realizados
-- Regra: Nota de 1 a 5 estrelas, cliente avalia apenas uma vez por pacote
-- ----------------------------------------------------------------------------
INSERT INTO tb_avaliacoes (id_cliente, id_pacote, nota, comentario) VALUES
(1, 1, 5, 'Experiência incrível! Resort maravilhoso e praias paradisíacas. Recomendo!'),
(2, 3, 5, 'Gramado é encantadora. Hotel perfeito para lua de mel. Voltaremos!'),
(3, 9, 4, 'Cancún superou expectativas. Único ponto negativo foi o voo lotado.'),
(4, 4, 5, 'Chapada Diamantina é simplesmente espetacular! Guias muito competentes.'),
(5, 5, 5, 'Bonito é um paraíso ecológico. Flutuação no Rio da Prata foi inesquecível!'),
(6, 6, 5, 'Hotel das Cataratas é sensacional! Acordar com vista para as quedas não tem preço.'),
(7, 7, 4, 'Jericoacoara linda, mas infraestrutura um pouco limitada. Ainda assim, vale muito!'),
(8, 8, 5, 'Ouro Preto é cultura pura. Cidade histórica belíssima e bem preservada.'),
(9, 10, 5, 'Paris é mágica! Hotel incrível, localização perfeita. Experiência dos sonhos!'),
(10, 2, 5, 'Fernando de Noronha é surreal! Natureza preservada e mar cristalino. Top absoluto!'),
(12, 12, 5, 'Machu Picchu é místico e energizante. Uma das 7 maravilhas merece esse título!'),
(13, 13, 4, 'Patagônia impressionante! Glaciar Perito Moreno é gigantesco. Frio intenso, levar roupas adequadas.');

-- ============================================================================
-- 2. CONSULTAS SQL COMPLEXAS
-- ============================================================================
-- Objetivo: Demonstrar queries avançadas com JOINs, subconsultas, agregações
-- e funções analíticas para relatórios gerenciais
-- ============================================================================

-- ----------------------------------------------------------------------------
-- CONSULTA 1: Relatório de Vendas por Funcionário
-- ----------------------------------------------------------------------------
-- Objetivo: Analisar performance dos vendedores
-- Técnicas: INNER JOIN, GROUP BY, agregações (COUNT, SUM), ORDER BY
-- Caso de uso: Comissões e metas de vendas
-- ----------------------------------------------------------------------------
SELECT
    f.id_funcionario,
    f.nome_completo AS vendedor,
    f.cargo,
    COUNT(r.id_reserva) AS total_vendas,
    SUM(r.numero_passageiros) AS total_passageiros_vendidos,
    SUM(r.valor_total) AS faturamento_total,
    ROUND(AVG(r.valor_total), 2) AS ticket_medio,
    ROUND(AVG(r.desconto_percentual), 2) AS desconto_medio_concedido
FROM
    tb_funcionarios f
INNER JOIN
    tb_reservas r ON f.id_funcionario = r.id_funcionario
WHERE
    r.status_reserva IN ('CONFIRMADA', 'FINALIZADA')
GROUP BY
    f.id_funcionario, f.nome_completo, f.cargo
ORDER BY
    faturamento_total DESC;

-- ----------------------------------------------------------------------------
-- CONSULTA 2: Top 5 Pacotes Mais Vendidos
-- ----------------------------------------------------------------------------
-- Objetivo: Identificar pacotes mais populares
-- Técnicas: Multiple JOINs, GROUP BY, HAVING, LIMIT
-- Caso de uso: Planejamento de marketing e reposição de estoque
-- ----------------------------------------------------------------------------
SELECT
    p.id_pacote,
    p.nome_pacote,
    d.nome_destino,
    d.pais,
    COUNT(r.id_reserva) AS quantidade_vendas,
    SUM(r.numero_passageiros) AS total_passageiros,
    SUM(r.valor_total) AS receita_total,
    ROUND(AVG(av.nota), 2) AS avaliacao_media
FROM
    tb_pacotes_turisticos p
INNER JOIN
    tb_destinos d ON p.id_destino = d.id_destino
LEFT JOIN
    tb_reservas r ON p.id_pacote = r.id_pacote
    AND r.status_reserva = 'CONFIRMADA'
LEFT JOIN
    tb_avaliacoes av ON p.id_pacote = av.id_pacote
GROUP BY
    p.id_pacote, p.nome_pacote, d.nome_destino, d.pais
HAVING
    COUNT(r.id_reserva) > 0
ORDER BY
    quantidade_vendas DESC, receita_total DESC
LIMIT 5;

-- ----------------------------------------------------------------------------
-- CONSULTA 3: Análise Financeira de Pagamentos
-- ----------------------------------------------------------------------------
-- Objetivo: Controle financeiro - valores recebidos vs pendentes
-- Técnicas: Subconsulta correlacionada, CASE, agregações condicionais
-- Caso de uso: Fluxo de caixa e inadimplência
-- ----------------------------------------------------------------------------
SELECT
    DATE_TRUNC('month', p.data_pagamento) AS mes_ano,
    COUNT(DISTINCT p.id_reserva) AS total_reservas_com_pagamento,
    COUNT(p.id_pagamento) AS total_parcelas,
    SUM(CASE WHEN p.status_pagamento = 'PAGO' THEN p.valor_parcela ELSE 0 END) AS valor_recebido,
    SUM(CASE WHEN p.status_pagamento = 'PENDENTE' THEN p.valor_parcela ELSE 0 END) AS valor_pendente,
    SUM(CASE WHEN p.status_pagamento = 'CANCELADO' THEN p.valor_parcela ELSE 0 END) AS valor_cancelado,
    SUM(p.valor_parcela) AS valor_total,
    ROUND(
        100.0 * SUM(CASE WHEN p.status_pagamento = 'PAGO' THEN p.valor_parcela ELSE 0 END) /
        NULLIF(SUM(p.valor_parcela), 0),
        2
    ) AS percentual_recebido
FROM
    tb_pagamentos p
GROUP BY
    DATE_TRUNC('month', p.data_pagamento)
ORDER BY
    mes_ano DESC;

-- ----------------------------------------------------------------------------
-- CONSULTA 4: Clientes VIP (Mais Gastaram)
-- ----------------------------------------------------------------------------
-- Objetivo: Identificar clientes de maior valor
-- Técnicas: Subconsulta, Window Functions (ROW_NUMBER), JOINs
-- Caso de uso: Programa de fidelidade e marketing direcionado
-- ----------------------------------------------------------------------------
WITH ranking_clientes AS (
    SELECT
        c.id_cliente,
        c.nome_completo,
        c.email,
        c.telefone,
        c.cidade,
        c.estado,
        COUNT(r.id_reserva) AS total_compras,
        SUM(r.valor_total) AS valor_total_gasto,
        ROUND(AVG(r.valor_total), 2) AS ticket_medio_compra,
        MAX(r.data_reserva) AS ultima_compra,
        ROW_NUMBER() OVER (ORDER BY SUM(r.valor_total) DESC) AS ranking
    FROM
        tb_clientes c
    INNER JOIN
        tb_reservas r ON c.id_cliente = r.id_cliente
    WHERE
        r.status_reserva IN ('CONFIRMADA', 'FINALIZADA')
    GROUP BY
        c.id_cliente, c.nome_completo, c.email, c.telefone, c.cidade, c.estado
)
SELECT
    ranking AS posicao,
    nome_completo,
    email,
    cidade || ' - ' || estado AS localizacao,
    total_compras,
    TO_CHAR(valor_total_gasto, 'L999G999G999D99') AS valor_gasto_formatado,
    TO_CHAR(ticket_medio_compra, 'L999G999D99') AS ticket_medio,
    TO_CHAR(ultima_compra, 'DD/MM/YYYY') AS data_ultima_compra
FROM
    ranking_clientes
WHERE
    ranking <= 10
ORDER BY
    ranking;

-- ----------------------------------------------------------------------------
-- CONSULTA 5: Ocupação de Pacotes e Vagas Disponíveis
-- ----------------------------------------------------------------------------
-- Objetivo: Controle de disponibilidade de vagas
-- Técnicas: Subconsulta, agregação, cálculo percentual
-- Caso de uso: Gestão de estoque e planejamento de novos pacotes
-- ----------------------------------------------------------------------------
SELECT
    p.id_pacote,
    p.nome_pacote,
    d.nome_destino,
    p.data_inicio,
    p.data_fim,
    p.vagas_disponiveis AS vagas_originais,
    COALESCE(SUM(r.numero_passageiros), 0) AS vagas_vendidas,
    p.vagas_disponiveis - COALESCE(SUM(r.numero_passageiros), 0) AS vagas_restantes,
    ROUND(
        100.0 * COALESCE(SUM(r.numero_passageiros), 0) /
        NULLIF(p.vagas_disponiveis, 0),
        2
    ) AS percentual_ocupacao,
    CASE
        WHEN p.vagas_disponiveis - COALESCE(SUM(r.numero_passageiros), 0) <= 0 THEN 'ESGOTADO'
        WHEN p.vagas_disponiveis - COALESCE(SUM(r.numero_passageiros), 0) <= 5 THEN 'ÚLTIMAS VAGAS'
        ELSE 'DISPONÍVEL'
    END AS status_disponibilidade
FROM
    tb_pacotes_turisticos p
INNER JOIN
    tb_destinos d ON p.id_destino = d.id_destino
LEFT JOIN
    tb_reservas r ON p.id_pacote = r.id_pacote
    AND r.status_reserva IN ('CONFIRMADA', 'PENDENTE')
WHERE
    p.data_inicio >= CURRENT_DATE
GROUP BY
    p.id_pacote, p.nome_pacote, d.nome_destino, p.data_inicio,
    p.data_fim, p.vagas_disponiveis
ORDER BY
    percentual_ocupacao DESC;

-- ----------------------------------------------------------------------------
-- CONSULTA 6: Destinos Mais Procurados por Categoria
-- ----------------------------------------------------------------------------
-- Objetivo: Análise de preferências de viagem por tipo de turismo
-- Técnicas: GROUP BY com ROLLUP (ou equivalente), múltiplas agregações
-- Caso de uso: Estratégia de expansão e novos destinos
-- ----------------------------------------------------------------------------
SELECT
    d.categoria,
    d.nome_destino,
    d.pais,
    COUNT(DISTINCT p.id_pacote) AS total_pacotes_disponiveis,
    COUNT(r.id_reserva) AS total_reservas,
    SUM(r.numero_passageiros) AS total_turistas,
    SUM(r.valor_total) AS receita_total,
    ROUND(AVG(av.nota), 2) AS avaliacao_media
FROM
    tb_destinos d
LEFT JOIN
    tb_pacotes_turisticos p ON d.id_destino = p.id_destino
LEFT JOIN
    tb_reservas r ON p.id_pacote = r.id_pacote
    AND r.status_reserva = 'CONFIRMADA'
LEFT JOIN
    tb_avaliacoes av ON p.id_pacote = av.id_pacote
GROUP BY
    d.categoria, d.nome_destino, d.pais
ORDER BY
    d.categoria, total_reservas DESC;

-- ----------------------------------------------------------------------------
-- CONSULTA 7: Relatório de Formas de Pagamento Preferidas
-- ----------------------------------------------------------------------------
-- Objetivo: Entender comportamento de pagamento dos clientes
-- Técnicas: GROUP BY, CASE, percentuais
-- Caso de uso: Negociação com operadoras de cartão e estratégia de descontos
-- ----------------------------------------------------------------------------
SELECT
    pg.forma_pagamento,
    COUNT(DISTINCT pg.id_reserva) AS total_reservas,
    COUNT(pg.id_pagamento) AS total_parcelas,
    ROUND(AVG(pg.total_parcelas), 2) AS media_parcelas,
    SUM(pg.valor_parcela) AS valor_total_transacionado,
    SUM(CASE WHEN pg.status_pagamento = 'PAGO' THEN pg.valor_parcela ELSE 0 END) AS valor_pago,
    SUM(CASE WHEN pg.status_pagamento = 'PENDENTE' THEN pg.valor_parcela ELSE 0 END) AS valor_pendente,
    ROUND(
        100.0 * COUNT(pg.id_pagamento) /
        SUM(COUNT(pg.id_pagamento)) OVER (),
        2
    ) AS percentual_uso
FROM
    tb_pagamentos pg
GROUP BY
    pg.forma_pagamento
ORDER BY
    total_reservas DESC;

-- ----------------------------------------------------------------------------
-- CONSULTA 8: Pacotes com Melhor Custo-Benefício (Subconsulta Complexa)
-- ----------------------------------------------------------------------------
-- Objetivo: Ranquear pacotes por preço/dia e avaliação
-- Técnicas: Subconsulta correlacionada, múltiplos JOINs, ranking
-- Caso de uso: Recomendações para clientes com orçamento limitado
-- ----------------------------------------------------------------------------
SELECT
    p.nome_pacote,
    d.nome_destino,
    h.nome_hotel,
    h.classificacao_estrelas,
    p.duracao_dias,
    p.preco_total,
    ROUND(p.preco_total / p.duracao_dias, 2) AS preco_por_dia,
    p.regime_alimentar,
    (
        SELECT ROUND(AVG(av.nota), 2)
        FROM tb_avaliacoes av
        WHERE av.id_pacote = p.id_pacote
    ) AS avaliacao_media,
    (
        SELECT COUNT(*)
        FROM tb_avaliacoes av
        WHERE av.id_pacote = p.id_pacote
    ) AS quantidade_avaliacoes,
    p.vagas_disponiveis - COALESCE(
        (
            SELECT SUM(r.numero_passageiros)
            FROM tb_reservas r
            WHERE r.id_pacote = p.id_pacote
            AND r.status_reserva IN ('CONFIRMADA', 'PENDENTE')
        ), 0
    ) AS vagas_restantes
FROM
    tb_pacotes_turisticos p
INNER JOIN
    tb_destinos d ON p.id_destino = d.id_destino
INNER JOIN
    tb_hoteis h ON p.id_hotel = h.id_hotel
WHERE
    p.data_inicio >= CURRENT_DATE
    AND p.status = 'DISPONIVEL'
ORDER BY
    preco_por_dia ASC, avaliacao_media DESC NULLS LAST;

-- ----------------------------------------------------------------------------
-- CONSULTA 9: Análise de Descontos Concedidos
-- ----------------------------------------------------------------------------
-- Objetivo: Avaliar impacto dos descontos na receita
-- Técnicas: Cálculos financeiros, agregações
-- Caso de uso: Política comercial e ajuste de margens
-- ----------------------------------------------------------------------------
SELECT
    CASE
        WHEN r.desconto_percentual = 0 THEN 'Sem desconto'
        WHEN r.desconto_percentual BETWEEN 0.01 AND 5 THEN '1% a 5%'
        WHEN r.desconto_percentual BETWEEN 5.01 AND 10 THEN '5% a 10%'
        WHEN r.desconto_percentual BETWEEN 10.01 AND 15 THEN '10% a 15%'
        ELSE 'Acima de 15%'
    END AS faixa_desconto,
    COUNT(r.id_reserva) AS quantidade_vendas,
    SUM(r.numero_passageiros) AS total_passageiros,
    SUM(r.valor_unitario * r.numero_passageiros) AS valor_sem_desconto,
    SUM(r.valor_total) AS valor_com_desconto,
    SUM(r.valor_unitario * r.numero_passageiros) - SUM(r.valor_total) AS valor_descontado,
    ROUND(AVG(r.desconto_percentual), 2) AS desconto_medio_percentual
FROM
    tb_reservas r
WHERE
    r.status_reserva IN ('CONFIRMADA', 'FINALIZADA')
GROUP BY
    faixa_desconto
ORDER BY
    MIN(r.desconto_percentual);

-- ----------------------------------------------------------------------------
-- CONSULTA 10: Relatório Gerencial Completo (Dashboard Executivo)
-- ----------------------------------------------------------------------------
-- Objetivo: Visão consolidada do negócio em um único SELECT
-- Técnicas: Múltiplas subconsultas, agregações cruzadas
-- Caso de uso: Apresentação para diretoria
-- ----------------------------------------------------------------------------
SELECT
    (SELECT COUNT(*) FROM tb_clientes) AS total_clientes_cadastrados,
    (SELECT COUNT(*) FROM tb_funcionarios WHERE status = 'ATIVO') AS total_funcionarios_ativos,
    (SELECT COUNT(*) FROM tb_destinos WHERE status = 'ATIVO') AS total_destinos_ativos,
    (SELECT COUNT(*) FROM tb_pacotes_turisticos WHERE status = 'DISPONIVEL') AS total_pacotes_disponiveis,
    (SELECT COUNT(*) FROM tb_reservas WHERE status_reserva = 'CONFIRMADA') AS total_reservas_confirmadas,
    (SELECT SUM(numero_passageiros) FROM tb_reservas WHERE status_reserva = 'CONFIRMADA') AS total_passageiros_atendidos,
    (SELECT TO_CHAR(SUM(valor_total), 'L999G999G999D99') FROM tb_reservas WHERE status_reserva IN ('CONFIRMADA', 'FINALIZADA')) AS receita_total_confirmada,
    (SELECT TO_CHAR(SUM(valor_parcela), 'L999G999G999D99') FROM tb_pagamentos WHERE status_pagamento = 'PAGO') AS valor_total_recebido,
    (SELECT TO_CHAR(SUM(valor_parcela), 'L999G999G999D99') FROM tb_pagamentos WHERE status_pagamento = 'PENDENTE') AS valor_total_pendente,
    (SELECT ROUND(AVG(nota), 2) FROM tb_avaliacoes) AS avaliacao_media_geral,
    (SELECT COUNT(*) FROM tb_avaliacoes WHERE nota >= 4) AS avaliacoes_positivas,
    (SELECT COUNT(*) FROM tb_avaliacoes) AS total_avaliacoes;

-- ============================================================================
-- RESUMO DA ETAPA 2
-- ============================================================================
-- DADOS INSERIDOS:
-- - 15 Clientes
-- - 12 Funcionários
-- - 15 Destinos
-- - 18 Hotéis
-- - 10 Transportes
-- - 15 Pacotes Turísticos
-- - 20 Reservas
-- - 25 Pagamentos (incluindo parcelamentos)
-- - 12 Avaliações
--
-- CONSULTAS CRIADAS:
-- 1. Performance de vendedores
-- 2. Top 5 pacotes mais vendidos
-- 3. Análise financeira de pagamentos
-- 4. Clientes VIP (ranking)
-- 5. Ocupação de pacotes
-- 6. Destinos por categoria
-- 7. Formas de pagamento
-- 8. Pacotes com melhor custo-benefício
-- 9. Análise de descontos
-- 10. Dashboard executivo
-- ============================================================================

SELECT 'Etapa 2 concluída com sucesso! Dados inseridos e consultas criadas.' AS status;
