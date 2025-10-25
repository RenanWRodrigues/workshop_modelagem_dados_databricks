-- Alert: silver.orders_clean violations
-- Contexto sugerido:
-- USE CATALOG workshop_modelagem;  -- se usar UC
-- USE SCHEMA silver;               -- ou USE DATABASE silver;

WITH
orders_dup AS (
  SELECT COUNT(*) AS c FROM (
    SELECT order_id FROM orders_clean GROUP BY order_id HAVING COUNT(*) > 1
  ) x
),
orders_nulls AS (
  SELECT COUNT(*) AS c FROM orders_clean
  WHERE order_id IS NULL OR order_date IS NULL OR order_status IS NULL OR total_amount IS NULL
),
orders_status_bad AS (
  SELECT COUNT(*) AS c
  FROM orders_clean
  WHERE UPPER(TRIM(order_status)) NOT IN ('DELIVERED', 'SHIPPED', 'PROCESSING', 'CANCELLED', 'RETURNED')
),
orders_negative AS (
  SELECT COUNT(*) AS c FROM orders_clean WHERE total_amount < 0
)
SELECT
  (SELECT c FROM orders_dup)
+ (SELECT c FROM orders_nulls)
+ (SELECT c FROM orders_status_bad)
+ (SELECT c FROM orders_negative)
  AS violations;
