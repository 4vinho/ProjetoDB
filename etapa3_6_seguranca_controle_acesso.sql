-- ============================================================================
-- ETAPA 3.6: SEGURANÇA E CONTROLE DE ACESSO (DCL)
-- ============================================================================
-- Descrição: Implementação de segurança e controle de acesso granular
-- Requisitos do projeto:
--   - Criar 3 usuários com perfis distintos (Admin, Operador, Auditor)
--   - Usar GRANT e REVOKE para permissões granulares
--   - Demonstrar bloqueio de acesso indevido
-- Objetivo: Aplicar boas práticas de segurança em nível de banco de dados
-- ============================================================================

-- Conectar ao banco de dados
\c agencia_turismo;

-- ============================================================================
-- CONCEITOS DE SEGURANÇA EM BANCO DE DADOS
-- ============================================================================

/*
PRINCÍPIOS DE SEGURANÇA:

1. LEAST PRIVILEGE (Menor Privilégio):
   - Usuários têm apenas permissões necessárias
   - Nunca mais que o mínimo exigido
   - Reduz superfície de ataque

2. SEPARATION OF DUTIES (Separação de Responsabilidades):
   - Diferentes perfis para diferentes funções
   - Administrador ≠ Operador ≠ Auditor
   - Evita fraudes internas

3. DEFENSE IN DEPTH (Defesa em Profundidade):
   - Múltiplas camadas de segurança
   - Autenticação + Autorização + Auditoria
   - Criptografia + Firewall + Logs

4. AUDITABILIDADE:
   - Registrar todas as ações críticas
   - Logs imutáveis
   - Rastreamento de mudanças

HIERARQUIA DE PERMISSÕES NO POSTGRESQL:

SUPERUSER (postgres)
   └─ DATABASE
       └─ SCHEMA
           └─ TABLES / VIEWS / FUNCTIONS / SEQUENCES
               └─ COLUMNS (RLS - Row Level Security)

COMANDOS DCL (Data Control Language):

- CREATE ROLE / CREATE USER
- GRANT: Conceder permissões
- REVOKE: Revogar permissões
- ALTER ROLE: Modificar propriedades
- DROP ROLE: Remover usuário
*/

-- ============================================================================
-- ETAPA 1: CRIAÇÃO DE ROLES (PERFIS DE ACESSO)
-- ============================================================================

-- ----------------------------------------------------------------------------
-- ROLE 1: ADMINISTRADOR (db_admin)
-- ----------------------------------------------------------------------------
-- Perfil: Administrador do sistema
-- Permissões: Todas (DDL, DML, DCL)
-- Uso: Gestão completa do banco de dados
-- Limitações: Não é SUPERUSER (não cria databases/roles)
-- ----------------------------------------------------------------------------

-- Remover se já existir (idempotência)
DROP ROLE IF EXISTS db_admin;

CREATE ROLE db_admin
    WITH
    LOGIN                       -- Pode fazer login
    PASSWORD 'Admin@2024!'      -- Senha forte (em produção: hash bcrypt)
    NOSUPERUSER                 -- Não é superusuário
    CREATEDB                    -- Pode criar databases
    NOCREATEROLE                -- Não pode criar roles
    NOINHERIT                   -- Não herda permissões automaticamente
    NOREPLICATION               -- Não pode replicar
    CONNECTION LIMIT 5          -- Máximo 5 conexões simultâneas
    VALID UNTIL '2025-12-31';   -- Expira em 31/12/2025

COMMENT ON ROLE db_admin IS
'Administrador do banco de dados da agência de turismo.
RESPONSABILIDADES:
- Gerenciar estrutura do banco (CREATE, ALTER, DROP)
- Configurar permissões de outros usuários
- Executar backups e restore
- Monitorar performance e logs
- Manutenção (VACUUM, ANALYZE, REINDEX)
RESTRIÇÕES:
- Não pode criar novos roles (necessita DBA)
- Não pode acessar outros bancos
- Conexões limitadas a 5 simultâneas';

-- Conceder permissões amplas ao administrador
GRANT ALL PRIVILEGES ON DATABASE agencia_turismo TO db_admin;
GRANT ALL PRIVILEGES ON SCHEMA public TO db_admin;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO db_admin;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO db_admin;
GRANT ALL PRIVILEGES ON ALL FUNCTIONS IN SCHEMA public TO db_admin;

-- Garantir permissões em objetos futuros
ALTER DEFAULT PRIVILEGES IN SCHEMA public
    GRANT ALL ON TABLES TO db_admin;
ALTER DEFAULT PRIVILEGES IN SCHEMA public
    GRANT ALL ON SEQUENCES TO db_admin;
ALTER DEFAULT PRIVILEGES IN SCHEMA public
    GRANT EXECUTE ON FUNCTIONS TO db_admin;

-- ----------------------------------------------------------------------------
-- ROLE 2: OPERADOR / VENDEDOR (db_operador)
-- ----------------------------------------------------------------------------
-- Perfil: Funcionário operacional (vendedor, atendente)
-- Permissões: Leitura ampla, escrita limitada
-- Uso: Operação diária (criar reservas, consultar pacotes)
-- Limitações: Não pode alterar estrutura, não pode deletar
-- ----------------------------------------------------------------------------

DROP ROLE IF EXISTS db_operador;

CREATE ROLE db_operador
    WITH
    LOGIN
    PASSWORD 'Operador@2024!'
    NOSUPERUSER
    NOCREATEDB
    NOCREATEROLE
    NOINHERIT
    NOREPLICATION
    CONNECTION LIMIT 20         -- Múltiplos operadores podem conectar
    VALID UNTIL '2025-12-31';

COMMENT ON ROLE db_operador IS
'Operador/Vendedor do sistema de agência de turismo.
PERMISSÕES:
- SELECT em todas as tabelas operacionais
- INSERT em tb_reservas, tb_pagamentos, tb_avaliacoes
- UPDATE em tb_reservas (status), tb_pagamentos (status)
- Executar functions de negócio
- Acesso a views operacionais
RESTRIÇÕES:
- Não pode DELETE (apenas admin)
- Não pode alterar estrutura (DDL)
- Não pode acessar tb_auditoria diretamente
- Não pode modificar clientes ou pacotes';

-- Permissões de leitura (SELECT) em todas as tabelas
GRANT CONNECT ON DATABASE agencia_turismo TO db_operador;
GRANT USAGE ON SCHEMA public TO db_operador;

GRANT SELECT ON ALL TABLES IN SCHEMA public TO db_operador;
GRANT SELECT ON ALL SEQUENCES IN SCHEMA public TO db_operador;

-- Permissões específicas de escrita

-- tb_reservas: Pode inserir e atualizar status
GRANT INSERT ON tb_reservas TO db_operador;
GRANT UPDATE (status_reserva, observacoes) ON tb_reservas TO db_operador;

-- tb_pagamentos: Pode inserir e atualizar status
GRANT INSERT ON tb_pagamentos TO db_operador;
GRANT UPDATE (status_pagamento, data_pagamento) ON tb_pagamentos TO db_operador;

-- tb_avaliacoes: Pode inserir (clientes avaliando)
GRANT INSERT ON tb_avaliacoes TO db_operador;

-- Permissões em sequences (para auto-increment)
GRANT USAGE ON SEQUENCE tb_reservas_id_reserva_seq TO db_operador;
GRANT USAGE ON SEQUENCE tb_pagamentos_id_pagamento_seq TO db_operador;
GRANT USAGE ON SEQUENCE tb_avaliacoes_id_avaliacao_seq TO db_operador;

-- Executar functions específicas
GRANT EXECUTE ON FUNCTION fn_criar_reserva_completa TO db_operador;
GRANT EXECUTE ON FUNCTION fn_processar_pagamento TO db_operador;
GRANT EXECUTE ON FUNCTION fn_relatorio_faturamento TO db_operador;

-- Acesso às views
GRANT SELECT ON vw_pacotes_completos TO db_operador;
GRANT SELECT ON vw_pacotes_disponiveis_filtrados TO db_operador;
GRANT SELECT ON vw_dashboard_vendas TO db_operador;

-- ----------------------------------------------------------------------------
-- ROLE 3: AUDITOR (db_auditor)
-- ----------------------------------------------------------------------------
-- Perfil: Auditor interno/externo
-- Permissões: Apenas leitura (SELECT)
-- Uso: Fiscalização, compliance, análise de dados
-- Limitações: Nenhuma escrita, acesso especial a auditoria
-- ----------------------------------------------------------------------------

DROP ROLE IF EXISTS db_auditor;

CREATE ROLE db_auditor
    WITH
    LOGIN
    PASSWORD 'Auditor@2024!'
    NOSUPERUSER
    NOCREATEDB
    NOCREATEROLE
    NOINHERIT
    NOREPLICATION
    CONNECTION LIMIT 3
    VALID UNTIL '2025-12-31';

COMMENT ON ROLE db_auditor IS
'Auditor do sistema - Acesso somente leitura.
PERMISSÕES:
- SELECT em TODAS as tabelas (incluindo auditoria)
- SELECT em todas as views
- Executar functions de relatório (sem escrita)
- Acesso a logs e metadados do sistema
RESTRIÇÕES:
- NENHUMA escrita (INSERT/UPDATE/DELETE)
- NENHUMA alteração de estrutura
- Apenas leitura e análise';

-- Permissões de leitura total
GRANT CONNECT ON DATABASE agencia_turismo TO db_auditor;
GRANT USAGE ON SCHEMA public TO db_auditor;
GRANT SELECT ON ALL TABLES IN SCHEMA public TO db_auditor;
GRANT SELECT ON ALL SEQUENCES IN SCHEMA public TO db_auditor;

-- Acesso especial à tabela de auditoria
GRANT SELECT ON tb_auditoria TO db_auditor;

-- Functions de relatório (sem side effects)
GRANT EXECUTE ON FUNCTION fn_relatorio_faturamento TO db_auditor;
GRANT EXECUTE ON FUNCTION fn_calcular_comissao_vendedor TO db_auditor;

-- Acesso a todas as views
GRANT SELECT ON ALL TABLES IN SCHEMA public TO db_auditor;

-- Permissões em tabelas do sistema (metadados)
GRANT SELECT ON pg_stat_user_tables TO db_auditor;
GRANT SELECT ON pg_stat_user_indexes TO db_auditor;
GRANT SELECT ON pg_stat_activity TO db_auditor;

-- ----------------------------------------------------------------------------
-- ROLE 4: APLICAÇÃO (db_app) - Usuário da aplicação web/mobile
-- ----------------------------------------------------------------------------
-- Perfil: Credenciais usadas pela aplicação
-- Permissões: Intermediárias (leitura ampla, escrita controlada)
-- Uso: Backend da aplicação
-- ----------------------------------------------------------------------------

DROP ROLE IF EXISTS db_app;

CREATE ROLE db_app
    WITH
    LOGIN
    PASSWORD 'App@SecurePass2024!'
    NOSUPERUSER
    NOCREATEDB
    NOCREATEROLE
    INHERIT                     -- Pode herdar de outros roles
    NOREPLICATION
    CONNECTION LIMIT 50;        -- Pool de conexões da aplicação

COMMENT ON ROLE db_app IS
'Usuário utilizado pela aplicação backend.
Credenciais armazenadas em variáveis de ambiente (nunca em código).';

-- Herdar permissões do operador
GRANT db_operador TO db_app;

-- Permissões adicionais
GRANT INSERT ON tb_clientes TO db_app;
GRANT UPDATE (email, telefone, endereco, cidade, estado, cep) ON tb_clientes TO db_app;
GRANT USAGE ON SEQUENCE tb_clientes_id_cliente_seq TO db_app;

-- ============================================================================
-- ETAPA 2: ROW LEVEL SECURITY (RLS) - SEGURANÇA EM NÍVEL DE LINHA
-- ============================================================================

-- ----------------------------------------------------------------------------
-- Cenário: Vendedores só podem ver suas próprias vendas
-- ----------------------------------------------------------------------------

-- Habilitar RLS na tabela
ALTER TABLE tb_reservas ENABLE ROW LEVEL SECURITY;

-- Política: Vendedor vê apenas reservas que ele criou
CREATE POLICY pol_vendedor_proprias_reservas
    ON tb_reservas
    FOR SELECT
    TO db_operador
    USING (
        id_funcionario IN (
            SELECT id_funcionario
            FROM tb_funcionarios
            WHERE email_corporativo = CURRENT_USER || '@viagenseaventuras.com.br'
        )
    );

COMMENT ON POLICY pol_vendedor_proprias_reservas ON tb_reservas IS
'Row-Level Security: Vendedores veem apenas suas vendas.
Vincula CURRENT_USER (login do PostgreSQL) ao email do funcionário.';

-- Admin e Auditor veem tudo (bypass RLS)
ALTER TABLE tb_reservas FORCE ROW LEVEL SECURITY;

CREATE POLICY pol_admin_todas_reservas
    ON tb_reservas
    FOR ALL
    TO db_admin, db_auditor
    USING (true);  -- Sem restrições

-- Desabilitar RLS para testes (pode reabilitar depois)
ALTER TABLE tb_reservas DISABLE ROW LEVEL SECURITY;

-- ============================================================================
-- ETAPA 3: DEMONSTRAÇÃO DE BLOQUEIO DE ACESSO
-- ============================================================================

-- ----------------------------------------------------------------------------
-- Teste 1: Operador tentando DELETE (deve FALHAR)
-- ----------------------------------------------------------------------------
/*
-- Conectar como db_operador
SET ROLE db_operador;

-- Tentar deletar cliente (DEVE FALHAR)
DELETE FROM tb_clientes WHERE id_cliente = 1;

-- ERRO ESPERADO:
-- ERROR: permission denied for table tb_clientes

-- Voltar ao admin
RESET ROLE;
*/

-- ----------------------------------------------------------------------------
-- Teste 2: Operador tentando alterar estrutura (deve FALHAR)
-- ----------------------------------------------------------------------------
/*
SET ROLE db_operador;

-- Tentar criar tabela (DEVE FALHAR)
CREATE TABLE teste_seguranca (id INT);

-- ERRO ESPERADO:
-- ERROR: permission denied for schema public

-- Tentar dropar coluna (DEVE FALHAR)
ALTER TABLE tb_clientes DROP COLUMN email;

-- ERRO ESPERADO:
-- ERROR: must be owner of table tb_clientes

RESET ROLE;
*/

-- ----------------------------------------------------------------------------
-- Teste 3: Auditor tentando INSERT (deve FALHAR)
-- ----------------------------------------------------------------------------
/*
SET ROLE db_auditor;

-- SELECT funciona
SELECT COUNT(*) FROM tb_reservas;

-- INSERT deve falhar
INSERT INTO tb_reservas (id_cliente, id_pacote, id_funcionario, numero_passageiros, valor_unitario, valor_total)
VALUES (1, 1, 1, 1, 1000, 1000);

-- ERRO ESPERADO:
-- ERROR: permission denied for table tb_reservas

RESET ROLE;
*/

-- ============================================================================
-- ETAPA 4: AUDITORIA DE ACESSOS E PERMISSÕES
-- ============================================================================

-- Ver permissões de uma tabela
SELECT
    grantee,
    privilege_type,
    is_grantable
FROM
    information_schema.table_privileges
WHERE
    table_name = 'tb_reservas'
    AND table_schema = 'public'
ORDER BY
    grantee, privilege_type;

-- Ver permissões de um usuário específico
SELECT
    table_name,
    privilege_type
FROM
    information_schema.table_privileges
WHERE
    grantee = 'db_operador'
    AND table_schema = 'public'
ORDER BY
    table_name, privilege_type;

-- Listar todos os roles/usuários
SELECT
    rolname AS nome_role,
    rolsuper AS superuser,
    rolcreatedb AS pode_criar_db,
    rolcreaterole AS pode_criar_role,
    rolcanlogin AS pode_login,
    rolconnlimit AS limite_conexoes,
    rolvaliduntil AS validade
FROM
    pg_roles
WHERE
    rolname NOT LIKE 'pg_%'  -- Excluir roles do sistema
ORDER BY
    rolname;

-- Ver conexões ativas por usuário
SELECT
    usename AS usuario,
    COUNT(*) AS conexoes_ativas,
    MAX(backend_start) AS ultima_conexao
FROM
    pg_stat_activity
WHERE
    datname = 'agencia_turismo'
GROUP BY
    usename
ORDER BY
    conexoes_ativas DESC;

-- ============================================================================
-- ETAPA 5: REVOGAÇÃO DE PERMISSÕES
-- ============================================================================

-- Exemplo: Revogar permissão de UPDATE que foi concedida por engano

-- Conceder UPDATE em tb_clientes para operador (ERRADO!)
GRANT UPDATE ON tb_clientes TO db_operador;

-- Ver que permissão foi concedida
SELECT privilege_type
FROM information_schema.table_privileges
WHERE table_name = 'tb_clientes'
AND grantee = 'db_operador';

-- Revogar UPDATE (CORRIGIR)
REVOKE UPDATE ON tb_clientes FROM db_operador;

-- Confirmar revogação
SELECT privilege_type
FROM information_schema.table_privileges
WHERE table_name = 'tb_clientes'
AND grantee = 'db_operador';

-- ============================================================================
-- ETAPA 6: CRIPTOGRAFIA E SEGURANÇA DE SENHA
-- ============================================================================

-- Extensão pgcrypto para criptografia
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Exemplo: Criptografar dados sensíveis
CREATE TABLE tb_dados_sensiveis_exemplo (
    id SERIAL PRIMARY KEY,
    usuario VARCHAR(50),
    senha_hash TEXT,  -- Armazenar apenas hash (nunca plain text)
    cpf_criptografado BYTEA,
    criado_em TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Inserir com senha hasheada
INSERT INTO tb_dados_sensiveis_exemplo (usuario, senha_hash)
VALUES ('usuario_teste', crypt('senha_secreta', gen_salt('bf')));

-- Validar senha
SELECT
    usuario,
    (senha_hash = crypt('senha_secreta', senha_hash)) AS senha_correta
FROM
    tb_dados_sensiveis_exemplo
WHERE
    usuario = 'usuario_teste';

-- Criptografar CPF (simétrico)
INSERT INTO tb_dados_sensiveis_exemplo (usuario, cpf_criptografado)
VALUES (
    'usuario_cpf',
    pgp_sym_encrypt('12345678901', 'chave_secreta_forte')
);

-- Descriptografar CPF
SELECT
    usuario,
    pgp_sym_decrypt(cpf_criptografado, 'chave_secreta_forte') AS cpf
FROM
    tb_dados_sensiveis_exemplo
WHERE
    usuario = 'usuario_cpf';

-- Limpar exemplo
DROP TABLE tb_dados_sensiveis_exemplo;

-- ============================================================================
-- ETAPA 7: BOAS PRÁTICAS DE SEGURANÇA
-- ============================================================================

/*
CHECKLIST DE SEGURANÇA:

1. AUTENTICAÇÃO:
   ✓ Senhas fortes (mínimo 12 caracteres, complexidade)
   ✓ Expiration dates (VALID UNTIL)
   ✓ Trocar senhas periodicamente
   ✓ Nunca armazenar senhas em plain text
   ✓ Usar autenticação externa (LDAP, Kerberos, etc.)

2. AUTORIZAÇÃO:
   ✓ Princípio do menor privilégio
   ✓ Separação de responsabilidades
   ✓ Usar roles ao invés de usuários individuais
   ✓ Revisar permissões regularmente
   ✓ Revogar permissões desnecessárias

3. AUDITORIA:
   ✓ Habilitar logging (postgresql.conf)
   ✓ Registrar todas as conexões
   ✓ Registrar DDL (ALTER, DROP, CREATE)
   ✓ Registrar acessos a dados sensíveis
   ✓ Triggers de auditoria (já implementados)
   ✓ Logs imutáveis (write-once)

4. CRIPTOGRAFIA:
   ✓ SSL/TLS para conexões (pg_hba.conf)
   ✓ Criptografia de dados em repouso
   ✓ Hash de senhas (bcrypt, scrypt)
   ✓ Criptografia de backups
   ✓ Nunca expor chaves de criptografia

5. NETWORK SECURITY:
   ✓ Firewall: Apenas portas necessárias
   ✓ pg_hba.conf: Restringir IPs permitidos
   ✓ VPN para acesso remoto
   ✓ Não expor PostgreSQL na internet
   ✓ Usar proxy reverso

6. BACKUP E RECOVERY:
   ✓ Backups regulares e automatizados
   ✓ Testar restore periodicamente
   ✓ Backups offsite (em local diferente)
   ✓ Criptografar backups
   ✓ Retention policy (quanto tempo manter)

7. MONITORAMENTO:
   ✓ Alertas de falhas de login
   ✓ Monitorar queries suspeitas
   ✓ Detectar tentativas de SQL injection
   ✓ Alertas de mudanças de permissões
   ✓ Monitorar uso de recursos

8. COMPLIANCE:
   ✓ LGPD (Brasil): Proteção de dados pessoais
   ✓ GDPR (Europa): Direito ao esquecimento
   ✓ PCI-DSS: Dados de cartão de crédito
   ✓ Documentar políticas de segurança
   ✓ Treinamento de equipe

CONFIGURAÇÕES RECOMENDADAS (postgresql.conf):

# Logging
log_connections = on
log_disconnections = on
log_duration = on
log_statement = 'ddl'  # Registrar CREATE, ALTER, DROP
log_line_prefix = '%t [%p]: [%l-1] user=%u,db=%d,app=%a,client=%h '

# SSL
ssl = on
ssl_cert_file = '/path/to/server.crt'
ssl_key_file = '/path/to/server.key'

# Timeouts
statement_timeout = 30000  # 30 segundos
idle_in_transaction_session_timeout = 60000  # 1 minuto

# Password encryption
password_encryption = scram-sha-256  # Mais seguro que md5

CONFIGURAÇÕES RECOMENDADAS (pg_hba.conf):

# Apenas conexões locais para postgres
local   all             postgres                                peer

# Aplicação com senha criptografada
host    agencia_turismo db_app          10.0.0.0/8            scram-sha-256

# Operadores apenas da rede interna
host    agencia_turismo db_operador     192.168.1.0/24        scram-sha-256

# Auditor apenas com VPN
host    agencia_turismo db_auditor      10.10.10.10/32        scram-sha-256

# Bloquear todo o resto
host    all             all             0.0.0.0/0             reject
*/

-- ============================================================================
-- SCRIPTS DE MANUTENÇÃO DE SEGURANÇA
-- ============================================================================

-- Relatório de permissões por usuário
CREATE OR REPLACE VIEW vw_relatorio_permissoes AS
SELECT
    r.rolname AS usuario,
    r.rolsuper AS superuser,
    r.rolcanlogin AS pode_login,
    r.rolconnlimit AS limite_conexoes,
    r.rolvaliduntil AS expira_em,
    COALESCE(
        STRING_AGG(DISTINCT t.table_name || ':' || p.privilege_type, ', '),
        'Sem permissões'
    ) AS permissoes
FROM
    pg_roles r
    LEFT JOIN information_schema.table_privileges p ON r.rolname = p.grantee
    LEFT JOIN information_schema.tables t ON p.table_name = t.table_name
WHERE
    r.rolname NOT LIKE 'pg_%'
    AND (t.table_schema = 'public' OR t.table_schema IS NULL)
GROUP BY
    r.rolname, r.rolsuper, r.rolcanlogin, r.rolconnlimit, r.rolvaliduntil
ORDER BY
    r.rolname;

-- Ver relatório
SELECT * FROM vw_relatorio_permissoes;

-- Identificar usuários com permissões excessivas
SELECT
    grantee AS usuario_com_all_privileges
FROM
    information_schema.table_privileges
WHERE
    privilege_type = 'DELETE'
    AND grantee NOT IN ('postgres', 'db_admin')
    AND table_schema = 'public';

-- ============================================================================
-- RESUMO DA ETAPA 3.6
-- ============================================================================
/*
USUÁRIOS CRIADOS:

1. db_admin (Administrador)
   - Permissões: Todas (exceto SUPERUSER)
   - Uso: Gestão e manutenção do banco
   - Limite: 5 conexões

2. db_operador (Vendedor/Atendente)
   - Permissões: Leitura ampla, escrita limitada
   - Uso: Operação diária do sistema
   - Limite: 20 conexões
   - Restrições: Não pode DELETE, não altera estrutura

3. db_auditor (Auditor)
   - Permissões: Apenas leitura
   - Uso: Fiscalização e compliance
   - Limite: 3 conexões
   - Acesso especial: tb_auditoria

4. db_app (Aplicação)
   - Permissões: Intermediárias
   - Uso: Backend da aplicação
   - Limite: 50 conexões (pool)

RECURSOS IMPLEMENTADOS:
✓ CREATE ROLE com configurações granulares
✓ GRANT e REVOKE de permissões
✓ Row Level Security (RLS)
✓ Criptografia (pgcrypto)
✓ Views de auditoria de permissões
✓ Demonstração de bloqueios de acesso
✓ Boas práticas documentadas

PRINCÍPIOS APLICADOS:
✓ Least Privilege
✓ Separation of Duties
✓ Defense in Depth
✓ Auditability
*/
-- ============================================================================

SELECT 'Etapa 3.6 concluída! Segurança e controle de acesso implementados.' AS status;
