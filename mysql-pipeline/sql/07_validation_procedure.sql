USE shop_analytics;

DROP PROCEDURE IF EXISTS sp_validate_shop_analytics;

DELIMITER //

CREATE PROCEDURE sp_validate_shop_analytics()
BEGIN
    DECLARE v_run_id INT;

    DECLARE v_source_rows INT DEFAULT 0;
    DECLARE v_fact_rows INT DEFAULT 0;

    DECLARE v_source_revenue DECIMAL(18,2) DEFAULT 0;
    DECLARE v_fact_revenue DECIMAL(18,2) DEFAULT 0;

    DECLARE v_missing_customer_keys INT DEFAULT 0;
    DECLARE v_missing_product_keys INT DEFAULT 0;
    DECLARE v_duplicate_order_items INT DEFAULT 0;

    SELECT MAX(run_id)
    INTO v_run_id
    FROM etl_run_log
    WHERE process_name = 'sp_refresh_shop_analytics'
      AND status = 'SUCCESS';

    IF v_run_id IS NULL THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'No successful ETL run found in etl_run_log';
    END IF;

    SELECT COUNT(*)
    INTO v_source_rows
    FROM source_shop.v_order_details;

    SELECT COUNT(*)
    INTO v_fact_rows
    FROM fact_order_items;

    INSERT INTO dq_check_log (
        run_id, check_name, expected_value, actual_value, status, message
    )
    VALUES (
        v_run_id,
        'row_count_match',
        v_source_rows,
        v_fact_rows,
        CASE WHEN v_source_rows = v_fact_rows THEN 'PASS' ELSE 'FAIL' END,
        'Compare source row count with fact row count'
    );

    SELECT COALESCE(SUM(line_total), 0)
    INTO v_source_revenue
    FROM source_shop.v_order_details;

    SELECT COALESCE(SUM(line_total), 0)
    INTO v_fact_revenue
    FROM fact_order_items;

    INSERT INTO dq_check_log (
        run_id, check_name, expected_value, actual_value, status, message
    )
    VALUES (
        v_run_id,
        'revenue_match',
        v_source_revenue,
        v_fact_revenue,
        CASE WHEN v_source_revenue = v_fact_revenue THEN 'PASS' ELSE 'FAIL' END,
        'Compare source revenue with fact revenue'
    );

    SELECT COUNT(*)
    INTO v_missing_customer_keys
    FROM fact_order_items
    WHERE customer_key IS NULL;

    INSERT INTO dq_check_log (
        run_id, check_name, expected_value, actual_value, status, message
    )
    VALUES (
        v_run_id,
        'missing_customer_keys',
        0,
        v_missing_customer_keys,
        CASE WHEN v_missing_customer_keys = 0 THEN 'PASS' ELSE 'FAIL' END,
        'Fact rows with NULL customer_key'
    );

    SELECT COUNT(*)
    INTO v_missing_product_keys
    FROM fact_order_items
    WHERE product_key IS NULL;

    INSERT INTO dq_check_log (
        run_id, check_name, expected_value, actual_value, status, message
    )
    VALUES (
        v_run_id,
        'missing_product_keys',
        0,
        v_missing_product_keys,
        CASE WHEN v_missing_product_keys = 0 THEN 'PASS' ELSE 'FAIL' END,
        'Fact rows with NULL product_key'
    );

    SELECT COUNT(*)
    INTO v_duplicate_order_items
    FROM (
        SELECT order_item_id
        FROM fact_order_items
        GROUP BY order_item_id
        HAVING COUNT(*) > 1
    ) t;

    INSERT INTO dq_check_log (
        run_id, check_name, expected_value, actual_value, status, message
    )
    VALUES (
        v_run_id,
        'duplicate_order_item_id',
        0,
        v_duplicate_order_items,
        CASE WHEN v_duplicate_order_items = 0 THEN 'PASS' ELSE 'FAIL' END,
        'Duplicate order_item_id in fact_order_items'
    );
END //

DELIMITER ;
