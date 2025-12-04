-- ============================================================================
-- ETAPA 3.6: SEGURANÇA E CONTROLE DE ACESSO (DCL)
-- Criação de 3 usuários com perfis distintos: Admin, Operador, Auditor
-- Uso de GRANT e REVOKE para permissões granulares
-- ============================================================================

\c agencia_turismo;

-- ============================================================================
-- CRIAÇÃO DE USUÁRIOS COM PERFIS DISTINTOS
-- ============================================================================

-- USUÁRIO 1: Administrador (Acesso total)
DROP USER IF EXISTS admin_agencia;
CREATE USER admin_agencia WITH PASSWORD 'Admin@2024!Seguro';

COMMENT ON ROLE admin_agencia IS 'Administrador com acesso completo ao banco';

-- USUÁRIO 2: Operador (Leitura + Escrita limitada)
DROP USER IF EXISTS operador_vendas;
CREATE USER operador_vendas WITH PASSWORD 'Oper@2024!Vendas';

COMMENT ON ROLE operador_vendas IS 'Operador de vendas: pode ler e inserir reservas';

-- USUÁRIO 3: Auditor (Somente leitura)
DROP USER IF EXISTS auditor_financeiro;
CREATE USER auditor_financeiro WITH PASSWORD 'Audit@2024!Financ';

COMMENT ON ROLE auditor_financeiro IS 'Auditor: acesso somente leitura para auditoria';

-- ============================================================================
-- PERFIL 1: ADMINISTRADOR (admin_agencia)
-- Permissões: Acesso total (SELECT, INSERT, UPDATE, DELETE em todas as tabelas)
-- ============================================================================

-- Conceder acesso ao banco de dados
GRANT CONNECT ON DATABASE agencia_turismo TO admin_agencia;

-- Conceder uso do schema public
GRANT USAGE ON SCHEMA public TO admin_agencia;

-- Conceder todos os privilégios em todas as tabelas
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO admin_agencia;

-- Conceder privilégios em sequences (para AUTO_INCREMENT/SERIAL)
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO admin_agencia;

-- Permitir criação de objetos
GRANT CREATE ON SCHEMA public TO admin_agencia;

-- Configurar privilégios padrão para novos objetos
ALTER DEFAULT PRIVILEGES IN SCHEMA public
GRANT ALL PRIVILEGES ON TABLES TO admin_agencia;

ALTER DEFAULT PRIVILEGES IN SCHEMA public
GRANT ALL PRIVILEGES ON SEQUENCES TO admin_agencia;

-- ============================================================================
-- PERFIL 2: OPERADOR DE VENDAS (operador_vendas)
-- Permissões: Leitura geral + Inserção/atualização limitada
-- Pode: Consultar tudo, Inserir/Atualizar reservas e pagamentos
-- Não pode: Deletar, Alterar estrutura, Acessar auditoria
-- ============================================================================

GRANT CONNECT ON DATABASE agencia_turismo TO operador_vendas;
GRANT USAGE ON SCHEMA public TO operador_vendas;

-- Leitura (SELECT) em todas as tabelas
GRANT SELECT ON ALL TABLES IN SCHEMA public TO operador_vendas;

-- Inserção e atualização APENAS em tabelas operacionais
GRANT INSERT, UPDATE ON tb_reservas TO operador_vendas;
GRANT INSERT, UPDATE ON tb_pagamentos TO operador_vendas;
GRANT INSERT ON tb_avaliacoes TO operador_vendas;

-- Acesso a sequences para gerar IDs
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO operador_vendas;

-- REVOGAR acesso à tabela de auditoria (apenas leitura permitida anteriormente)
REVOKE INSERT, UPDATE, DELETE ON tb_auditoria FROM operador_vendas;

-- REVOGAR modificações em tabelas mestras
REVOKE INSERT, UPDATE, DELETE ON tb_clientes FROM operador_vendas;
REVOKE INSERT, UPDATE, DELETE ON tb_funcionarios FROM operador_vendas;
REVOKE INSERT, UPDATE, DELETE ON tb_destinos FROM operador_vendas;
REVOKE INSERT, UPDATE, DELETE ON tb_hoteis FROM operador_vendas;
REVOKE INSERT, UPDATE, DELETE ON tb_transportes FROM operador_vendas;
REVOKE INSERT, UPDATE, DELETE ON tb_pacotes_turisticos FROM operador_vendas;

-- ============================================================================
-- PERFIL 3: AUDITOR FINANCEIRO (auditor_financeiro)
-- Permissões: Somente leitura (SELECT) em tabelas específicas
-- Pode: Consultar reservas, pagamentos, auditoria, clientes
-- Não pode: Modificar, Inserir, Deletar nada
-- ============================================================================

GRANT CONNECT ON DATABASE agencia_turismo TO auditor_financeiro;
GRANT USAGE ON SCHEMA public TO auditor_financeiro;

-- Leitura apenas em tabelas relacionadas a finanças e auditoria
GRANT SELECT ON tb_reservas TO auditor_financeiro;
GRANT SELECT ON tb_pagamentos TO auditor_financeiro;
GRANT SELECT ON tb_auditoria TO auditor_financeiro;
GRANT SELECT ON tb_clientes TO auditor_financeiro;
GRANT SELECT ON tb_funcionarios TO auditor_financeiro;

-- Acesso às views de relatórios
GRANT SELECT ON vw_dashboard_vendas TO auditor_financeiro;
GRANT SELECT ON vw_pacotes_completos TO auditor_financeiro;

-- REVOGAR qualquer permissão de escrita (garantia)
REVOKE INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public FROM auditor_financeiro;

-- ============================================================================
-- TESTES DE PERMISSÕES
-- ============================================================================

-- TESTE 1: Administrador (deve ter acesso total)
-- Execute em sessão conectada como admin_agencia:
/*
\c agencia_turismo admin_agencia
SELECT * FROM tb_reservas LIMIT 5;  -- Deve funcionar
INSERT INTO tb_clientes (nome_completo, cpf, data_nascimento, email, telefone)
VALUES ('Teste Admin', '99999999999', '1990-01-01', 'admin@test.com', '61999999999');  -- Deve funcionar
DELETE FROM tb_clientes WHERE cpf = '99999999999';  -- Deve funcionar
*/

-- TESTE 2: Operador de Vendas (leitura + escrita limitada)
-- Execute em sessão conectada como operador_vendas:
/*
\c agencia_turismo operador_vendas
SELECT * FROM tb_reservas;  -- Deve funcionar (leitura)
INSERT INTO tb_reservas (id_cliente, id_pacote, id_funcionario, numero_passageiros, valor_unitario, desconto_percentual, valor_total, status_reserva)
VALUES (1, 2, 4, 1, 15000.00, 5.00, 14250.00, 'CONFIRMADA');  -- Deve funcionar (inserção)
DELETE FROM tb_reservas WHERE id_reserva = 1;  -- Deve FALHAR (sem permissão DELETE)
UPDATE tb_clientes SET email = 'teste@test.com' WHERE id_cliente = 1;  -- Deve FALHAR (tabela bloqueada)
*/

-- TESTE 3: Auditor Financeiro (somente leitura)
-- Execute em sessão conectada como auditor_financeiro:
/*
\c agencia_turismo auditor_financeiro
SELECT * FROM tb_reservas;  -- Deve funcionar (leitura)
SELECT * FROM tb_auditoria;  -- Deve funcionar (leitura)
SELECT * FROM vw_dashboard_vendas;  -- Deve funcionar (view permitida)
INSERT INTO tb_pagamentos (id_reserva, forma_pagamento, valor_parcela)
VALUES (1, 'PIX', 100.00);  -- Deve FALHAR (sem permissão INSERT)
SELECT * FROM tb_destinos;  -- Deve FALHAR (tabela não permitida)
*/

-- ============================================================================
-- VISUALIZAÇÃO DE PERMISSÕES
-- ============================================================================

-- Listar permissões de todos os usuários criados
SELECT
    grantee AS usuario,
    table_schema AS schema,
    table_name AS tabela,
    privilege_type AS permissao
FROM information_schema.table_privileges
WHERE grantee IN ('admin_agencia', 'operador_vendas', 'auditor_financeiro')
ORDER BY grantee, table_name, privilege_type;

-- Verificar roles e suas configurações
SELECT
    rolname AS usuario,
    rolsuper AS superusuario,
    rolcreatedb AS pode_criar_db,
    rolcreaterole AS pode_criar_role,
    rolcanlogin AS pode_logar
FROM pg_roles
WHERE rolname IN ('admin_agencia', 'operador_vendas', 'auditor_financeiro');

-- ============================================================================
-- REVOGAÇÃO DE PERMISSÕES (EXEMPLO)
-- Demonstra como remover acessos específicos
-- ============================================================================

-- Exemplo: Remover permissão de UPDATE de operador_vendas em tb_pagamentos
-- REVOKE UPDATE ON tb_pagamentos FROM operador_vendas;

-- Exemplo: Bloquear completamente acesso de um usuário
-- REVOKE ALL PRIVILEGES ON ALL TABLES IN SCHEMA public FROM operador_vendas;
-- REVOKE CONNECT ON DATABASE agencia_turismo FROM operador_vendas;

-- ============================================================================
-- BOAS PRÁTICAS DE SEGURANÇA
-- ============================================================================

-- 1. Rotação de senhas (alterar senhas periodicamente)
-- ALTER USER operador_vendas WITH PASSWORD 'NovaSenha@2025!';

-- 2. Auditoria de conexões (verificar quem está conectado)
SELECT pid, usename, application_name, client_addr, backend_start, state
FROM pg_stat_activity
WHERE datname = 'agencia_turismo';

-- 3. Limitar conexões por usuário
ALTER USER operador_vendas CONNECTION LIMIT 5;

-- 4. Forçar SSL (conexões criptografadas)
-- ALTER USER auditor_financeiro WITH PASSWORD 'senha' CONNECTION LIMIT 10 ENCRYPTED PASSWORD 'senha_crypt';

-- ============================================================================
-- RESUMO DA ETAPA 3.6
-- USUÁRIO 1: admin_agencia - Acesso total (ALL PRIVILEGES)
-- USUÁRIO 2: operador_vendas - Leitura geral + Escrita limitada (reservas/pagamentos)
-- USUÁRIO 3: auditor_financeiro - Somente leitura (SELECT) em tabelas específicas
-- PRINCÍPIO: Least Privilege (Menor privilégio necessário)
-- DEMONSTRADO: GRANT, REVOKE, bloqueios de acesso indevido
-- ============================================================================

SELECT 'Etapa 3.6 concluída! Segurança e controle de acesso implementados.' AS status;
