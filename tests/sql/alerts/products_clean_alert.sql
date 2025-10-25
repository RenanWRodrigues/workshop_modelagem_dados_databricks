-- Alert: silver.products_clean violations
-- Contexto sugerido:
-- USE CATALOG workshop_modelagem;  -- se usar UC
-- USE SCHEMA silver;               -- ou USE DATABASE silver;

WITH
prod_dup AS (
  SELECT COUNT(*) AS c FROM (
    SELECT product_id FROM products_clean GROUP BY product_id HAVING COUNT(*) > 1
  ) x
),
prod_nulls AS (
  SELECT COUNT(*) AS c FROM products_clean
  WHERE product_id IS NULL OR product_name IS NULL OR cost_price IS NULL OR list_price IS NULL OR last_update IS NULL
),
prod_negative AS (
  SELECT COUNT(*) AS c FROM products_clean WHERE cost_price < 0 OR list_price < 0
)
SELECT
  (SELECT c FROM prod_dup)
+ (SELECT c FROM prod_nulls)
+ (SELECT c FROM prod_negative)
  AS violations;
