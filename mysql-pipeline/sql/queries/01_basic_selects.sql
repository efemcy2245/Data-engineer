USE de_learning;

SELECT *
FROM orders
WHERE status IN ('paid', 'shipped')
ORDER BY order_date;

SELECT
    oi.order_id,
    SUM(oi.quantity * oi.unit_price) AS order_total
FROM order_items oi
GROUP BY oi.order_id
ORDER BY oi.order_id;
