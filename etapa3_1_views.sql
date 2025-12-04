-- ============================================================================
-- ETAPA 3.1: VIEWS (VISÕES)
-- Criação de 3 views para simplificar consultas complexas
-- ============================================================================

\c agencia_turismo;

-- VIEW 1: vw_pacotes_completos (VIEW SIMPLES)
-- Objetivo: Consolidar informações de pacotes turísticos
CREATE OR REPLACE VIEW vw_pacotes_completos AS
SELECT
    p.id_pacote, p.nome_pacote, p.duracao_dias,
    p.data_inicio, p.data_fim, p.preco_total,
    p.vagas_disponiveis, p.status AS status_pacote,
    d.nome_destino, d.pais, d.categoria AS categoria_turismo,
    h.nome_hotel, h.classificacao_estrelas,
    t.tipo_transporte, t.empresa_parceira
FROM tb_pacotes_turisticos p
INNER JOIN tb_destinos d ON p.id_destino = d.id_destino
INNER JOIN tb_hoteis h ON p.id_hotel = h.id_hotel
INNER JOIN tb_transportes t ON p.id_transporte = t.id_transporte;

-- VIEW 2: vw_vendas_por_funcionario (VIEW COM AGREGAÇÕES)
-- Objetivo: Resumo de vendas por funcionário
CREATE OR REPLACE VIEW vw_vendas_por_funcionario AS
SELECT
    f.id_funcionario,
    f.nome_completo AS vendedor,
    f.cargo,
    COUNT(r.id_reserva) AS total_vendas,
    SUM(r.numero_passageiros) AS total_passageiros,
    SUM(r.valor_total) AS receita_total
FROM tb_funcionarios f
LEFT JOIN tb_reservas r ON f.id_funcionario = r.id_funcionario
    AND r.status_reserva IN ('CONFIRMADA', 'FINALIZADA')
GROUP BY f.id_funcionario, f.nome_completo, f.cargo;

-- VIEW 3: vw_reservas_detalhadas (VIEW COM JOINS)
-- Objetivo: Informações completas das reservas
CREATE OR REPLACE VIEW vw_reservas_detalhadas AS
SELECT
    r.id_reserva,
    r.data_reserva,
    r.numero_passageiros,
    r.valor_total,
    r.status_reserva,
    c.nome_completo AS cliente,
    c.email AS email_cliente,
    f.nome_completo AS vendedor,
    p.nome_pacote,
    d.nome_destino,
    d.pais
FROM tb_reservas r
INNER JOIN tb_clientes c ON r.id_cliente = c.id_cliente
INNER JOIN tb_funcionarios f ON r.id_funcionario = f.id_funcionario
INNER JOIN tb_pacotes_turisticos p ON r.id_pacote = p.id_pacote
INNER JOIN tb_destinos d ON p.id_destino = d.id_destino;

-- ============================================================================
-- DEMONSTRAÇÃO DE USO DAS VIEWS
-- ============================================================================

-- Exemplo 1: Listar pacotes disponíveis
SELECT nome_pacote, nome_destino, pais, preco_total, classificacao_estrelas
FROM vw_pacotes_completos
WHERE status_pacote = 'DISPONIVEL'
ORDER BY preco_total ASC
LIMIT 10;

-- Exemplo 2: Ranking de vendedores
SELECT vendedor, cargo, total_vendas, receita_total
FROM vw_vendas_por_funcionario
WHERE total_vendas > 0
ORDER BY receita_total DESC;

-- Exemplo 3: Reservas confirmadas
SELECT cliente, vendedor, nome_pacote, nome_destino, valor_total
FROM vw_reservas_detalhadas
WHERE status_reserva = 'CONFIRMADA'
ORDER BY data_reserva DESC
LIMIT 10;

-- ============================================================================
-- RESUMO DA ETAPA 3.1
-- VIEW 1: vw_pacotes_completos - Consolida pacotes com destino, hotel e transporte
-- VIEW 2: vw_vendas_por_funcionario - Agregação de vendas por vendedor
-- VIEW 3: vw_reservas_detalhadas - Informações completas das reservas
-- ============================================================================

SELECT 'Etapa 3.1 concluída! 3 views criadas com sucesso.' AS status;
