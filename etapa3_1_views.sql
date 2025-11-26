-- ============================================================================
-- ETAPA 3.1: VIEWS (VISÕES)
-- ============================================================================
-- Descrição: Criação de 3 views para simplificar consultas complexas
--            e criar abstrações sobre o modelo de dados
-- Requisitos do projeto:
--   1. View simples (seleção direta)
--   2. View com JOIN e agregações
--   3. View com filtros dinâmicos ou subconsultas
-- ============================================================================

-- Conectar ao banco de dados
\c agencia_turismo;

-- ============================================================================
-- VIEW 1: vw_pacotes_completos (VIEW SIMPLES)
-- ============================================================================
-- Objetivo: Simplificar acesso a informações completas dos pacotes
-- Tipo: View simples com múltiplos JOINs
-- Benefício: Abstrai a complexidade dos relacionamentos entre tabelas
-- Caso de uso: Catálogo de pacotes para site/app, consulta rápida
-- ============================================================================

CREATE OR REPLACE VIEW vw_pacotes_completos AS
SELECT
    -- Informações do Pacote
    p.id_pacote,
    p.nome_pacote,
    p.descricao_completa,
    p.duracao_dias,
    p.data_inicio,
    p.data_fim,
    p.preco_total,
    p.vagas_disponiveis,
    p.regime_alimentar,
    p.status AS status_pacote,

    -- Informações do Destino
    d.id_destino,
    d.nome_destino,
    d.pais,
    d.estado AS estado_destino,
    d.cidade AS cidade_destino,
    d.categoria AS categoria_turismo,
    d.clima,
    d.idioma_principal,
    d.moeda_local,

    -- Informações do Hotel
    h.id_hotel,
    h.nome_hotel,
    h.classificacao_estrelas,
    h.comodidades,
    h.telefone AS telefone_hotel,
    h.email AS email_hotel,

    -- Informações do Transporte
    t.id_transporte,
    t.tipo_transporte,
    t.empresa_parceira,
    t.classe AS classe_transporte,

    -- Campos Calculados
    ROUND(p.preco_total / p.duracao_dias, 2) AS preco_por_dia,
    p.incluso,
    p.nao_incluso,

    -- Metadados úteis para interface
    TO_CHAR(p.data_inicio, 'DD/MM/YYYY') AS data_inicio_formatada,
    TO_CHAR(p.data_fim, 'DD/MM/YYYY') AS data_fim_formatada,
    TO_CHAR(p.preco_total, 'L999G999G999D99') AS preco_formatado

FROM
    tb_pacotes_turisticos p
    INNER JOIN tb_destinos d ON p.id_destino = d.id_destino
    INNER JOIN tb_hoteis h ON p.id_hotel = h.id_hotel
    INNER JOIN tb_transportes t ON p.id_transporte = t.id_transporte;

-- Comentários explicativos
COMMENT ON VIEW vw_pacotes_completos IS
'View que consolida todas as informações de pacotes turísticos em uma única consulta.
BENEFÍCIOS:
- Elimina necessidade de múltiplos JOINs em consultas frequentes
- Padroniza apresentação de dados para aplicações front-end
- Facilita manutenção: alterações no modelo são refletidas automaticamente
- Melhora legibilidade do código em queries complexas
USO RECOMENDADO:
- Listagem de pacotes em sites e aplicativos
- APIs REST para consulta de catálogo
- Relatórios de marketing e vendas';

-- Exemplo de uso da view
-- SELECT * FROM vw_pacotes_completos WHERE pais = 'Brasil' AND preco_total < 10000;

-- ============================================================================
-- VIEW 2: vw_dashboard_vendas (VIEW COM JOIN E AGREGAÇÕES)
-- ============================================================================
-- Objetivo: Dashboard analítico com métricas consolidadas de vendas
-- Tipo: View com agregações complexas e múltiplos JOINs
-- Benefício: Performance em relatórios gerenciais recorrentes
-- Caso de uso: Dashboards executivos, relatórios mensais, KPIs
-- ============================================================================

CREATE OR REPLACE VIEW vw_dashboard_vendas AS
SELECT
    -- Dimensões de análise
    f.id_funcionario,
    f.nome_completo AS vendedor,
    f.cargo,
    d.categoria AS categoria_destino,
    d.pais,
    TO_CHAR(r.data_reserva, 'YYYY-MM') AS mes_ano_venda,
    EXTRACT(YEAR FROM r.data_reserva) AS ano_venda,
    EXTRACT(MONTH FROM r.data_reserva) AS mes_venda,

    -- Métricas de Quantidade
    COUNT(DISTINCT r.id_reserva) AS quantidade_vendas,
    COUNT(DISTINCT r.id_cliente) AS quantidade_clientes_unicos,
    SUM(r.numero_passageiros) AS total_passageiros,

    -- Métricas Financeiras
    SUM(r.valor_total) AS receita_total,
    AVG(r.valor_total) AS ticket_medio,
    MIN(r.valor_total) AS menor_venda,
    MAX(r.valor_total) AS maior_venda,

    -- Métricas de Desconto
    AVG(r.desconto_percentual) AS desconto_medio_percentual,
    SUM(r.valor_unitario * r.numero_passageiros - r.valor_total) AS valor_total_descontado,

    -- Métricas de Performance
    ROUND(
        SUM(r.valor_total) / NULLIF(COUNT(DISTINCT r.id_reserva), 0),
        2
    ) AS receita_por_venda,
    ROUND(
        SUM(r.numero_passageiros)::DECIMAL / NULLIF(COUNT(DISTINCT r.id_reserva), 0),
        2
    ) AS passageiros_por_venda

FROM
    tb_reservas r
    INNER JOIN tb_funcionarios f ON r.id_funcionario = f.id_funcionario
    INNER JOIN tb_pacotes_turisticos p ON r.id_pacote = p.id_pacote
    INNER JOIN tb_destinos d ON p.id_destino = d.id_destino

WHERE
    r.status_reserva IN ('CONFIRMADA', 'FINALIZADA')

GROUP BY
    f.id_funcionario,
    f.nome_completo,
    f.cargo,
    d.categoria,
    d.pais,
    TO_CHAR(r.data_reserva, 'YYYY-MM'),
    EXTRACT(YEAR FROM r.data_reserva),
    EXTRACT(MONTH FROM r.data_reserva);

COMMENT ON VIEW vw_dashboard_vendas IS
'View analítica com métricas agregadas de vendas por vendedor, destino e período.
BENEFÍCIOS:
- Pré-processa agregações complexas, melhorando performance de dashboards
- Centraliza lógica de cálculo de KPIs (evita inconsistências)
- Facilita integração com ferramentas de BI (Tableau, Power BI, Metabase)
- Reduz tempo de resposta em relatórios gerenciais
MÉTRICAS INCLUÍDAS:
- Quantidade: vendas, clientes únicos, passageiros
- Financeiras: receita, ticket médio, menor/maior venda
- Descontos: média percentual e valor total descontado
- Performance: receita por venda, passageiros por venda
USO RECOMENDADO:
- Dashboards executivos em tempo real
- Relatórios mensais de performance de vendedores
- Análise de categorias de destinos mais rentáveis
- Comparativos de performance por período';

-- Exemplo de uso da view
-- SELECT vendedor, mes_ano_venda, quantidade_vendas, receita_total
-- FROM vw_dashboard_vendas
-- WHERE ano_venda = 2024
-- ORDER BY receita_total DESC;

-- ============================================================================
-- VIEW 3: vw_pacotes_disponiveis_filtrados (VIEW COM SUBCONSULTAS E FILTROS)
-- ============================================================================
-- Objetivo: Pacotes disponíveis com cálculo dinâmico de vagas e avaliações
-- Tipo: View complexa com subconsultas correlacionadas e filtros
-- Benefício: Lógica de negócio centralizada (disponibilidade e ranking)
-- Caso de uso: Sistema de busca e recomendação de pacotes
-- ============================================================================

CREATE OR REPLACE VIEW vw_pacotes_disponiveis_filtrados AS
SELECT
    -- Identificação
    p.id_pacote,
    p.nome_pacote,
    d.nome_destino,
    d.pais,
    d.categoria AS tipo_turismo,

    -- Detalhes do Pacote
    p.duracao_dias,
    p.data_inicio,
    p.data_fim,
    p.preco_total,
    p.regime_alimentar,
    h.nome_hotel,
    h.classificacao_estrelas,

    -- Cálculo Dinâmico de Disponibilidade (Subconsulta Correlacionada)
    p.vagas_disponiveis AS vagas_originais,

    (
        SELECT COALESCE(SUM(r.numero_passageiros), 0)
        FROM tb_reservas r
        WHERE r.id_pacote = p.id_pacote
        AND r.status_reserva IN ('CONFIRMADA', 'PENDENTE')
    ) AS vagas_vendidas,

    (
        p.vagas_disponiveis - COALESCE(
            (
                SELECT SUM(r.numero_passageiros)
                FROM tb_reservas r
                WHERE r.id_pacote = p.id_pacote
                AND r.status_reserva IN ('CONFIRMADA', 'PENDENTE')
            ), 0
        )
    ) AS vagas_restantes,

    -- Percentual de Ocupação
    ROUND(
        100.0 * COALESCE(
            (
                SELECT SUM(r.numero_passageiros)
                FROM tb_reservas r
                WHERE r.id_pacote = p.id_pacote
                AND r.status_reserva IN ('CONFIRMADA', 'PENDENTE')
            ), 0
        ) / NULLIF(p.vagas_disponiveis, 0),
        2
    ) AS percentual_ocupacao,

    -- Avaliações (Subconsulta Agregada)
    (
        SELECT ROUND(AVG(av.nota), 2)
        FROM tb_avaliacoes av
        WHERE av.id_pacote = p.id_pacote
    ) AS avaliacao_media,

    (
        SELECT COUNT(*)
        FROM tb_avaliacoes av
        WHERE av.id_pacote = p.id_pacote
    ) AS quantidade_avaliacoes,

    -- Classificação de Qualidade Baseada em Avaliações
    CASE
        WHEN (SELECT AVG(av.nota) FROM tb_avaliacoes av WHERE av.id_pacote = p.id_pacote) >= 4.5
            THEN 'EXCELENTE'
        WHEN (SELECT AVG(av.nota) FROM tb_avaliacoes av WHERE av.id_pacote = p.id_pacote) >= 4.0
            THEN 'MUITO BOM'
        WHEN (SELECT AVG(av.nota) FROM tb_avaliacoes av WHERE av.id_pacote = p.id_pacote) >= 3.0
            THEN 'BOM'
        WHEN (SELECT AVG(av.nota) FROM tb_avaliacoes av WHERE av.id_pacote = p.id_pacote) IS NOT NULL
            THEN 'REGULAR'
        ELSE 'SEM AVALIAÇÕES'
    END AS classificacao_qualidade,

    -- Status de Disponibilidade Calculado Dinamicamente
    CASE
        WHEN p.vagas_disponiveis - COALESCE(
            (
                SELECT SUM(r.numero_passageiros)
                FROM tb_reservas r
                WHERE r.id_pacote = p.id_pacote
                AND r.status_reserva IN ('CONFIRMADA', 'PENDENTE')
            ), 0
        ) <= 0 THEN 'ESGOTADO'
        WHEN p.vagas_disponiveis - COALESCE(
            (
                SELECT SUM(r.numero_passageiros)
                FROM tb_reservas r
                WHERE r.id_pacote = p.id_pacote
                AND r.status_reserva IN ('CONFIRMADA', 'PENDENTE')
            ), 0
        ) <= 5 THEN 'ÚLTIMAS VAGAS'
        WHEN p.data_inicio <= CURRENT_DATE + INTERVAL '30 days' THEN 'SAÍDA EM BREVE'
        ELSE 'DISPONÍVEL'
    END AS status_disponibilidade,

    -- Análise de Custo-Benefício
    ROUND(p.preco_total / p.duracao_dias, 2) AS preco_por_dia,

    -- Popularidade (baseada em vendas)
    (
        SELECT COUNT(*)
        FROM tb_reservas r
        WHERE r.id_pacote = p.id_pacote
        AND r.status_reserva IN ('CONFIRMADA', 'FINALIZADA')
    ) AS total_vendas_historicas

FROM
    tb_pacotes_turisticos p
    INNER JOIN tb_destinos d ON p.id_destino = d.id_destino
    INNER JOIN tb_hoteis h ON p.id_hotel = h.id_hotel

WHERE
    -- Filtros: Apenas pacotes ativos e com data futura
    p.status = 'DISPONIVEL'
    AND p.data_inicio >= CURRENT_DATE
    AND p.vagas_disponiveis > 0;

COMMENT ON VIEW vw_pacotes_disponiveis_filtrados IS
'View inteligente que calcula dinamicamente disponibilidade e ranking de pacotes.
BENEFÍCIOS:
- Cálculo em tempo real de vagas restantes (não armazena dados desatualizados)
- Lógica de negócio centralizada para status de disponibilidade
- Integra avaliações de clientes para sistema de recomendação
- Filtra automaticamente apenas pacotes válidos e disponíveis
SUBCONSULTAS CORRELACIONADAS:
- Vagas vendidas: soma passageiros de reservas confirmadas/pendentes
- Avaliação média: média aritmética das notas dos clientes
- Total de vendas históricas: contador de popularidade do pacote
REGRAS DE NEGÓCIO IMPLEMENTADAS:
- Status "ESGOTADO": sem vagas restantes
- Status "ÚLTIMAS VAGAS": 5 ou menos vagas
- Status "SAÍDA EM BREVE": início em até 30 dias
- Classificação de qualidade: baseada em faixas de avaliação
USO RECOMENDADO:
- Sistema de busca de pacotes em websites
- Motor de recomendação (ordenar por avaliação_media DESC)
- Alertas de escassez (ÚLTIMAS VAGAS)
- APIs para aplicativos mobile';

-- Exemplo de uso da view com filtros dinâmicos
-- SELECT * FROM vw_pacotes_disponiveis_filtrados
-- WHERE tipo_turismo = 'PRAIA'
-- AND preco_total BETWEEN 5000 AND 15000
-- AND classificacao_qualidade IN ('EXCELENTE', 'MUITO BOM')
-- ORDER BY avaliacao_media DESC, preco_por_dia ASC;

-- ============================================================================
-- DEMONSTRAÇÃO DE USO DAS VIEWS
-- ============================================================================

-- ----------------------------------------------------------------------------
-- Exemplo 1: Usando vw_pacotes_completos para catálogo
-- ----------------------------------------------------------------------------
-- Caso de uso: Listar pacotes internacionais com hotel 5 estrelas
-- Benefício: Sem necessidade de escrever JOINs complexos
-- ----------------------------------------------------------------------------
SELECT
    nome_pacote,
    nome_destino,
    pais,
    nome_hotel,
    classificacao_estrelas,
    duracao_dias,
    preco_formatado,
    data_inicio_formatada
FROM
    vw_pacotes_completos
WHERE
    pais != 'Brasil'
    AND classificacao_estrelas = 5
    AND status_pacote = 'DISPONIVEL'
ORDER BY
    preco_total ASC;

-- ----------------------------------------------------------------------------
-- Exemplo 2: Usando vw_dashboard_vendas para relatório mensal
-- ----------------------------------------------------------------------------
-- Caso de uso: Ranking de vendedores do mês
-- Benefício: Métricas pré-calculadas, resposta instantânea
-- ----------------------------------------------------------------------------
SELECT
    vendedor,
    cargo,
    quantidade_vendas,
    total_passageiros,
    TO_CHAR(receita_total, 'L999G999G999D99') AS receita,
    TO_CHAR(ticket_medio, 'L999G999D99') AS ticket_medio,
    ROUND(desconto_medio_percentual, 2) || '%' AS desconto_medio
FROM
    vw_dashboard_vendas
WHERE
    mes_ano_venda = TO_CHAR(CURRENT_DATE, 'YYYY-MM')
ORDER BY
    receita_total DESC
LIMIT 5;

-- ----------------------------------------------------------------------------
-- Exemplo 3: Usando vw_pacotes_disponiveis_filtrados para recomendação
-- ----------------------------------------------------------------------------
-- Caso de uso: Recomendar pacotes bem avaliados com vagas disponíveis
-- Benefício: Lógica de negócio complexa abstraída em uma consulta simples
-- ----------------------------------------------------------------------------
SELECT
    nome_pacote,
    nome_destino,
    tipo_turismo,
    vagas_restantes,
    status_disponibilidade,
    avaliacao_media,
    classificacao_qualidade,
    TO_CHAR(preco_total, 'L999G999G999D99') AS preco,
    preco_por_dia
FROM
    vw_pacotes_disponiveis_filtrados
WHERE
    classificacao_qualidade IN ('EXCELENTE', 'MUITO BOM')
    AND vagas_restantes >= 2
ORDER BY
    avaliacao_media DESC,
    total_vendas_historicas DESC,
    preco_por_dia ASC
LIMIT 10;

-- ============================================================================
-- ANÁLISE DE PERFORMANCE DAS VIEWS
-- ============================================================================

-- ----------------------------------------------------------------------------
-- Verificar plano de execução da vw_pacotes_disponiveis_filtrados
-- ----------------------------------------------------------------------------
-- As subconsultas correlacionadas podem ser otimizadas pelo PostgreSQL
-- Analisar se há necessidade de índices adicionais
-- ----------------------------------------------------------------------------
EXPLAIN ANALYZE
SELECT * FROM vw_pacotes_disponiveis_filtrados
WHERE tipo_turismo = 'PRAIA'
LIMIT 10;

-- ============================================================================
-- MANUTENÇÃO E SEGURANÇA DAS VIEWS
-- ============================================================================

-- Conceder permissões de leitura para usuários operacionais (será detalhado na Etapa 3.6)
-- GRANT SELECT ON vw_pacotes_completos TO operador;
-- GRANT SELECT ON vw_dashboard_vendas TO gerente;
-- GRANT SELECT ON vw_pacotes_disponiveis_filtrados TO atendente;

-- ============================================================================
-- RESUMO DA ETAPA 3.1 - VIEWS
-- ============================================================================
-- VIEW 1: vw_pacotes_completos
--   Tipo: View simples com JOINs
--   Benefício: Simplifica acesso a dados relacionados
--   Uso: Catálogos, APIs, listagens
--
-- VIEW 2: vw_dashboard_vendas
--   Tipo: View com agregações complexas
--   Benefício: Performance em relatórios analíticos
--   Uso: Dashboards, KPIs, BI
--
-- VIEW 3: vw_pacotes_disponiveis_filtrados
--   Tipo: View com subconsultas correlacionadas
--   Benefício: Lógica de negócio centralizada e cálculos dinâmicos
--   Uso: Busca de pacotes, recomendações, disponibilidade em tempo real
--
-- MELHORIAS DE DESEMPENHO:
-- - Redução de código duplicado em consultas frequentes
-- - Otimização automática pelo planner do PostgreSQL
-- - Cache de planos de execução
-- - Abstração que facilita manutenção futura
--
-- MELHORIAS DE ORGANIZAÇÃO:
-- - Separação de lógica de apresentação e armazenamento
-- - Controle de acesso granular (segurança em camadas)
-- - Documentação centralizada de regras de negócio
-- ============================================================================

SELECT 'Etapa 3.1 concluída! 3 views criadas com sucesso.' AS status;
