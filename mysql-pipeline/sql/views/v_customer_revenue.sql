USE de_learning;

CREATE OR REPLACE VIEW v_customer_revenue AS
SELECT
    c.customer_id,
    c.full_name,
    SUM(oi.quantity * oi.unit_price) AS customer_revenue
FROM customers c
JOIN orders o
    ON c.customer_id = o.customer_id
JOIN order_items oi
    ON o.order_id = oi.order_id
WHERE o.status IN ('paid', 'shipped')
GROUP BY c.customer_id, c.full_name;
