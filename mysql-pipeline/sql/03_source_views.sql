USE source_shop;

DROP VIEW IF EXISTS v_product_sales;
DROP VIEW IF EXISTS v_customer_revenue;
DROP VIEW IF EXISTS v_daily_revenue;
DROP VIEW IF EXISTS v_order_details;

CREATE VIEW v_order_details AS
SELECT
    o.order_id,
    oi.order_item_id,
    DATE(o.order_date) AS order_day,
    o.order_date,
    o.customer_id,
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
    c.email,
    a.city,
    a.country,
    p.product_id,
    p.product_name,
    p.sku,
    cat.category_id,
    cat.category_name,
    oi.quantity,
    oi.unit_price,
    oi.line_total,
    o.order_status,
    pay.payment_method,
    pay.payment_status,
    pay.amount AS payment_amount
FROM orders o
JOIN customers c
    ON o.customer_id = c.customer_id
LEFT JOIN customers_addresses a
    ON c.customer_id = a.customer_id
   AND a.is_default = 1
JOIN order_items oi
    ON o.order_id = oi.order_id
JOIN products p
    ON oi.product_id = p.product_id
JOIN categories cat
    ON p.category_id = cat.category_id
LEFT JOIN (
    SELECT
        p1.order_id,
        p1.payment_method,
        p1.payment_status,
        p1.amount
    FROM payments p1
    JOIN (
        SELECT order_id, MAX(payment_date) AS max_payment_date
        FROM payments
        GROUP BY order_id
    ) p2
        ON p1.order_id = p2.order_id
       AND p1.payment_date = p2.max_payment_date
) pay
    ON o.order_id = pay.order_id;

CREATE VIEW v_daily_revenue AS
SELECT
    order_day,
    COUNT(DISTINCT order_id) AS orders_count,
    SUM(line_total) AS revenue
FROM v_order_details
GROUP BY order_day;

CREATE VIEW v_customer_revenue AS
SELECT
    customer_id,
    customer_name,
    email,
    city,
    country,
    COUNT(DISTINCT order_id) AS orders_count,
    SUM(line_total) AS revenue
FROM v_order_details
GROUP BY customer_id, customer_name, email, city, country;

CREATE VIEW v_product_sales AS
SELECT
    product_id,
    product_name,
    sku,
    category_id,
    category_name,
    SUM(quantity) AS total_quantity,
    SUM(line_total) AS revenue
FROM v_order_details
GROUP BY product_id, product_name, sku, category_id, category_name;
