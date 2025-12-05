# Instrucoes de Execucao e Validacao

## Preparacao Geral
- As etapas podem ser executadas de duas formas:
  1. **psql**: `psql -U <usuario> -h <host> -d <banco> -f arquivo.sql`.
  2. **Interface SQL (ex.: pgAdmin 4)**: abra o Query Tool, copie/cole todo o conteudo do arquivo `.sql`, confirme o banco de destino e execute (botao ▶).
- Sempre configure o cliente para `UTF-8` (`\encoding UTF8` no `psql`, ou "Client Encoding" = `UTF8` no Query Tool).
- Utilize um usuario com privilegios de criacao/alteracao (CREATE DATABASE, CREATE ROLE etc.).

## Etapa 1 – Modelagem e Criacao do Banco (PDF, Secao "Etapa 1")
- **Arquivo**: `etapa1_modelagem_criacao.sql`
- **Via psql**:
  ```bash
  psql -U postgres -h localhost -f etapa1_modelagem_criacao.sql
  ```
- **Via Query Tool/GUI**: abra o banco `postgres`, selecione `File > Open` (ou cole o arquivo completo) e execute.
- **Validacao SQL**:
  ```sql
  SELECT table_schema, table_name
  FROM information_schema.tables
  WHERE table_schema = 'public'
  ORDER BY table_name;
  ```
- **Validacao no pgAdmin 4**: expanda `Schemas > public > Tables` e verifique se todas as tabelas do DER foram criadas.

## Etapa 2 – Populacao e Consultas (PDF, Secao "Etapa 2")
- **Arquivo**: `etapa2_populacao_consultas.sql`
- **Via psql**:
  ```bash
  psql -U postgres -h localhost -d agencia_turismo -f etapa2_populacao_consultas.sql
  ```
- **Via Query Tool/GUI**: conecte-se ao banco `agencia_turismo`, cole o script e execute.
- **Validacao SQL**:
  ```sql
  SELECT 'tb_clientes' AS tabela, COUNT(*) FROM tb_clientes
  UNION ALL
  SELECT 'tb_reservas', COUNT(*) FROM tb_reservas;
  ```
- **Validacao no pgAdmin 4**: execute as consultas de teste do script e analise o painel "Data Output".

## Etapa 3 – Recursos Avancados (PDF, Secao "Etapa 3")
### 3.1 Views
- **Arquivo**: `etapa3_1_views.sql`
- **Via psql**:
  ```bash
  psql -U postgres -h localhost -d agencia_turismo -f etapa3_1_views.sql
  ```
- **Via Query Tool/GUI**: execute o conteudo no banco `agencia_turismo`.
- **Validacao**:
  ```sql
  \dv+ public.*
  SELECT * FROM vw_resumo_reservas LIMIT 5;
  ```
- **pgAdmin 4**: em `Schemas > public > Views`, utilize "View/Edit Data" para conferir o resultado.

### 3.2 Triggers
- **Arquivo**: `etapa3_2_triggers.sql`
- **Executar**: mesmo procedimento (psql ou Query Tool).
- **Validacao**:
  ```sql
  SELECT tgname, relname
  FROM pg_trigger t
  JOIN pg_class c ON c.oid = t.tgrelid
  WHERE c.relname IN ('tb_reservas','tb_pacotes_turisticos')
    AND NOT t.tgisinternal;
  ```
  Em seguida, rode inserts/updates de teste em `tb_reservas` e confira `tb_auditoria`.

### 3.3 Functions
- **Arquivo**: `etapa3_3_functions.sql`
- **Validacao**:
  ```sql
  SELECT * FROM fn_relatorio_faturamento(CURRENT_DATE - INTERVAL '30 days', CURRENT_DATE);
  SELECT * FROM fn_calcular_comissao_vendedor(4, 11, 2024);
  ```
  (Execute via psql ou copiando o bloco para o Query Tool.)

### 3.4 Indices e Otimizacao
- **Arquivo**: `etapa3_4_indices_otimizacao.sql`
- **Validacao**:
  ```sql
  \di+ public.*
  EXPLAIN ANALYZE SELECT * FROM vw_resumo_reservas WHERE status_reserva = 'CONFIRMADA';
  ```
  Compare os planos antes/depois em qualquer cliente SQL.

### 3.5 Transacoes e Concorrencia
- **Arquivo**: `etapa3_5_transacoes_concorrencia.sql`
- **Validacao**:
  1. Abra dois terminais `psql` **ou** duas abas do Query Tool.
  2. Copie/cole os blocos `BEGIN ...` descritos no arquivo em cada sessao e observe os bloqueios/commits.

### 3.6 Seguranca e Controle de Acesso
- **Arquivo**: `etapa3_6_seguranca_controle_acesso.sql`
- **Validacao**:
  ```sql
  \du
  SELECT grantee, privilege_type
  FROM information_schema.role_table_grants
  WHERE table_name = 'tb_reservas';
  ```
  A consulta pode ser executada em qualquer cliente; no pgAdmin verifique tambem "Login/Group Roles".

### 3.7 Performance Tuning
- **Arquivo**: `etapa3_7_performance_tuning.sql`
- **Validacao**:
  ```sql
  EXPLAIN (ANALYZE, BUFFERS) SELECT * FROM vw_resumo_financeiro;
  ```
  Rode via psql (copy/paste) e registre os tempos conforme solicitado no PDF.

## Popular Dados Massivos
- **Arquivo**: `popular_dados_massivos.sql`
- **Via psql**:
  ```bash
  psql -U postgres -h localhost -d agencia_turismo -f popular_dados_massivos.sql
  ```
- **Via Query Tool/GUI**: cole o script inteiro, confirme que `\encoding UTF8` esta definido e execute.
- **Execucao da funcao**:
  - `SELECT popular_dados_massivos();` (modo rapido, padrao p_fast_mode = TRUE).
  - `SELECT popular_dados_massivos(FALSE);` (modo completo, gera os milhoes originais e demanda bem mais tempo).
- **Validacao**:
  ```sql
  SELECT * FROM verificar_tamanho_tabelas();
  ```
  Ou, no pgAdmin, veja o retorno de `SELECT popular_dados_massivos();` e os contadores em "Statistics".

## Execucao Consolidada
- **Arquivo**: `EXECUTAR_TUDO.sql`
- **Via psql**:
  ```bash
  psql -U postgres -h localhost -f EXECUTAR_TUDO.sql
  ```
- **Via Query Tool/GUI**: abra o script principal, verifique que cada `\i` referencia o caminho correto (ajuste se necessario) e execute.
- **Validacao**: repita as consultas-chave (DER, contagem de tabelas, funcoes) para garantir que toda a suite rodou com sucesso.

## Referencias
- `GUIA_RAPIDO.md`: resumo de credenciais e fluxo operacional.
- `proposta_proj_bd2_mat_not.pdf`: documento base com todas as etapas e criterios de avaliacao.
