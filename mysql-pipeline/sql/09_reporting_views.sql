USE shop_analytics;

DROP VIEW IF EXISTS vw_daily_revenue;
DROP VIEW IF EXISTS vw_customer_revenue;
DROP VIEW IF EXISTS vw_product_sales;

CREATE VIEW vw_daily_revenue AS
SELECT
    d.full_date,
    COUNT(DISTINCT f.order_id) AS orders_count,
    SUM(f.line_total) AS revenue
FROM fact_order_items f
JOIN dim_dates d
    ON f.date_key = d.date_key
GROUP BY d.full_date;

CREATE VIEW vw_customer_revenue AS
SELECT
    c.customer_id,
    c.full_name,
    c.email,
    c.city,
    c.country,
    COUNT(DISTINCT f.order_id) AS orders_count,
    SUM(f.line_total) AS revenue
FROM fact_order_items f
JOIN dim_customers c
    ON f.customer_key = c.customer_key
GROUP BY c.customer_id, c.full_name, c.email, c.city, c.country;

CREATE VIEW vw_product_sales AS
SELECT
    p.product_id,
    p.product_name,
    p.sku,
    cat.category_name,
    SUM(f.quantity) AS total_quantity,
    SUM(f.line_total) AS revenue
FROM fact_order_items f
JOIN dim_products p
    ON f.product_key = p.product_key
JOIN dim_categories cat
    ON p.category_key = cat.category_key
GROUP BY p.product_id, p.product_name, p.sku, cat.category_name;
