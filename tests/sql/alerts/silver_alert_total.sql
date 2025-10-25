-- Alert consolidado: soma de violacoes na camada Silver
-- Contexto sugerido:
-- USE CATALOG workshop_modelagem;  -- se usar UC
-- USE SCHEMA silver;               -- ou USE DATABASE silver;

WITH
-- orders_clean
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
),
-- order_items_clean
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
),
-- products_clean
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
),
-- dim_customer_scd
scd_multi_curr AS (
  SELECT COUNT(*) AS c FROM (
    SELECT customer_id FROM dim_customer_scd WHERE is_current = TRUE GROUP BY customer_id HAVING COUNT(*) > 1
  ) x
),
scd_bad_range AS (
  SELECT COUNT(*) AS c FROM dim_customer_scd WHERE effective_start >= effective_end
),
scd_overlap AS (
  SELECT COUNT(*) AS c FROM (
    SELECT customer_id, effective_end,
           LEAD(effective_start) OVER (PARTITION BY customer_id ORDER BY effective_start) AS next_start
    FROM dim_customer_scd
  ) z WHERE next_start IS NOT NULL AND effective_end > next_start
),
scd_missing_hash AS (
  SELECT COUNT(*) AS c FROM dim_customer_scd WHERE row_hash IS NULL
),
scd_curr_bad_end AS (
  SELECT COUNT(*) AS c FROM dim_customer_scd WHERE is_current = TRUE AND date(effective_end) <> DATE('9999-12-31')
)
SELECT
  (SELECT c FROM orders_dup)
+ (SELECT c FROM orders_nulls)
+ (SELECT c FROM orders_status_bad)
+ (SELECT c FROM orders_negative)
+ (SELECT c FROM items_dup)
+ (SELECT c FROM items_nulls)
+ (SELECT c FROM items_negative)
+ (SELECT c FROM prod_dup)
+ (SELECT c FROM prod_nulls)
+ (SELECT c FROM prod_negative)
+ (SELECT c FROM scd_multi_curr)
+ (SELECT c FROM scd_bad_range)
+ (SELECT c FROM scd_overlap)
+ (SELECT c FROM scd_missing_hash)
+ (SELECT c FROM scd_curr_bad_end) AS violations;
