-- Alert: silver.order_items_clean violations
-- Contexto sugerido:
-- USE CATALOG workshop_modelagem;  -- se usar UC
-- USE SCHEMA silver;               -- ou USE DATABASE silver;

WITH
items_dup AS (
  SELECT COUNT(*) AS c FROM (
    SELECT order_id, product_id FROM order_items_clean GROUP BY order_id, product_id HAVING COUNT(*) > 1
  ) x
),
items_nulls AS (
  SELECT COUNT(*) AS c FROM order_items_clean
  WHERE order_id IS NULL OR product_id IS NULL OR quantity IS NULL OR unit_price IS NULL OR updated_at IS NULL
),
items_negative AS (
  SELECT COUNT(*) AS c FROM order_items_clean
  WHERE quantity < 0 OR unit_price < 0 OR discount_amount < 0
)
SELECT
  (SELECT c FROM items_dup)
+ (SELECT c FROM items_nulls)
+ (SELECT c FROM items_negative)
  AS violations;
