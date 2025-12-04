-- ============================================================================
-- SUPER SQL: POPULAÇÃO MASSIVA DE DADOS
-- Função para popular TODAS as tabelas com MILHÕES de dados aleatórios
-- GARANTIA: TODAS as tabelas terão MILHÕES de registros!
-- Uso: SELECT popular_dados_massivos(); -- Popula com milhões em TODAS
-- ============================================================================

\c agencia_turismo;

-- ============================================================================
-- FUNÇÃO PRINCIPAL: popular_dados_massivos
-- Gera MILHÕES de dados aleatórios em TODAS as tabelas
-- SEM parâmetros = popula milhões em todas as tabelas automaticamente
-- ============================================================================

CREATE OR REPLACE FUNCTION popular_dados_massivos()
RETURNS TEXT AS $$
DECLARE
    v_inicio TIMESTAMP;
    v_fim TIMESTAMP;
    v_duracao INTERVAL;
    v_total_registros BIGINT := 0;
    i INTEGER;
    v_batch_size INTEGER := 100000;
    v_id_cliente INTEGER;
    v_id_funcionario INTEGER;
    v_id_destino INTEGER;
    v_id_hotel INTEGER;
    v_id_transporte INTEGER;
    v_id_pacote INTEGER;
    v_id_reserva INTEGER;
    v_preco_total NUMERIC(10,2);
    v_valor_total NUMERIC(10,2);
BEGIN
    v_inicio := clock_timestamp();

    RAISE NOTICE '╔════════════════════════════════════════════════════════╗';
    RAISE NOTICE '║  INICIANDO POPULAÇÃO MASSIVA DE DADOS                 ║';
    RAISE NOTICE '║  META: MILHÕES DE REGISTROS EM TODAS AS TABELAS!      ║';
    RAISE NOTICE '╚════════════════════════════════════════════════════════╝';
    RAISE NOTICE '';

    -- Desabilitar triggers temporariamente para performance
    SET session_replication_role = replica;

    -- ========================================================================
    -- 1. TB_CLIENTES: 5 MILHÕES DE REGISTROS
    -- ========================================================================
    RAISE NOTICE '┌─────────────────────────────────────────────────────┐';
    RAISE NOTICE '│ [1/10] Populando tb_clientes (5 MILHÕES)...        │';
    RAISE NOTICE '└─────────────────────────────────────────────────────┘';

    FOR batch IN 0..49 LOOP
        INSERT INTO tb_clientes (nome_completo, cpf, data_nascimento, email, telefone, endereco, cidade, estado, cep)
        SELECT
            'Cliente ' || (batch * v_batch_size + i) || ' ' ||
            (ARRAY['Silva', 'Santos', 'Oliveira', 'Souza', 'Lima', 'Pereira', 'Costa', 'Rodrigues', 'Almeida', 'Nascimento', 'Ferreira', 'Martins', 'Araújo', 'Cardoso', 'Ribeiro'])[floor(random() * 15 + 1)],
            LPAD((10000000000 + (batch * v_batch_size + i))::TEXT, 11, '0'),
            DATE '1950-01-01' + (random() * 25000)::INTEGER,
            'cliente' || (batch * v_batch_size + i) || '@email.com.br',
            (ARRAY['11', '21', '31', '41', '51', '61', '71', '81', '85', '91'])[floor(random() * 10 + 1)] || LPAD((900000000 + i)::TEXT, 9, '0'),
            (ARRAY['Rua das Flores', 'Avenida Brasil', 'Rua Principal', 'Alameda Santos', 'Travessa do Comércio'])[floor(random() * 5 + 1)] || ', ' || i,
            (ARRAY['São Paulo', 'Rio de Janeiro', 'Brasília', 'Belo Horizonte', 'Salvador', 'Fortaleza', 'Recife', 'Curitiba', 'Porto Alegre', 'Manaus', 'Belém', 'Goiânia', 'Campinas', 'Guarulhos', 'São Luís'])[floor(random() * 15 + 1)],
            (ARRAY['SP', 'RJ', 'DF', 'MG', 'BA', 'CE', 'PE', 'PR', 'RS', 'AM', 'PA', 'GO', 'MA', 'ES', 'SC'])[floor(random() * 15 + 1)],
            LPAD((10000000 + (random() * 89999999)::INTEGER)::TEXT, 8, '0')
        FROM generate_series(1, v_batch_size) AS i;

        RAISE NOTICE '  ► Progresso: % / 5.000.000 (%%) concluído', (batch + 1) * v_batch_size, ((batch + 1) * 2)::INTEGER;
    END LOOP;

    v_total_registros := v_total_registros + 5000000;
    RAISE NOTICE '  ✓ tb_clientes: 5.000.000 registros inseridos!';
    RAISE NOTICE '';

    -- ========================================================================
    -- 2. TB_FUNCIONARIOS: 2 MILHÕES DE REGISTROS
    -- ========================================================================
    RAISE NOTICE '┌─────────────────────────────────────────────────────┐';
    RAISE NOTICE '│ [2/10] Populando tb_funcionarios (2 MILHÕES)...    │';
    RAISE NOTICE '└─────────────────────────────────────────────────────┘';

    FOR batch IN 0..19 LOOP
        INSERT INTO tb_funcionarios (nome_completo, cpf, email_corporativo, telefone, cargo, salario, data_admissao, status)
        SELECT
            'Funcionário ' || (batch * v_batch_size + i) || ' ' ||
            (ARRAY['Silva', 'Santos', 'Oliveira', 'Costa', 'Lima', 'Pereira', 'Souza', 'Almeida'])[floor(random() * 8 + 1)],
            LPAD((50000000000 + (batch * v_batch_size + i))::TEXT, 11, '0'),
            'func' || (batch * v_batch_size + i) || '@agenciaturismo.com.br',
            '61' || LPAD((991000000 + i)::TEXT, 9, '0'),
            (ARRAY['VENDEDOR', 'VENDEDOR', 'VENDEDOR', 'ATENDENTE', 'ATENDENTE', 'SUPERVISOR', 'GERENTE', 'DIRETOR'])[floor(random() * 8 + 1)],
            2500.00 + (random() * 17500)::NUMERIC(10,2),
            DATE '2010-01-01' + (random() * 5000)::INTEGER,
            (ARRAY['ATIVO', 'ATIVO', 'ATIVO', 'ATIVO', 'ATIVO', 'FERIAS', 'AFASTADO'])[floor(random() * 7 + 1)]
        FROM generate_series(1, v_batch_size) AS i;

        RAISE NOTICE '  ► Progresso: % / 2.000.000 (%%) concluído', (batch + 1) * v_batch_size, ((batch + 1) * 5)::INTEGER;
    END LOOP;

    v_total_registros := v_total_registros + 2000000;
    RAISE NOTICE '  ✓ tb_funcionarios: 2.000.000 registros inseridos!';
    RAISE NOTICE '';

    -- ========================================================================
    -- 3. TB_DESTINOS: 1 MILHÃO DE REGISTROS
    -- ========================================================================
    RAISE NOTICE '┌─────────────────────────────────────────────────────┐';
    RAISE NOTICE '│ [3/10] Populando tb_destinos (1 MILHÃO)...         │';
    RAISE NOTICE '└─────────────────────────────────────────────────────┘';

    FOR batch IN 0..9 LOOP
        INSERT INTO tb_destinos (nome_destino, pais, estado, cidade, descricao, categoria, clima, idioma_principal, moeda_local, status)
        SELECT
            'Destino ' || (batch * v_batch_size + i) || ' - ' ||
            (ARRAY['Paraíso', 'Encanto', 'Maravilha', 'Sonho', 'Fantasia', 'Aventura', 'Descoberta', 'Tesouro'])[floor(random() * 8 + 1)],
            (ARRAY['Brasil', 'Brasil', 'Argentina', 'Chile', 'Peru', 'Colômbia', 'México', 'EUA', 'Canadá', 'França', 'Itália', 'Espanha', 'Portugal', 'Grécia', 'Tailândia', 'Japão', 'Austrália', 'Nova Zelândia'])[floor(random() * 18 + 1)],
            CASE WHEN random() > 0.5 THEN (ARRAY['SP', 'RJ', 'BA', 'CE', 'PE', 'SC', 'RS', 'MG', 'PR', 'GO'])[floor(random() * 10 + 1)] ELSE NULL END,
            'Cidade Turística ' || i,
            'Destino turístico incrível com paisagens deslumbrantes e cultura rica. Perfeito para todas as idades.',
            (ARRAY['PRAIA', 'PRAIA', 'MONTANHA', 'URBANO', 'AVENTURA', 'CULTURAL', 'ECOLOGICO', 'RELIGIOSO'])[floor(random() * 8 + 1)],
            (ARRAY['Tropical', 'Temperado', 'Subtropical', 'Equatorial', 'Árido', 'Mediterrâneo', 'Continental'])[floor(random() * 7 + 1)],
            (ARRAY['Português', 'Espanhol', 'Inglês', 'Francês', 'Italiano', 'Alemão', 'Mandarim', 'Japonês'])[floor(random() * 8 + 1)],
            (ARRAY['Real (BRL)', 'Dólar (USD)', 'Euro (EUR)', 'Peso (ARS)', 'Peso (CLP)', 'Sol (PEN)', 'Libra (GBP)', 'Iene (JPY)'])[floor(random() * 8 + 1)],
            (ARRAY['ATIVO', 'ATIVO', 'ATIVO', 'ATIVO', 'INATIVO'])[floor(random() * 5 + 1)]
        FROM generate_series(1, v_batch_size) AS i;

        RAISE NOTICE '  ► Progresso: % / 1.000.000 (%%) concluído', (batch + 1) * v_batch_size, ((batch + 1) * 10)::INTEGER;
    END LOOP;

    v_total_registros := v_total_registros + 1000000;
    RAISE NOTICE '  ✓ tb_destinos: 1.000.000 registros inseridos!';
    RAISE NOTICE '';

    -- ========================================================================
    -- 4. TB_HOTEIS: 3 MILHÕES DE REGISTROS
    -- ========================================================================
    RAISE NOTICE '┌─────────────────────────────────────────────────────┐';
    RAISE NOTICE '│ [4/10] Populando tb_hoteis (3 MILHÕES)...          │';
    RAISE NOTICE '└─────────────────────────────────────────────────────┘';

    FOR batch IN 0..29 LOOP
        INSERT INTO tb_hoteis (id_destino, nome_hotel, endereco, classificacao_estrelas, descricao, comodidades, valor_diaria_minima, telefone, email, status)
        SELECT
            floor(random() * 1000000 + 1)::INTEGER,
            (ARRAY['Hotel', 'Resort', 'Pousada', 'Inn', 'Hostel', 'Lodge'])[floor(random() * 6 + 1)] || ' ' ||
            (ARRAY['Plaza', 'Royal', 'Grand', 'Paradise', 'Golden', 'Imperial', 'Majestic', 'Sunset', 'Ocean', 'Mountain'])[floor(random() * 10 + 1)] || ' ' || i,
            'Rua Principal, ' || i || ', Centro',
            floor(random() * 5 + 1)::INTEGER,
            'Hotel confortável e bem localizado com excelente infraestrutura para turistas.',
            (ARRAY['Wi-Fi, Piscina, Academia', 'Wi-Fi, Café da manhã, Estacionamento', 'Wi-Fi, Spa, Sauna, Academia', 'Wi-Fi, Piscina, Bar, Restaurante', 'Wi-Fi, Ar condicionado, TV a cabo'])[floor(random() * 5 + 1)],
            100.00 + (random() * 4900)::NUMERIC(10,2),
            (ARRAY['11', '21', '31', '41', '51', '61', '71', '81'])[floor(random() * 8 + 1)] || LPAD((30000000 + i)::TEXT, 8, '0'),
            'contato' || (batch * v_batch_size + i) || '@hotel.com.br',
            (ARRAY['ATIVO', 'ATIVO', 'ATIVO', 'ATIVO', 'INATIVO'])[floor(random() * 5 + 1)]
        FROM generate_series(1, v_batch_size) AS i;

        RAISE NOTICE '  ► Progresso: % / 3.000.000 (%%) concluído', (batch + 1) * v_batch_size, ((batch + 1) * 10 / 3)::INTEGER;
    END LOOP;

    v_total_registros := v_total_registros + 3000000;
    RAISE NOTICE '  ✓ tb_hoteis: 3.000.000 registros inseridos!';
    RAISE NOTICE '';

    -- ========================================================================
    -- 5. TB_TRANSPORTES: 1 MILHÃO DE REGISTROS
    -- ========================================================================
    RAISE NOTICE '┌─────────────────────────────────────────────────────┐';
    RAISE NOTICE '│ [5/10] Populando tb_transportes (1 MILHÃO)...      │';
    RAISE NOTICE '└─────────────────────────────────────────────────────┘';

    FOR batch IN 0..9 LOOP
        INSERT INTO tb_transportes (tipo_transporte, empresa_parceira, modelo, capacidade_passageiros, classe, preco_base, status)
        SELECT
            (ARRAY['AEREO', 'AEREO', 'AEREO', 'ONIBUS', 'ONIBUS', 'VAN', 'NAVIO', 'TREM'])[floor(random() * 8 + 1)],
            (ARRAY['LATAM', 'GOL', 'Azul', 'TAP', 'Emirates', 'Air France', 'United', 'Viação Cometa', 'Viação Itapemirim', 'MSC Cruzeiros', 'Costa Cruzeiros'])[floor(random() * 11 + 1)],
            'Modelo ' || (batch * v_batch_size + i) || ' ' || (ARRAY['Executivo', 'Standard', 'Premium', 'Luxury'])[floor(random() * 4 + 1)],
            floor(random() * 500 + 10)::INTEGER,
            (ARRAY['ECONOMICA', 'ECONOMICA', 'EXECUTIVA', 'PRIMEIRA_CLASSE', 'LEITO', 'SEMI_LEITO'])[floor(random() * 6 + 1)],
            80.00 + (random() * 9920)::NUMERIC(10,2),
            (ARRAY['ATIVO', 'ATIVO', 'ATIVO', 'ATIVO', 'MANUTENCAO'])[floor(random() * 5 + 1)]
        FROM generate_series(1, v_batch_size) AS i;

        RAISE NOTICE '  ► Progresso: % / 1.000.000 (%%) concluído', (batch + 1) * v_batch_size, ((batch + 1) * 10)::INTEGER;
    END LOOP;

    v_total_registros := v_total_registros + 1000000;
    RAISE NOTICE '  ✓ tb_transportes: 1.000.000 registros inseridos!';
    RAISE NOTICE '';

    -- ========================================================================
    -- 6. TB_PACOTES_TURISTICOS: 4 MILHÕES DE REGISTROS
    -- ========================================================================
    RAISE NOTICE '┌─────────────────────────────────────────────────────┐';
    RAISE NOTICE '│ [6/10] Populando tb_pacotes_turisticos (4 MILHÕES).│';
    RAISE NOTICE '└─────────────────────────────────────────────────────┘';

    FOR batch IN 0..39 LOOP
        INSERT INTO tb_pacotes_turisticos (nome_pacote, id_destino, id_hotel, id_transporte, descricao_completa, duracao_dias, data_inicio, data_fim, preco_total, vagas_disponiveis, regime_alimentar, incluso, nao_incluso, status)
        SELECT
            'Pacote Especial ' || (batch * v_batch_size + i) || ' - ' ||
            (ARRAY['Férias dos Sonhos', 'Aventura Radical', 'Relax Total', 'Família Feliz', 'Lua de Mel', 'Executivo'])[floor(random() * 6 + 1)],
            floor(random() * 1000000 + 1)::INTEGER,
            floor(random() * 3000000 + 1)::INTEGER,
            floor(random() * 1000000 + 1)::INTEGER,
            'Pacote completo com hospedagem, transporte e passeios inclusos. Experiência inesquecível!',
            floor(random() * 20 + 1)::INTEGER,
            CURRENT_DATE + (random() * 730)::INTEGER,
            CURRENT_DATE + (random() * 730 + 3)::INTEGER,
            1000.00 + (random() * 49000)::NUMERIC(10,2),
            floor(random() * 100 + 1)::INTEGER,
            (ARRAY['CAFE_MANHA', 'MEIA_PENSAO', 'PENSAO_COMPLETA', 'ALL_INCLUSIVE', 'SEM_ALIMENTACAO'])[floor(random() * 5 + 1)],
            'Transporte, hospedagem, café da manhã, seguro viagem',
            'Passeios opcionais, refeições extras, bebidas',
            (ARRAY['DISPONIVEL', 'DISPONIVEL', 'DISPONIVEL', 'DISPONIVEL', 'ESGOTADO', 'CANCELADO'])[floor(random() * 6 + 1)]
        FROM generate_series(1, v_batch_size) AS i;

        RAISE NOTICE '  ► Progresso: % / 4.000.000 (%%) concluído', (batch + 1) * v_batch_size, ((batch + 1) * 10 / 4)::INTEGER;
    END LOOP;

    v_total_registros := v_total_registros + 4000000;
    RAISE NOTICE '  ✓ tb_pacotes_turisticos: 4.000.000 registros inseridos!';
    RAISE NOTICE '';

    -- ========================================================================
    -- 7. TB_RESERVAS: 10 MILHÕES DE REGISTROS (MAIOR TABELA)
    -- ========================================================================
    RAISE NOTICE '┌─────────────────────────────────────────────────────┐';
    RAISE NOTICE '│ [7/10] Populando tb_reservas (10 MILHÕES)...       │';
    RAISE NOTICE '│        ⚠️  MAIOR TABELA - Pode demorar mais...      │';
    RAISE NOTICE '└─────────────────────────────────────────────────────┘';

    FOR batch IN 0..99 LOOP
        INSERT INTO tb_reservas (id_cliente, id_pacote, id_funcionario, numero_passageiros, valor_unitario, desconto_percentual, valor_total, observacoes, status_reserva, data_reserva)
        SELECT
            floor(random() * 5000000 + 1)::INTEGER,
            floor(random() * 4000000 + 1)::INTEGER,
            floor(random() * 2000000 + 1)::INTEGER,
            floor(random() * 6 + 1)::INTEGER,
            1000.00 + (random() * 49000)::NUMERIC(10,2),
            (random() * 25)::NUMERIC(5,2),
            (1000.00 + (random() * 49000)::NUMERIC(10,2)) * floor(random() * 6 + 1) * (1 - (random() * 25)::NUMERIC(5,2) / 100),
            CASE WHEN random() > 0.8 THEN 'Observação especial da reserva' ELSE NULL END,
            (ARRAY['CONFIRMADA', 'CONFIRMADA', 'CONFIRMADA', 'CONFIRMADA', 'PENDENTE', 'CANCELADA', 'FINALIZADA'])[floor(random() * 7 + 1)],
            CURRENT_TIMESTAMP - (random() * 730 ||' days')::INTERVAL
        FROM generate_series(1, v_batch_size) AS i;

        RAISE NOTICE '  ► Progresso: % / 10.000.000 (%%) concluído', (batch + 1) * v_batch_size, (batch + 1)::INTEGER;
    END LOOP;

    v_total_registros := v_total_registros + 10000000;
    RAISE NOTICE '  ✓ tb_reservas: 10.000.000 registros inseridos!';
    RAISE NOTICE '';

    -- ========================================================================
    -- 8. TB_PAGAMENTOS: 15 MILHÕES DE REGISTROS (MÚLTIPLAS PARCELAS)
    -- ========================================================================
    RAISE NOTICE '┌─────────────────────────────────────────────────────┐';
    RAISE NOTICE '│ [8/10] Populando tb_pagamentos (15 MILHÕES)...     │';
    RAISE NOTICE '│        ⚠️  SEGUNDA MAIOR TABELA - Aguarde...        │';
    RAISE NOTICE '└─────────────────────────────────────────────────────┘';

    FOR batch IN 0..149 LOOP
        INSERT INTO tb_pagamentos (id_reserva, forma_pagamento, numero_parcela, total_parcelas, valor_parcela, data_vencimento, status_pagamento, numero_transacao, data_pagamento)
        SELECT
            floor(random() * 10000000 + 1)::INTEGER,
            (ARRAY['DINHEIRO', 'DEBITO', 'CREDITO', 'CREDITO', 'CREDITO', 'PIX', 'PIX', 'TRANSFERENCIA', 'BOLETO'])[floor(random() * 9 + 1)],
            floor(random() * 12 + 1)::INTEGER,
            floor(random() * 12 + 1)::INTEGER,
            100.00 + (random() * 9900)::NUMERIC(10,2),
            CURRENT_DATE + (random() * 365)::INTEGER,
            (ARRAY['PENDENTE', 'PAGO', 'PAGO', 'PAGO', 'PAGO', 'CANCELADO', 'ESTORNADO'])[floor(random() * 7 + 1)],
            'TXN' || LPAD((batch * v_batch_size + i)::TEXT, 20, '0'),
            CURRENT_TIMESTAMP - (random() * 365 ||' days')::INTERVAL
        FROM generate_series(1, v_batch_size) AS i;

        IF batch % 10 = 9 THEN
            RAISE NOTICE '  ► Progresso: % / 15.000.000 (%%) concluído', (batch + 1) * v_batch_size, ((batch + 1) * 100 / 150)::INTEGER;
        END IF;
    END LOOP;

    v_total_registros := v_total_registros + 15000000;
    RAISE NOTICE '  ✓ tb_pagamentos: 15.000.000 registros inseridos!';
    RAISE NOTICE '';

    -- ========================================================================
    -- 9. TB_AVALIACOES: 5 MILHÕES DE REGISTROS
    -- ========================================================================
    RAISE NOTICE '┌─────────────────────────────────────────────────────┐';
    RAISE NOTICE '│ [9/10] Populando tb_avaliacoes (5 MILHÕES)...      │';
    RAISE NOTICE '└─────────────────────────────────────────────────────┘';

    FOR batch IN 0..49 LOOP
        INSERT INTO tb_avaliacoes (id_cliente, id_pacote, nota, comentario, data_avaliacao)
        SELECT
            floor(random() * 5000000 + 1)::INTEGER,
            floor(random() * 4000000 + 1)::INTEGER,
            floor(random() * 5 + 1)::INTEGER,
            (ARRAY['Excelente experiência!', 'Muito bom, recomendo!', 'Bom custo-benefício', 'Atendeu as expectativas', 'Poderia melhorar', 'Maravilhoso!', 'Perfeito!', 'Inesquecível!', NULL, NULL])[floor(random() * 10 + 1)],
            CURRENT_TIMESTAMP - (random() * 365 ||' days')::INTERVAL
        FROM generate_series(1, v_batch_size) AS i
        ON CONFLICT (id_cliente, id_pacote) DO NOTHING;

        RAISE NOTICE '  ► Progresso: % / 5.000.000 (%%) concluído', (batch + 1) * v_batch_size, ((batch + 1) * 2)::INTEGER;
    END LOOP;

    v_total_registros := v_total_registros + 5000000;
    RAISE NOTICE '  ✓ tb_avaliacoes: ~5.000.000 registros inseridos!';
    RAISE NOTICE '';

    -- ========================================================================
    -- 10. TB_AUDITORIA: 2 MILHÕES DE REGISTROS
    -- ========================================================================
    RAISE NOTICE '┌─────────────────────────────────────────────────────┐';
    RAISE NOTICE '│ [10/10] Populando tb_auditoria (2 MILHÕES)...      │';
    RAISE NOTICE '└─────────────────────────────────────────────────────┘';

    FOR batch IN 0..19 LOOP
        INSERT INTO tb_auditoria (tabela_afetada, operacao, usuario_db, dados_antigos, dados_novos, id_registro_afetado, observacao, data_hora)
        SELECT
            (ARRAY['tb_reservas', 'tb_pagamentos', 'tb_clientes', 'tb_pacotes_turisticos'])[floor(random() * 4 + 1)],
            (ARRAY['INSERT', 'UPDATE', 'DELETE'])[floor(random() * 3 + 1)],
            'user_' || floor(random() * 100 + 1),
            CASE WHEN random() > 0.5 THEN ('{"id": ' || i || ', "valor": ' || (random() * 10000)::INTEGER || '}')::JSONB ELSE NULL END,
            ('{"id": ' || i || ', "novo_valor": ' || (random() * 10000)::INTEGER || '}')::JSONB,
            floor(random() * 10000000 + 1)::INTEGER,
            'Operação registrada automaticamente pelo sistema de auditoria',
            CURRENT_TIMESTAMP - (random() * 365 ||' days')::INTERVAL
        FROM generate_series(1, v_batch_size) AS i;

        RAISE NOTICE '  ► Progresso: % / 2.000.000 (%%) concluído', (batch + 1) * v_batch_size, ((batch + 1) * 5)::INTEGER;
    END LOOP;

    v_total_registros := v_total_registros + 2000000;
    RAISE NOTICE '  ✓ tb_auditoria: 2.000.000 registros inseridos!';
    RAISE NOTICE '';

    -- Reabilitar triggers
    SET session_replication_role = DEFAULT;

    -- ========================================================================
    -- FINALIZAÇÃO E ESTATÍSTICAS
    -- ========================================================================
    RAISE NOTICE '┌─────────────────────────────────────────────────────┐';
    RAISE NOTICE '│ Atualizando estatísticas do banco de dados...      │';
    RAISE NOTICE '└─────────────────────────────────────────────────────┘';
    ANALYZE;

    v_fim := clock_timestamp();
    v_duracao := v_fim - v_inicio;

    RAISE NOTICE '';
    RAISE NOTICE '╔════════════════════════════════════════════════════════╗';
    RAISE NOTICE '║         POPULAÇÃO MASSIVA CONCLUÍDA!                  ║';
    RAISE NOTICE '╠════════════════════════════════════════════════════════╣';
    RAISE NOTICE '║  Total de registros: %                    ║', LPAD(v_total_registros::TEXT, 26, ' ');
    RAISE NOTICE '║  Tempo de execução: %                     ║', LPAD(v_duracao::TEXT, 27, ' ');
    RAISE NOTICE '║  Taxa: % reg/seg                          ║', LPAD(ROUND(v_total_registros / EXTRACT(EPOCH FROM v_duracao), 2)::TEXT, 38, ' ');
    RAISE NOTICE '╠════════════════════════════════════════════════════════╣';
    RAISE NOTICE '║  DISTRIBUIÇÃO:                                         ║';
    RAISE NOTICE '║    • tb_clientes: 5.000.000                            ║';
    RAISE NOTICE '║    • tb_funcionarios: 2.000.000                        ║';
    RAISE NOTICE '║    • tb_destinos: 1.000.000                            ║';
    RAISE NOTICE '║    • tb_hoteis: 3.000.000                              ║';
    RAISE NOTICE '║    • tb_transportes: 1.000.000                         ║';
    RAISE NOTICE '║    • tb_pacotes_turisticos: 4.000.000                  ║';
    RAISE NOTICE '║    • tb_reservas: 10.000.000 ⭐                        ║';
    RAISE NOTICE '║    • tb_pagamentos: 15.000.000 ⭐⭐                    ║';
    RAISE NOTICE '║    • tb_avaliacoes: 5.000.000                          ║';
    RAISE NOTICE '║    • tb_auditoria: 2.000.000                           ║';
    RAISE NOTICE '╚════════════════════════════════════════════════════════╝';

    RETURN '✓ SUCESSO! ' || v_total_registros || ' registros em ' || v_duracao;

EXCEPTION
    WHEN OTHERS THEN
        SET session_replication_role = DEFAULT;
        RAISE NOTICE '❌ ERRO: %', SQLERRM;
        RETURN 'ERRO: ' || SQLERRM;
END;
$$ LANGUAGE plpgsql;

-- ============================================================================
-- FUNÇÕES AUXILIARES
-- ============================================================================

-- Limpar TODAS as tabelas
CREATE OR REPLACE FUNCTION limpar_todas_tabelas()
RETURNS TEXT AS $$
BEGIN
    TRUNCATE TABLE tb_avaliacoes CASCADE;
    TRUNCATE TABLE tb_pagamentos CASCADE;
    TRUNCATE TABLE tb_reservas CASCADE;
    TRUNCATE TABLE tb_pacotes_turisticos CASCADE;
    TRUNCATE TABLE tb_transportes CASCADE;
    TRUNCATE TABLE tb_hoteis CASCADE;
    TRUNCATE TABLE tb_destinos CASCADE;
    TRUNCATE TABLE tb_funcionarios CASCADE;
    TRUNCATE TABLE tb_clientes CASCADE;
    TRUNCATE TABLE tb_auditoria CASCADE;
    RETURN '✓ Todas as tabelas foram limpas!';
END;
$$ LANGUAGE plpgsql;

-- Verificar quantidade e tamanho das tabelas
CREATE OR REPLACE FUNCTION verificar_tamanho_tabelas()
RETURNS TABLE (
    tabela TEXT,
    registros TEXT,
    tamanho_dados TEXT,
    tamanho_indices TEXT,
    tamanho_total TEXT
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        relname::TEXT AS tabela,
        TO_CHAR(n_live_tup, '999G999G999') AS registros,
        pg_size_pretty(pg_relation_size(schemaname||'.'||relname)) AS tamanho_dados,
        pg_size_pretty(pg_indexes_size(schemaname||'.'||relname)) AS tamanho_indices,
        pg_size_pretty(pg_total_relation_size(schemaname||'.'||relname)) AS tamanho_total
    FROM pg_stat_user_tables
    WHERE schemaname = 'public'
    ORDER BY n_live_tup DESC;
END;
$$ LANGUAGE plpgsql;

-- ============================================================================
-- USO
-- ============================================================================

-- EXECUTAR POPULAÇÃO MASSIVA (48 MILHÕES DE REGISTROS!)
-- SELECT popular_dados_massivos();

-- LIMPAR TUDO
-- SELECT limpar_todas_tabelas();

-- VERIFICAR RESULTADO
-- SELECT * FROM verificar_tamanho_tabelas();

-- ============================================================================
-- RESUMO FINAL
-- Total: 48 MILHÕES DE REGISTROS distribuídos em TODAS as 10 tabelas!
-- ============================================================================

SELECT '🚀 Super SQL criado! Execute: SELECT popular_dados_massivos();' AS status;
