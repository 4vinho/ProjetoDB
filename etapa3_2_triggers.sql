-- ============================================================================
-- ETAPA 3.2: TRIGGERS (GATILHOS)
-- Criação de triggers para automação e integridade de dados
-- Requisitos: Trigger de auditoria + Trigger de validação + Triggers adicionais
-- ============================================================================

\c agencia_turismo;

-- ============================================================================
-- TRIGGER 1: AUDITORIA DE ALTERAÇÕES EM RESERVAS
-- Objetivo: Registrar INSERT, UPDATE, DELETE em tb_auditoria
-- Benefício: Rastreabilidade, compliance LGPD, investigação de fraudes
-- ============================================================================

CREATE OR REPLACE FUNCTION fn_auditoria_reservas()
RETURNS TRIGGER AS $$
BEGIN
    -- A função é executada para cada linha (FOR EACH ROW)
    -- TG_OP: tipo de operação (INSERT, UPDATE, DELETE)
    -- OLD: valores antigos (UPDATE/DELETE) | NEW: valores novos (INSERT/UPDATE)

    IF (TG_OP = 'INSERT') THEN
        INSERT INTO tb_auditoria (tabela_afetada, operacao, usuario_db, dados_novos, id_registro_afetado, observacao)
        VALUES ('tb_reservas', 'INSERT', CURRENT_USER, row_to_json(NEW), NEW.id_reserva, 'Nova reserva criada');
        RETURN NEW;

    ELSIF (TG_OP = 'UPDATE') THEN
        INSERT INTO tb_auditoria (tabela_afetada, operacao, usuario_db, dados_antigos, dados_novos, id_registro_afetado, observacao)
        VALUES ('tb_reservas', 'UPDATE', CURRENT_USER, row_to_json(OLD), row_to_json(NEW), NEW.id_reserva, 'Reserva modificada');
        RETURN NEW;

    ELSIF (TG_OP = 'DELETE') THEN
        INSERT INTO tb_auditoria (tabela_afetada, operacao, usuario_db, dados_antigos, id_registro_afetado, observacao)
        VALUES ('tb_reservas', 'DELETE', CURRENT_USER, row_to_json(OLD), OLD.id_reserva, 'Reserva excluída');
        RETURN OLD;
    END IF;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION fn_auditoria_reservas() IS
'Registra todas operações em tb_reservas na tabela de auditoria.
Armazena dados antes/depois em JSON para compliance e rastreabilidade.';

CREATE TRIGGER trg_auditoria_reservas
AFTER INSERT OR UPDATE OR DELETE ON tb_reservas
FOR EACH ROW
EXECUTE FUNCTION fn_auditoria_reservas();

COMMENT ON TRIGGER trg_auditoria_reservas ON tb_reservas IS
'Trigger de auditoria automática para rastreabilidade e compliance.';

-- ============================================================================
-- TRIGGER 2: VALIDAÇÃO DE VAGAS DISPONÍVEIS
-- Objetivo: Impedir overbooking (reservas além da capacidade)
-- Regra de negócio: Vagas não podem ficar negativas
-- Tipo: BEFORE INSERT/UPDATE (validação preventiva)
-- ============================================================================

CREATE OR REPLACE FUNCTION fn_validar_vagas_pacote()
RETURNS TRIGGER AS $$
DECLARE
    v_vagas_disponiveis INTEGER;
    v_vagas_ja_vendidas INTEGER;
    v_vagas_restantes INTEGER;
    v_nome_pacote VARCHAR(150);
BEGIN
    -- Buscar informações do pacote
    SELECT p.vagas_disponiveis, p.nome_pacote
    INTO v_vagas_disponiveis, v_nome_pacote
    FROM tb_pacotes_turisticos p
    WHERE p.id_pacote = NEW.id_pacote;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Pacote ID % não encontrado.', NEW.id_pacote;
    END IF;

    -- Calcular vagas já vendidas (excluindo a reserva atual se for UPDATE)
    SELECT COALESCE(SUM(r.numero_passageiros), 0)
    INTO v_vagas_ja_vendidas
    FROM tb_reservas r
    WHERE r.id_pacote = NEW.id_pacote
    AND r.status_reserva IN ('CONFIRMADA', 'PENDENTE')
    AND (TG_OP = 'INSERT' OR r.id_reserva != NEW.id_reserva);

    v_vagas_restantes := v_vagas_disponiveis - v_vagas_ja_vendidas;

    -- Validar disponibilidade
    IF NEW.numero_passageiros > v_vagas_restantes THEN
        RAISE EXCEPTION 'ERRO: Pacote "%" possui apenas % vaga(s) disponível(is). Tentativa de reservar % passageiro(s).',
            v_nome_pacote, v_vagas_restantes, NEW.numero_passageiros;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION fn_validar_vagas_pacote() IS
'Valida vagas antes de criar/atualizar reserva.
Impede overbooking calculando dinamicamente vagas disponíveis.';

CREATE TRIGGER trg_validar_vagas_pacote
BEFORE INSERT OR UPDATE ON tb_reservas
FOR EACH ROW
EXECUTE FUNCTION fn_validar_vagas_pacote();

COMMENT ON TRIGGER trg_validar_vagas_pacote ON tb_reservas IS
'Trigger de validação que impede overbooking.';

-- ============================================================================
-- TRIGGER 3: ATUALIZAÇÃO AUTOMÁTICA DE STATUS DE PACOTES
-- Objetivo: Atualizar status para ESGOTADO quando vagas acabam
-- Tipo: AFTER INSERT/UPDATE/DELETE (automação em cascata)
-- ============================================================================

CREATE OR REPLACE FUNCTION fn_atualizar_status_pacote()
RETURNS TRIGGER AS $$
DECLARE
    v_id_pacote INTEGER;
    v_vagas_disponiveis INTEGER;
    v_vagas_vendidas INTEGER;
    v_novo_status VARCHAR(20);
BEGIN
    -- Determinar qual pacote foi afetado
    v_id_pacote := CASE WHEN TG_OP = 'DELETE' THEN OLD.id_pacote ELSE NEW.id_pacote END;

    -- Buscar vagas totais
    SELECT vagas_disponiveis INTO v_vagas_disponiveis
    FROM tb_pacotes_turisticos WHERE id_pacote = v_id_pacote;

    -- Calcular vagas vendidas
    SELECT COALESCE(SUM(numero_passageiros), 0) INTO v_vagas_vendidas
    FROM tb_reservas
    WHERE id_pacote = v_id_pacote AND status_reserva IN ('CONFIRMADA', 'PENDENTE');

    -- Determinar novo status
    v_novo_status := CASE
        WHEN (v_vagas_disponiveis - v_vagas_vendidas) <= 0 THEN 'ESGOTADO'
        ELSE 'DISPONIVEL'
    END;

    -- Atualizar status do pacote
    UPDATE tb_pacotes_turisticos SET status = v_novo_status WHERE id_pacote = v_id_pacote;

    RETURN CASE WHEN TG_OP = 'DELETE' THEN OLD ELSE NEW END;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION fn_atualizar_status_pacote() IS
'Atualiza automaticamente status do pacote baseado em vagas disponíveis.
Lógica: vagas_restantes ≤ 0 = ESGOTADO, > 0 = DISPONIVEL.';

CREATE TRIGGER trg_atualizar_status_pacote
AFTER INSERT OR UPDATE OR DELETE ON tb_reservas
FOR EACH ROW
EXECUTE FUNCTION fn_atualizar_status_pacote();

COMMENT ON TRIGGER trg_atualizar_status_pacote ON tb_reservas IS
'Trigger que atualiza automaticamente status do pacote (DISPONIVEL/ESGOTADO).';

-- ============================================================================
-- TRIGGER 4: VALIDAÇÃO DE VALORES FINANCEIROS
-- Objetivo: Garantir que valor_total = valor_unitario × passageiros × (1 - desconto/100)
-- Tipo: BEFORE INSERT/UPDATE (previne fraudes)
-- ============================================================================

CREATE OR REPLACE FUNCTION fn_validar_valor_reserva()
RETURNS TRIGGER AS $$
DECLARE
    v_valor_calculado DECIMAL(10, 2);
    v_diferenca DECIMAL(10, 2);
BEGIN
    -- Calcular valor esperado
    v_valor_calculado := NEW.valor_unitario * NEW.numero_passageiros * (1 - NEW.desconto_percentual / 100.0);
    v_diferenca := ABS(NEW.valor_total - v_valor_calculado);

    -- Validar com tolerância de R$ 0,01 (arredondamento)
    IF v_diferenca > 0.01 THEN
        RAISE EXCEPTION 'ERRO FINANCEIRO: Valor total incorreto! Esperado: R$ %, Informado: R$ %.',
            ROUND(v_valor_calculado, 2), NEW.valor_total;
    END IF;

    -- Corrigir possíveis diferenças de arredondamento
    NEW.valor_total := ROUND(v_valor_calculado, 2);
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION fn_validar_valor_reserva() IS
'Valida e corrige cálculo do valor total da reserva.
Previne fraudes financeiras e erros de arredondamento.';

CREATE TRIGGER trg_validar_valor_reserva
BEFORE INSERT OR UPDATE ON tb_reservas
FOR EACH ROW
EXECUTE FUNCTION fn_validar_valor_reserva();

COMMENT ON TRIGGER trg_validar_valor_reserva ON tb_reservas IS
'Trigger que valida cálculo financeiro automaticamente.';

-- ============================================================================
-- TESTES DOS TRIGGERS
-- ============================================================================

-- TESTE 1: Auditoria (INSERT, UPDATE, DELETE)
INSERT INTO tb_reservas (id_cliente, id_pacote, id_funcionario, numero_passageiros, valor_unitario, desconto_percentual, valor_total, status_reserva)
VALUES (1, 1, 4, 1, 7500.00, 0.00, 7500.00, 'PENDENTE');

-- Consultar auditoria gerada
SELECT id_auditoria, tabela_afetada, operacao, usuario_db,
    TO_CHAR(data_hora, 'DD/MM/YYYY HH24:MI:SS') AS data_hora,
    observacao
FROM tb_auditoria
WHERE tabela_afetada = 'tb_reservas'
ORDER BY data_hora DESC LIMIT 5;

-- TESTE 2: Validação de Vagas (deve FALHAR se tentar reservar mais do que disponível)
-- Descomentar para testar erro:
/*
INSERT INTO tb_reservas (id_cliente, id_pacote, id_funcionario, numero_passageiros, valor_unitario, desconto_percentual, valor_total, status_reserva)
VALUES (2, 1, 4, 999, 7500.00, 0.00, 7492500.00, 'CONFIRMADA');
-- ERRO ESPERADO: Pacote possui apenas X vagas disponíveis
*/

-- TESTE 3: Atualização de Status Automática
-- Verificar status do pacote antes e depois de esgotar vagas
SELECT id_pacote, nome_pacote, vagas_disponiveis, status,
    (SELECT COALESCE(SUM(numero_passageiros), 0) FROM tb_reservas
     WHERE id_pacote = p.id_pacote AND status_reserva IN ('CONFIRMADA', 'PENDENTE')) AS vagas_vendidas
FROM tb_pacotes_turisticos p
WHERE id_pacote = 1;

-- TESTE 4: Validação Financeira (deve FALHAR se valor incorreto)
-- Descomentar para testar erro:
/*
INSERT INTO tb_reservas (id_cliente, id_pacote, id_funcionario, numero_passageiros, valor_unitario, desconto_percentual, valor_total, status_reserva)
VALUES (3, 2, 5, 2, 15000.00, 10.00, 99999.99, 'CONFIRMADA');
-- ERRO ESPERADO: Valor total incorreto!
*/

-- Visualizar todos os triggers criados
SELECT t.tgname AS trigger_name, c.relname AS tabela, p.proname AS funcao,
    CASE WHEN t.tgtype & 2 = 2 THEN 'BEFORE' ELSE 'AFTER' END AS momento,
    CASE WHEN t.tgtype & 4 = 4 THEN 'INSERT ' ELSE '' END ||
    CASE WHEN t.tgtype & 8 = 8 THEN 'UPDATE ' ELSE '' END ||
    CASE WHEN t.tgtype & 16 = 16 THEN 'DELETE' ELSE '' END AS eventos
FROM pg_trigger t
JOIN pg_class c ON t.tgrelid = c.oid
JOIN pg_proc p ON t.tgfoid = p.oid
WHERE c.relname = 'tb_reservas' AND NOT t.tgisinternal
ORDER BY t.tgname;

-- ============================================================================
-- RESUMO DA ETAPA 3.2
-- TRIGGER 1: trg_auditoria_reservas - Registra operações em tb_auditoria
-- TRIGGER 2: trg_validar_vagas_pacote - Impede overbooking
-- TRIGGER 3: trg_atualizar_status_pacote - Atualiza status automaticamente
-- TRIGGER 4: trg_validar_valor_reserva - Valida cálculos financeiros
-- BENEFÍCIOS: Integridade automática, regras centralizadas, automação
-- ============================================================================

SELECT 'Etapa 3.2 concluída! 4 triggers criados e testados.' AS status;
