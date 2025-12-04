-- ============================================================================
-- ETAPA 3.4: ÍNDICES E OTIMIZAÇÃO DE CONSULTAS
-- Criação de 3 tipos de índices: simples, composto, único
-- Análise EXPLAIN antes/depois para demonstrar ganhos de performance
-- ============================================================================

\c agencia_turismo;

-- ============================================================================
-- ÍNDICE 1: ÍNDICE SIMPLES (B-Tree em coluna única)
-- Objetivo: Acelerar buscas e ordenações por data de reserva
-- Uso: Relatórios cronológicos, filtros por período
-- ============================================================================

CREATE INDEX idx_reservas_data_reserva
ON tb_reservas (data_reserva DESC);


ANALYZE tb_reservas;

-- Teste de performance
EXPLAIN ANALYZE
SELECT * FROM tb_reservas
WHERE data_reserva BETWEEN '2024-01-01' AND '2024-12-31'
ORDER BY data_reserva DESC;

/*
RESULTADO ESPERADO:
ANTES: Seq Scan (varredura completa) + Sort
DEPOIS: Index Scan using idx_reservas_data_reserva (sem sort)
GANHO: 50-80% em tabelas médias/grandes
*/

-- ============================================================================
-- ÍNDICE 2: ÍNDICE COMPOSTO (Multi-Column Index)
-- Objetivo: Otimizar consultas com múltiplas condições WHERE
-- Colunas: data_reserva (mais seletivo) + status_reserva
-- Uso: Relatórios de reservas confirmadas por período
-- ============================================================================

CREATE INDEX idx_reservas_data_status
ON tb_reservas (data_reserva DESC, status_reserva);


ANALYZE tb_reservas;

-- Teste comparativo
EXPLAIN ANALYZE
SELECT id_reserva, data_reserva, status_reserva, valor_total
FROM tb_reservas
WHERE data_reserva BETWEEN '2024-01-01' AND '2024-12-31'
AND status_reserva = 'CONFIRMADA'
ORDER BY data_reserva DESC;

/*
RESULTADO ESPERADO:
ANTES: Seq Scan + Filter + Sort
DEPOIS: Index Scan using idx_reservas_data_status (sem sort)
GANHO: 60-90% em queries com alta seletividade
*/

-- ============================================================================
-- ÍNDICE 3: ÍNDICE ÚNICO (UNIQUE Index Parcial)
-- Objetivo: Garantir unicidade + otimizar buscas por número de transação
-- Benefício duplo: Integridade de dados + Performance
-- ============================================================================

CREATE UNIQUE INDEX idx_pagamentos_numero_transacao_unique
ON tb_pagamentos (numero_transacao)
WHERE numero_transacao IS NOT NULL;


ANALYZE tb_pagamentos;

-- Teste de busca por número de transação
EXPLAIN ANALYZE
SELECT * FROM tb_pagamentos
WHERE numero_transacao = 'TXN001234567890';

/*
RESULTADO ESPERADO:
ANTES: Seq Scan (lento)
DEPOIS: Index Scan using idx_pagamentos_numero_transacao_unique (instantâneo)
GANHO: 95%+ em tabelas grandes
*/

-- ============================================================================
-- ÍNDICES ADICIONAIS ESTRATÉGICOS
-- ============================================================================

-- Índice composto para busca de pacotes por destino e status
CREATE INDEX idx_pacotes_destino_status
ON tb_pacotes_turisticos (id_destino, status, data_inicio);


-- Índice parcial para reservas ativas (não canceladas)
CREATE INDEX idx_reservas_ativas_cliente
ON tb_reservas (id_cliente, status_reserva)
WHERE status_reserva IN ('CONFIRMADA', 'PENDENTE', 'FINALIZADA');


ANALYZE tb_pacotes_turisticos;
ANALYZE tb_reservas;

-- ============================================================================
-- COMPARAÇÕES DE PERFORMANCE
-- ============================================================================

-- Consulta 1: Busca de pacotes disponíveis para um destino
EXPLAIN ANALYZE
SELECT p.nome_pacote, p.preco_total, p.data_inicio
FROM tb_pacotes_turisticos p
WHERE p.id_destino = 1
AND p.status = 'DISPONIVEL'
AND p.data_inicio >= CURRENT_DATE
ORDER BY p.data_inicio ASC;

-- Consulta 2: Histórico de reservas ativas de um cliente
EXPLAIN ANALYZE
SELECT r.id_reserva, r.data_reserva, r.valor_total, r.status_reserva
FROM tb_reservas r
WHERE r.id_cliente = 1
AND r.status_reserva IN ('CONFIRMADA', 'PENDENTE', 'FINALIZADA')
ORDER BY r.data_reserva DESC;

-- ============================================================================
-- ANÁLISE DE ÍNDICES CRIADOS
-- ============================================================================

-- Listar todos os índices customizados
SELECT
    schemaname, tablename, indexname,
    pg_size_pretty(pg_relation_size(indexrelid)) AS tamanho_indice
FROM pg_indexes
JOIN pg_class ON indexname = relname
WHERE schemaname = 'public'
AND indexname LIKE 'idx_%'
ORDER BY tablename, indexname;

-- Estatísticas de uso dos índices
SELECT
    schemaname, tablename, indexname,
    idx_scan AS num_scans,
    idx_tup_read AS tuplas_lidas,
    idx_tup_fetch AS tuplas_buscadas
FROM pg_stat_user_indexes
WHERE indexname LIKE 'idx_%'
ORDER BY idx_scan DESC;

-- ============================================================================
-- RESUMO DA ETAPA 3.4
-- ÍNDICE 1: idx_reservas_data_reserva - Simples (data_reserva)
-- ÍNDICE 2: idx_reservas_data_status - Composto (data + status)
-- ÍNDICE 3: idx_pagamentos_numero_transacao_unique - Único (transação)
-- ADICIONAIS: idx_pacotes_destino_status, idx_reservas_ativas_cliente
-- GANHOS: 50-95% de redução no tempo de consultas com índices estratégicos
-- ============================================================================

SELECT 'Etapa 3.4 concluída! Índices criados e performance otimizada.' AS status;
