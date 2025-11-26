# 🎯 PROJETO: SISTEMA DE BANCO DE DADOS PARA AGÊNCIA DE TURISMO

**Empresa:** Viagens & Aventuras Ltda
**SGBD:** PostgreSQL
**Disciplina:** Banco de Dados Avançados 2025/2
**Professor:** Michel Junio Ferreira Rosa
**Instituição:** Centro Universitário de Brasília (CEUB)

---

## 📋 SUMÁRIO

1. [Visão Geral](#visão-geral)
2. [Estrutura do Projeto](#estrutura-do-projeto)
3. [Requisitos](#requisitos)
4. [Instruções de Execução](#instruções-de-execução)
5. [Conteúdo de Cada Etapa](#conteúdo-de-cada-etapa)
6. [Modelagem do Banco de Dados](#modelagem-do-banco-de-dados)
7. [Recursos Implementados](#recursos-implementados)
8. [Autores](#autores)

---

## 🎯 VISÃO GERAL

Este projeto implementa um **sistema completo de banco de dados** para uma agência de turismo fictícia, abrangendo desde a modelagem conceitual até otimização avançada de performance.

### Objetivos do Projeto

- ✅ Aplicar conceitos de modelagem relacional (3ª Forma Normal)
- ✅ Implementar recursos avançados (Views, Triggers, Functions)
- ✅ Demonstrar controle de concorrência e transações
- ✅ Aplicar segurança e controle de acesso (DCL)
- ✅ Otimizar performance com índices e tuning
- ✅ Documentar todas as decisões técnicas

---

## 📂 ESTRUTURA DO PROJETO

```
ProjetoDB/
│
├── README.md                              # Este arquivo
├── proposta_proj_bd2_mat_not.pdf         # Proposta original do projeto
│
├── etapa1_modelagem_criacao.sql          # DDL: Criação do banco e tabelas
├── etapa2_populacao_consultas.sql        # DML: Inserção de dados e queries
│
├── etapa3_1_views.sql                    # 3 Views (simples, agregada, filtrada)
├── etapa3_2_triggers.sql                 # 4 Triggers (auditoria, validação)
├── etapa3_3_functions.sql                # 4 Functions (procedimentos)
├── etapa3_4_indices_otimizacao.sql       # 6 Índices + EXPLAIN ANALYZE
├── etapa3_5_transacoes_concorrencia.sql  # Transações, Locks, Níveis de Isolamento
├── etapa3_6_seguranca_controle_acesso.sql# 4 Usuários + DCL (GRANT/REVOKE)
└── etapa3_7_performance_tuning.sql       # Otimização de 2 consultas lentas
```

---

## 💻 REQUISITOS

### Software Necessário

- **PostgreSQL 12+** (recomendado: PostgreSQL 14 ou superior)
- **Cliente PostgreSQL:**
  - `psql` (linha de comando)
  - pgAdmin 4 (interface gráfica)
  - DBeaver ou outro cliente SQL

### Sistema Operacional

- Windows, Linux ou macOS

---

## 🚀 INSTRUÇÕES DE EXECUÇÃO

### Opção 1: Execução Completa (Todos os Scripts)

Execute os scripts **na ordem** usando o terminal `psql`:

```bash
# 1. Conectar ao PostgreSQL
psql -U postgres

# 2. Executar cada etapa em sequência
\i C:/Users/Administrator/Documents/ProjetoDB/etapa1_modelagem_criacao.sql
\i C:/Users/Administrator/Documents/ProjetoDB/etapa2_populacao_consultas.sql
\i C:/Users/Administrator/Documents/ProjetoDB/etapa3_1_views.sql
\i C:/Users/Administrator/Documents/ProjetoDB/etapa3_2_triggers.sql
\i C:/Users/Administrator/Documents/ProjetoDB/etapa3_3_functions.sql
\i C:/Users/Administrator/Documents/ProjetoDB/etapa3_4_indices_otimizacao.sql
\i C:/Users/Administrator/Documents/ProjetoDB/etapa3_5_transacoes_concorrencia.sql
\i C:/Users/Administrator/Documents/ProjetoDB/etapa3_6_seguranca_controle_acesso.sql
\i C:/Users/Administrator/Documents/ProjetoDB/etapa3_7_performance_tuning.sql
```

**Nota:** Ajuste os caminhos se necessário (use `/` em vez de `\` no psql).

### Opção 2: Execução Usando pgAdmin

1. Abrir pgAdmin 4
2. Conectar ao servidor PostgreSQL
3. Criar um novo Query Tool (botão direito no servidor → Query Tool)
4. Abrir cada arquivo `.sql` (File → Open)
5. Executar com `F5` ou botão `Execute`

### Opção 3: Execução Individual de Etapas

Você pode executar apenas etapas específicas:

```bash
# Conectar ao banco (após criar)
psql -U postgres -d agencia_turismo

# Executar etapa específica
\i C:/Users/Administrator/Documents/ProjetoDB/etapa3_1_views.sql
```

---

## 📚 CONTEÚDO DE CADA ETAPA

### 📄 **Etapa 1: Modelagem e Criação do Banco**

**Arquivo:** `etapa1_modelagem_criacao.sql`

- ✅ Criação do banco de dados `agencia_turismo`
- ✅ Criação de 10 tabelas normalizadas (3ª Forma Normal)
- ✅ Definição de chaves primárias (PK) e estrangeiras (FK)
- ✅ Constraints de validação (CHECK, UNIQUE, NOT NULL)
- ✅ Comentários detalhados em todas as tabelas e colunas
- ✅ Índices básicos em FKs

**Tabelas Criadas:**
- `tb_clientes` - Cadastro de clientes
- `tb_funcionarios` - Funcionários da agência
- `tb_destinos` - Catálogo de destinos turísticos
- `tb_hoteis` - Hotéis parceiros
- `tb_transportes` - Meios de transporte
- `tb_pacotes_turisticos` - Pacotes completos
- `tb_reservas` - Vendas/reservas
- `tb_pagamentos` - Controle financeiro
- `tb_avaliacoes` - Feedback de clientes
- `tb_auditoria` - Logs de auditoria

---

### 📄 **Etapa 2: População de Dados e Consultas**

**Arquivo:** `etapa2_populacao_consultas.sql`

- ✅ Inserção de dados (mínimo 10 registros por tabela)
  - 15 Clientes
  - 12 Funcionários
  - 15 Destinos (nacionais e internacionais)
  - 18 Hotéis
  - 10 Transportes
  - 15 Pacotes Turísticos
  - 20 Reservas
  - 25 Pagamentos
  - 12 Avaliações

- ✅ **10 Consultas SQL Complexas:**
  1. Performance de vendedores (JOINs, GROUP BY)
  2. Top 5 pacotes mais vendidos (agregações)
  3. Análise financeira de pagamentos (CASE, agregações condicionais)
  4. Clientes VIP com ranking (Window Functions)
  5. Ocupação de pacotes (subconsultas, percentuais)
  6. Destinos por categoria (análise de preferências)
  7. Formas de pagamento preferidas
  8. Pacotes com melhor custo-benefício (subconsultas correlacionadas)
  9. Análise de descontos concedidos
  10. Dashboard executivo (consulta consolidada)

---

### 📄 **Etapa 3.1: Views**

**Arquivo:** `etapa3_1_views.sql`

**3 Views Criadas:**

1. **`vw_pacotes_completos`** (View Simples)
   - Consolidação de pacotes com destinos, hotéis e transportes
   - Simplifica queries frequentes
   - Elimina necessidade de JOINs repetidos

2. **`vw_dashboard_vendas`** (View com Agregações)
   - Métricas de vendas por vendedor, destino e período
   - KPIs pré-calculados (receita, ticket médio, desconto)
   - Ideal para dashboards executivos

3. **`vw_pacotes_disponiveis_filtrados`** (View com Subconsultas)
   - Cálculo dinâmico de vagas disponíveis
   - Integração com avaliações
   - Sistema de classificação de qualidade
   - Filtros automatizados (apenas pacotes disponíveis)

---

### 📄 **Etapa 3.2: Triggers**

**Arquivo:** `etapa3_2_triggers.sql`

**4 Triggers Criados:**

1. **`trg_auditoria_reservas`** (Auditoria)
   - Registra INSERT, UPDATE, DELETE em tb_auditoria
   - Armazena dados antes/depois em JSON
   - Compliance e rastreabilidade

2. **`trg_validar_vagas_pacote`** (Validação de Regra de Negócio)
   - Impede overbooking (reservas além da capacidade)
   - Valida disponibilidade de vagas
   - Lança exceção com mensagem clara

3. **`trg_atualizar_status_pacote`** (Automação)
   - Atualiza status do pacote (DISPONIVEL → ESGOTADO)
   - Executa automaticamente após reservas
   - Mantém consistência

4. **`trg_validar_valor_reserva`** (Validação Financeira)
   - Valida cálculo do valor total
   - Previne fraudes e erros
   - Corrige arredondamentos automaticamente

---

### 📄 **Etapa 3.3: Functions (Stored Procedures)**

**Arquivo:** `etapa3_3_functions.sql`

**4 Functions Criadas:**

1. **`fn_criar_reserva_completa()`**
   - Parâmetros: 6 IN, 4 OUT
   - Cria reserva com validações completas
   - Verifica cliente, pacote, funcionário, vagas
   - Calcula valor total automaticamente

2. **`fn_relatorio_faturamento()`**
   - Parâmetros: 2 IN (datas), retorna TABLE
   - Relatório financeiro consolidado por período
   - Métricas: receita, descontos, ticket médio, taxa de recebimento

3. **`fn_calcular_comissao_vendedor()`**
   - Parâmetros: 3 IN, 6 OUT
   - Calcula comissão com bonificação progressiva
   - Regras: 5% base, +2% se >R$50k, +5% se >R$100k

4. **`fn_processar_pagamento()`**
   - Parâmetros: 4 IN, 4 OUT
   - Processa pagamento parcelado
   - Cria múltiplas parcelas com vencimentos mensais

---

### 📄 **Etapa 3.4: Índices e Otimização**

**Arquivo:** `etapa3_4_indices_otimizacao.sql`

**6 Índices Estratégicos:**

1. **`idx_reservas_data_reserva`** (Simples)
   - B-Tree descendente em data_reserva
   - Otimiza ORDER BY e filtros cronológicos

2. **`idx_reservas_data_status`** (Composto)
   - Colunas: (data_reserva, status_reserva)
   - Filtros múltiplos otimizados

3. **`idx_pagamentos_numero_transacao_unique`** (Único)
   - Garante unicidade + performance
   - Previne transações duplicadas

4. **`idx_pacotes_destino_status`** (Composto)
   - Busca de pacotes por destino e status

5. **`idx_reservas_ativas_cliente`** (Parcial)
   - Apenas reservas não canceladas
   - Índice menor e mais rápido

6. **`idx_reservas_pacote_passageiros`** (Covering)
   - Index-only scan em agregações
   - Extremamente eficiente

**Análises:**
- EXPLAIN ANALYZE antes e depois de cada índice
- Comparação de custos e tempos de execução
- Ganhos: 50-95% de redução no tempo

---

### 📄 **Etapa 3.5: Transações e Concorrência**

**Arquivo:** `etapa3_5_transacoes_concorrencia.sql`

**Conceitos Demonstrados:**

1. **Transações ACID**
   - BEGIN, COMMIT, ROLLBACK
   - SAVEPOINT (rollback parcial)
   - Atomicidade e consistência

2. **Locks (Bloqueios)**
   - SELECT FOR UPDATE (pessimistic locking)
   - LOCK TABLE (table-level locks)
   - Row-level vs table-level

3. **Níveis de Isolamento**
   - READ COMMITTED (padrão)
   - REPEATABLE READ
   - SERIALIZABLE
   - Comparação de trade-offs

4. **Problemas de Concorrência**
   - Lost Update (atualização perdida)
   - Non-Repeatable Read
   - Phantom Read
   - Deadlock (detecção e prevenção)

5. **Cenários Práticos**
   - Simulação de 2 sessões concorrentes
   - Demonstração de bloqueios
   - Função `fn_reservar_pacote_seguro()` com locks

---

### 📄 **Etapa 3.6: Segurança e Controle de Acesso**

**Arquivo:** `etapa3_6_seguranca_controle_acesso.sql`

**4 Usuários/Roles Criados:**

1. **`db_admin`** (Administrador)
   - Permissões: Todas (DDL, DML, DCL)
   - Limite: 5 conexões
   - Uso: Gestão completa do banco

2. **`db_operador`** (Vendedor/Atendente)
   - Permissões: SELECT em tudo, INSERT/UPDATE limitado
   - Restrições: Não pode DELETE, não altera estrutura
   - Limite: 20 conexões

3. **`db_auditor`** (Auditor)
   - Permissões: Apenas SELECT (leitura total)
   - Acesso especial: tb_auditoria
   - Limite: 3 conexões

4. **`db_app`** (Aplicação Backend)
   - Permissões: Intermediárias
   - Herda de db_operador
   - Limite: 50 conexões (pool)

**Recursos de Segurança:**
- ✅ GRANT e REVOKE granulares
- ✅ Row Level Security (RLS)
- ✅ Criptografia (pgcrypto)
- ✅ Views de auditoria de permissões
- ✅ Demonstração de bloqueio de acesso
- ✅ Boas práticas documentadas

---

### 📄 **Etapa 3.7: Performance Tuning**

**Arquivo:** `etapa3_7_performance_tuning.sql`

**2 Consultas Otimizadas:**

1. **Relatório de Vendas com Múltiplos JOINs**
   - Problema: Subconsultas correlacionadas (N+1 queries)
   - Solução: CTEs com pré-agregação + LEFT JOINs
   - Ganho: **85% de redução** (~100ms → ~15ms)

2. **Agregação Complexa sem Índices**
   - Problema: EXTRACT sem índice, agregações pesadas
   - Solução: Índices funcionais + FILTER(WHERE)
   - Ganho: **70% de redução** (~80ms → ~25ms)

**Bônus: View Materializada**
- `mv_vendas_mensais`: Dados históricos pré-calculados
- Ganho: **98% de redução** (~80ms → ~2ms)

**Técnicas Aplicadas:**
- ✅ CTEs (Common Table Expressions)
- ✅ Índices funcionais
- ✅ Window Functions
- ✅ LATERAL JOINs
- ✅ Views materializadas
- ✅ VACUUM e ANALYZE
- ✅ pg_stat_statements (monitoramento)

---

## 🗂️ MODELAGEM DO BANCO DE DADOS

### Diagrama Entidade-Relacionamento (DER)

```
tb_clientes (1) ----< (N) tb_reservas (N) >---- (1) tb_pacotes_turisticos
                                                           |
tb_funcionarios (1) ----< (N) tb_reservas                  |
                                                           |
tb_reservas (1) ----< (N) tb_pagamentos          +--------+--------+
                                                  |        |        |
tb_clientes (1) ----< (N) tb_avaliacoes          |        |        |
                                                  v        v        v
tb_pacotes_turisticos (1) ----< (N) tb_avaliacoes   tb_destinos  tb_hoteis  tb_transportes
                                                     (1)       (1)       (1)
tb_destinos (1) ----< (N) tb_hoteis                  |         |         |
                                                      v         v         v
                                                   (N) tb_pacotes_turisticos
```

### Normalização (3ª Forma Normal)

✅ **1FN:** Todos os atributos são atômicos (não há grupos repetitivos)
✅ **2FN:** Não há dependências parciais (atributos dependem totalmente da PK)
✅ **3FN:** Não há dependências transitivas (atributos não-chave não dependem de outros não-chave)

---

## 🎯 RECURSOS IMPLEMENTADOS

### ✅ Etapa 1: Modelagem
- [x] 10 tabelas normalizadas
- [x] Chaves primárias e estrangeiras
- [x] Constraints de validação
- [x] Comentários detalhados

### ✅ Etapa 2: População e Consultas
- [x] Mínimo 10 registros por tabela
- [x] 10 consultas SQL complexas
- [x] JOINs, subconsultas, agregações

### ✅ Etapa 3: Recursos Avançados

**3.1 Views:**
- [x] 3 views (simples, agregada, filtrada)

**3.2 Triggers:**
- [x] 4 triggers (auditoria, validação, automação)

**3.3 Functions:**
- [x] 4 functions com parâmetros IN/OUT

**3.4 Índices:**
- [x] 6 índices (simples, composto, único, parcial, covering)
- [x] EXPLAIN ANALYZE antes e depois

**3.5 Transações:**
- [x] BEGIN, COMMIT, ROLLBACK
- [x] Demonstração de locks
- [x] Níveis de isolamento
- [x] Simulação de concorrência

**3.6 Segurança:**
- [x] 4 usuários/roles distintos
- [x] GRANT e REVOKE
- [x] Row Level Security
- [x] Demonstração de bloqueios

**3.7 Performance:**
- [x] 2 consultas otimizadas
- [x] Métricas antes/depois
- [x] View materializada
- [x] Técnicas de tuning

---

## 📊 ESTATÍSTICAS DO PROJETO

| Item | Quantidade |
|------|------------|
| **Tabelas** | 10 |
| **Views** | 3 |
| **Views Materializadas** | 1 |
| **Triggers** | 4 |
| **Functions** | 4 |
| **Índices** | 20+ (básicos + otimizados) |
| **Usuários/Roles** | 4 |
| **Registros Inseridos** | 120+ |
| **Consultas SQL** | 10+ complexas |
| **Linhas de Código SQL** | 5000+ |
| **Comentários** | Extensivos em todos os scripts |

---

## 🏆 DIFERENCIAIS DO PROJETO

1. **Documentação Completa:**
   - Cada linha de código SQL comentada
   - Explicação de decisões técnicas
   - Exemplos de uso

2. **Dados Realistas:**
   - Cenário de agência de turismo
   - Pacotes nacionais e internacionais
   - Relacionamentos complexos

3. **Boas Práticas:**
   - Nomenclatura padronizada (tb_, vw_, fn_, trg_, idx_)
   - Normalização rigorosa (3FN)
   - Constraints de validação
   - Segurança em camadas

4. **Performance:**
   - Análises detalhadas (EXPLAIN ANALYZE)
   - Ganhos mensurados (50-98%)
   - Técnicas modernas (CTEs, Window Functions)

5. **Complexidade:**
   - Triggers com lógica de negócio
   - Functions com múltiplos parâmetros
   - Controle de concorrência avançado
   - View materializada para Big Data

---

## 🧪 TESTANDO O PROJETO

### Testes Funcionais

```sql
-- Conectar ao banco
\c agencia_turismo

-- Testar criação de reserva
SELECT * FROM fn_criar_reserva_completa(
    p_id_cliente := 1,
    p_id_pacote := 5,
    p_id_funcionario := 4,
    p_numero_passageiros := 2,
    p_desconto_percentual := 10
);

-- Testar views
SELECT * FROM vw_pacotes_disponiveis_filtrados
WHERE tipo_turismo = 'PRAIA'
LIMIT 10;

-- Testar relatório
SELECT * FROM fn_relatorio_faturamento('2024-01-01', '2024-12-31');

-- Verificar auditoria
SELECT * FROM tb_auditoria
ORDER BY data_hora DESC
LIMIT 10;

-- Testar segurança (conectar como operador)
SET ROLE db_operador;
SELECT * FROM tb_reservas LIMIT 5;  -- OK
DELETE FROM tb_clientes WHERE id_cliente = 1;  -- DEVE FALHAR
RESET ROLE;
```

---

## 📖 REFERÊNCIAS E RECURSOS

### Documentação Oficial
- [PostgreSQL Documentation](https://www.postgresql.org/docs/)
- [PostgreSQL Tutorial](https://www.postgresqltutorial.com/)

### Ferramentas Úteis
- [pgAdmin 4](https://www.pgadmin.org/) - Interface gráfica
- [DBeaver](https://dbeaver.io/) - Cliente SQL universal
- [SQL Fiddle](http://sqlfiddle.com/) - Testes online

### Livros Recomendados
- "PostgreSQL: Up and Running" - Regina Obe, Leo Hsu
- "The Art of PostgreSQL" - Dimitri Fontaine
- "Mastering PostgreSQL" - Hans-Jürgen Schönig

---

## 👥 AUTORES

**Projeto Acadêmico - Banco de Dados Avançados**
Centro Universitário de Brasília (CEUB)
Faculdade de Tecnologia e Ciências Sociais

**Professor:** Michel Junio Ferreira Rosa
**Período:** 2025/2

---

## 📝 LICENÇA

Este projeto foi desenvolvido para fins **exclusivamente acadêmicos** como parte da disciplina de Banco de Dados Avançados.

**Direitos Autorais:**
- Estrutura do projeto: Centro Universitário de Brasília (CEUB)
- Implementação: Alunos da disciplina
- Uso: Restrito ao contexto educacional

---

## 🚀 PRÓXIMOS PASSOS (Sugestões)

Melhorias futuras que poderiam ser implementadas:

1. **Backend API REST:**
   - Node.js + Express + pg
   - Endpoints para CRUD de reservas
   - Autenticação JWT

2. **Frontend:**
   - React ou Vue.js
   - Dashboard de vendas
   - Sistema de busca de pacotes

3. **Recursos Adicionais:**
   - Particionamento de tabelas grandes
   - Full-text search (pg_trgm)
   - Replicação (master-slave)
   - Backup automatizado

4. **DevOps:**
   - Docker containerization
   - CI/CD com GitHub Actions
   - Monitoramento (Grafana + Prometheus)

---

## 📞 SUPORTE

Para dúvidas ou problemas:

1. Revisar a **documentação inline** (comentários nos scripts)
2. Consultar o arquivo **proposta_proj_bd2_mat_not.pdf**
3. Entrar em contato com o professor da disciplina

---

**⭐ Bom estudo e sucesso no projeto! ⭐**

---

**Última atualização:** Novembro de 2024
**Versão:** 1.0
