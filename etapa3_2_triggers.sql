-- ============================================================================
-- ETAPA 3.2: TRIGGERS (GATILHOS)
-- ============================================================================
-- Descrição: Criação de triggers para automação e integridade de dados
-- Requisitos do projeto:
--   1. Trigger de auditoria (registrar alterações em tb_auditoria)
--   2. Trigger de validação de regra de negócio
--   3. Trigger adicional para demonstrar diferentes cenários
-- ============================================================================

-- Conectar ao banco de dados
\c agencia_turismo;

-- ============================================================================
-- TRIGGER 1: AUDITORIA DE ALTERAÇÕES EM RESERVAS
-- ============================================================================
-- Objetivo: Registrar todas as operações (INSERT, UPDATE, DELETE) na tabela
--           tb_reservas para rastreabilidade e compliance
-- Tabela afetada: tb_reservas
-- Tabela de log: tb_auditoria
-- Gatilho: AFTER INSERT OR UPDATE OR DELETE
-- ============================================================================

-- ----------------------------------------------------------------------------
-- Passo 1: Criar a função que será executada pelo trigger
-- ----------------------------------------------------------------------------
-- Esta função captura os dados antes e depois da operação
-- e insere um registro na tabela de auditoria
-- ----------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION fn_auditoria_reservas()
RETURNS TRIGGER AS $$
BEGIN
    -- A função é executada para cada linha afetada (FOR EACH ROW)
    -- TG_OP contém o tipo de operação: INSERT, UPDATE ou DELETE
    -- OLD contém os valores antigos (disponível em UPDATE e DELETE)
    -- NEW contém os valores novos (disponível em INSERT e UPDATE)

    IF (TG_OP = 'INSERT') THEN
        -- Operação de inserção: registrar apenas dados novos
        INSERT INTO tb_auditoria (
            tabela_afetada,
            operacao,
            usuario_db,
            dados_antigos,
            dados_novos,
            id_registro_afetado,
            observacao
        ) VALUES (
            'tb_reservas',
            'INSERT',
            CURRENT_USER,                    -- Usuário do PostgreSQL que executou
            NULL,                             -- Não há dados antigos em INSERT
            row_to_json(NEW),                 -- Converte a linha nova para JSON
            NEW.id_reserva,
            'Nova reserva criada no sistema'
        );
        RETURN NEW;

    ELSIF (TG_OP = 'UPDATE') THEN
        -- Operação de atualização: registrar dados antes e depois
        INSERT INTO tb_auditoria (
            tabela_afetada,
            operacao,
            usuario_db,
            dados_antigos,
            dados_novos,
            id_registro_afetado,
            observacao
        ) VALUES (
            'tb_reservas',
            'UPDATE',
            CURRENT_USER,
            row_to_json(OLD),                 -- Dados antes da alteração
            row_to_json(NEW),                 -- Dados depois da alteração
            NEW.id_reserva,
            'Reserva modificada - verificar alterações'
        );
        RETURN NEW;

    ELSIF (TG_OP = 'DELETE') THEN
        -- Operação de exclusão: registrar dados removidos
        INSERT INTO tb_auditoria (
            tabela_afetada,
            operacao,
            usuario_db,
            dados_antigos,
            dados_novos,
            id_registro_afetado,
            observacao
        ) VALUES (
            'tb_reservas',
            'DELETE',
            CURRENT_USER,
            row_to_json(OLD),                 -- Dados antes da exclusão
            NULL,                             -- Não há dados novos em DELETE
            OLD.id_reserva,
            'Reserva excluída do sistema'
        );
        RETURN OLD;
    END IF;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION fn_auditoria_reservas() IS
'Função trigger que registra todas as operações (INSERT, UPDATE, DELETE)
realizadas na tabela tb_reservas na tabela de auditoria.
BENEFÍCIOS:
- Rastreabilidade completa de alterações
- Compliance com LGPD e normas de auditoria
- Investigação de inconsistências e fraudes
- Histórico para rollback manual se necessário';

-- ----------------------------------------------------------------------------
-- Passo 2: Criar o trigger que chama a função
-- ----------------------------------------------------------------------------
-- AFTER: executa depois da operação (dados já foram modificados)
-- FOR EACH ROW: executa uma vez para cada linha afetada
-- ----------------------------------------------------------------------------
CREATE TRIGGER trg_auditoria_reservas
AFTER INSERT OR UPDATE OR DELETE ON tb_reservas
FOR EACH ROW
EXECUTE FUNCTION fn_auditoria_reservas();

COMMENT ON TRIGGER trg_auditoria_reservas ON tb_reservas IS
'Trigger de auditoria que registra automaticamente todas as operações
na tabela tb_reservas para fins de rastreabilidade e compliance.';

-- ============================================================================
-- TRIGGER 2: VALIDAÇÃO DE VAGAS DISPONÍVEIS EM PACOTES
-- ============================================================================
-- Objetivo: Impedir que reservas sejam criadas/atualizadas se ultrapassarem
--           o número de vagas disponíveis no pacote
-- Regra de negócio: Vagas do pacote não podem ficar negativas
-- Gatilho: BEFORE INSERT OR UPDATE
-- Tipo: Validação preventiva (impede operação inválida)
-- ============================================================================

-- ----------------------------------------------------------------------------
-- Passo 1: Criar a função de validação
-- ----------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION fn_validar_vagas_pacote()
RETURNS TRIGGER AS $$
DECLARE
    v_vagas_disponiveis INTEGER;
    v_vagas_ja_vendidas INTEGER;
    v_vagas_restantes INTEGER;
    v_nome_pacote VARCHAR(150);
BEGIN
    -- Buscar informações do pacote
    SELECT
        p.vagas_disponiveis,
        p.nome_pacote
    INTO
        v_vagas_disponiveis,
        v_nome_pacote
    FROM
        tb_pacotes_turisticos p
    WHERE
        p.id_pacote = NEW.id_pacote;

    -- Verificar se o pacote existe
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Pacote ID % não encontrado.', NEW.id_pacote;
    END IF;

    -- Calcular quantas vagas já foram vendidas (excluindo a reserva atual se for UPDATE)
    SELECT
        COALESCE(SUM(r.numero_passageiros), 0)
    INTO
        v_vagas_ja_vendidas
    FROM
        tb_reservas r
    WHERE
        r.id_pacote = NEW.id_pacote
        AND r.status_reserva IN ('CONFIRMADA', 'PENDENTE')
        AND (TG_OP = 'INSERT' OR r.id_reserva != NEW.id_reserva);  -- Exclui a própria reserva em UPDATE

    -- Calcular vagas restantes
    v_vagas_restantes := v_vagas_disponiveis - v_vagas_ja_vendidas;

    -- Validar se a nova reserva cabe nas vagas disponíveis
    IF NEW.numero_passageiros > v_vagas_restantes THEN
        RAISE EXCEPTION 'ERRO DE VALIDAÇÃO: Pacote "%" possui apenas % vaga(s) disponível(is). Você está tentando reservar % passageiro(s). Operação cancelada.',
            v_nome_pacote,
            v_vagas_restantes,
            NEW.numero_passageiros;
    END IF;

    -- Se passou na validação, permitir a operação
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION fn_validar_vagas_pacote() IS
'Função trigger que valida se há vagas suficientes no pacote antes de
permitir a criação ou atualização de uma reserva.
REGRA DE NEGÓCIO:
- Impede overbooking (venda de vagas além da capacidade)
- Calcula dinamicamente vagas já vendidas
- Lança exceção com mensagem clara se validação falhar
- Garante integridade dos dados a nível de banco';

-- ----------------------------------------------------------------------------
-- Passo 2: Criar o trigger de validação
-- ----------------------------------------------------------------------------
-- BEFORE: executa antes da operação (pode impedir a operação)
-- FOR EACH ROW: valida cada reserva individualmente
-- ----------------------------------------------------------------------------
CREATE TRIGGER trg_validar_vagas_pacote
BEFORE INSERT OR UPDATE ON tb_reservas
FOR EACH ROW
EXECUTE FUNCTION fn_validar_vagas_pacote();

COMMENT ON TRIGGER trg_validar_vagas_pacote ON tb_reservas IS
'Trigger de validação que impede reservas que ultrapassem o número
de vagas disponíveis no pacote, evitando overbooking.';

-- ============================================================================
-- TRIGGER 3: ATUALIZAÇÃO AUTOMÁTICA DE STATUS DE PACOTES
-- ============================================================================
-- Objetivo: Atualizar automaticamente o status do pacote para 'ESGOTADO'
--           quando todas as vagas forem vendidas
-- Regra de negócio: Pacote com 0 vagas restantes = ESGOTADO
-- Gatilho: AFTER INSERT OR UPDATE OR DELETE em tb_reservas
-- Tipo: Automação de atualização em cascata
-- ============================================================================

-- ----------------------------------------------------------------------------
-- Passo 1: Criar a função de atualização de status
-- ----------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION fn_atualizar_status_pacote()
RETURNS TRIGGER AS $$
DECLARE
    v_id_pacote INTEGER;
    v_vagas_disponiveis INTEGER;
    v_vagas_vendidas INTEGER;
    v_vagas_restantes INTEGER;
    v_novo_status VARCHAR(20);
BEGIN
    -- Determinar qual pacote foi afetado
    IF (TG_OP = 'DELETE') THEN
        v_id_pacote := OLD.id_pacote;
    ELSE
        v_id_pacote := NEW.id_pacote;
    END IF;

    -- Buscar vagas totais do pacote
    SELECT vagas_disponiveis
    INTO v_vagas_disponiveis
    FROM tb_pacotes_turisticos
    WHERE id_pacote = v_id_pacote;

    -- Calcular vagas vendidas
    SELECT COALESCE(SUM(numero_passageiros), 0)
    INTO v_vagas_vendidas
    FROM tb_reservas
    WHERE id_pacote = v_id_pacote
    AND status_reserva IN ('CONFIRMADA', 'PENDENTE');

    -- Calcular vagas restantes
    v_vagas_restantes := v_vagas_disponiveis - v_vagas_vendidas;

    -- Determinar novo status baseado nas vagas
    IF v_vagas_restantes <= 0 THEN
        v_novo_status := 'ESGOTADO';
    ELSE
        v_novo_status := 'DISPONIVEL';
    END IF;

    -- Atualizar status do pacote
    UPDATE tb_pacotes_turisticos
    SET status = v_novo_status
    WHERE id_pacote = v_id_pacote;

    -- Retornar adequadamente baseado na operação
    IF (TG_OP = 'DELETE') THEN
        RETURN OLD;
    ELSE
        RETURN NEW;
    END IF;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION fn_atualizar_status_pacote() IS
'Função trigger que atualiza automaticamente o status do pacote turístico
baseado na disponibilidade de vagas.
LÓGICA:
- Se vagas_restantes <= 0: status = ESGOTADO
- Se vagas_restantes > 0: status = DISPONIVEL
BENEFÍCIOS:
- Automação: elimina necessidade de atualização manual
- Consistência: status sempre reflete disponibilidade real
- Performance: views e consultas podem filtrar por status';

-- ----------------------------------------------------------------------------
-- Passo 2: Criar o trigger de atualização
-- ----------------------------------------------------------------------------
CREATE TRIGGER trg_atualizar_status_pacote
AFTER INSERT OR UPDATE OR DELETE ON tb_reservas
FOR EACH ROW
EXECUTE FUNCTION fn_atualizar_status_pacote();

COMMENT ON TRIGGER trg_atualizar_status_pacote ON tb_reservas IS
'Trigger que atualiza automaticamente o status do pacote (DISPONIVEL/ESGOTADO)
baseado nas vagas vendidas.';

-- ============================================================================
-- TRIGGER 4: VALIDAÇÃO DE VALORES FINANCEIROS EM RESERVAS
-- ============================================================================
-- Objetivo: Garantir que o valor total da reserva está correto baseado
--           na fórmula: valor_total = valor_unitario × numero_passageiros × (1 - desconto/100)
-- Regra de negócio: Impedir fraudes ou erros de cálculo
-- Gatilho: BEFORE INSERT OR UPDATE
-- ============================================================================

CREATE OR REPLACE FUNCTION fn_validar_valor_reserva()
RETURNS TRIGGER AS $$
DECLARE
    v_valor_calculado DECIMAL(10, 2);
    v_diferenca DECIMAL(10, 2);
    v_tolerancia DECIMAL(10, 2) := 0.01;  -- Tolerância de R$ 0,01 para arredondamentos
BEGIN
    -- Calcular o valor esperado
    v_valor_calculado := NEW.valor_unitario * NEW.numero_passageiros *
                         (1 - NEW.desconto_percentual / 100.0);

    -- Calcular diferença absoluta
    v_diferenca := ABS(NEW.valor_total - v_valor_calculado);

    -- Validar se o valor total está correto (com tolerância para arredondamento)
    IF v_diferenca > v_tolerancia THEN
        RAISE EXCEPTION 'ERRO DE VALIDAÇÃO FINANCEIRA: Valor total incorreto! Esperado: R$ %, Informado: R$ %. Diferença: R$ %.',
            ROUND(v_valor_calculado, 2),
            NEW.valor_total,
            ROUND(v_diferenca, 2);
    END IF;

    -- Se passou na validação, corrigir possíveis diferenças de arredondamento
    NEW.valor_total := ROUND(v_valor_calculado, 2);

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION fn_validar_valor_reserva() IS
'Função trigger que valida e corrige automaticamente o valor total da reserva.
FÓRMULA: valor_total = valor_unitario × numero_passageiros × (1 - desconto_percentual/100)
BENEFÍCIOS:
- Previne fraudes financeiras
- Corrige erros de arredondamento automaticamente
- Garante consistência nos cálculos
- Auditoria financeira facilitada';

CREATE TRIGGER trg_validar_valor_reserva
BEFORE INSERT OR UPDATE ON tb_reservas
FOR EACH ROW
EXECUTE FUNCTION fn_validar_valor_reserva();

COMMENT ON TRIGGER trg_validar_valor_reserva ON tb_reservas IS
'Trigger que valida e corrige automaticamente o cálculo do valor total da reserva.';

-- ============================================================================
-- DEMONSTRAÇÃO E TESTES DOS TRIGGERS
-- ============================================================================

-- ----------------------------------------------------------------------------
-- TESTE 1: Trigger de Auditoria
-- ----------------------------------------------------------------------------
-- Objetivo: Verificar se operações em tb_reservas são registradas em tb_auditoria
-- ----------------------------------------------------------------------------

-- Inserir uma nova reserva de teste
INSERT INTO tb_reservas (id_cliente, id_pacote, id_funcionario, numero_passageiros, valor_unitario, desconto_percentual, valor_total, status_reserva)
VALUES (1, 1, 4, 1, 7500.00, 0.00, 7500.00, 'PENDENTE');

-- Capturar o ID da reserva criada
DO $$
DECLARE
    v_id_reserva_teste INTEGER;
BEGIN
    SELECT MAX(id_reserva) INTO v_id_reserva_teste FROM tb_reservas;

    -- Atualizar a reserva
    UPDATE tb_reservas
    SET status_reserva = 'CONFIRMADA'
    WHERE id_reserva = v_id_reserva_teste;

    -- Excluir a reserva
    DELETE FROM tb_reservas
    WHERE id_reserva = v_id_reserva_teste;
END $$;

-- Consultar os registros de auditoria gerados
SELECT
    id_auditoria,
    tabela_afetada,
    operacao,
    usuario_db,
    TO_CHAR(data_hora, 'DD/MM/YYYY HH24:MI:SS') AS data_hora_formatada,
    observacao,
    dados_antigos::TEXT AS dados_antes,
    dados_novos::TEXT AS dados_depois
FROM
    tb_auditoria
WHERE
    tabela_afetada = 'tb_reservas'
ORDER BY
    data_hora DESC
LIMIT 10;

-- ----------------------------------------------------------------------------
-- TESTE 2: Trigger de Validação de Vagas (deve FALHAR)
-- ----------------------------------------------------------------------------
-- Objetivo: Tentar criar reserva com mais passageiros do que vagas disponíveis
-- Resultado esperado: ERRO com mensagem clara
-- ----------------------------------------------------------------------------

-- Descobrir um pacote e suas vagas
SELECT
    id_pacote,
    nome_pacote,
    vagas_disponiveis,
    (
        SELECT COALESCE(SUM(numero_passageiros), 0)
        FROM tb_reservas
        WHERE id_pacote = p.id_pacote
        AND status_reserva IN ('CONFIRMADA', 'PENDENTE')
    ) AS vagas_vendidas,
    vagas_disponiveis - (
        SELECT COALESCE(SUM(numero_passageiros), 0)
        FROM tb_reservas
        WHERE id_pacote = p.id_pacote
        AND status_reserva IN ('CONFIRMADA', 'PENDENTE')
    ) AS vagas_restantes
FROM
    tb_pacotes_turisticos p
WHERE
    id_pacote = 1;

-- Tentar reservar mais vagas do que o disponível (DEVE FALHAR)
/*
DESCOMENTAR PARA TESTAR:

INSERT INTO tb_reservas (id_cliente, id_pacote, id_funcionario, numero_passageiros, valor_unitario, desconto_percentual, valor_total, status_reserva)
VALUES (5, 1, 4, 999, 7500.00, 0.00, 7492500.00, 'CONFIRMADA');

ERRO ESPERADO:
ERRO:  ERRO DE VALIDAÇÃO: Pacote "Porto de Galinhas Premium 5 dias" possui apenas X vaga(s) disponível(is).
       Você está tentando reservar 999 passageiro(s). Operação cancelada.
*/

-- ----------------------------------------------------------------------------
-- TESTE 3: Trigger de Atualização de Status de Pacote
-- ----------------------------------------------------------------------------
-- Objetivo: Verificar se status do pacote muda para ESGOTADO quando vagas acabam
-- ----------------------------------------------------------------------------

-- Criar um pacote de teste com poucas vagas
INSERT INTO tb_pacotes_turisticos (
    nome_pacote, id_destino, id_hotel, id_transporte,
    descricao_completa, duracao_dias, data_inicio, data_fim,
    preco_total, vagas_disponiveis, regime_alimentar, status
) VALUES (
    'Teste Trigger - Pacote Limitado', 1, 1, 1,
    'Pacote de teste para demonstração de trigger',
    3, CURRENT_DATE + 60, CURRENT_DATE + 63,
    3000.00, 2, 'CAFE_MANHA', 'DISPONIVEL'
);

-- Capturar ID do pacote criado
DO $$
DECLARE
    v_id_pacote_teste INTEGER;
BEGIN
    SELECT MAX(id_pacote) INTO v_id_pacote_teste FROM tb_pacotes_turisticos;

    -- Verificar status inicial
    RAISE NOTICE 'Status inicial do pacote: %', (SELECT status FROM tb_pacotes_turisticos WHERE id_pacote = v_id_pacote_teste);

    -- Criar reserva que esgota as vagas
    INSERT INTO tb_reservas (id_cliente, id_pacote, id_funcionario, numero_passageiros, valor_unitario, desconto_percentual, valor_total, status_reserva)
    VALUES (2, v_id_pacote_teste, 4, 2, 3000.00, 0.00, 6000.00, 'CONFIRMADA');

    -- Verificar status após reserva
    RAISE NOTICE 'Status após esgotar vagas: %', (SELECT status FROM tb_pacotes_turisticos WHERE id_pacote = v_id_pacote_teste);

    -- Limpar teste
    DELETE FROM tb_reservas WHERE id_pacote = v_id_pacote_teste;
    DELETE FROM tb_pacotes_turisticos WHERE id_pacote = v_id_pacote_teste;
END $$;

-- ----------------------------------------------------------------------------
-- TESTE 4: Trigger de Validação Financeira
-- ----------------------------------------------------------------------------
-- Objetivo: Testar se valores incorretos são rejeitados
-- ----------------------------------------------------------------------------

-- Teste 1: Valor correto (deve passar)
INSERT INTO tb_reservas (id_cliente, id_pacote, id_funcionario, numero_passageiros, valor_unitario, desconto_percentual, valor_total, status_reserva)
VALUES (3, 2, 5, 2, 15000.00, 10.00, 27000.00, 'CONFIRMADA');

-- Limpar teste
DELETE FROM tb_reservas WHERE id_cliente = 3 AND id_pacote = 2 AND numero_passageiros = 2;

-- Teste 2: Valor incorreto (DEVE FALHAR)
/*
DESCOMENTAR PARA TESTAR:

INSERT INTO tb_reservas (id_cliente, id_pacote, id_funcionario, numero_passageiros, valor_unitario, desconto_percentual, valor_total, status_reserva)
VALUES (3, 2, 5, 2, 15000.00, 10.00, 99999.99, 'CONFIRMADA');

ERRO ESPERADO:
ERRO:  ERRO DE VALIDAÇÃO FINANCEIRA: Valor total incorreto!
       Esperado: R$ 27000.00, Informado: R$ 99999.99. Diferença: R$ 72999.99
*/

-- ============================================================================
-- VISUALIZAÇÃO DE TODOS OS TRIGGERS CRIADOS
-- ============================================================================

SELECT
    t.tgname AS trigger_name,
    c.relname AS tabela,
    p.proname AS funcao_executada,
    CASE
        WHEN t.tgtype & 1 = 1 THEN 'ROW'
        ELSE 'STATEMENT'
    END AS nivel,
    CASE
        WHEN t.tgtype & 2 = 2 THEN 'BEFORE'
        WHEN t.tgtype & 64 = 64 THEN 'INSTEAD OF'
        ELSE 'AFTER'
    END AS momento,
    CASE
        WHEN t.tgtype & 4 = 4 THEN 'INSERT'
        ELSE ''
    END ||
    CASE
        WHEN t.tgtype & 8 = 8 THEN ' UPDATE'
        ELSE ''
    END ||
    CASE
        WHEN t.tgtype & 16 = 16 THEN ' DELETE'
        ELSE ''
    END AS eventos
FROM
    pg_trigger t
    JOIN pg_class c ON t.tgrelid = c.oid
    JOIN pg_proc p ON t.tgfoid = p.oid
WHERE
    c.relname IN ('tb_reservas', 'tb_pacotes_turisticos')
    AND NOT t.tgisinternal
ORDER BY
    c.relname, t.tgname;

-- ============================================================================
-- RESUMO DA ETAPA 3.2 - TRIGGERS
-- ============================================================================
-- TRIGGERS CRIADOS:
--
-- 1. trg_auditoria_reservas (tb_reservas)
--    Função: fn_auditoria_reservas()
--    Momento: AFTER INSERT OR UPDATE OR DELETE
--    Objetivo: Registrar todas as operações em tb_auditoria
--    Benefício: Rastreabilidade, compliance, investigação de fraudes
--
-- 2. trg_validar_vagas_pacote (tb_reservas)
--    Função: fn_validar_vagas_pacote()
--    Momento: BEFORE INSERT OR UPDATE
--    Objetivo: Impedir overbooking (reservas além da capacidade)
--    Benefício: Integridade de dados, previne erros operacionais
--
-- 3. trg_atualizar_status_pacote (tb_reservas)
--    Função: fn_atualizar_status_pacote()
--    Momento: AFTER INSERT OR UPDATE OR DELETE
--    Objetivo: Atualizar status do pacote automaticamente (DISPONIVEL/ESGOTADO)
--    Benefício: Automação, consistência, redução de código na aplicação
--
-- 4. trg_validar_valor_reserva (tb_reservas)
--    Função: fn_validar_valor_reserva()
--    Momento: BEFORE INSERT OR UPDATE
--    Objetivo: Validar e corrigir cálculo do valor total
--    Benefício: Segurança financeira, previne fraudes, consistência
--
-- VANTAGENS DOS TRIGGERS:
-- - Integridade de dados garantida a nível de banco
-- - Regras de negócio centralizadas (não duplicadas em múltiplas aplicações)
-- - Automação de tarefas repetitivas
-- - Auditoria e compliance facilitados
-- - Redução de código nas camadas de aplicação
--
-- BOAS PRÁTICAS APLICADAS:
-- - Comentários detalhados em cada função e trigger
-- - Mensagens de erro claras e informativas
-- - Validações antes de modificações (BEFORE)
-- - Logs depois de modificações (AFTER)
-- - Uso de variáveis declaradas para legibilidade
-- - Tratamento adequado de casos NULL (COALESCE)
-- ============================================================================

SELECT 'Etapa 3.2 concluída! 4 triggers criados e testados com sucesso.' AS status;
