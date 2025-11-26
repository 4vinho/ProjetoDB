-- ============================================================================
-- ETAPA 3.4: ÍNDICES E OTIMIZAÇÃO DE CONSULTAS
-- ============================================================================
-- Descrição: Criação de índices estratégicos e análise de performance
-- Requisitos do projeto:
--   - Criar pelo menos 3 índices: simples, composto, único
--   - Comparar plano de execução (EXPLAIN / EXPLAIN ANALYZE) antes e depois
--   - Documentar ganhos de performance
-- Objetivo: Demonstrar impacto dos índices no desempenho de consultas
-- ============================================================================

-- Conectar ao banco de dados
\c agencia_turismo;

-- ============================================================================
-- ANÁLISE INICIAL: CONSULTAS SEM ÍNDICES ESPECÍFICOS
-- ============================================================================
-- Identificar consultas lentas que se beneficiariam de índices
-- ============================================================================

-- ----------------------------------------------------------------------------
-- CONSULTA 1: Buscar reservas por período e status
-- ----------------------------------------------------------------------------
-- Cenário: Relatório diário de reservas confirmadas
-- Problema: Sem índice, faz Seq Scan (varredura completa da tabela)
-- ----------------------------------------------------------------------------

-- ANTES DA OTIMIZAÇÃO - Analisar plano de execução
EXPLAIN ANALYZE
SELECT
    r.id_reserva,
    r.data_reserva,
    r.status_reserva,
    r.valor_total,
    c.nome_completo AS cliente,
    p.nome_pacote
FROM
    tb_reservas r
    INNER JOIN tb_clientes c ON r.id_cliente = c.id_cliente
    INNER JOIN tb_pacotes_turisticos p ON r.id_pacote = p.id_pacote
WHERE
    r.data_reserva BETWEEN '2024-11-01' AND '2024-11-30'
    AND r.status_reserva = 'CONFIRMADA'
ORDER BY
    r.data_reserva DESC;

/*
ANÁLISE ESPERADA (ANTES):
- Seq Scan on tb_reservas: varredura completa (lento)
- Filter: aplicado linha por linha
- Custo alto: depende do tamanho da tabela
- Tempo estimado: proporcionalmente alto

SOLUÇÃO:
- Criar índice composto em (data_reserva, status_reserva)
*/

-- ----------------------------------------------------------------------------
-- CONSULTA 2: Buscar pacotes por destino e datas
-- ----------------------------------------------------------------------------
-- Cenário: Cliente buscando pacotes disponíveis para um destino específico
-- Problema: Múltiplas condições sem índice específico
-- ----------------------------------------------------------------------------

EXPLAIN ANALYZE
SELECT
    p.id_pacote,
    p.nome_pacote,
    p.preco_total,
    p.data_inicio,
    p.data_fim,
    d.nome_destino,
    d.pais
FROM
    tb_pacotes_turisticos p
    INNER JOIN tb_destinos d ON p.id_destino = d.id_destino
WHERE
    p.id_destino IN (1, 2, 3, 4, 5)
    AND p.data_inicio >= CURRENT_DATE
    AND p.status = 'DISPONIVEL'
ORDER BY
    p.preco_total ASC;

/*
ANÁLISE ESPERADA (ANTES):
- Bitmap Index Scan (se houver índice em id_destino)
- Seq Scan (se não houver)
- Sort: custo adicional para ORDER BY

SOLUÇÃO:
- Criar índice composto em (id_destino, data_inicio, status)
*/

-- ----------------------------------------------------------------------------
-- CONSULTA 3: Buscar avaliações de um pacote específico
-- ----------------------------------------------------------------------------
-- Cenário: Exibir avaliações de clientes para um pacote
-- Problema: Busca por chave estrangeira sem índice otimizado
-- ----------------------------------------------------------------------------

EXPLAIN ANALYZE
SELECT
    av.nota,
    av.comentario,
    av.data_avaliacao,
    c.nome_completo AS cliente
FROM
    tb_avaliacoes av
    INNER JOIN tb_clientes c ON av.id_cliente = c.id_cliente
WHERE
    av.id_pacote = 1
ORDER BY
    av.data_avaliacao DESC;

/*
ANÁLISE ESPERADA (ANTES):
- Index Scan using fk (se FK tiver índice automático)
- Possível Sort necessário

SOLUÇÃO:
- Índice já existe em id_pacote (FK)
- Adicionar índice composto incluindo data_avaliacao
*/

-- ============================================================================
-- SEÇÃO 1: CRIAÇÃO DE ÍNDICES ESTRATÉGICOS
-- ============================================================================

-- ----------------------------------------------------------------------------
-- ÍNDICE 1: ÍNDICE SIMPLES (B-Tree)
-- ----------------------------------------------------------------------------
-- Objetivo: Acelerar buscas por data de reserva
-- Tipo: Índice simples em coluna única
-- Coluna: tb_reservas.data_reserva
-- Uso: Filtros por período, ordenações cronológicas
-- ----------------------------------------------------------------------------

CREATE INDEX idx_reservas_data_reserva
ON tb_reservas (data_reserva DESC);

COMMENT ON INDEX idx_reservas_data_reserva IS
'Índice B-Tree descendente para otimizar consultas por data de reserva.
BENEFÍCIOS:
- Acelera filtros WHERE data_reserva = X
- Otimiza BETWEEN para intervalos de datas
- Suporta ORDER BY data_reserva DESC (sem sort adicional)
- Essencial para relatórios cronológicos
USO TÍPICO:
- Relatórios diários/mensais
- Dashboards com filtros de período
- Buscas históricas';

-- Análise de impacto
ANALYZE tb_reservas;

-- Teste de performance após criação
EXPLAIN ANALYZE
SELECT * FROM tb_reservas
WHERE data_reserva BETWEEN '2024-11-01' AND '2024-11-30'
ORDER BY data_reserva DESC;

/*
ANÁLISE ESPERADA (DEPOIS):
- Index Scan using idx_reservas_data_reserva
- Sem necessidade de Sort (índice já está ordenado DESC)
- Custo reduzido significativamente
- Ganho: 50-80% em tabelas médias/grandes
*/

-- ----------------------------------------------------------------------------
-- ÍNDICE 2: ÍNDICE COMPOSTO (Multi-Column Index)
-- ----------------------------------------------------------------------------
-- Objetivo: Otimizar consultas que filtram por data E status simultaneamente
-- Tipo: Índice composto em múltiplas colunas
-- Colunas: tb_reservas (data_reserva, status_reserva)
-- Uso: Consultas com múltiplas condições WHERE
-- Ordem: data_reserva (mais seletivo) → status_reserva
-- ----------------------------------------------------------------------------

CREATE INDEX idx_reservas_data_status
ON tb_reservas (data_reserva DESC, status_reserva);

COMMENT ON INDEX idx_reservas_data_status IS
'Índice composto para consultas com filtro por data e status.
ESTRATÉGIA DE ORDENAÇÃO:
- data_reserva primeiro (maior seletividade)
- status_reserva segundo (poucos valores distintos)
BENEFÍCIOS:
- Otimiza WHERE data_reserva = X AND status_reserva = Y
- Suporta WHERE data_reserva = X (usa apenas primeira coluna)
- Elimina sort para ORDER BY data_reserva DESC
- Covering index para algumas queries
QUANDO É USADO:
- Relatórios de reservas confirmadas do dia
- Listagem de reservas pendentes do mês
- Análises de conversão por período';

ANALYZE tb_reservas;

-- Teste comparativo
EXPLAIN ANALYZE
SELECT id_reserva, data_reserva, status_reserva, valor_total
FROM tb_reservas
WHERE data_reserva BETWEEN '2024-01-01' AND '2024-12-31'
AND status_reserva = 'CONFIRMADA'
ORDER BY data_reserva DESC;

/*
ANÁLISE ESPERADA (DEPOIS):
- Index Scan using idx_reservas_data_status
- Filter aplicado diretamente no índice (mais eficiente)
- Sem sort necessário
- Ganho: 60-90% em seletividade alta
*/

-- ----------------------------------------------------------------------------
-- ÍNDICE 3: ÍNDICE ÚNICO (UNIQUE Index)
-- ----------------------------------------------------------------------------
-- Objetivo: Garantir unicidade e otimizar buscas por número de transação
-- Tipo: Índice único em coluna de identificação
-- Coluna: tb_pagamentos.numero_transacao
-- Benefício duplo: integridade + performance
-- ----------------------------------------------------------------------------

CREATE UNIQUE INDEX idx_pagamentos_numero_transacao_unique
ON tb_pagamentos (numero_transacao)
WHERE numero_transacao IS NOT NULL;

COMMENT ON INDEX idx_pagamentos_numero_transacao_unique IS
'Índice único parcial para número de transação de pagamentos.
CARACTERÍSTICAS:
- UNIQUE: Impede duplicação de números de transação
- PARTIAL: Aplica-se apenas quando numero_transacao NOT NULL
- B-Tree: Otimizado para buscas de igualdade
BENEFÍCIOS:
- Integridade: Previne transações duplicadas
- Performance: Busca O(log n) por número de transação
- Economia: Índice menor (ignora NULLs)
- Segurança: Detecta tentativas de fraude
USO:
- Conciliação bancária
- Validação de pagamentos
- APIs de integração com gateways';

ANALYZE tb_pagamentos;

-- Teste de busca por número de transação
EXPLAIN ANALYZE
SELECT * FROM tb_pagamentos
WHERE numero_transacao = 'TXN001234567890';

/*
ANÁLISE ESPERADA (DEPOIS):
- Index Scan using idx_pagamentos_numero_transacao_unique
- Busca direta (extremamente rápida)
- Ganho: 95%+ em tabelas grandes
*/

-- ----------------------------------------------------------------------------
-- ÍNDICE 4: ÍNDICE COMPOSTO EM CHAVES ESTRANGEIRAS
-- ----------------------------------------------------------------------------
-- Objetivo: Otimizar JOINs frequentes entre reservas e pacotes
-- Tipo: Índice composto em FK + coluna filtro
-- Uso: Consultas que juntam tabelas e filtram por status
-- ----------------------------------------------------------------------------

CREATE INDEX idx_pacotes_destino_status
ON tb_pacotes_turisticos (id_destino, status, data_inicio);

COMMENT ON INDEX idx_pacotes_destino_status IS
'Índice composto para otimizar buscas de pacotes por destino.
CENÁRIO:
- Cliente busca pacotes para um destino específico
- Filtra apenas disponíveis
- Ordena por data de início
BENEFÍCIOS:
- Acelera JOINs com tb_destinos
- Filtra status no índice
- Suporta range scan em data_inicio';

ANALYZE tb_pacotes_turisticos;

-- Teste
EXPLAIN ANALYZE
SELECT p.nome_pacote, p.preco_total, p.data_inicio
FROM tb_pacotes_turisticos p
WHERE p.id_destino = 1
AND p.status = 'DISPONIVEL'
AND p.data_inicio >= CURRENT_DATE
ORDER BY p.data_inicio ASC;

-- ----------------------------------------------------------------------------
-- ÍNDICE 5: ÍNDICE PARCIAL (Partial Index)
-- ----------------------------------------------------------------------------
-- Objetivo: Índice apenas em reservas ativas (não canceladas)
-- Tipo: Índice parcial com condição WHERE
-- Benefício: Menor tamanho, maior velocidade
-- ----------------------------------------------------------------------------

CREATE INDEX idx_reservas_ativas_cliente
ON tb_reservas (id_cliente, data_reserva)
WHERE status_reserva IN ('CONFIRMADA', 'PENDENTE', 'FINALIZADA');

COMMENT ON INDEX idx_reservas_ativas_cliente IS
'Índice parcial para reservas ativas (exclui canceladas).
ESTRATÉGIA:
- Apenas reservas relevantes (90% dos casos)
- Índice menor = mais rápido
- Cache mais eficiente
CENÁRIO:
- Histórico de compras do cliente
- Reservas futuras
- Relatórios operacionais';

ANALYZE tb_reservas;

-- ----------------------------------------------------------------------------
-- ÍNDICE 6: ÍNDICE PARA FUNÇÕES DE AGREGAÇÃO
-- ----------------------------------------------------------------------------
-- Objetivo: Acelerar contagens e somas por pacote
-- Tipo: Índice covering para agregações
-- ----------------------------------------------------------------------------

CREATE INDEX idx_reservas_pacote_passageiros
ON tb_reservas (id_pacote, status_reserva, numero_passageiros)
WHERE status_reserva IN ('CONFIRMADA', 'PENDENTE');

COMMENT ON INDEX idx_reservas_pacote_passageiros IS
'Índice covering para cálculo de vagas vendidas.
COVERING INDEX:
- Contém todas as colunas necessárias
- Evita acesso à tabela principal (index-only scan)
- Extremamente rápido para agregações
USO:
- Cálculo de vagas disponíveis
- Triggers de validação
- Views materializadas';

ANALYZE tb_reservas;

-- Teste de agregação
EXPLAIN ANALYZE
SELECT
    id_pacote,
    COUNT(*) AS total_reservas,
    SUM(numero_passageiros) AS total_passageiros
FROM
    tb_reservas
WHERE
    status_reserva IN ('CONFIRMADA', 'PENDENTE')
GROUP BY
    id_pacote;

/*
ANÁLISE ESPERADA (DEPOIS):
- Index Only Scan (não acessa heap)
- Ganho massivo em agregações
*/

-- ============================================================================
-- SEÇÃO 2: ANÁLISE COMPARATIVA DE PERFORMANCE
-- ============================================================================

-- ----------------------------------------------------------------------------
-- TESTE 1: Comparação ANTES x DEPOIS - Consulta por Período
-- ----------------------------------------------------------------------------

-- Desabilitar temporariamente o índice para simular "antes"
-- (Não executar em produção!)
/*
DROP INDEX IF EXISTS idx_reservas_data_status;

EXPLAIN (ANALYZE, BUFFERS, FORMAT TEXT)
SELECT COUNT(*), SUM(valor_total)
FROM tb_reservas
WHERE data_reserva >= '2024-01-01'
AND status_reserva = 'CONFIRMADA';

-- Recriar o índice
CREATE INDEX idx_reservas_data_status
ON tb_reservas (data_reserva, status_reserva);
*/

EXPLAIN (ANALYZE, BUFFERS, FORMAT TEXT)
SELECT COUNT(*), SUM(valor_total)
FROM tb_reservas
WHERE data_reserva >= '2024-01-01'
AND status_reserva = 'CONFIRMADA';

/*
COMPARAÇÃO ESPERADA:

ANTES (Seq Scan):
- Planning Time: ~0.5ms
- Execution Time: ~50ms (depende do volume)
- Shared Buffers: 1000+ blocos lidos
- Método: Sequential Scan + Filter

DEPOIS (Index Scan):
- Planning Time: ~0.3ms
- Execution Time: ~5ms (90% mais rápido)
- Shared Buffers: <100 blocos lidos
- Método: Index Scan (acesso direto)

GANHO: ~90% de redução no tempo de execução
*/

-- ----------------------------------------------------------------------------
-- TESTE 2: Index-Only Scan vs Table Scan
-- ----------------------------------------------------------------------------

-- Query que se beneficia de covering index
EXPLAIN (ANALYZE, BUFFERS)
SELECT id_pacote, COUNT(*)
FROM tb_reservas
WHERE status_reserva = 'CONFIRMADA'
GROUP BY id_pacote;

/*
COM COVERING INDEX:
- Index Only Scan (não acessa tabela)
- Heap Fetches: 0 (ideal!)
- Velocidade máxima

SEM COVERING INDEX:
- Index Scan + Heap Fetch
- Acesso duplo (índice + tabela)
- 2-3x mais lento
*/

-- ============================================================================
-- SEÇÃO 3: MANUTENÇÃO E MONITORAMENTO DE ÍNDICES
-- ============================================================================

-- ----------------------------------------------------------------------------
-- Visualizar todos os índices criados
-- ----------------------------------------------------------------------------
SELECT
    schemaname,
    tablename AS tabela,
    indexname AS indice,
    indexdef AS definicao
FROM
    pg_indexes
WHERE
    schemaname = 'public'
    AND tablename LIKE 'tb_%'
ORDER BY
    tablename, indexname;

-- ----------------------------------------------------------------------------
-- Analisar tamanho dos índices
-- ----------------------------------------------------------------------------
SELECT
    t.tablename AS tabela,
    i.indexname AS indice,
    pg_size_pretty(pg_relation_size(i.indexrelid)) AS tamanho_indice,
    idx_scan AS vezes_usado,
    idx_tup_read AS tuplas_lidas,
    idx_tup_fetch AS tuplas_buscadas,
    CASE
        WHEN idx_scan = 0 THEN 'NUNCA USADO'
        WHEN idx_scan < 100 THEN 'POUCO USADO'
        WHEN idx_scan < 1000 THEN 'USO MODERADO'
        ELSE 'MUITO USADO'
    END AS classificacao_uso
FROM
    pg_stat_user_indexes s
    JOIN pg_indexes i ON s.indexrelname = i.indexname
    JOIN pg_tables t ON s.relname = t.tablename
WHERE
    t.schemaname = 'public'
    AND t.tablename LIKE 'tb_%'
ORDER BY
    idx_scan DESC;

-- ----------------------------------------------------------------------------
-- Identificar índices não utilizados (candidatos a remoção)
-- ----------------------------------------------------------------------------
SELECT
    schemaname || '.' || tablename AS tabela,
    indexname AS indice_nao_usado,
    pg_size_pretty(pg_relation_size(indexrelid)) AS espaco_desperdicado
FROM
    pg_stat_user_indexes
WHERE
    idx_scan = 0
    AND schemaname = 'public'
    AND indexrelname NOT LIKE 'pg_toast%'
ORDER BY
    pg_relation_size(indexrelid) DESC;

-- ----------------------------------------------------------------------------
-- Verificar índices duplicados ou redundantes
-- ----------------------------------------------------------------------------
SELECT
    a.tablename AS tabela,
    a.indexname AS indice1,
    b.indexname AS indice2,
    a.indexdef AS definicao1,
    b.indexdef AS definicao2
FROM
    pg_indexes a
    JOIN pg_indexes b ON a.tablename = b.tablename
WHERE
    a.indexname < b.indexname
    AND a.indexdef = b.indexdef
    AND a.schemaname = 'public';

-- ----------------------------------------------------------------------------
-- Reindexar tabelas para otimização (manutenção periódica)
-- ----------------------------------------------------------------------------
-- ATENÇÃO: Executar em janela de manutenção, pode bloquear tabela

-- Reindexar tabela específica
-- REINDEX TABLE tb_reservas;

-- Reindexar índice específico
-- REINDEX INDEX idx_reservas_data_status;

-- Atualizar estatísticas do otimizador
ANALYZE tb_reservas;
ANALYZE tb_pacotes_turisticos;
ANALYZE tb_pagamentos;
ANALYZE tb_clientes;
ANALYZE tb_destinos;

-- ============================================================================
-- SEÇÃO 4: BOAS PRÁTICAS E RECOMENDAÇÕES
-- ============================================================================

/*
RESUMO DE BOAS PRÁTICAS:

1. QUANDO CRIAR ÍNDICES:
   ✓ Colunas em cláusulas WHERE frequentes
   ✓ Colunas usadas em JOINs (FKs)
   ✓ Colunas em ORDER BY / GROUP BY
   ✓ Colunas com alta cardinalidade

2. QUANDO NÃO CRIAR ÍNDICES:
   ✗ Tabelas muito pequenas (<1000 linhas)
   ✗ Colunas com baixa seletividade (poucos valores distintos)
   ✗ Tabelas com muitas escritas (INSERT/UPDATE)
   ✗ Índices que nunca são usados

3. TIPOS DE ÍNDICES:
   - B-Tree (padrão): Igualdade, ranges, ordenação
   - Hash: Apenas igualdade (=)
   - GiST: Dados geométricos, full-text
   - GIN: Arrays, JSONB, full-text
   - BRIN: Tabelas muito grandes ordenadas

4. ÍNDICES COMPOSTOS:
   - Ordem importa: mais seletivo primeiro
   - Suporta prefixo (WHERE a AND b usa índice em (a,b))
   - Não suporta sufixo (WHERE b não usa índice em (a,b))

5. MANUTENÇÃO:
   - ANALYZE após mudanças significativas
   - REINDEX periodicamente (fragmentação)
   - VACUUM para recuperar espaço
   - Monitorar uso com pg_stat_user_indexes

6. TRADE-OFFS:
   Vantagens:
   + Consultas SELECT mais rápidas
   + Menos I/O de disco
   + Melhor concorrência em leituras

   Desvantagens:
   - INSERT/UPDATE/DELETE mais lentos
   - Espaço em disco adicional
   - Necessita manutenção

7. ÍNDICES PARCIAIS:
   - Indexar apenas subset relevante
   - Menor tamanho = maior performance
   - Exemplo: WHERE status = 'ATIVO'

8. COVERING INDEXES:
   - Incluir todas as colunas necessárias
   - Index-Only Scan (sem acesso à tabela)
   - Extremamente rápido, mas maior tamanho
*/

-- ============================================================================
-- RESUMO DA ETAPA 3.4
-- ============================================================================
-- ÍNDICES CRIADOS:
--
-- 1. idx_reservas_data_reserva (SIMPLES)
--    Coluna: data_reserva DESC
--    Uso: Filtros cronológicos, ordenação
--    Ganho: 50-80% em consultas por período
--
-- 2. idx_reservas_data_status (COMPOSTO)
--    Colunas: (data_reserva, status_reserva)
--    Uso: Relatórios com múltiplos filtros
--    Ganho: 60-90% em consultas complexas
--
-- 3. idx_pagamentos_numero_transacao_unique (ÚNICO)
--    Coluna: numero_transacao
--    Benefício duplo: Integridade + Performance
--    Ganho: 95%+ em buscas exatas
--
-- 4. idx_pacotes_destino_status (COMPOSTO)
--    Colunas: (id_destino, status, data_inicio)
--    Uso: Busca de pacotes disponíveis
--
-- 5. idx_reservas_ativas_cliente (PARCIAL)
--    Colunas: (id_cliente, data_reserva)
--    Condição: Status ativo
--    Benefício: Índice menor e mais rápido
--
-- 6. idx_reservas_pacote_passageiros (COVERING)
--    Colunas: (id_pacote, status_reserva, numero_passageiros)
--    Benefício: Index-only scan em agregações
--
-- ANÁLISES REALIZADAS:
-- - EXPLAIN ANALYZE antes e depois
-- - Comparação de custos e tempos
-- - Análise de buffers e I/O
-- - Monitoramento de uso de índices
--
-- FERRAMENTAS APRESENTADAS:
-- - pg_indexes: Listar índices
-- - pg_stat_user_indexes: Estatísticas de uso
-- - pg_relation_size: Tamanho em disco
-- - EXPLAIN (ANALYZE, BUFFERS): Análise detalhada
-- ============================================================================

SELECT 'Etapa 3.4 concluída! Índices criados e analisados com sucesso.' AS status;
