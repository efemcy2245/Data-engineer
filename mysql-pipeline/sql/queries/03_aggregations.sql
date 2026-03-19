USE de_learning;

SELECT
    DATE(o.order_date) AS order_day,
    SUM(oi.quantity * oi.unit_price) AS daily_revenue
FROM orders o
JOIN order_items oi
    ON o.order_id = oi.order_id
WHERE o.status IN ('paid', 'shipped')
GROUP BY DATE(o.order_date)
ORDER BY order_day;

SELECT
    p.category,
    SUM(oi.quantity) AS total_units_sold
FROM order_items oi
JOIN products p
    ON oi.product_id = p.product_id
GROUP BY p.category
ORDER BY total_units_sold DESC;
