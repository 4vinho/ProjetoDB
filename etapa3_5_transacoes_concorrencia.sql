-- ============================================================================
-- ETAPA 3.5: TRANSAÇÕES E CONTROLE DE CONCORRÊNCIA
-- Demonstração de BEGIN, COMMIT, ROLLBACK, LOCKS e níveis de isolamento
-- Requisito: Criar 2 cenários de transações simulando concorrência
-- ============================================================================

\c agencia_turismo;

-- ============================================================================
-- CENÁRIO 1: TRANSFERÊNCIA DE VALOR ENTRE RESERVAS (ATOMICIDADE)
-- Objetivo: Demonstrar transação atômica com COMMIT e ROLLBACK
-- Situação: Transferir desconto de uma reserva para outra (ou desfazer)
-- ============================================================================

-- Exemplo 1A: Transação bem-sucedida (COMMIT)
BEGIN;

-- Simular transferência de desconto entre reservas
UPDATE tb_reservas
SET desconto_percentual = 15.00,
    valor_total = valor_unitario * numero_passageiros * (1 - 15.00 / 100.0)
WHERE id_reserva = 1;

UPDATE tb_reservas
SET desconto_percentual = 5.00,
    valor_total = valor_unitario * numero_passageiros * (1 - 5.00 / 100.0)
WHERE id_reserva = 2;

-- Verificar alterações antes do COMMIT
SELECT id_reserva, desconto_percentual, valor_total
FROM tb_reservas
WHERE id_reserva IN (1, 2);

COMMIT; -- Confirma as alterações

-- Exemplo 1B: Transação com erro (ROLLBACK)
BEGIN;

UPDATE tb_reservas
SET desconto_percentual = 20.00,
    valor_total = valor_unitario * numero_passageiros * (1 - 20.00 / 100.0)
WHERE id_reserva = 3;

-- Simular erro: tentar inserir desconto inválido
-- Esta operação falhará devido a constraint
UPDATE tb_reservas
SET desconto_percentual = 150.00  -- INVÁLIDO: > 100%
WHERE id_reserva = 4;

ROLLBACK; -- Desfaz TODAS as alterações (incluindo a primeira UPDATE)

-- Verificar que nenhuma alteração foi aplicada
SELECT id_reserva, desconto_percentual, valor_total
FROM tb_reservas
WHERE id_reserva IN (3, 4);

-- ============================================================================
-- CENÁRIO 2: CONCORRÊNCIA COM LOCKS E NÍVEIS DE ISOLAMENTO
-- Objetivo: Demonstrar comportamento de múltiplas sessões editando mesmo registro
-- Conceitos: READ COMMITTED vs SERIALIZABLE, dirty reads, phantom reads
-- ============================================================================

-- SESSÃO 1: Atualizar reserva com lock explícito
-- Execute este bloco em uma sessão/terminal
BEGIN;

SELECT id_reserva, status_reserva, valor_total
FROM tb_reservas
WHERE id_reserva = 5
FOR UPDATE;  -- Lock explícito: outras sessões aguardam

UPDATE tb_reservas
SET status_reserva = 'FINALIZADA'
WHERE id_reserva = 5;

-- Aguardar 10 segundos antes de commit (simula processamento)
SELECT pg_sleep(10);

COMMIT;

-- SESSÃO 2: Tentar atualizar a mesma reserva (executar em paralelo)
-- Este bloco ficará BLOQUEADO até a SESSÃO 1 fazer COMMIT
/*
BEGIN;

UPDATE tb_reservas
SET observacoes = 'Tentativa de update concorrente'
WHERE id_reserva = 5;

COMMIT;
*/

-- ============================================================================
-- DEMONSTRAÇÃO DE NÍVEIS DE ISOLAMENTO
-- ============================================================================

-- Nível 1: READ COMMITTED (padrão no PostgreSQL)
-- Permite dirty reads: sessões veem commits de outras sessões imediatamente
BEGIN TRANSACTION ISOLATION LEVEL READ COMMITTED;

SELECT status_reserva FROM tb_reservas WHERE id_reserva = 6;
-- Se outra sessão alterar e commitar, a próxima leitura verá a mudança

COMMIT;

-- Nível 2: REPEATABLE READ
-- Garante leituras consistentes dentro da transação (snapshot no início)
BEGIN TRANSACTION ISOLATION LEVEL REPEATABLE READ;

SELECT status_reserva FROM tb_reservas WHERE id_reserva = 7;
-- Mesmo que outra sessão altere e commite, esta sessão verá o valor original

COMMIT;

-- Nível 3: SERIALIZABLE (maior isolamento)
-- Previne phantom reads e garante serialização completa
BEGIN TRANSACTION ISOLATION LEVEL SERIALIZABLE;

SELECT COUNT(*) FROM tb_reservas WHERE status_reserva = 'CONFIRMADA';
-- Outras sessões que inserem/deletam reservas não afetam esta contagem

COMMIT;

-- ============================================================================
-- SAVEPOINTS: CHECKPOINTS DENTRO DE TRANSAÇÕES
-- Objetivo: Permitir rollback parcial sem desfazer toda a transação
-- ============================================================================

BEGIN;

-- Checkpoint 1
INSERT INTO tb_reservas (id_cliente, id_pacote, id_funcionario, numero_passageiros, valor_unitario, desconto_percentual, valor_total, status_reserva)
VALUES (1, 3, 4, 2, 4200.00, 5.00, 7980.00, 'CONFIRMADA');

SAVEPOINT checkpoint1;

-- Checkpoint 2
UPDATE tb_reservas SET status_reserva = 'PENDENTE' WHERE id_reserva = 8;

SAVEPOINT checkpoint2;

-- Tentativa de operação que pode falhar
UPDATE tb_reservas SET desconto_percentual = 200.00 WHERE id_reserva = 9;  -- INVÁLIDO

-- Rollback apenas até checkpoint2 (mantém INSERT e UPDATE anteriores)
ROLLBACK TO SAVEPOINT checkpoint2;

COMMIT;  -- Confirma INSERT e primeira UPDATE

-- ============================================================================
-- DEADLOCK: DETECÇÃO E PREVENÇÃO
-- Situação: Duas sessões travam esperando recursos uma da outra
-- ============================================================================

-- SESSÃO A (executar em um terminal):
/*
BEGIN;
UPDATE tb_reservas SET status_reserva = 'PENDENTE' WHERE id_reserva = 10;
SELECT pg_sleep(5);
UPDATE tb_reservas SET status_reserva = 'PENDENTE' WHERE id_reserva = 11;  -- Aguarda sessão B
COMMIT;
*/

-- SESSÃO B (executar em outro terminal SIMULTANEAMENTE):
/*
BEGIN;
UPDATE tb_reservas SET status_reserva = 'PENDENTE' WHERE id_reserva = 11;
SELECT pg_sleep(5);
UPDATE tb_reservas SET status_reserva = 'PENDENTE' WHERE id_reserva = 10;  -- DEADLOCK!
COMMIT;
*/

-- PostgreSQL detecta deadlock automaticamente e aborta uma das transações

-- ============================================================================
-- MONITORAMENTO DE LOCKS ATIVOS
-- ============================================================================

-- Visualizar locks atualmente ativos no banco
SELECT
    locktype, database, relation::regclass AS tabela,
    mode AS tipo_lock, granted AS concedido,
    pid AS process_id
FROM pg_locks
WHERE database = (SELECT oid FROM pg_database WHERE datname = 'agencia_turismo')
AND relation IS NOT NULL
ORDER BY relation;

-- Identificar transações bloqueadas
SELECT
    blocked_locks.pid AS bloqueado_pid,
    blocked_activity.usename AS bloqueado_usuario,
    blocking_locks.pid AS bloqueante_pid,
    blocking_activity.usename AS bloqueante_usuario,
    blocked_activity.query AS consulta_bloqueada,
    blocking_activity.query AS consulta_bloqueante
FROM pg_catalog.pg_locks blocked_locks
JOIN pg_catalog.pg_stat_activity blocked_activity ON blocked_activity.pid = blocked_locks.pid
JOIN pg_catalog.pg_locks blocking_locks ON blocking_locks.locktype = blocked_locks.locktype
    AND blocking_locks.database IS NOT DISTINCT FROM blocked_locks.database
    AND blocking_locks.relation IS NOT DISTINCT FROM blocked_locks.relation
    AND blocking_locks.pid != blocked_locks.pid
JOIN pg_catalog.pg_stat_activity blocking_activity ON blocking_activity.pid = blocking_locks.pid
WHERE NOT blocked_locks.granted;

-- ============================================================================
-- RESUMO DA ETAPA 3.5
-- CONCEITOS DEMONSTRADOS:
-- - ATOMICIDADE: BEGIN, COMMIT, ROLLBACK
-- - SAVEPOINTS: Rollback parcial
-- - LOCKS: FOR UPDATE, comportamento de concorrência
-- - ISOLAMENTO: READ COMMITTED, REPEATABLE READ, SERIALIZABLE
-- - DEADLOCK: Detecção automática pelo PostgreSQL
-- - MONITORAMENTO: pg_locks, transações bloqueadas
-- ============================================================================

SELECT 'Etapa 3.5 concluída! Transações e concorrência demonstrados.' AS status;
