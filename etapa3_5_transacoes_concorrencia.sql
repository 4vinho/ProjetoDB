-- ============================================================================
-- ETAPA 3.5: TRANSAÇÕES E CONTROLE DE CONCORRÊNCIA
-- ============================================================================
-- Descrição: Demonstração de transações, locks e níveis de isolamento
-- Requisitos do projeto:
--   - Uso de BEGIN, COMMIT, ROLLBACK
--   - Demonstrar LOCKs (bloqueios)
--   - Criar 2 cenários de concorrência (duas sessões editando mesmo registro)
--   - Demonstrar níveis de isolamento (READ COMMITTED vs SERIALIZABLE)
--   - Explicar efeitos (dirty read, phantom read, etc.)
-- ============================================================================

-- Conectar ao banco de dados
\c agencia_turismo;

-- ============================================================================
-- CONCEITOS FUNDAMENTAIS
-- ============================================================================

/*
PROPRIEDADES ACID DAS TRANSAÇÕES:

A - ATOMICIDADE:
    - Tudo ou nada: todas as operações são executadas ou nenhuma é
    - Se houver erro, ROLLBACK desfaz todas as mudanças
    - Garante consistência mesmo em falhas

C - CONSISTÊNCIA:
    - Banco vai de um estado válido para outro estado válido
    - Constraints, triggers e regras são respeitados
    - Dados mantêm integridade referencial

I - ISOLAMENTO (ISOLATION):
    - Transações concorrentes não interferem entre si
    - Níveis de isolamento controlam visibilidade de mudanças
    - Previne condições de corrida (race conditions)

D - DURABILIDADE:
    - Após COMMIT, dados persistem mesmo em falhas de sistema
    - Garantia de gravação em disco
    - Logs de transação (WAL - Write-Ahead Logging)

NÍVEIS DE ISOLAMENTO (PostgreSQL):

1. READ UNCOMMITTED (não implementado no PostgreSQL, trata como READ COMMITTED)
   - Lê dados não commitados (dirty read)
   - Menor isolamento, maior concorrência

2. READ COMMITTED (padrão do PostgreSQL)
   - Lê apenas dados commitados
   - Cada query vê snapshot no momento da execução
   - Previne dirty reads
   - Permite non-repeatable reads e phantom reads

3. REPEATABLE READ
   - Snapshot da transação inteira (não por query)
   - Previne dirty e non-repeatable reads
   - Pode ter phantom reads em alguns SGBDs (PostgreSQL previne)

4. SERIALIZABLE
   - Isolamento total
   - Transações executam como se fossem sequenciais
   - Previne todos os problemas de concorrência
   - Pode causar falhas por conflitos de serialização

PROBLEMAS DE CONCORRÊNCIA:

- Dirty Read: Ler dados não commitados de outra transação
- Non-Repeatable Read: Mesma query retorna resultados diferentes
- Phantom Read: Novas linhas aparecem entre queries
- Lost Update: Update de uma transação sobrescreve outra
*/

-- ============================================================================
-- CENÁRIO 1: TRANSAÇÃO BÁSICA COM COMMIT E ROLLBACK
-- ============================================================================

-- ----------------------------------------------------------------------------
-- Exemplo 1A: Transação com COMMIT (sucesso)
-- ----------------------------------------------------------------------------
-- Objetivo: Criar uma reserva e registrar pagamento atomicamente
-- Se qualquer operação falhar, desfazer tudo (ROLLBACK)
-- ----------------------------------------------------------------------------

BEGIN;  -- Inicia a transação

    -- Operação 1: Criar reserva
    INSERT INTO tb_reservas (
        id_cliente, id_pacote, id_funcionario,
        numero_passageiros, valor_unitario,
        desconto_percentual, valor_total,
        status_reserva, observacoes
    ) VALUES (
        1, 5, 4,
        2, 5200.00,
        10.00, 9360.00,
        'CONFIRMADA', 'Transação de teste - COMMIT'
    );

    -- Capturar ID da reserva criada
    -- (em aplicação real, usaria RETURNING ou currval)

    -- Operação 2: Registrar pagamento
    INSERT INTO tb_pagamentos (
        id_reserva, forma_pagamento,
        numero_parcela, total_parcelas,
        valor_parcela, status_pagamento
    ) VALUES (
        (SELECT MAX(id_reserva) FROM tb_reservas),
        'PIX',
        1, 1,
        9360.00, 'PAGO'
    );

    -- Verificar dados antes do commit
    SELECT 'Dados inseridos na transação:' AS status;
    SELECT * FROM tb_reservas WHERE id_reserva = (SELECT MAX(id_reserva) FROM tb_reservas);

COMMIT;  -- Confirma a transação (torna permanente)

SELECT 'Transação commitada com sucesso!' AS status;

-- Limpar dados de teste
DELETE FROM tb_pagamentos
WHERE id_reserva = (SELECT MAX(id_reserva) FROM tb_reservas WHERE observacoes = 'Transação de teste - COMMIT');

DELETE FROM tb_reservas
WHERE observacoes = 'Transação de teste - COMMIT';

-- ----------------------------------------------------------------------------
-- Exemplo 1B: Transação com ROLLBACK (erro/cancelamento)
-- ----------------------------------------------------------------------------
-- Objetivo: Simular erro e desfazer todas as operações
-- ----------------------------------------------------------------------------

BEGIN;

    -- Operação 1: Inserir cliente
    INSERT INTO tb_clientes (
        nome_completo, cpf, data_nascimento, email, telefone
    ) VALUES (
        'Cliente Teste Rollback', '99999999999',
        '1990-01-01', 'teste.rollback@test.com', '61999999999'
    );

    SELECT 'Cliente inserido (ainda não commitado)' AS status;
    SELECT * FROM tb_clientes WHERE cpf = '99999999999';

    -- Simular erro ou decisão de cancelar
    SELECT 'Decidindo cancelar operação...' AS status;

ROLLBACK;  -- Desfaz TODAS as operações da transação

SELECT 'Transação cancelada! Verificando que cliente não existe:' AS status;
SELECT COUNT(*) AS deve_ser_zero FROM tb_clientes WHERE cpf = '99999999999';

-- ============================================================================
-- CENÁRIO 2: SAVEPOINTS (Pontos de Salvamento)
-- ============================================================================
-- Objetivo: Rollback parcial dentro de uma transação
-- Útil para desfazer apenas parte das operações
-- ============================================================================

BEGIN;

    -- Operação 1: Inserir destino
    INSERT INTO tb_destinos (
        nome_destino, pais, cidade, categoria,
        clima, idioma_principal, moeda_local
    ) VALUES (
        'Teste Savepoint 1', 'Brasil', 'Brasília', 'URBANO',
        'Tropical', 'Português', 'Real'
    );

    SAVEPOINT sp_apos_destino;  -- Criar ponto de salvamento

    -- Operação 2: Inserir outro destino
    INSERT INTO tb_destinos (
        nome_destino, pais, cidade, categoria,
        clima, idioma_principal, moeda_local
    ) VALUES (
        'Teste Savepoint 2', 'Brasil', 'São Paulo', 'URBANO',
        'Subtropical', 'Português', 'Real'
    );

    SELECT 'Dois destinos inseridos' AS status;
    SELECT nome_destino FROM tb_destinos WHERE nome_destino LIKE 'Teste Savepoint%';

    -- Desfazer apenas a segunda operação
    ROLLBACK TO SAVEPOINT sp_apos_destino;

    SELECT 'Segundo destino removido, primeiro mantido' AS status;
    SELECT nome_destino FROM tb_destinos WHERE nome_destino LIKE 'Teste Savepoint%';

COMMIT;  -- Confirma apenas o primeiro destino

-- Limpar
DELETE FROM tb_destinos WHERE nome_destino LIKE 'Teste Savepoint%';

-- ============================================================================
-- CENÁRIO 3: CONTROLE DE CONCORRÊNCIA - LOCKS
-- ============================================================================

-- ----------------------------------------------------------------------------
-- Tipos de LOCKs no PostgreSQL:
-- ----------------------------------------------------------------------------
/*
1. ROW LEVEL LOCKS (Bloqueios de Linha):
   - FOR UPDATE: Bloqueia linhas para atualização
   - FOR NO KEY UPDATE: Permite UPDATE em colunas não-chave
   - FOR SHARE: Permite leitura, impede UPDATE/DELETE
   - FOR KEY SHARE: Menos restritivo que FOR SHARE

2. TABLE LEVEL LOCKS (Bloqueios de Tabela):
   - ACCESS SHARE: Gerado por SELECT
   - ROW SHARE: Gerado por SELECT FOR UPDATE
   - ROW EXCLUSIVE: Gerado por INSERT, UPDATE, DELETE
   - SHARE: LOCK TABLE ... IN SHARE MODE
   - EXCLUSIVE: LOCK TABLE ... IN EXCLUSIVE MODE
   - ACCESS EXCLUSIVE: ALTER TABLE, DROP TABLE, VACUUM FULL

3. ADVISORY LOCKS (Bloqueios Consultivos):
   - Controlados pela aplicação
   - pg_advisory_lock(), pg_advisory_unlock()
*/

-- ----------------------------------------------------------------------------
-- Exemplo 3A: SELECT FOR UPDATE (Pessimistic Locking)
-- ----------------------------------------------------------------------------
-- Objetivo: Bloquear linha para garantir que ninguém mais altere
-- Cenário: Decrementar vagas de pacote (evitar overbooking)
-- ----------------------------------------------------------------------------

-- SESSÃO 1 (simulação):
BEGIN;

    -- Buscar pacote e bloquear linha para atualização
    SELECT
        id_pacote,
        nome_pacote,
        vagas_disponiveis
    FROM
        tb_pacotes_turisticos
    WHERE
        id_pacote = 1
    FOR UPDATE;  -- BLOQUEIA a linha (outras sessões esperam)

    -- Aqui faríamos validações complexas...
    -- Outras transações que tentarem FOR UPDATE nesta linha AGUARDAM

    -- Decrementar vagas
    UPDATE tb_pacotes_turisticos
    SET vagas_disponiveis = vagas_disponiveis - 2
    WHERE id_pacote = 1;

COMMIT;  -- Libera o lock

SELECT 'Lock liberado' AS status;

-- Reverter alteração
UPDATE tb_pacotes_turisticos
SET vagas_disponiveis = vagas_disponiveis + 2
WHERE id_pacote = 1;

-- ----------------------------------------------------------------------------
-- Exemplo 3B: LOCK TABLE (Table-Level Lock)
-- ----------------------------------------------------------------------------
-- Objetivo: Bloquear tabela inteira para operações em lote
-- Uso: Manutenção, migração de dados, operações batch
-- ----------------------------------------------------------------------------

BEGIN;

    -- Bloquear tabela em modo SHARE (permite leitura, impede escrita)
    LOCK TABLE tb_destinos IN SHARE MODE;

    SELECT 'Tabela bloqueada para escrita' AS status;

    -- Fazer análise ou validação
    SELECT COUNT(*) FROM tb_destinos;

    -- Outras transações podem LER, mas não podem INSERT/UPDATE/DELETE

COMMIT;  -- Libera o lock

-- ============================================================================
-- CENÁRIO 4: SIMULAÇÃO DE CONCORRÊNCIA (Duas Sessões)
-- ============================================================================

-- ----------------------------------------------------------------------------
-- Cenário 4A: Lost Update Problem
-- ----------------------------------------------------------------------------
-- Problema: Duas transações atualizam mesmo registro, uma sobrescreve a outra
-- Solução: SELECT FOR UPDATE
-- ----------------------------------------------------------------------------

/*
INSTRUÇÕES PARA TESTE MANUAL:

Abrir duas janelas de terminal PostgreSQL (psql) simultaneamente.

SESSÃO 1:                                SESSÃO 2:
-----------------------------------------------------------------------
BEGIN;
SELECT vagas_disponiveis
FROM tb_pacotes_turisticos
WHERE id_pacote = 1;                     BEGIN;
-- Resultado: 20 vagas                   SELECT vagas_disponiveis
                                         FROM tb_pacotes_turisticos
                                         WHERE id_pacote = 1;
                                         -- Resultado: 20 vagas

UPDATE tb_pacotes_turisticos             UPDATE tb_pacotes_turisticos
SET vagas_disponiveis = 18               SET vagas_disponiveis = 15
WHERE id_pacote = 1;                     WHERE id_pacote = 1;
-- Define 18 vagas                       -- AGUARDA (bloqueado!)

COMMIT;
-- Sessão 1 commitou                     -- Agora executa e define 15
                                         COMMIT;

-- RESULTADO: Vagas = 15 (perdeu update da Sessão 1!)

SOLUÇÃO COM FOR UPDATE:

SESSÃO 1:                                SESSÃO 2:
-----------------------------------------------------------------------
BEGIN;
SELECT vagas_disponiveis
FROM tb_pacotes_turisticos
WHERE id_pacote = 1
FOR UPDATE;                              BEGIN;
-- Bloqueia a linha!                     SELECT vagas_disponiveis
                                         FROM tb_pacotes_turisticos
                                         WHERE id_pacote = 1
                                         FOR UPDATE;
                                         -- AGUARDA lock da Sessão 1

UPDATE tb_pacotes_turisticos
SET vagas_disponiveis = 18
WHERE id_pacote = 1;
COMMIT;
-- Libera lock                           -- Agora pega lock e vê valor 18
                                         -- Pode decidir baseado no novo valor
                                         COMMIT;

-- RESULTADO: Consistente!
*/

-- ----------------------------------------------------------------------------
-- Cenário 4B: Deadlock (Impasse)
-- ----------------------------------------------------------------------------
-- Problema: Duas transações esperam uma pela outra (ciclo)
-- PostgreSQL detecta e cancela uma automaticamente
-- ----------------------------------------------------------------------------

/*
SIMULAÇÃO DE DEADLOCK:

SESSÃO 1:                                SESSÃO 2:
-----------------------------------------------------------------------
BEGIN;
UPDATE tb_pacotes_turisticos             BEGIN;
SET status = 'DISPONIVEL'                UPDATE tb_destinos
WHERE id_pacote = 1;                     SET status = 'ATIVO'
-- Bloqueia pacote 1                     WHERE id_destino = 1;
                                         -- Bloqueia destino 1

UPDATE tb_destinos                       UPDATE tb_pacotes_turisticos
SET status = 'ATIVO'                     SET status = 'DISPONIVEL'
WHERE id_destino = 1;                    WHERE id_pacote = 1;
-- AGUARDA Sessão 2                      -- AGUARDA Sessão 1
                                         -- DEADLOCK DETECTADO!

-- PostgreSQL cancela uma transação:
-- ERROR: deadlock detected

ROLLBACK;                                ROLLBACK;

PREVENÇÃO DE DEADLOCKS:
1. Sempre acessar recursos na mesma ordem
2. Manter transações curtas
3. Usar timeouts (lock_timeout)
4. Retry logic na aplicação
*/

-- Configurar timeout para locks (prevenir espera infinita)
SET lock_timeout = '5s';  -- Cancelar após 5 segundos esperando lock

-- ============================================================================
-- CENÁRIO 5: NÍVEIS DE ISOLAMENTO
-- ============================================================================

-- Verificar nível de isolamento atual
SHOW transaction_isolation;

-- ----------------------------------------------------------------------------
-- Exemplo 5A: READ COMMITTED (Padrão do PostgreSQL)
-- ----------------------------------------------------------------------------
-- Comportamento: Cada SELECT vê dados commitados até aquele momento
-- ----------------------------------------------------------------------------

/*
SESSÃO 1:                                SESSÃO 2:
-----------------------------------------------------------------------
BEGIN;
SELECT preco_total
FROM tb_pacotes_turisticos
WHERE id_pacote = 1;                     BEGIN;
-- Resultado: R$ 7500.00                 UPDATE tb_pacotes_turisticos
                                         SET preco_total = 8000.00
                                         WHERE id_pacote = 1;
                                         COMMIT;
                                         -- Mudança commitada

SELECT preco_total
FROM tb_pacotes_turisticos
WHERE id_pacote = 1;
-- Resultado: R$ 8000.00 (VÊ A MUDANÇA!)
-- NON-REPEATABLE READ!

COMMIT;

EFEITO: Mesma query na mesma transação retornou valores diferentes
NÍVEL: READ COMMITTED permite non-repeatable reads
*/

-- ----------------------------------------------------------------------------
-- Exemplo 5B: REPEATABLE READ
-- ----------------------------------------------------------------------------
-- Comportamento: Snapshot da transação inteira (consistência)
-- ----------------------------------------------------------------------------

BEGIN TRANSACTION ISOLATION LEVEL REPEATABLE READ;

    SELECT preco_total
    FROM tb_pacotes_turisticos
    WHERE id_pacote = 1;
    -- Resultado: R$ 7500.00

    -- Mesmo que outra sessão altere e commite, esta transação
    -- continuará vendo R$ 7500.00 (snapshot inicial)

    SELECT preco_total
    FROM tb_pacotes_turisticos
    WHERE id_pacote = 1;
    -- Resultado: R$ 7500.00 (MESMO VALOR!)

COMMIT;

-- Agora vê a mudança
SELECT preco_total FROM tb_pacotes_turisticos WHERE id_pacote = 1;

/*
COMPARAÇÃO:

READ COMMITTED:
- Cada query vê últimos dados commitados
- Permite non-repeatable reads
- Maior concorrência
- Padrão do PostgreSQL

REPEATABLE READ:
- Snapshot no início da transação
- Consistência garantida
- Pode falhar em conflitos de write
- Phantom reads prevenidos no PostgreSQL

SERIALIZABLE:
- Isolamento total
- Como se transações fossem sequenciais
- Falha com serialization errors
- Menor concorrência
*/

-- ----------------------------------------------------------------------------
-- Exemplo 5C: SERIALIZABLE
-- ----------------------------------------------------------------------------
-- Mais alto nível de isolamento
-- Pode causar falhas de serialização
-- ----------------------------------------------------------------------------

BEGIN TRANSACTION ISOLATION LEVEL SERIALIZABLE;

    -- Qualquer leitura/escrita pode conflitar
    SELECT SUM(valor_total)
    FROM tb_reservas
    WHERE id_pacote = 1;

    -- Se outra transação modificar estas linhas e commitar,
    -- esta transação FALHARÁ no commit com erro:
    -- ERROR: could not serialize access due to concurrent update

COMMIT;

-- ============================================================================
-- CENÁRIO 6: DEMONSTRAÇÃO PRÁTICA - SISTEMA DE RESERVA
-- ============================================================================

-- ----------------------------------------------------------------------------
-- Função: Reservar pacote com controle de concorrência
-- ----------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION fn_reservar_pacote_seguro(
    p_id_cliente INTEGER,
    p_id_pacote INTEGER,
    p_numero_passageiros INTEGER,
    OUT o_sucesso BOOLEAN,
    OUT o_mensagem TEXT
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_vagas_disponiveis INTEGER;
    v_vagas_vendidas INTEGER;
    v_vagas_restantes INTEGER;
BEGIN
    -- Iniciar transação com REPEATABLE READ
    -- (função já executa dentro de transação)

    -- LOCK pessimista: bloquear pacote para atualização
    SELECT vagas_disponiveis
    INTO v_vagas_disponiveis
    FROM tb_pacotes_turisticos
    WHERE id_pacote = p_id_pacote
    FOR UPDATE;  -- Bloqueia linha (outras sessões esperam)

    IF NOT FOUND THEN
        o_sucesso := FALSE;
        o_mensagem := 'Pacote não encontrado';
        RETURN;
    END IF;

    -- Calcular vagas vendidas
    SELECT COALESCE(SUM(numero_passageiros), 0)
    INTO v_vagas_vendidas
    FROM tb_reservas
    WHERE id_pacote = p_id_pacote
    AND status_reserva IN ('CONFIRMADA', 'PENDENTE')
    FOR UPDATE;  -- Bloqueia reservas também

    v_vagas_restantes := v_vagas_disponiveis - v_vagas_vendidas;

    -- Validar disponibilidade
    IF p_numero_passageiros > v_vagas_restantes THEN
        o_sucesso := FALSE;
        o_mensagem := 'Apenas ' || v_vagas_restantes || ' vaga(s) disponível(is)';
        RETURN;
    END IF;

    -- Criar reserva (protegido por locks)
    INSERT INTO tb_reservas (
        id_cliente, id_pacote, id_funcionario,
        numero_passageiros, valor_unitario,
        desconto_percentual, valor_total, status_reserva
    )
    SELECT
        p_id_cliente,
        p_id_pacote,
        4,  -- Funcionário padrão
        p_numero_passageiros,
        preco_total,
        0,
        preco_total * p_numero_passageiros,
        'CONFIRMADA'
    FROM tb_pacotes_turisticos
    WHERE id_pacote = p_id_pacote;

    o_sucesso := TRUE;
    o_mensagem := 'Reserva criada com sucesso! Vagas restantes: ' ||
                  (v_vagas_restantes - p_numero_passageiros);

EXCEPTION
    WHEN OTHERS THEN
        o_sucesso := FALSE;
        o_mensagem := 'Erro: ' || SQLERRM;
END;
$$;

-- Testar função
SELECT * FROM fn_reservar_pacote_seguro(1, 1, 2);

-- ============================================================================
-- MONITORAMENTO DE LOCKS E TRANSAÇÕES ATIVAS
-- ============================================================================

-- Ver transações ativas e locks
SELECT
    pid,
    usename,
    state,
    query,
    query_start,
    state_change,
    wait_event_type,
    wait_event
FROM
    pg_stat_activity
WHERE
    datname = 'agencia_turismo'
    AND state != 'idle'
ORDER BY
    query_start;

-- Ver locks ativos
SELECT
    locktype,
    database,
    relation::regclass AS tabela,
    page,
    tuple,
    transactionid,
    pid,
    mode,
    granted
FROM
    pg_locks
WHERE
    NOT granted  -- Locks aguardando
ORDER BY
    pid;

-- Matar transação travada (emergência)
-- SELECT pg_terminate_backend(pid);

-- ============================================================================
-- RESUMO DA ETAPA 3.5
-- ============================================================================
/*
CONCEITOS DEMONSTRADOS:

1. TRANSAÇÕES:
   ✓ BEGIN / COMMIT / ROLLBACK
   ✓ Propriedades ACID
   ✓ SAVEPOINT (rollback parcial)
   ✓ Atomicidade de operações

2. LOCKS:
   ✓ SELECT FOR UPDATE (pessimistic locking)
   ✓ LOCK TABLE (table-level locks)
   ✓ Row-level locks vs table-level locks
   ✓ Advisory locks

3. NÍVEIS DE ISOLAMENTO:
   ✓ READ COMMITTED (padrão)
   ✓ REPEATABLE READ
   ✓ SERIALIZABLE
   ✓ Trade-offs de cada nível

4. PROBLEMAS DE CONCORRÊNCIA:
   ✓ Lost Update
   ✓ Non-Repeatable Read
   ✓ Phantom Read
   ✓ Dirty Read
   ✓ Deadlock

5. SOLUÇÕES:
   ✓ Locks pessimistas (FOR UPDATE)
   ✓ Locks otimistas (versioning)
   ✓ Retry logic
   ✓ Timeouts
   ✓ Ordem consistente de acesso

6. BOAS PRÁTICAS:
   - Manter transações curtas
   - Acessar recursos na mesma ordem
   - Usar níveis de isolamento adequados
   - Implementar retry logic
   - Monitorar locks e deadlocks
   - Configurar timeouts
   - Evitar user input dentro de transações

FERRAMENTAS:
- pg_stat_activity: Monitorar transações
- pg_locks: Ver locks ativos
- pg_terminate_backend(): Matar processos
- lock_timeout: Timeout automático
- deadlock_timeout: Detecção de deadlocks
*/
-- ============================================================================

SELECT 'Etapa 3.5 concluída! Transações e concorrência demonstradas.' AS status;
