USE de_learning;

CREATE OR REPLACE VIEW v_daily_revenue AS
SELECT
    DATE(o.order_date) AS order_day,
    SUM(oi.quantity * oi.unit_price) AS daily_revenue
FROM orders o
JOIN order_items oi
    ON o.order_id = oi.order_id
WHERE o.status IN ('paid', 'shipped')
GROUP BY DATE(o.order_date)
ORDER BY order_day;
