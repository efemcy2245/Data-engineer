USE de_learning;

WITH order_totals AS (
    SELECT
        order_id,
        SUM(quantity * unit_price) AS total_amount
    FROM order_items
    GROUP BY order_id
)
SELECT
    o.order_id,
    c.full_name,
    o.status,
    ot.total_amount
FROM orders o
JOIN customers c
    ON o.customer_id = c.customer_id
JOIN order_totals ot
    ON o.order_id = ot.order_id
ORDER BY ot.total_amount DESC;
