-- ============================================================================
-- ETAPA 3.1: VIEWS (VISÕES)
-- Criação de 3 views para simplificar consultas complexas
-- ============================================================================

\c agencia_turismo;

-- ============================================================================
-- VIEW 1: vw_pacotes_completos (VIEW SIMPLES)
-- Objetivo: Simplificar acesso a informações completas dos pacotes
-- Benefício: Abstrai complexidade dos relacionamentos, consulta rápida
-- Uso: Catálogo de pacotes para site/app
-- ============================================================================

CREATE OR REPLACE VIEW vw_pacotes_completos AS
SELECT
    -- Informações do Pacote
    p.id_pacote, p.nome_pacote, p.descricao_completa,
    p.duracao_dias, p.data_inicio, p.data_fim,
    p.preco_total, p.vagas_disponiveis,
    p.regime_alimentar, p.status AS status_pacote,

    -- Informações do Destino
    d.nome_destino, d.pais, d.cidade AS cidade_destino,
    d.categoria AS categoria_turismo, d.clima,

    -- Informações do Hotel
    h.nome_hotel, h.classificacao_estrelas, h.comodidades,

    -- Informações do Transporte
    t.tipo_transporte, t.empresa_parceira, t.classe AS classe_transporte,

    -- Campos Calculados
    ROUND(p.preco_total / p.duracao_dias, 2) AS preco_por_dia,
    TO_CHAR(p.data_inicio, 'DD/MM/YYYY') AS data_inicio_formatada,
    TO_CHAR(p.preco_total, 'L999G999G999D99') AS preco_formatado
FROM tb_pacotes_turisticos p
INNER JOIN tb_destinos d ON p.id_destino = d.id_destino
INNER JOIN tb_hoteis h ON p.id_hotel = h.id_hotel
INNER JOIN tb_transportes t ON p.id_transporte = t.id_transporte;

COMMENT ON VIEW vw_pacotes_completos IS
'View que consolida informações de pacotes em uma única consulta.
Elimina múltiplos JOINs, padroniza dados para front-end, facilita manutenção.
Uso: Listagem de pacotes, APIs REST, relatórios de marketing.';

-- ============================================================================
-- VIEW 2: vw_dashboard_vendas (VIEW COM AGREGAÇÕES)
-- Objetivo: Dashboard analítico com métricas consolidadas
-- Benefício: Performance em relatórios gerenciais recorrentes
-- Uso: Dashboards executivos, relatórios mensais, KPIs
-- ============================================================================

CREATE OR REPLACE VIEW vw_dashboard_vendas AS
SELECT
    -- Dimensões de análise
    f.nome_completo AS vendedor, f.cargo,
    d.categoria AS categoria_destino, d.pais,
    TO_CHAR(r.data_reserva, 'YYYY-MM') AS mes_ano_venda,
    EXTRACT(YEAR FROM r.data_reserva) AS ano_venda,

    -- Métricas de Quantidade
    COUNT(DISTINCT r.id_reserva) AS quantidade_vendas,
    COUNT(DISTINCT r.id_cliente) AS clientes_unicos,
    SUM(r.numero_passageiros) AS total_passageiros,

    -- Métricas Financeiras
    SUM(r.valor_total) AS receita_total,
    AVG(r.valor_total) AS ticket_medio,
    MIN(r.valor_total) AS menor_venda,
    MAX(r.valor_total) AS maior_venda,

    -- Métricas de Desconto
    AVG(r.desconto_percentual) AS desconto_medio_percentual,
    SUM(r.valor_unitario * r.numero_passageiros - r.valor_total) AS valor_total_descontado
FROM tb_reservas r
INNER JOIN tb_funcionarios f ON r.id_funcionario = f.id_funcionario
INNER JOIN tb_pacotes_turisticos p ON r.id_pacote = p.id_pacote
INNER JOIN tb_destinos d ON p.id_destino = d.id_destino
WHERE r.status_reserva IN ('CONFIRMADA', 'FINALIZADA')
GROUP BY f.nome_completo, f.cargo, d.categoria, d.pais,
    TO_CHAR(r.data_reserva, 'YYYY-MM'), EXTRACT(YEAR FROM r.data_reserva);

COMMENT ON VIEW vw_dashboard_vendas IS
'View analítica com métricas agregadas por vendedor, destino e período.
Pré-processa KPIs, melhora performance, centraliza lógica de cálculo.
Facilita integração com BI (Tableau, Power BI, Metabase).';

-- ============================================================================
-- VIEW 3: vw_pacotes_disponiveis (VIEW COM SUBCONSULTAS)
-- Objetivo: Pacotes disponíveis com cálculo dinâmico de vagas e avaliações
-- Benefício: Lógica de negócio centralizada (disponibilidade e ranking)
-- Uso: Sistema de busca e recomendação de pacotes
-- ============================================================================

CREATE OR REPLACE VIEW vw_pacotes_disponiveis AS
SELECT
    -- Identificação
    p.id_pacote, p.nome_pacote, d.nome_destino, d.pais,
    d.categoria AS tipo_turismo,

    -- Detalhes do Pacote
    p.duracao_dias, p.data_inicio, p.data_fim, p.preco_total,
    p.regime_alimentar, h.nome_hotel, h.classificacao_estrelas,

    -- Cálculo Dinâmico de Disponibilidade
    p.vagas_disponiveis AS vagas_originais,
    (SELECT COALESCE(SUM(r.numero_passageiros), 0)
     FROM tb_reservas r
     WHERE r.id_pacote = p.id_pacote
     AND r.status_reserva IN ('CONFIRMADA', 'PENDENTE')) AS vagas_vendidas,

    (p.vagas_disponiveis - COALESCE(
        (SELECT SUM(r.numero_passageiros)
         FROM tb_reservas r
         WHERE r.id_pacote = p.id_pacote
         AND r.status_reserva IN ('CONFIRMADA', 'PENDENTE')), 0)) AS vagas_restantes,

    -- Percentual de Ocupação
    ROUND(100.0 * COALESCE(
        (SELECT SUM(r.numero_passageiros)
         FROM tb_reservas r
         WHERE r.id_pacote = p.id_pacote
         AND r.status_reserva IN ('CONFIRMADA', 'PENDENTE')), 0)
        / NULLIF(p.vagas_disponiveis, 0), 2) AS percentual_ocupacao,

    -- Avaliações
    (SELECT ROUND(AVG(av.nota), 2)
     FROM tb_avaliacoes av
     WHERE av.id_pacote = p.id_pacote) AS avaliacao_media,

    (SELECT COUNT(*)
     FROM tb_avaliacoes av
     WHERE av.id_pacote = p.id_pacote) AS quantidade_avaliacoes,

    -- Classificação de Qualidade
    CASE
        WHEN (SELECT AVG(av.nota) FROM tb_avaliacoes av WHERE av.id_pacote = p.id_pacote) >= 4.5 THEN 'EXCELENTE'
        WHEN (SELECT AVG(av.nota) FROM tb_avaliacoes av WHERE av.id_pacote = p.id_pacote) >= 4.0 THEN 'MUITO BOM'
        WHEN (SELECT AVG(av.nota) FROM tb_avaliacoes av WHERE av.id_pacote = p.id_pacote) >= 3.0 THEN 'BOM'
        WHEN (SELECT AVG(av.nota) FROM tb_avaliacoes av WHERE av.id_pacote = p.id_pacote) IS NOT NULL THEN 'REGULAR'
        ELSE 'SEM AVALIAÇÕES'
    END AS classificacao_qualidade,

    -- Status de Disponibilidade Calculado
    CASE
        WHEN p.vagas_disponiveis - COALESCE((SELECT SUM(r.numero_passageiros) FROM tb_reservas r
            WHERE r.id_pacote = p.id_pacote AND r.status_reserva IN ('CONFIRMADA', 'PENDENTE')), 0) <= 0
            THEN 'ESGOTADO'
        WHEN p.vagas_disponiveis - COALESCE((SELECT SUM(r.numero_passageiros) FROM tb_reservas r
            WHERE r.id_pacote = p.id_pacote AND r.status_reserva IN ('CONFIRMADA', 'PENDENTE')), 0) <= 5
            THEN 'ÚLTIMAS VAGAS'
        WHEN p.data_inicio <= CURRENT_DATE + INTERVAL '30 days' THEN 'SAÍDA EM BREVE'
        ELSE 'DISPONÍVEL'
    END AS status_disponibilidade,

    -- Custo-Benefício
    ROUND(p.preco_total / p.duracao_dias, 2) AS preco_por_dia,

    -- Popularidade
    (SELECT COUNT(*) FROM tb_reservas r
     WHERE r.id_pacote = p.id_pacote
     AND r.status_reserva IN ('CONFIRMADA', 'FINALIZADA')) AS total_vendas_historicas
FROM tb_pacotes_turisticos p
INNER JOIN tb_destinos d ON p.id_destino = d.id_destino
INNER JOIN tb_hoteis h ON p.id_hotel = h.id_hotel
WHERE p.status = 'DISPONIVEL' AND p.data_inicio >= CURRENT_DATE AND p.vagas_disponiveis > 0;

COMMENT ON VIEW vw_pacotes_disponiveis IS
'View inteligente com cálculo dinâmico de disponibilidade e ranking.
Subconsultas calculam vagas em tempo real, integra avaliações.
Regras: ESGOTADO (0 vagas), ÚLTIMAS VAGAS (≤5), SAÍDA EM BREVE (≤30 dias).
Uso: Busca de pacotes, motor de recomendação, alertas de escassez.';

-- ============================================================================
-- DEMONSTRAÇÃO DE USO DAS VIEWS
-- ============================================================================

-- Exemplo 1: Catálogo de pacotes internacionais 5 estrelas
SELECT nome_pacote, nome_destino, pais, nome_hotel,
    duracao_dias, preco_formatado, data_inicio_formatada
FROM vw_pacotes_completos
WHERE pais != 'Brasil' AND classificacao_estrelas = 5 AND status_pacote = 'DISPONIVEL'
ORDER BY preco_total ASC;

-- Exemplo 2: Ranking de vendedores do mês atual
SELECT vendedor, cargo, quantidade_vendas, total_passageiros,
    TO_CHAR(receita_total, 'L999G999G999D99') AS receita,
    TO_CHAR(ticket_medio, 'L999G999D99') AS ticket_medio
FROM vw_dashboard_vendas
WHERE mes_ano_venda = TO_CHAR(CURRENT_DATE, 'YYYY-MM')
ORDER BY receita_total DESC LIMIT 5;

-- Exemplo 3: Pacotes bem avaliados com vagas disponíveis
SELECT nome_pacote, nome_destino, tipo_turismo,
    vagas_restantes, status_disponibilidade,
    avaliacao_media, classificacao_qualidade,
    TO_CHAR(preco_total, 'L999G999G999D99') AS preco
FROM vw_pacotes_disponiveis
WHERE classificacao_qualidade IN ('EXCELENTE', 'MUITO BOM') AND vagas_restantes >= 2
ORDER BY avaliacao_media DESC, preco_por_dia ASC LIMIT 10;

-- ============================================================================
-- RESUMO DA ETAPA 3.1
-- VIEW 1: vw_pacotes_completos - Simplifica JOINs, uso em catálogos
-- VIEW 2: vw_dashboard_vendas - Agregações para dashboards e KPIs
-- VIEW 3: vw_pacotes_disponiveis - Subconsultas para disponibilidade dinâmica
-- BENEFÍCIOS: Redução de código, otimização automática, abstração de lógica
-- ============================================================================

SELECT 'Etapa 3.1 concluída! 3 views criadas com sucesso.' AS status;
