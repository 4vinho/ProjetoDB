-- ============================================================================
-- ETAPA 3.3: FUNCTIONS (FUNÇÕES ARMAZENADAS)
-- Criação de 3 functions com parâmetros IN/OUT e variáveis locais
-- ============================================================================

\c agencia_turismo;

-- ============================================================================
-- FUNCTION 1: CRIAR RESERVA COMPLETA COM VALIDAÇÕES
-- Objetivo: Encapsular lógica de reserva com validações integradas
-- Parâmetros IN: dados da reserva | OUT: id_reserva, valor_total, mensagem, sucesso
-- Validações: Cliente existe, Pacote disponível, Vagas suficientes, Desconto válido
-- Benefício: Centraliza regras de negócio, reduz código na aplicação
-- ============================================================================

CREATE OR REPLACE FUNCTION fn_criar_reserva_completa(
    p_id_cliente INTEGER, p_id_pacote INTEGER, p_id_funcionario INTEGER,
    p_numero_passageiros INTEGER, p_desconto_percentual DECIMAL(5,2) DEFAULT 0.00,
    p_observacoes TEXT DEFAULT NULL,
    OUT o_id_reserva INTEGER, OUT o_valor_total DECIMAL(10,2),
    OUT o_mensagem TEXT, OUT o_sucesso BOOLEAN
)
LANGUAGE plpgsql AS $$
DECLARE
    v_preco_pacote DECIMAL(10,2);
    v_vagas_restantes INTEGER;
    v_nome_pacote VARCHAR(150);
    v_nome_cliente VARCHAR(150);
BEGIN
    o_sucesso := FALSE;

    -- Validar cliente
    SELECT nome_completo INTO v_nome_cliente FROM tb_clientes WHERE id_cliente = p_id_cliente;
    IF NOT FOUND THEN
        o_mensagem := 'ERRO: Cliente não encontrado.';
        RETURN;
    END IF;

    -- Validar funcionário
    IF NOT EXISTS(SELECT 1 FROM tb_funcionarios WHERE id_funcionario = p_id_funcionario AND status = 'ATIVO') THEN
        o_mensagem := 'ERRO: Funcionário inválido ou inativo.';
        RETURN;
    END IF;

    -- Validar pacote e vagas
    SELECT preco_total, nome_pacote INTO v_preco_pacote, v_nome_pacote
    FROM tb_pacotes_turisticos WHERE id_pacote = p_id_pacote AND status = 'DISPONIVEL' AND data_inicio >= CURRENT_DATE;
    IF NOT FOUND THEN
        o_mensagem := 'ERRO: Pacote não disponível.';
        RETURN;
    END IF;

    -- Calcular vagas restantes
    SELECT (p.vagas_disponiveis - COALESCE(SUM(r.numero_passageiros), 0)) INTO v_vagas_restantes
    FROM tb_pacotes_turisticos p LEFT JOIN tb_reservas r ON p.id_pacote = r.id_pacote
        AND r.status_reserva IN ('CONFIRMADA', 'PENDENTE')
    WHERE p.id_pacote = p_id_pacote GROUP BY p.vagas_disponiveis;

    IF p_numero_passageiros > v_vagas_restantes THEN
        o_mensagem := 'ERRO: Apenas ' || v_vagas_restantes || ' vaga(s) disponível(is).';
        RETURN;
    END IF;

    -- Validar desconto
    IF p_desconto_percentual < 0 OR p_desconto_percentual > 100 THEN
        o_mensagem := 'ERRO: Desconto inválido (0-100%).';
        RETURN;
    END IF;

    -- Calcular valor total
    o_valor_total := ROUND(p_numero_passageiros * v_preco_pacote * (1 - p_desconto_percentual / 100.0), 2);

    -- Inserir reserva
    INSERT INTO tb_reservas (id_cliente, id_pacote, id_funcionario, numero_passageiros,
        valor_unitario, desconto_percentual, valor_total, observacoes, status_reserva)
    VALUES (p_id_cliente, p_id_pacote, p_id_funcionario, p_numero_passageiros,
        v_preco_pacote, p_desconto_percentual, o_valor_total, p_observacoes, 'CONFIRMADA')
    RETURNING id_reserva INTO o_id_reserva;

    o_sucesso := TRUE;
    o_mensagem := 'SUCESSO! Reserva #' || o_id_reserva || ' criada para ' || v_nome_cliente ||
        '. Pacote: ' || v_nome_pacote || '. Valor: R$ ' || o_valor_total;
EXCEPTION
    WHEN OTHERS THEN
        o_sucesso := FALSE;
        o_mensagem := 'ERRO: ' || SQLERRM;
END;
$$;

COMMENT ON FUNCTION fn_criar_reserva_completa IS
'Cria reserva com validações completas: cliente, funcionário, pacote, vagas, desconto.
Centraliza regras de negócio e calcula valor automaticamente.
Parâmetros OUT: id_reserva, valor_total, mensagem, sucesso (TRUE/FALSE).';

-- ============================================================================
-- FUNCTION 2: RELATÓRIO DE FATURAMENTO POR PERÍODO
-- Objetivo: Gerar relatório financeiro consolidado
-- Parâmetros IN: data_inicio, data_fim | Retorna TABLE com métricas
-- Uso: Relatórios gerenciais, dashboards, fechamento mensal
-- ============================================================================

CREATE OR REPLACE FUNCTION fn_relatorio_faturamento(
    p_data_inicio DATE, p_data_fim DATE
)
RETURNS TABLE (
    total_reservas BIGINT, total_passageiros BIGINT, receita_bruta DECIMAL(10,2),
    total_descontos DECIMAL(10,2), receita_liquida DECIMAL(10,2), ticket_medio DECIMAL(10,2),
    valor_recebido DECIMAL(10,2), valor_pendente DECIMAL(10,2), taxa_recebimento DECIMAL(5,2)
)
LANGUAGE plpgsql AS $$
BEGIN
    IF p_data_inicio > p_data_fim THEN
        RAISE EXCEPTION 'Data início não pode ser maior que data fim.';
    END IF;

    RETURN QUERY
    SELECT
        COUNT(r.id_reserva)::BIGINT,
        COALESCE(SUM(r.numero_passageiros), 0)::BIGINT,
        COALESCE(SUM(r.valor_unitario * r.numero_passageiros), 0)::DECIMAL(10,2),
        COALESCE(SUM(r.valor_unitario * r.numero_passageiros - r.valor_total), 0)::DECIMAL(10,2),
        COALESCE(SUM(r.valor_total), 0)::DECIMAL(10,2),
        COALESCE(AVG(r.valor_total), 0)::DECIMAL(10,2),
        (SELECT COALESCE(SUM(pg.valor_parcela), 0) FROM tb_pagamentos pg WHERE pg.id_reserva IN (SELECT id_reserva FROM tb_reservas WHERE data_reserva::DATE BETWEEN p_data_inicio AND p_data_fim) AND pg.status_pagamento = 'PAGO')::DECIMAL(10,2),
        (SELECT COALESCE(SUM(pg.valor_parcela), 0) FROM tb_pagamentos pg WHERE pg.id_reserva IN (SELECT id_reserva FROM tb_reservas WHERE data_reserva::DATE BETWEEN p_data_inicio AND p_data_fim) AND pg.status_pagamento = 'PENDENTE')::DECIMAL(10,2),
        CASE WHEN SUM(r.valor_total) > 0 THEN
            ROUND(100.0 * (SELECT COALESCE(SUM(pg.valor_parcela), 0) FROM tb_pagamentos pg WHERE pg.id_reserva IN (SELECT id_reserva FROM tb_reservas WHERE data_reserva::DATE BETWEEN p_data_inicio AND p_data_fim) AND pg.status_pagamento = 'PAGO') / SUM(r.valor_total), 2)
        ELSE 0 END::DECIMAL(5,2)
    FROM tb_reservas r
    WHERE r.data_reserva::DATE BETWEEN p_data_inicio AND p_data_fim AND r.status_reserva IN ('CONFIRMADA', 'FINALIZADA');
END;
$$;

COMMENT ON FUNCTION fn_relatorio_faturamento IS
'Relatório financeiro consolidado: reservas, passageiros, receitas, descontos, pagamentos.
Uso: SELECT * FROM fn_relatorio_faturamento(''2024-01-01'', ''2024-12-31'');';

-- ============================================================================
-- FUNCTION 3: CALCULAR COMISSÃO DE VENDEDOR
-- Objetivo: Calcular comissão baseada em vendas com sistema de bônus
-- Regras: Base 5% | Bônus +2% se > R$ 50k | Bônus +3% se > R$ 100k
-- Parâmetros IN: id_funcionario, mes, ano | OUT: comissão e detalhes
-- ============================================================================

CREATE OR REPLACE FUNCTION fn_calcular_comissao_vendedor(
    p_id_funcionario INTEGER, p_mes INTEGER, p_ano INTEGER,
    OUT o_nome_vendedor VARCHAR(150), OUT o_total_vendas BIGINT,
    OUT o_valor_vendido DECIMAL(10,2), OUT o_percentual_comissao DECIMAL(5,2),
    OUT o_valor_comissao DECIMAL(10,2), OUT o_bonus_aplicado VARCHAR(50)
)
LANGUAGE plpgsql AS $$
DECLARE
    v_data_inicio DATE;
    v_data_fim DATE;
BEGIN
    -- Calcular período
    v_data_inicio := DATE(p_ano || '-' || p_mes || '-01');
    v_data_fim := (v_data_inicio + INTERVAL '1 month - 1 day')::DATE;

    -- Buscar dados do funcionário e vendas
    SELECT f.nome_completo,
        COUNT(r.id_reserva)::BIGINT,
        COALESCE(SUM(r.valor_total), 0)
    INTO o_nome_vendedor, o_total_vendas, o_valor_vendido
    FROM tb_funcionarios f
    LEFT JOIN tb_reservas r ON f.id_funcionario = r.id_funcionario
        AND r.data_reserva::DATE BETWEEN v_data_inicio AND v_data_fim
        AND r.status_reserva IN ('CONFIRMADA', 'FINALIZADA')
    WHERE f.id_funcionario = p_id_funcionario
    GROUP BY f.nome_completo;

    IF NOT FOUND THEN
        o_nome_vendedor := 'Funcionário não encontrado';
        RETURN;
    END IF;

    -- Calcular comissão com bônus progressivo
    IF o_valor_vendido >= 100000 THEN
        o_percentual_comissao := 10.00;  -- 5% + 2% + 3%
        o_bonus_aplicado := 'BÔNUS PLATINUM (≥ R$ 100k)';
    ELSIF o_valor_vendido >= 50000 THEN
        o_percentual_comissao := 7.00;   -- 5% + 2%
        o_bonus_aplicado := 'BÔNUS GOLD (≥ R$ 50k)';
    ELSE
        o_percentual_comissao := 5.00;   -- Base
        o_bonus_aplicado := 'SEM BÔNUS';
    END IF;

    o_valor_comissao := ROUND(o_valor_vendido * o_percentual_comissao / 100, 2);
END;
$$;

COMMENT ON FUNCTION fn_calcular_comissao_vendedor IS
'Calcula comissão de vendedor com sistema de bônus progressivo.
Regras: 5% base | +2% se vendeu ≥ R$ 50k | +3% se vendeu ≥ R$ 100k.
Uso: SELECT * FROM fn_calcular_comissao_vendedor(4, 11, 2024);';

-- ============================================================================
-- TESTES DAS FUNCTIONS
-- ============================================================================

-- TESTE 1: Criar Reserva Completa
DO $$
DECLARE
    v_id_reserva INTEGER;
    v_valor_total DECIMAL(10,2);
    v_mensagem TEXT;
    v_sucesso BOOLEAN;
BEGIN
    SELECT * INTO v_id_reserva, v_valor_total, v_mensagem, v_sucesso
    FROM fn_criar_reserva_completa(1, 2, 4, 2, 5.00, 'Teste de função');

    RAISE NOTICE 'Sucesso: % | Mensagem: % | ID: % | Valor: R$ %',
        v_sucesso, v_mensagem, v_id_reserva, v_valor_total;
END $$;

-- TESTE 2: Relatório de Faturamento
SELECT * FROM fn_relatorio_faturamento('2024-01-01', '2024-12-31');

-- TESTE 3: Calcular Comissão de Vendedor (Novembro/2024)
SELECT o_nome_vendedor AS vendedor, o_total_vendas AS vendas,
    TO_CHAR(o_valor_vendido, 'L999G999G999D99') AS valor_vendido,
    o_percentual_comissao || '%' AS percentual,
    TO_CHAR(o_valor_comissao, 'L999G999D99') AS comissao,
    o_bonus_aplicado AS bonus
FROM fn_calcular_comissao_vendedor(4, 11, 2024);

-- Testar com todos os vendedores
SELECT f.id_funcionario, c.*
FROM tb_funcionarios f, fn_calcular_comissao_vendedor(f.id_funcionario, 11, 2024) c
WHERE f.cargo = 'VENDEDOR' AND f.status = 'ATIVO';

-- ============================================================================
-- RESUMO DA ETAPA 3.3
-- FUNCTION 1: fn_criar_reserva_completa - Criação de reserva com validações
-- FUNCTION 2: fn_relatorio_faturamento - Relatório financeiro consolidado
-- FUNCTION 3: fn_calcular_comissao_vendedor - Cálculo de comissão com bônus
-- Demonstra: Parâmetros IN/OUT, variáveis locais, lógica procedural, RETURNS TABLE
-- ============================================================================

SELECT 'Etapa 3.3 concluída! 3 functions criadas e testadas.' AS status;
