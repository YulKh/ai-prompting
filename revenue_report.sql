EXPLAIN ANALYZE
WITH order_sales AS (
    SELECT 
        order_id,
        SUM(quantity * unit_price) FILTER (WHERE status = 'FULFILLED') 
            OVER (PARTITION BY order_id) AS gross_sales
    FROM order_items
)
SELECT
    o.order_id,
    o.customer_id,
    COALESCE(os.gross_sales, 0) AS gross_sales,
    COALESCE(SUM(r.amount) FILTER (WHERE r.created_at::date = CURRENT_DATE - 1)
        OVER (PARTITION BY r.order_id), 0) AS total_refund,
    c.iso_code AS currency
FROM orders o
LEFT JOIN order_sales os
       ON os.order_id = o.order_id
LEFT JOIN refunds r
       ON r.order_id = o.order_id  
LEFT JOIN currencies c
       ON c.currency_id = o.currency_id
WHERE o.created_at::date = CURRENT_DATE - 1
ORDER BY gross_sales DESC;

EXPLAIN ANALYZE
