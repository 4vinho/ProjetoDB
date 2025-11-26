# 🚀 GUIA RÁPIDO DE EXECUÇÃO

## ⚡ Execução Rápida (3 passos)

### 1️⃣ Abrir Terminal PostgreSQL

```bash
# Windows (PowerShell ou CMD)
psql -U postgres

# Linux/Mac
psql -U postgres
```

### 2️⃣ Navegar até a pasta do projeto

```sql
-- Ajustar caminho conforme sua instalação
\cd C:/Users/Administrator/Documents/ProjetoDB
```

### 3️⃣ Executar script consolidado

```sql
\i EXECUTAR_TUDO.sql
```

**Pronto! 🎉** O sistema completo será criado automaticamente.

---

## 📝 Execução Passo a Passo (Alternativa)

Se preferir executar etapa por etapa:

```sql
-- Conectar ao PostgreSQL
psql -U postgres

-- Executar cada etapa
\i etapa1_modelagem_criacao.sql
\i etapa2_populacao_consultas.sql
\i etapa3_1_views.sql
\i etapa3_2_triggers.sql
\i etapa3_3_functions.sql
\i etapa3_4_indices_otimizacao.sql
\i etapa3_5_transacoes_concorrencia.sql
\i etapa3_6_seguranca_controle_acesso.sql
\i etapa3_7_performance_tuning.sql
```

---

## 🧪 Testes Rápidos

Após executar, teste o sistema:

```sql
-- Conectar ao banco criado
\c agencia_turismo

-- 1. Ver pacotes disponíveis
SELECT * FROM vw_pacotes_disponiveis_filtrados LIMIT 5;

-- 2. Criar uma reserva
SELECT * FROM fn_criar_reserva_completa(
    p_id_cliente := 1,
    p_id_pacote := 5,
    p_id_funcionario := 4,
    p_numero_passageiros := 2,
    p_desconto_percentual := 10
);

-- 3. Ver dashboard de vendas
SELECT * FROM vw_dashboard_vendas LIMIT 10;

-- 4. Relatório financeiro
SELECT * FROM fn_relatorio_faturamento('2024-01-01', '2024-12-31');

-- 5. Ver auditoria
SELECT * FROM tb_auditoria ORDER BY data_hora DESC LIMIT 5;
```

---

## 🔍 Comandos Úteis

### Ver tabelas criadas
```sql
\dt
```

### Ver views
```sql
\dv
```

### Ver functions
```sql
\df fn_*
```

### Ver triggers
```sql
SELECT trigger_name, event_object_table
FROM information_schema.triggers
WHERE trigger_schema = 'public';
```

### Ver índices
```sql
\di
```

### Ver usuários/roles
```sql
\du
```

### Descrição de uma tabela
```sql
\d tb_reservas
```

### Sair do psql
```sql
\q
```

---

## 📊 Consultas Úteis

### Top 5 pacotes mais vendidos
```sql
SELECT
    p.nome_pacote,
    d.nome_destino,
    COUNT(r.id_reserva) AS vendas,
    SUM(r.valor_total) AS receita
FROM tb_pacotes_turisticos p
INNER JOIN tb_destinos d ON p.id_destino = d.id_destino
LEFT JOIN tb_reservas r ON p.id_pacote = r.id_pacote
WHERE r.status_reserva = 'CONFIRMADA'
GROUP BY p.id_pacote, p.nome_pacote, d.nome_destino
ORDER BY vendas DESC
LIMIT 5;
```

### Clientes VIP
```sql
SELECT
    c.nome_completo,
    COUNT(r.id_reserva) AS total_compras,
    SUM(r.valor_total) AS valor_gasto
FROM tb_clientes c
INNER JOIN tb_reservas r ON c.id_cliente = r.id_cliente
WHERE r.status_reserva IN ('CONFIRMADA', 'FINALIZADA')
GROUP BY c.id_cliente, c.nome_completo
ORDER BY valor_gasto DESC
LIMIT 10;
```

### Performance de vendedores
```sql
SELECT
    f.nome_completo AS vendedor,
    COUNT(r.id_reserva) AS vendas,
    SUM(r.valor_total) AS faturamento
FROM tb_funcionarios f
INNER JOIN tb_reservas r ON f.id_funcionario = r.id_funcionario
WHERE r.status_reserva = 'CONFIRMADA'
GROUP BY f.id_funcionario, f.nome_completo
ORDER BY faturamento DESC;
```

---

## ⚠️ Troubleshooting

### Erro: "database already exists"
```sql
-- Remover banco existente
DROP DATABASE IF EXISTS agencia_turismo;
-- Executar novamente
\i etapa1_modelagem_criacao.sql
```

### Erro: "role already exists"
```sql
-- Remover roles
DROP ROLE IF EXISTS db_admin;
DROP ROLE IF EXISTS db_operador;
DROP ROLE IF EXISTS db_auditor;
DROP ROLE IF EXISTS db_app;
-- Executar etapa 3.6 novamente
\i etapa3_6_seguranca_controle_acesso.sql
```

### Erro: "permission denied"
```sql
-- Executar como superuser (postgres)
-- Ou conceder permissões necessárias
```

### Consulta lenta
```sql
-- Atualizar estatísticas
ANALYZE;

-- Ver plano de execução
EXPLAIN ANALYZE SELECT ...;
```

---

## 🔐 Teste de Segurança

```sql
-- Conectar como operador
SET ROLE db_operador;

-- Tentar SELECT (deve funcionar)
SELECT * FROM tb_reservas LIMIT 5;

-- Tentar DELETE (deve falhar)
DELETE FROM tb_clientes WHERE id_cliente = 1;
-- ERRO ESPERADO: permission denied

-- Voltar ao admin
RESET ROLE;
```

---

## 📦 Backup Rápido

```bash
# Criar backup do banco
pg_dump -U postgres agencia_turismo > backup_agencia.sql

# Restaurar backup
psql -U postgres < backup_agencia.sql
```

---

## 📞 Ajuda

- **README completo:** Veja `README.md`
- **Documentação inline:** Todos os scripts têm comentários detalhados
- **Proposta original:** `proposta_proj_bd2_mat_not.pdf`

---

## ✅ Checklist de Verificação

Após executar tudo, confirme:

- [ ] Banco `agencia_turismo` criado
- [ ] 10 tabelas existem (`\dt`)
- [ ] 3 views criadas (`\dv`)
- [ ] 4 functions criadas (`\df fn_*`)
- [ ] 4 triggers ativos
- [ ] 4 usuários criados (`\du`)
- [ ] Dados inseridos (SELECT COUNT(*) FROM tb_reservas;)
- [ ] Testes básicos funcionando

---

**🎯 Tudo pronto! Sistema completo e operacional!**
