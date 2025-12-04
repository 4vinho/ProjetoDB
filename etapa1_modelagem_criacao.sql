-- ============================================================================
-- ETAPA 1: MODELAGEM E CRIAÇÃO DO BANCO DE DADOS
-- Projeto: Sistema de Banco de Dados para Agência de Turismo
-- Empresa: Viagens & Aventuras Ltda | SGBD: PostgreSQL
-- ============================================================================

-- 1. CRIAÇÃO DO BANCO DE DADOS
-- Encoding UTF8 para suportar caracteres especiais (acentuação)
DROP DATABASE IF EXISTS agencia_turismo;

CREATE DATABASE agencia_turismo
    WITH OWNER = postgres ENCODING = 'UTF8'
    LC_COLLATE = 'pt_BR.UTF-8' LC_CTYPE = 'pt_BR.UTF-8'
    TABLESPACE = pg_default CONNECTION LIMIT = -1;

\c agencia_turismo;

-- ============================================================================
-- 2. CRIAÇÃO DAS TABELAS (DDL)
-- Estrutura normalizada seguindo a 3ª Forma Normal (3FN)
-- ============================================================================

-- Tabela: tb_clientes
-- Descrição: Armazena informações dos clientes da agência
-- Regras: CPF único, Email único, Telefone obrigatório para contato
CREATE TABLE tb_clientes (
    id_cliente SERIAL PRIMARY KEY,
    nome_completo VARCHAR(150) NOT NULL,
    cpf CHAR(11) NOT NULL UNIQUE,
    data_nascimento DATE NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    telefone VARCHAR(15) NOT NULL,
    endereco VARCHAR(200),
    cidade VARCHAR(100),
    estado CHAR(2),
    cep CHAR(8),
    data_cadastro TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_cpf_valido CHECK (LENGTH(cpf) = 11),
    CONSTRAINT chk_email_formato CHECK (email ~* '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$'),
    CONSTRAINT chk_data_nascimento CHECK (data_nascimento < CURRENT_DATE),
    CONSTRAINT chk_estado_uf CHECK (estado ~ '^[A-Z]{2}$')
);

COMMENT ON TABLE tb_clientes IS 'Cadastro de clientes da agência de turismo';
COMMENT ON COLUMN tb_clientes.cpf IS 'CPF do cliente (apenas números, sem formatação)';

-- Tabela: tb_funcionarios
-- Descrição: Armazena dados dos funcionários da agência
-- Regras: CPF único, Email corporativo único, Salário positivo, Data admissão válida
CREATE TABLE tb_funcionarios (
    id_funcionario SERIAL PRIMARY KEY,
    nome_completo VARCHAR(150) NOT NULL,
    cpf CHAR(11) NOT NULL UNIQUE,
    email_corporativo VARCHAR(100) NOT NULL UNIQUE,
    telefone VARCHAR(15) NOT NULL,
    cargo VARCHAR(50) NOT NULL,
    salario DECIMAL(10, 2) NOT NULL,
    data_admissao DATE NOT NULL,
    status VARCHAR(20) DEFAULT 'ATIVO',
    CONSTRAINT chk_func_cpf_valido CHECK (LENGTH(cpf) = 11),
    CONSTRAINT chk_func_salario_positivo CHECK (salario > 0),
    CONSTRAINT chk_func_data_admissao CHECK (data_admissao <= CURRENT_DATE),
    CONSTRAINT chk_func_status CHECK (status IN ('ATIVO', 'INATIVO', 'FERIAS', 'AFASTADO'))
);

COMMENT ON TABLE tb_funcionarios IS 'Cadastro de funcionários da agência';
COMMENT ON COLUMN tb_funcionarios.cargo IS 'Cargo: Vendedor, Gerente, Atendente, etc.';

-- Tabela: tb_destinos
-- Descrição: Catálogo de destinos turísticos oferecidos
-- Regras: Informações geográficas completas, Categoria de turismo, Status ativo/inativo
CREATE TABLE tb_destinos (
    id_destino SERIAL PRIMARY KEY,
    nome_destino VARCHAR(100) NOT NULL,
    pais VARCHAR(50) NOT NULL,
    estado VARCHAR(50),
    cidade VARCHAR(100) NOT NULL,
    descricao TEXT,
    categoria VARCHAR(30) NOT NULL,
    clima VARCHAR(50),
    idioma_principal VARCHAR(30),
    moeda_local VARCHAR(30),
    status VARCHAR(20) DEFAULT 'ATIVO',
    CONSTRAINT chk_dest_categoria CHECK (categoria IN ('PRAIA', 'MONTANHA', 'URBANO', 'AVENTURA', 'CULTURAL', 'ECOLOGICO', 'RELIGIOSO')),
    CONSTRAINT chk_dest_status CHECK (status IN ('ATIVO', 'INATIVO'))
);

COMMENT ON TABLE tb_destinos IS 'Catálogo de destinos turísticos disponíveis';

-- Tabela: tb_hoteis
-- Descrição: Cadastro de hotéis parceiros em cada destino
-- Relacionamento: N:1 com tb_destinos (vários hotéis por destino)
-- Regras: Estrelas entre 1 e 5, Diária mínima positiva
CREATE TABLE tb_hoteis (
    id_hotel SERIAL PRIMARY KEY,
    id_destino INTEGER NOT NULL,
    nome_hotel VARCHAR(150) NOT NULL,
    endereco VARCHAR(200) NOT NULL,
    classificacao_estrelas INTEGER,
    descricao TEXT,
    comodidades TEXT,
    valor_diaria_minima DECIMAL(10, 2) NOT NULL,
    telefone VARCHAR(20),
    email VARCHAR(100),
    status VARCHAR(20) DEFAULT 'ATIVO',
    CONSTRAINT fk_hotel_destino FOREIGN KEY (id_destino)
        REFERENCES tb_destinos(id_destino) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT chk_hotel_estrelas CHECK (classificacao_estrelas BETWEEN 1 AND 5),
    CONSTRAINT chk_hotel_diaria_positiva CHECK (valor_diaria_minima > 0),
    CONSTRAINT chk_hotel_status CHECK (status IN ('ATIVO', 'INATIVO'))
);

COMMENT ON TABLE tb_hoteis IS 'Hotéis parceiros disponíveis em cada destino';
COMMENT ON COLUMN tb_hoteis.comodidades IS 'Wi-Fi, Piscina, Academia, etc.';

-- Tabela: tb_transportes
-- Descrição: Meios de transporte disponíveis (aéreo, terrestre, marítimo)
-- Regras: Preço positivo, Capacidade maior que zero
CREATE TABLE tb_transportes (
    id_transporte SERIAL PRIMARY KEY,
    tipo_transporte VARCHAR(30) NOT NULL,
    empresa_parceira VARCHAR(100) NOT NULL,
    modelo VARCHAR(50),
    capacidade_passageiros INTEGER NOT NULL,
    classe VARCHAR(30),
    preco_base DECIMAL(10, 2) NOT NULL,
    status VARCHAR(20) DEFAULT 'ATIVO',
    CONSTRAINT chk_transp_tipo CHECK (tipo_transporte IN ('AEREO', 'ONIBUS', 'VAN', 'NAVIO', 'TREM')),
    CONSTRAINT chk_transp_capacidade CHECK (capacidade_passageiros > 0),
    CONSTRAINT chk_transp_preco CHECK (preco_base > 0),
    CONSTRAINT chk_transp_status CHECK (status IN ('ATIVO', 'INATIVO', 'MANUTENCAO'))
);

COMMENT ON TABLE tb_transportes IS 'Meios de transporte disponíveis para os pacotes';

-- Tabela: tb_pacotes_turisticos
-- Descrição: Pacotes turísticos montados pela agência
-- Relacionamentos: N:1 com destinos, hotéis e transportes
-- Regras: Preço positivo, Duração mínima 1 dia, Vagas não negativas, Datas válidas
CREATE TABLE tb_pacotes_turisticos (
    id_pacote SERIAL PRIMARY KEY,
    nome_pacote VARCHAR(150) NOT NULL,
    id_destino INTEGER NOT NULL,
    id_hotel INTEGER NOT NULL,
    id_transporte INTEGER NOT NULL,
    descricao_completa TEXT,
    duracao_dias INTEGER NOT NULL,
    data_inicio DATE NOT NULL,
    data_fim DATE NOT NULL,
    preco_total DECIMAL(10, 2) NOT NULL,
    vagas_disponiveis INTEGER NOT NULL,
    regime_alimentar VARCHAR(30),
    incluso TEXT,
    nao_incluso TEXT,
    status VARCHAR(20) DEFAULT 'DISPONIVEL',
    CONSTRAINT fk_pacote_destino FOREIGN KEY (id_destino) REFERENCES tb_destinos(id_destino) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_pacote_hotel FOREIGN KEY (id_hotel) REFERENCES tb_hoteis(id_hotel) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_pacote_transporte FOREIGN KEY (id_transporte) REFERENCES tb_transportes(id_transporte) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT chk_pacote_duracao CHECK (duracao_dias >= 1),
    CONSTRAINT chk_pacote_datas CHECK (data_fim > data_inicio),
    CONSTRAINT chk_pacote_preco CHECK (preco_total > 0),
    CONSTRAINT chk_pacote_vagas CHECK (vagas_disponiveis >= 0),
    CONSTRAINT chk_pacote_regime CHECK (regime_alimentar IN ('CAFE_MANHA', 'MEIA_PENSAO', 'PENSAO_COMPLETA', 'ALL_INCLUSIVE', 'SEM_ALIMENTACAO')),
    CONSTRAINT chk_pacote_status CHECK (status IN ('DISPONIVEL', 'ESGOTADO', 'CANCELADO', 'FINALIZADO'))
);

COMMENT ON TABLE tb_pacotes_turisticos IS 'Pacotes turísticos completos oferecidos pela agência';
COMMENT ON COLUMN tb_pacotes_turisticos.incluso IS 'Itens inclusos no pacote';

-- Tabela: tb_reservas
-- Descrição: Reservas/vendas realizadas pela agência
-- Relacionamentos: N:1 com clientes, pacotes e funcionários (vendedor)
-- Regras: Número passageiros positivo, Valor total = preço × passageiros × (1 - desconto)
CREATE TABLE tb_reservas (
    id_reserva SERIAL PRIMARY KEY,
    id_cliente INTEGER NOT NULL,
    id_pacote INTEGER NOT NULL,
    id_funcionario INTEGER NOT NULL,
    data_reserva TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    numero_passageiros INTEGER NOT NULL,
    valor_unitario DECIMAL(10, 2) NOT NULL,
    desconto_percentual DECIMAL(5, 2) DEFAULT 0.00,
    valor_total DECIMAL(10, 2) NOT NULL,
    observacoes TEXT,
    status_reserva VARCHAR(30) DEFAULT 'CONFIRMADA',
    CONSTRAINT fk_reserva_cliente FOREIGN KEY (id_cliente) REFERENCES tb_clientes(id_cliente) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_reserva_pacote FOREIGN KEY (id_pacote) REFERENCES tb_pacotes_turisticos(id_pacote) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_reserva_funcionario FOREIGN KEY (id_funcionario) REFERENCES tb_funcionarios(id_funcionario) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT chk_reserva_passageiros CHECK (numero_passageiros > 0),
    CONSTRAINT chk_reserva_valor_unitario CHECK (valor_unitario > 0),
    CONSTRAINT chk_reserva_desconto CHECK (desconto_percentual >= 0 AND desconto_percentual <= 100),
    CONSTRAINT chk_reserva_valor_total CHECK (valor_total > 0),
    CONSTRAINT chk_reserva_status CHECK (status_reserva IN ('CONFIRMADA', 'PENDENTE', 'CANCELADA', 'FINALIZADA'))
);

COMMENT ON TABLE tb_reservas IS 'Reservas e vendas de pacotes turísticos';
COMMENT ON COLUMN tb_reservas.id_funcionario IS 'Funcionário (vendedor) responsável pela venda';

-- Tabela: tb_pagamentos
-- Descrição: Controle de pagamentos das reservas
-- Relacionamento: N:1 com reservas (uma reserva pode ter vários pagamentos)
-- Regras: Valor parcela positivo, Suporte a pagamento parcelado, Status controlado
CREATE TABLE tb_pagamentos (
    id_pagamento SERIAL PRIMARY KEY,
    id_reserva INTEGER NOT NULL,
    data_pagamento TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    forma_pagamento VARCHAR(30) NOT NULL,
    numero_parcela INTEGER DEFAULT 1,
    total_parcelas INTEGER DEFAULT 1,
    valor_parcela DECIMAL(10, 2) NOT NULL,
    data_vencimento DATE,
    status_pagamento VARCHAR(30) DEFAULT 'PENDENTE',
    numero_transacao VARCHAR(100),
    CONSTRAINT fk_pagamento_reserva FOREIGN KEY (id_reserva) REFERENCES tb_reservas(id_reserva) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT chk_pagto_forma CHECK (forma_pagamento IN ('DINHEIRO', 'DEBITO', 'CREDITO', 'PIX', 'TRANSFERENCIA', 'BOLETO')),
    CONSTRAINT chk_pagto_valor CHECK (valor_parcela > 0),
    CONSTRAINT chk_pagto_parcelas CHECK (numero_parcela > 0 AND total_parcelas > 0 AND numero_parcela <= total_parcelas),
    CONSTRAINT chk_pagto_status CHECK (status_pagamento IN ('PENDENTE', 'PAGO', 'CANCELADO', 'ESTORNADO'))
);

COMMENT ON TABLE tb_pagamentos IS 'Controle de pagamentos e parcelas das reservas';

-- Tabela: tb_avaliacoes
-- Descrição: Avaliações dos clientes sobre os pacotes realizados
-- Relacionamentos: N:1 com clientes e pacotes
-- Regras: Nota entre 1 e 5, Cliente avalia apenas uma vez por pacote
CREATE TABLE tb_avaliacoes (
    id_avaliacao SERIAL PRIMARY KEY,
    id_cliente INTEGER NOT NULL,
    id_pacote INTEGER NOT NULL,
    nota INTEGER NOT NULL,
    comentario TEXT,
    data_avaliacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_avaliacao_cliente FOREIGN KEY (id_cliente) REFERENCES tb_clientes(id_cliente) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_avaliacao_pacote FOREIGN KEY (id_pacote) REFERENCES tb_pacotes_turisticos(id_pacote) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT chk_avaliacao_nota CHECK (nota BETWEEN 1 AND 5),
    CONSTRAINT uk_avaliacao_cliente_pacote UNIQUE (id_cliente, id_pacote)
);

COMMENT ON TABLE tb_avaliacoes IS 'Avaliações e feedbacks dos clientes sobre os pacotes';

-- Tabela: tb_auditoria
-- Descrição: Tabela de auditoria para registrar operações críticas (será usada pelos triggers)
-- Regras: Registro automático via triggers, Não permite exclusão de registros
CREATE TABLE tb_auditoria (
    id_auditoria SERIAL PRIMARY KEY,
    tabela_afetada VARCHAR(50) NOT NULL,
    operacao VARCHAR(10) NOT NULL,
    usuario_db VARCHAR(50) NOT NULL,
    data_hora TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    dados_antigos JSONB,
    dados_novos JSONB,
    id_registro_afetado INTEGER,
    observacao TEXT,
    CONSTRAINT chk_audit_operacao CHECK (operacao IN ('INSERT', 'UPDATE', 'DELETE'))
);

COMMENT ON TABLE tb_auditoria IS 'Tabela de auditoria para rastreamento de operações críticas';
COMMENT ON COLUMN tb_auditoria.dados_antigos IS 'Dados antes da operação (formato JSON)';

-- ============================================================================
-- 3. CRIAÇÃO DE ÍNDICES BÁSICOS
-- Índices para melhorar performance de consultas frequentes
-- ============================================================================

-- Índices em chaves estrangeiras (melhoram JOINs)
CREATE INDEX idx_hoteis_destino ON tb_hoteis(id_destino);
CREATE INDEX idx_pacotes_destino ON tb_pacotes_turisticos(id_destino);
CREATE INDEX idx_pacotes_hotel ON tb_pacotes_turisticos(id_hotel);
CREATE INDEX idx_pacotes_transporte ON tb_pacotes_turisticos(id_transporte);
CREATE INDEX idx_reservas_cliente ON tb_reservas(id_cliente);
CREATE INDEX idx_reservas_pacote ON tb_reservas(id_pacote);
CREATE INDEX idx_reservas_funcionario ON tb_reservas(id_funcionario);
CREATE INDEX idx_pagamentos_reserva ON tb_pagamentos(id_reserva);
CREATE INDEX idx_avaliacoes_cliente ON tb_avaliacoes(id_cliente);
CREATE INDEX idx_avaliacoes_pacote ON tb_avaliacoes(id_pacote);

-- Índices em colunas frequentemente utilizadas em buscas
CREATE INDEX idx_clientes_cpf ON tb_clientes(cpf);
CREATE INDEX idx_clientes_email ON tb_clientes(email);
CREATE INDEX idx_funcionarios_cpf ON tb_funcionarios(cpf);
CREATE INDEX idx_pacotes_datas ON tb_pacotes_turisticos(data_inicio, data_fim);
CREATE INDEX idx_pacotes_status ON tb_pacotes_turisticos(status);
CREATE INDEX idx_reservas_data ON tb_reservas(data_reserva);
CREATE INDEX idx_reservas_status ON tb_reservas(status_reserva);

-- ============================================================================
-- RESUMO DA MODELAGEM
-- NORMALIZAÇÃO (3ª Forma Normal):
-- 1FN - Todos os atributos são atômicos
-- 2FN - Não há dependências parciais
-- 3FN - Não há dependências transitivas
--
-- RELACIONAMENTOS:
-- tb_clientes (1) ----< (N) tb_reservas
-- tb_funcionarios (1) ----< (N) tb_reservas
-- tb_destinos (1) ----< (N) tb_hoteis
-- tb_destinos (1) ----< (N) tb_pacotes_turisticos
-- tb_hoteis (1) ----< (N) tb_pacotes_turisticos
-- tb_transportes (1) ----< (N) tb_pacotes_turisticos
-- tb_pacotes_turisticos (1) ----< (N) tb_reservas
-- tb_reservas (1) ----< (N) tb_pagamentos
-- tb_clientes (1) ----< (N) tb_avaliacoes
-- tb_pacotes_turisticos (1) ----< (N) tb_avaliacoes
-- ============================================================================

SELECT 'Etapa 1 concluída com sucesso! Banco de dados criado e estruturado.' AS status;
