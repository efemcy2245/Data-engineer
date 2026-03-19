USE de_learning;

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
GROUP BY c.customer_id, c.full_name
ORDER BY customer_revenue DESC;

SELECT
    c.country,
    COUNT(DISTINCT o.order_id) AS total_orders
FROM customers c
JOIN orders o
    ON c.customer_id = o.customer_id
GROUP BY c.country
ORDER BY total_orders DESC;
