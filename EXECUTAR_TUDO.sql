-- ============================================================================
-- PROJETO COMPLETO: SISTEMA DE BANCO DE DADOS PARA AGÊNCIA DE TURISMO
-- ============================================================================
-- Empresa: Viagens & Aventuras Ltda
-- SGBD: PostgreSQL
-- Disciplina: Banco de Dados Avançados 2025/2
-- Prof. Michel Junio Ferreira Rosa
-- ============================================================================
-- ARQUIVO: EXECUTAR_TUDO.sql
-- Descrição: Script consolidado que executa todas as etapas do projeto
-- ============================================================================

\echo '============================================================================'
\echo 'PROJETO: SISTEMA DE BANCO DE DADOS PARA AGÊNCIA DE TURISMO'
\echo 'Viagens & Aventuras Ltda'
\echo '============================================================================'
\echo ''
\echo 'Este script executará TODAS as etapas do projeto em sequência:'
\echo '  1. Modelagem e Criação do Banco'
\echo '  2. População de Dados e Consultas'
\echo '  3.1. Views (3 views)'
\echo '  3.2. Triggers (4 triggers)'
\echo '  3.3. Functions (4 functions)'
\echo '  3.4. Índices e Otimização'
\echo '  3.5. Transações e Concorrência'
\echo '  3.6. Segurança e Controle de Acesso'
\echo '  3.7. Performance Tuning'
\echo ''
\echo 'Tempo estimado: 2-5 minutos'
\echo '============================================================================'
\echo ''

-- Pausar para confirmação (comentar se executar automaticamente)
-- \prompt 'Pressione ENTER para continuar...' confirmacao

-- ============================================================================
-- ETAPA 1: MODELAGEM E CRIAÇÃO DO BANCO
-- ============================================================================
\echo '▶ Executando Etapa 1: Modelagem e Criação do Banco...'
\i etapa1_modelagem_criacao.sql

-- ============================================================================
-- ETAPA 2: POPULAÇÃO DE DADOS E CONSULTAS
-- ============================================================================
\echo '▶ Executando Etapa 2: População de Dados e Consultas...'
\i etapa2_populacao_consultas.sql

-- ============================================================================
-- ETAPA 3.1: VIEWS
-- ============================================================================
\echo '▶ Executando Etapa 3.1: Views...'
\i etapa3_1_views.sql

-- ============================================================================
-- ETAPA 3.2: TRIGGERS
-- ============================================================================
\echo '▶ Executando Etapa 3.2: Triggers...'
\i etapa3_2_triggers.sql

-- ============================================================================
-- ETAPA 3.3: FUNCTIONS
-- ============================================================================
\echo '▶ Executando Etapa 3.3: Functions...'
\i etapa3_3_functions.sql

-- ============================================================================
-- ETAPA 3.4: ÍNDICES E OTIMIZAÇÃO
-- ============================================================================
\echo '▶ Executando Etapa 3.4: Índices e Otimização...'
\i etapa3_4_indices_otimizacao.sql

-- ============================================================================
-- ETAPA 3.5: TRANSAÇÕES E CONCORRÊNCIA
-- ============================================================================
\echo '▶ Executando Etapa 3.5: Transações e Concorrência...'
\i etapa3_5_transacoes_concorrencia.sql

-- ============================================================================
-- ETAPA 3.6: SEGURANÇA E CONTROLE DE ACESSO
-- ============================================================================
\echo '▶ Executando Etapa 3.6: Segurança e Controle de Acesso...'
\i etapa3_6_seguranca_controle_acesso.sql

-- ============================================================================
-- ETAPA 3.7: PERFORMANCE TUNING
-- ============================================================================
\echo '▶ Executando Etapa 3.7: Performance Tuning...'
\i etapa3_7_performance_tuning.sql

-- ============================================================================
-- RESUMO FINAL
-- ============================================================================
\echo ''
\echo '============================================================================'
\echo '✓ TODAS AS ETAPAS FORAM EXECUTADAS COM SUCESSO!'
\echo '============================================================================'
\echo ''
\echo 'Banco de dados: agencia_turismo'
\echo 'Status: Pronto para uso'
\echo ''
\echo 'ESTATÍSTICAS DO PROJETO:'
\echo '------------------------'

SELECT
    'Tabelas criadas' AS item,
    COUNT(*) || ' tabelas' AS quantidade
FROM
    information_schema.tables
WHERE
    table_schema = 'public'
    AND table_type = 'BASE TABLE'

UNION ALL

SELECT
    'Views criadas',
    COUNT(*) || ' views'
FROM
    information_schema.views
WHERE
    table_schema = 'public'

UNION ALL

SELECT
    'Triggers criados',
    COUNT(*) || ' triggers'
FROM
    information_schema.triggers
WHERE
    trigger_schema = 'public'

UNION ALL

SELECT
    'Functions criadas',
    COUNT(*) || ' functions'
FROM
    information_schema.routines
WHERE
    routine_schema = 'public'
    AND routine_type = 'FUNCTION'
    AND routine_name LIKE 'fn_%'

UNION ALL

SELECT
    'Índices criados',
    COUNT(*) || ' índices'
FROM
    pg_indexes
WHERE
    schemaname = 'public'

UNION ALL

SELECT
    'Usuários/Roles',
    COUNT(*) || ' roles'
FROM
    pg_roles
WHERE
    rolname LIKE 'db_%'

UNION ALL

SELECT
    'Registros inseridos',
    (
        SELECT SUM(n_live_tup)::TEXT || ' registros'
        FROM pg_stat_user_tables
        WHERE schemaname = 'public'
    );

\echo ''
\echo 'OBJETOS PRINCIPAIS:'
\echo '-------------------'

-- Listar tabelas
\echo ''
\echo 'TABELAS:'
SELECT
    tablename AS nome_tabela,
    pg_size_pretty(pg_total_relation_size(schemaname||'.'||tablename)) AS tamanho
FROM
    pg_tables
WHERE
    schemaname = 'public'
ORDER BY
    tablename;

-- Listar views
\echo ''
\echo 'VIEWS:'
SELECT viewname AS nome_view
FROM pg_views
WHERE schemaname = 'public'
ORDER BY viewname;

-- Listar functions
\echo ''
\echo 'FUNCTIONS:'
SELECT routine_name AS nome_function
FROM information_schema.routines
WHERE routine_schema = 'public'
AND routine_type = 'FUNCTION'
AND routine_name LIKE 'fn_%'
ORDER BY routine_name;

-- Listar triggers
\echo ''
\echo 'TRIGGERS:'
SELECT DISTINCT trigger_name AS nome_trigger, event_object_table AS tabela
FROM information_schema.triggers
WHERE trigger_schema = 'public'
ORDER BY event_object_table, trigger_name;

\echo ''
\echo '============================================================================'
\echo 'PARA TESTAR O SISTEMA:'
\echo '============================================================================'
\echo ''
\echo '1. Criar uma reserva:'
\echo '   SELECT * FROM fn_criar_reserva_completa(1, 5, 4, 2, 10);'
\echo ''
\echo '2. Ver pacotes disponíveis:'
\echo '   SELECT * FROM vw_pacotes_disponiveis_filtrados LIMIT 10;'
\echo ''
\echo '3. Relatório de faturamento:'
\echo '   SELECT * FROM fn_relatorio_faturamento(''2024-01-01'', ''2024-12-31'');'
\echo ''
\echo '4. Ver auditoria:'
\echo '   SELECT * FROM tb_auditoria ORDER BY data_hora DESC LIMIT 10;'
\echo ''
\echo '5. Dashboard de vendas:'
\echo '   SELECT * FROM vw_dashboard_vendas LIMIT 10;'
\echo ''
\echo '============================================================================'
\echo 'PROJETO CONCLUÍDO COM SUCESSO! 🎉'
\echo '============================================================================'
