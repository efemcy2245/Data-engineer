-- Manual pipeline run
CALL shop_analytics.sp_run_shop_pipeline();

-- Check ETL logs
SELECT *
FROM shop_analytics.etl_run_log
ORDER BY run_id DESC;

-- Check data quality logs
SELECT *
FROM shop_analytics.dq_check_log
ORDER BY dq_id DESC;

-- Compare source and fact row counts
SELECT COUNT(*) AS source_rows
FROM source_shop.v_order_details;

SELECT COUNT(*) AS fact_rows
FROM shop_analytics.fact_order_items;

-- Compare source and fact revenue
SELECT COALESCE(SUM(line_total), 0) AS source_revenue
FROM source_shop.v_order_details;

SELECT COALESCE(SUM(line_total), 0) AS fact_revenue
FROM shop_analytics.fact_order_items;

-- Reporting views
SELECT * FROM shop_analytics.vw_daily_revenue ORDER BY full_date;
SELECT * FROM shop_analytics.vw_customer_revenue ORDER BY revenue DESC;
SELECT * FROM shop_analytics.vw_product_sales ORDER BY revenue DESC;

-- Event inspection
SHOW VARIABLES LIKE 'event_scheduler';
SHOW EVENTS FROM shop_analytics;
