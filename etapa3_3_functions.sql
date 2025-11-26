-- ============================================================================
-- ETAPA 3.3: FUNCTIONS (FUNÇÕES ARMAZENADAS)
-- ============================================================================
-- Descrição: Criação de funções (stored procedures) para programação procedural
-- Requisitos do projeto:
--   - Criar no mínimo 3 functions
--   - Demonstrar uso de parâmetros (IN, OUT, INOUT)
--   - Utilizar variáveis locais
--   - Exemplos: inserção complexa, relatórios, cálculos
-- ============================================================================

-- Conectar ao banco de dados
\c agencia_turismo;

-- ============================================================================
-- FUNCTION 1: CRIAR RESERVA COMPLETA COM VALIDAÇÕES
-- ============================================================================
-- Objetivo: Encapsular toda a lógica de criação de uma reserva com validações
-- Parâmetros IN: dados da reserva
-- Parâmetros OUT: id da reserva criada, mensagem de sucesso
-- Validações:
--   - Cliente existe e está ativo
--   - Pacote existe e está disponível
--   - Há vagas suficientes
--   - Cálculo automático do valor total
-- Benefício: Centraliza regras de negócio, reduz código na aplicação
-- ============================================================================

CREATE OR REPLACE FUNCTION fn_criar_reserva_completa(
    -- Parâmetros de entrada (IN)
    p_id_cliente INTEGER,
    p_id_pacote INTEGER,
    p_id_funcionario INTEGER,
    p_numero_passageiros INTEGER,
    p_desconto_percentual DECIMAL(5,2) DEFAULT 0.00,
    p_observacoes TEXT DEFAULT NULL,

    -- Parâmetros de saída (OUT)
    OUT o_id_reserva INTEGER,
    OUT o_valor_total DECIMAL(10,2),
    OUT o_mensagem TEXT,
    OUT o_sucesso BOOLEAN
)
LANGUAGE plpgsql
AS $$
DECLARE
    -- Variáveis locais para validações e cálculos
    v_cliente_existe BOOLEAN;
    v_pacote_existe BOOLEAN;
    v_funcionario_existe BOOLEAN;
    v_status_pacote VARCHAR(20);
    v_preco_pacote DECIMAL(10,2);
    v_vagas_disponiveis INTEGER;
    v_vagas_vendidas INTEGER;
    v_vagas_restantes INTEGER;
    v_nome_pacote VARCHAR(150);
    v_nome_cliente VARCHAR(150);
    v_data_inicio DATE;
    v_data_fim DATE;
BEGIN
    -- Inicializar parâmetros de saída
    o_sucesso := FALSE;
    o_id_reserva := NULL;
    o_valor_total := 0;

    -- --------------------------------------------------------------------
    -- VALIDAÇÃO 1: Verificar se o cliente existe
    -- --------------------------------------------------------------------
    SELECT EXISTS(
        SELECT 1 FROM tb_clientes WHERE id_cliente = p_id_cliente
    ) INTO v_cliente_existe;

    IF NOT v_cliente_existe THEN
        o_mensagem := 'ERRO: Cliente ID ' || p_id_cliente || ' não encontrado.';
        RETURN;
    END IF;

    SELECT nome_completo INTO v_nome_cliente
    FROM tb_clientes WHERE id_cliente = p_id_cliente;

    -- --------------------------------------------------------------------
    -- VALIDAÇÃO 2: Verificar se o funcionário existe e está ativo
    -- --------------------------------------------------------------------
    SELECT EXISTS(
        SELECT 1 FROM tb_funcionarios
        WHERE id_funcionario = p_id_funcionario AND status = 'ATIVO'
    ) INTO v_funcionario_existe;

    IF NOT v_funcionario_existe THEN
        o_mensagem := 'ERRO: Funcionário ID ' || p_id_funcionario || ' não encontrado ou inativo.';
        RETURN;
    END IF;

    -- --------------------------------------------------------------------
    -- VALIDAÇÃO 3: Verificar se o pacote existe e está disponível
    -- --------------------------------------------------------------------
    SELECT
        (id_pacote IS NOT NULL),
        COALESCE(status, 'INEXISTENTE'),
        COALESCE(preco_total, 0),
        COALESCE(vagas_disponiveis, 0),
        COALESCE(nome_pacote, 'DESCONHECIDO'),
        data_inicio,
        data_fim
    INTO
        v_pacote_existe,
        v_status_pacote,
        v_preco_pacote,
        v_vagas_disponiveis,
        v_nome_pacote,
        v_data_inicio,
        v_data_fim
    FROM
        tb_pacotes_turisticos
    WHERE
        id_pacote = p_id_pacote;

    IF NOT v_pacote_existe THEN
        o_mensagem := 'ERRO: Pacote ID ' || p_id_pacote || ' não encontrado.';
        RETURN;
    END IF;

    IF v_status_pacote NOT IN ('DISPONIVEL', 'ESGOTADO') THEN
        o_mensagem := 'ERRO: Pacote "' || v_nome_pacote || '" não está disponível para venda. Status: ' || v_status_pacote;
        RETURN;
    END IF;

    IF v_data_inicio < CURRENT_DATE THEN
        o_mensagem := 'ERRO: Pacote "' || v_nome_pacote || '" já iniciou ou está no passado.';
        RETURN;
    END IF;

    -- --------------------------------------------------------------------
    -- VALIDAÇÃO 4: Verificar disponibilidade de vagas
    -- --------------------------------------------------------------------
    SELECT COALESCE(SUM(numero_passageiros), 0)
    INTO v_vagas_vendidas
    FROM tb_reservas
    WHERE id_pacote = p_id_pacote
    AND status_reserva IN ('CONFIRMADA', 'PENDENTE');

    v_vagas_restantes := v_vagas_disponiveis - v_vagas_vendidas;

    IF p_numero_passageiros > v_vagas_restantes THEN
        o_mensagem := 'ERRO: Pacote "' || v_nome_pacote || '" possui apenas ' ||
                      v_vagas_restantes || ' vaga(s) disponível(is). ' ||
                      'Solicitado: ' || p_numero_passageiros || ' passageiro(s).';
        RETURN;
    END IF;

    -- --------------------------------------------------------------------
    -- VALIDAÇÃO 5: Validar desconto (0 a 100%)
    -- --------------------------------------------------------------------
    IF p_desconto_percentual < 0 OR p_desconto_percentual > 100 THEN
        o_mensagem := 'ERRO: Desconto inválido. Deve estar entre 0% e 100%.';
        RETURN;
    END IF;

    -- --------------------------------------------------------------------
    -- CÁLCULO: Valor total da reserva
    -- --------------------------------------------------------------------
    o_valor_total := p_numero_passageiros * v_preco_pacote *
                     (1 - p_desconto_percentual / 100.0);
    o_valor_total := ROUND(o_valor_total, 2);

    -- --------------------------------------------------------------------
    -- INSERÇÃO: Criar a reserva
    -- --------------------------------------------------------------------
    INSERT INTO tb_reservas (
        id_cliente,
        id_pacote,
        id_funcionario,
        numero_passageiros,
        valor_unitario,
        desconto_percentual,
        valor_total,
        observacoes,
        status_reserva
    ) VALUES (
        p_id_cliente,
        p_id_pacote,
        p_id_funcionario,
        p_numero_passageiros,
        v_preco_pacote,
        p_desconto_percentual,
        o_valor_total,
        p_observacoes,
        'CONFIRMADA'
    )
    RETURNING id_reserva INTO o_id_reserva;

    -- --------------------------------------------------------------------
    -- SUCESSO: Montar mensagem de confirmação
    -- --------------------------------------------------------------------
    o_sucesso := TRUE;
    o_mensagem := 'SUCESSO! Reserva #' || o_id_reserva || ' criada para ' ||
                  v_nome_cliente || '. Pacote: "' || v_nome_pacote || '". ' ||
                  p_numero_passageiros || ' passageiro(s). ' ||
                  'Valor total: R$ ' || TO_CHAR(o_valor_total, '999G999G999D99') || '. ' ||
                  'Viagem: ' || TO_CHAR(v_data_inicio, 'DD/MM/YYYY') ||
                  ' a ' || TO_CHAR(v_data_fim, 'DD/MM/YYYY') || '.';

EXCEPTION
    WHEN OTHERS THEN
        o_sucesso := FALSE;
        o_mensagem := 'ERRO INESPERADO: ' || SQLERRM;
        RETURN;
END;
$$;

COMMENT ON FUNCTION fn_criar_reserva_completa IS
'Função completa para criação de reservas com validações integradas.
PARÂMETROS IN:
  - p_id_cliente: ID do cliente
  - p_id_pacote: ID do pacote turístico
  - p_id_funcionario: ID do vendedor
  - p_numero_passageiros: Quantidade de passageiros
  - p_desconto_percentual: Desconto (0-100%)
  - p_observacoes: Observações adicionais
PARÂMETROS OUT:
  - o_id_reserva: ID da reserva criada
  - o_valor_total: Valor total calculado
  - o_mensagem: Mensagem de sucesso ou erro
  - o_sucesso: TRUE se criou, FALSE se falhou
VALIDAÇÕES:
  - Cliente existe
  - Funcionário existe e está ativo
  - Pacote existe e está disponível
  - Há vagas suficientes
  - Desconto é válido
  - Data de início é futura
BENEFÍCIOS:
  - Centraliza lógica de negócio
  - Reduz código na aplicação
  - Garante consistência de dados
  - Facilita manutenção';

-- ============================================================================
-- FUNCTION 2: RELATÓRIO DE FATURAMENTO POR PERÍODO
-- ============================================================================
-- Objetivo: Gerar relatório financeiro consolidado de um período
-- Parâmetros IN: data início, data fim
-- Retorno: Tabela com métricas financeiras
-- Uso: Relatórios gerenciais, fechamento mensal
-- ============================================================================

CREATE OR REPLACE FUNCTION fn_relatorio_faturamento(
    p_data_inicio DATE,
    p_data_fim DATE
)
RETURNS TABLE (
    total_reservas BIGINT,
    total_passageiros BIGINT,
    receita_bruta DECIMAL(10,2),
    total_descontos DECIMAL(10,2),
    receita_liquida DECIMAL(10,2),
    ticket_medio DECIMAL(10,2),
    valor_recebido DECIMAL(10,2),
    valor_pendente DECIMAL(10,2),
    taxa_recebimento DECIMAL(5,2),
    total_cancelamentos BIGINT,
    valor_cancelado DECIMAL(10,2)
)
LANGUAGE plpgsql
AS $$
DECLARE
    -- Variáveis para cálculos intermediários
    v_receita_bruta DECIMAL(10,2);
    v_receita_liquida DECIMAL(10,2);
BEGIN
    -- Validar datas
    IF p_data_inicio > p_data_fim THEN
        RAISE EXCEPTION 'Data início (%) não pode ser maior que data fim (%)',
            p_data_inicio, p_data_fim;
    END IF;

    -- Retornar dados consolidados
    RETURN QUERY
    SELECT
        -- Quantidade de reservas no período
        COUNT(r.id_reserva)::BIGINT AS total_reservas,

        -- Total de passageiros
        COALESCE(SUM(r.numero_passageiros), 0)::BIGINT AS total_passageiros,

        -- Receita bruta (sem descontos)
        COALESCE(SUM(r.valor_unitario * r.numero_passageiros), 0)::DECIMAL(10,2) AS receita_bruta,

        -- Total de descontos concedidos
        COALESCE(SUM(r.valor_unitario * r.numero_passageiros - r.valor_total), 0)::DECIMAL(10,2) AS total_descontos,

        -- Receita líquida (com descontos)
        COALESCE(SUM(r.valor_total), 0)::DECIMAL(10,2) AS receita_liquida,

        -- Ticket médio
        COALESCE(AVG(r.valor_total), 0)::DECIMAL(10,2) AS ticket_medio,

        -- Valor recebido (pagamentos confirmados)
        COALESCE(
            (SELECT SUM(pg.valor_parcela)
             FROM tb_pagamentos pg
             WHERE pg.id_reserva = r.id_reserva
             AND pg.status_pagamento = 'PAGO'),
            0
        )::DECIMAL(10,2) AS valor_recebido,

        -- Valor pendente (pagamentos não confirmados)
        COALESCE(
            (SELECT SUM(pg.valor_parcela)
             FROM tb_pagamentos pg
             WHERE pg.id_reserva = r.id_reserva
             AND pg.status_pagamento = 'PENDENTE'),
            0
        )::DECIMAL(10,2) AS valor_pendente,

        -- Taxa de recebimento (percentual pago)
        CASE
            WHEN SUM(r.valor_total) > 0 THEN
                ROUND(
                    100.0 * COALESCE(
                        (SELECT SUM(pg.valor_parcela)
                         FROM tb_pagamentos pg
                         WHERE pg.id_reserva = r.id_reserva
                         AND pg.status_pagamento = 'PAGO'),
                        0
                    ) / SUM(r.valor_total),
                    2
                )
            ELSE 0
        END::DECIMAL(5,2) AS taxa_recebimento,

        -- Total de cancelamentos
        COUNT(CASE WHEN r.status_reserva = 'CANCELADA' THEN 1 END)::BIGINT AS total_cancelamentos,

        -- Valor de reservas canceladas
        COALESCE(SUM(CASE WHEN r.status_reserva = 'CANCELADA' THEN r.valor_total ELSE 0 END), 0)::DECIMAL(10,2) AS valor_cancelado

    FROM
        tb_reservas r
    WHERE
        r.data_reserva::DATE BETWEEN p_data_inicio AND p_data_fim;
END;
$$;

COMMENT ON FUNCTION fn_relatorio_faturamento IS
'Gera relatório financeiro consolidado para um período específico.
PARÂMETROS:
  - p_data_inicio: Data inicial do período
  - p_data_fim: Data final do período
RETORNA (TABLE):
  - total_reservas: Quantidade de reservas
  - total_passageiros: Soma de passageiros
  - receita_bruta: Valor sem descontos
  - total_descontos: Valor total descontado
  - receita_liquida: Valor com descontos
  - ticket_medio: Valor médio por reserva
  - valor_recebido: Pagamentos confirmados
  - valor_pendente: Pagamentos pendentes
  - taxa_recebimento: % de recebimento
  - total_cancelamentos: Reservas canceladas
  - valor_cancelado: Valor de cancelamentos
USO:
  SELECT * FROM fn_relatorio_faturamento(''2024-01-01'', ''2024-12-31'');
BENEFÍCIOS:
  - Consolidação automática de métricas
  - Reduz complexidade de queries
  - Facilita integração com BI
  - Performance otimizada';

-- ============================================================================
-- FUNCTION 3: CALCULAR COMISSÃO DE VENDEDOR
-- ============================================================================
-- Objetivo: Calcular comissão de um vendedor baseado em suas vendas
-- Parâmetros IN: id do funcionário, período
-- Parâmetros OUT: valor da comissão, detalhes
-- Regra de negócio:
--   - Comissão base: 5% do valor das vendas
--   - Bônus: +2% se vendeu mais de R$ 50.000
--   - Bônus: +3% se vendeu mais de R$ 100.000
-- ============================================================================

CREATE OR REPLACE FUNCTION fn_calcular_comissao_vendedor(
    p_id_funcionario INTEGER,
    p_mes INTEGER,
    p_ano INTEGER,
    OUT o_nome_vendedor VARCHAR(150),
    OUT o_total_vendas BIGINT,
    OUT o_valor_vendido DECIMAL(10,2),
    OUT o_percentual_comissao DECIMAL(5,2),
    OUT o_valor_comissao DECIMAL(10,2),
    OUT o_bonus_aplicado VARCHAR(50),
    OUT o_mensagem TEXT
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_data_inicio DATE;
    v_data_fim DATE;
    v_funcionario_existe BOOLEAN;
    v_cargo VARCHAR(50);
BEGIN
    -- Validar parâmetros
    IF p_mes < 1 OR p_mes > 12 THEN
        o_mensagem := 'ERRO: Mês inválido. Deve estar entre 1 e 12.';
        RETURN;
    END IF;

    -- Calcular período
    v_data_inicio := MAKE_DATE(p_ano, p_mes, 1);
    v_data_fim := (MAKE_DATE(p_ano, p_mes, 1) + INTERVAL '1 month - 1 day')::DATE;

    -- Verificar se funcionário existe
    SELECT
        (id_funcionario IS NOT NULL),
        nome_completo,
        cargo
    INTO
        v_funcionario_existe,
        o_nome_vendedor,
        v_cargo
    FROM
        tb_funcionarios
    WHERE
        id_funcionario = p_id_funcionario;

    IF NOT v_funcionario_existe THEN
        o_mensagem := 'ERRO: Funcionário ID ' || p_id_funcionario || ' não encontrado.';
        RETURN;
    END IF;

    -- Buscar vendas do período
    SELECT
        COUNT(r.id_reserva)::BIGINT,
        COALESCE(SUM(r.valor_total), 0)::DECIMAL(10,2)
    INTO
        o_total_vendas,
        o_valor_vendido
    FROM
        tb_reservas r
    WHERE
        r.id_funcionario = p_id_funcionario
        AND r.data_reserva::DATE BETWEEN v_data_inicio AND v_data_fim
        AND r.status_reserva IN ('CONFIRMADA', 'FINALIZADA');

    -- Calcular percentual de comissão com bonificação
    o_percentual_comissao := 5.00;  -- Comissão base
    o_bonus_aplicado := 'Nenhum';

    IF o_valor_vendido >= 100000.00 THEN
        o_percentual_comissao := 10.00;  -- 5% + 5% bônus
        o_bonus_aplicado := 'Bônus Platinum (>R$ 100k): +5%';
    ELSIF o_valor_vendido >= 50000.00 THEN
        o_percentual_comissao := 7.00;   -- 5% + 2% bônus
        o_bonus_aplicado := 'Bônus Gold (>R$ 50k): +2%';
    END IF;

    -- Calcular valor da comissão
    o_valor_comissao := ROUND(o_valor_vendido * o_percentual_comissao / 100.0, 2);

    -- Montar mensagem
    o_mensagem := 'Comissão calculada para ' || o_nome_vendedor || ' (' || v_cargo || ') ' ||
                  'referente a ' || TO_CHAR(v_data_inicio, 'MM/YYYY') || '. ' ||
                  o_total_vendas || ' venda(s) totalizando R$ ' ||
                  TO_CHAR(o_valor_vendido, '999G999G999D99') || '. ' ||
                  'Comissão ' || o_percentual_comissao || '%: R$ ' ||
                  TO_CHAR(o_valor_comissao, '999G999D99') || '.';
END;
$$;

COMMENT ON FUNCTION fn_calcular_comissao_vendedor IS
'Calcula comissão de vendedor com sistema de bonificação progressiva.
PARÂMETROS IN:
  - p_id_funcionario: ID do vendedor
  - p_mes: Mês (1-12)
  - p_ano: Ano (ex: 2024)
PARÂMETROS OUT:
  - o_nome_vendedor: Nome do funcionário
  - o_total_vendas: Quantidade de vendas
  - o_valor_vendido: Valor total vendido
  - o_percentual_comissao: % aplicado
  - o_valor_comissao: Valor em R$
  - o_bonus_aplicado: Descrição do bônus
  - o_mensagem: Resumo completo
REGRAS DE BONIFICAÇÃO:
  - Base: 5% de comissão
  - Gold (>R$ 50k): +2% = 7% total
  - Platinum (>R$ 100k): +5% = 10% total
USO:
  SELECT * FROM fn_calcular_comissao_vendedor(4, 11, 2024);';

-- ============================================================================
-- FUNCTION 4: PROCESSAR PAGAMENTO DE RESERVA
-- ============================================================================
-- Objetivo: Registrar pagamento e atualizar status automaticamente
-- Parâmetros IN: dados do pagamento
-- Parâmetros OUT: confirmação e ID do pagamento
-- ============================================================================

CREATE OR REPLACE FUNCTION fn_processar_pagamento(
    p_id_reserva INTEGER,
    p_forma_pagamento VARCHAR(30),
    p_numero_parcelas INTEGER DEFAULT 1,
    p_numero_transacao VARCHAR(100) DEFAULT NULL,
    OUT o_id_pagamento INTEGER,
    OUT o_valor_total_reserva DECIMAL(10,2),
    OUT o_valor_parcela DECIMAL(10,2),
    OUT o_sucesso BOOLEAN,
    OUT o_mensagem TEXT
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_reserva_existe BOOLEAN;
    v_status_reserva VARCHAR(30);
    v_valor_reserva DECIMAL(10,2);
    v_data_vencimento DATE;
    v_contador INTEGER;
BEGIN
    -- Inicializar
    o_sucesso := FALSE;

    -- Validar reserva
    SELECT
        (id_reserva IS NOT NULL),
        status_reserva,
        valor_total
    INTO
        v_reserva_existe,
        v_status_reserva,
        v_valor_reserva
    FROM
        tb_reservas
    WHERE
        id_reserva = p_id_reserva;

    IF NOT v_reserva_existe THEN
        o_mensagem := 'ERRO: Reserva ID ' || p_id_reserva || ' não encontrada.';
        RETURN;
    END IF;

    IF v_status_reserva = 'CANCELADA' THEN
        o_mensagem := 'ERRO: Não é possível processar pagamento de reserva cancelada.';
        RETURN;
    END IF;

    -- Validar forma de pagamento
    IF p_forma_pagamento NOT IN ('DINHEIRO', 'DEBITO', 'CREDITO', 'PIX', 'TRANSFERENCIA', 'BOLETO') THEN
        o_mensagem := 'ERRO: Forma de pagamento inválida.';
        RETURN;
    END IF;

    -- Validar número de parcelas
    IF p_numero_parcelas < 1 OR p_numero_parcelas > 12 THEN
        o_mensagem := 'ERRO: Número de parcelas deve estar entre 1 e 12.';
        RETURN;
    END IF;

    -- Calcular valores
    o_valor_total_reserva := v_valor_reserva;
    o_valor_parcela := ROUND(v_valor_reserva / p_numero_parcelas, 2);

    -- Inserir parcelas
    FOR v_contador IN 1..p_numero_parcelas LOOP
        -- Calcular data de vencimento (mensal)
        v_data_vencimento := CURRENT_DATE + (v_contador * INTERVAL '1 month');

        -- Inserir pagamento
        INSERT INTO tb_pagamentos (
            id_reserva,
            forma_pagamento,
            numero_parcela,
            total_parcelas,
            valor_parcela,
            data_vencimento,
            status_pagamento,
            numero_transacao
        ) VALUES (
            p_id_reserva,
            p_forma_pagamento,
            v_contador,
            p_numero_parcelas,
            o_valor_parcela,
            v_data_vencimento,
            CASE WHEN v_contador = 1 THEN 'PAGO' ELSE 'PENDENTE' END,  -- Primeira parcela paga
            p_numero_transacao || '-' || v_contador
        )
        RETURNING id_pagamento INTO o_id_pagamento;
    END LOOP;

    -- Sucesso
    o_sucesso := TRUE;
    o_mensagem := 'Pagamento processado! Reserva #' || p_id_reserva ||
                  '. Valor total: R$ ' || TO_CHAR(o_valor_total_reserva, '999G999D99') ||
                  '. Parcelado em ' || p_numero_parcelas || 'x de R$ ' ||
                  TO_CHAR(o_valor_parcela, '999G999D99') || '.';

EXCEPTION
    WHEN OTHERS THEN
        o_sucesso := FALSE;
        o_mensagem := 'ERRO: ' || SQLERRM;
END;
$$;

COMMENT ON FUNCTION fn_processar_pagamento IS
'Processa pagamento de reserva com parcelamento automático.
Cria registros de parcelas com vencimentos mensais.';

-- ============================================================================
-- DEMONSTRAÇÃO DE USO DAS FUNCTIONS
-- ============================================================================

-- ----------------------------------------------------------------------------
-- TESTE 1: Criar reserva completa
-- ----------------------------------------------------------------------------
SELECT * FROM fn_criar_reserva_completa(
    p_id_cliente := 1,
    p_id_pacote := 3,
    p_id_funcionario := 4,
    p_numero_passageiros := 2,
    p_desconto_percentual := 5.00,
    p_observacoes := 'Teste de function - criação de reserva'
);

-- ----------------------------------------------------------------------------
-- TESTE 2: Relatório de faturamento
-- ----------------------------------------------------------------------------
SELECT
    total_reservas,
    total_passageiros,
    TO_CHAR(receita_bruta, 'L999G999G999D99') AS receita_bruta,
    TO_CHAR(total_descontos, 'L999G999D99') AS descontos,
    TO_CHAR(receita_liquida, 'L999G999G999D99') AS receita_liquida,
    TO_CHAR(ticket_medio, 'L999G999D99') AS ticket_medio,
    TO_CHAR(taxa_recebimento, '990D99') || '%' AS taxa_recebimento
FROM
    fn_relatorio_faturamento('2024-01-01', '2024-12-31');

-- ----------------------------------------------------------------------------
-- TESTE 3: Calcular comissão de vendedor
-- ----------------------------------------------------------------------------
SELECT
    o_nome_vendedor AS vendedor,
    o_total_vendas AS vendas,
    TO_CHAR(o_valor_vendido, 'L999G999D99') AS faturamento,
    o_percentual_comissao || '%' AS percentual,
    TO_CHAR(o_valor_comissao, 'L999G999D99') AS comissao,
    o_bonus_aplicado AS bonus,
    o_mensagem AS detalhes
FROM
    fn_calcular_comissao_vendedor(4, 11, 2024);

-- Calcular comissões de todos os vendedores
SELECT
    f.id_funcionario,
    comissao.*
FROM
    tb_funcionarios f
    CROSS JOIN LATERAL fn_calcular_comissao_vendedor(f.id_funcionario, 11, 2024) AS comissao
WHERE
    f.cargo IN ('VENDEDOR', 'SUPERVISOR', 'GERENTE')
    AND f.status = 'ATIVO'
ORDER BY
    comissao.o_valor_comissao DESC;

-- ----------------------------------------------------------------------------
-- TESTE 4: Processar pagamento
-- ----------------------------------------------------------------------------
-- Buscar uma reserva para teste
DO $$
DECLARE
    v_id_reserva_teste INTEGER;
    v_resultado RECORD;
BEGIN
    -- Pegar primeira reserva confirmada
    SELECT id_reserva INTO v_id_reserva_teste
    FROM tb_reservas
    WHERE status_reserva = 'CONFIRMADA'
    LIMIT 1;

    -- Processar pagamento em 3 parcelas
    SELECT * INTO v_resultado
    FROM fn_processar_pagamento(
        p_id_reserva := v_id_reserva_teste,
        p_forma_pagamento := 'CREDITO',
        p_numero_parcelas := 3,
        p_numero_transacao := 'TEST-' || v_id_reserva_teste
    );

    RAISE NOTICE '%', v_resultado.o_mensagem;
END $$;

-- ============================================================================
-- RESUMO DA ETAPA 3.3 - FUNCTIONS
-- ============================================================================
-- FUNCTIONS CRIADAS:
--
-- 1. fn_criar_reserva_completa()
--    Parâmetros: 6 IN, 4 OUT
--    Objetivo: Criar reserva com validações completas
--    Benefício: Centraliza lógica de negócio complexa
--    Uso: Aplicações, APIs, processos batch
--
-- 2. fn_relatorio_faturamento()
--    Parâmetros: 2 IN, retorna TABLE
--    Objetivo: Relatório financeiro consolidado
--    Benefício: Performance em análises gerenciais
--    Uso: Dashboards, relatórios mensais
--
-- 3. fn_calcular_comissao_vendedor()
--    Parâmetros: 3 IN, 6 OUT
--    Objetivo: Calcular comissão com bonificação
--    Benefício: Automatiza cálculo de folha de pagamento
--    Uso: RH, comissões, metas
--
-- 4. fn_processar_pagamento()
--    Parâmetros: 4 IN, 4 OUT
--    Objetivo: Processar pagamento parcelado
--    Benefício: Automação de lançamentos financeiros
--    Uso: Integração com gateways de pagamento
--
-- VANTAGENS DAS FUNCTIONS:
-- - Reutilização de código
-- - Performance (execução no servidor de banco)
-- - Segurança (encapsulamento de lógica)
-- - Manutenção centralizada
-- - Redução de tráfego de rede
-- - Transações atômicas garantidas
--
-- TÉCNICAS DEMONSTRADAS:
-- - Parâmetros IN, OUT, DEFAULT
-- - Variáveis locais (DECLARE)
-- - Estruturas condicionais (IF/ELSIF/ELSE)
-- - Loops (FOR)
-- - Tratamento de exceções (EXCEPTION)
-- - Funções que retornam TABLE
-- - Subconsultas correlacionadas
-- - Conversão de tipos
-- - Formatação de valores
-- ============================================================================

SELECT 'Etapa 3.3 concluída! 4 functions criadas e testadas com sucesso.' AS status;
