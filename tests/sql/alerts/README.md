# Alerts SQL (camada Silver)

Consultas pensadas para uso direto em Databricks Alerts. Cada arquivo retorna uma única linha com a coluna `violations` (inteiro). Configure o alerta para disparar quando `violations > 0`.

## Contexto

Defina o contexto conforme seu ambiente antes de salvar a query no Databricks SQL:

- Com Unity Catalog:
```sql
USE CATALOG workshop_modelagem;  -- ajuste se necessário
USE SCHEMA silver;
```

- Sem Unity Catalog:
```sql
USE DATABASE silver;
```

## Arquivos

- `orders_clean_alert.sql`
- `order_items_clean_alert.sql`
- `products_clean_alert.sql`
- `dim_customer_scd_alert.sql`
- `silver_alert_total.sql` (soma de todas as violações da camada Silver)

## Como configurar um Alert

1. No Databricks SQL, crie uma Query colando o conteúdo de um desses arquivos.
2. Clique em "Alerts" > "Create alert".
3. Escolha a Query, defina a condição: `violations > 0`.
4. Defina a cadência (ex.: a cada 15 min) e os canais de notificação.
