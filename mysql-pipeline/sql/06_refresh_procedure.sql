USE shop_analytics;

DROP PROCEDURE IF EXISTS sp_refresh_shop_analytics;

DELIMITER //

CREATE PROCEDURE sp_refresh_shop_analytics()
BEGIN
    DECLARE v_run_start DATETIME DEFAULT NOW();
    DECLARE v_run_end DATETIME;
    DECLARE v_rows_loaded INT DEFAULT 0;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;

        SET v_run_end = NOW();

        INSERT INTO etl_run_log (
            process_name,
            run_start,
            run_end,
            status,
            rows_loaded,
            message
        )
        VALUES (
            'sp_refresh_shop_analytics',
            v_run_start,
            v_run_end,
            'FAILED',
            v_rows_loaded,
            'ETL refresh failed'
        );

        RESIGNAL;
    END;

    START TRANSACTION;

    DELETE FROM fact_order_items;
    DELETE FROM dim_products;
    DELETE FROM dim_categories;
    DELETE FROM dim_customers;
    DELETE FROM dim_dates;

    INSERT INTO dim_customers (
        customer_id,
        full_name,
        email,
        city,
        country,
        source_created_at
    )
    SELECT
        c.customer_id,
        CONCAT(c.first_name, ' ', c.last_name) AS full_name,
        c.email,
        a.city,
        a.country,
        c.created_at
    FROM source_shop.customers c
    LEFT JOIN source_shop.customers_addresses a
        ON c.customer_id = a.customer_id
       AND a.is_default = 1;

    INSERT INTO dim_categories (
        category_id,
        category_name
    )
    SELECT
        category_id,
        category_name
    FROM source_shop.categories;

    INSERT INTO dim_products (
        product_id,
        category_key,
        category_id,
        product_name,
        sku,
        current_unit_price
    )
    SELECT
        p.product_id,
        dc.category_key,
        p.category_id,
        p.product_name,
        p.sku,
        p.unit_price
    FROM source_shop.products p
    JOIN dim_categories dc
        ON p.category_id = dc.category_id;

    INSERT INTO dim_dates (
        date_key,
        full_date,
        day_of_month,
        month_number,
        month_name,
        quarter_number,
        year_number,
        weekday_name
    )
    SELECT DISTINCT
        CAST(DATE_FORMAT(vod.order_day, '%Y%m%d') AS UNSIGNED) AS date_key,
        vod.order_day AS full_date,
        DAY(vod.order_day) AS day_of_month,
        MONTH(vod.order_day) AS month_number,
        MONTHNAME(vod.order_day) AS month_name,
        QUARTER(vod.order_day) AS quarter_number,
        YEAR(vod.order_day) AS year_number,
        DAYNAME(vod.order_day) AS weekday_name
    FROM source_shop.v_order_details vod;

    INSERT INTO fact_order_items (
        order_id,
        order_item_id,
        date_key,
        customer_key,
        product_key,
        quantity,
        unit_price,
        line_total,
        order_status,
        payment_method,
        payment_status
    )
    SELECT
        vod.order_id,
        vod.order_item_id,
        CAST(DATE_FORMAT(vod.order_day, '%Y%m%d') AS UNSIGNED) AS date_key,
        dc.customer_key,
        dp.product_key,
        vod.quantity,
        vod.unit_price,
        vod.line_total,
        vod.order_status,
        vod.payment_method,
        vod.payment_status
    FROM source_shop.v_order_details vod
    JOIN dim_customers dc
        ON vod.customer_id = dc.customer_id
    JOIN dim_products dp
        ON vod.product_id = dp.product_id;

    SET v_rows_loaded = ROW_COUNT();

    COMMIT;

    SET v_run_end = NOW();

    INSERT INTO etl_run_log (
        process_name,
        run_start,
        run_end,
        status,
        rows_loaded,
        message
    )
    VALUES (
        'sp_refresh_shop_analytics',
        v_run_start,
        v_run_end,
        'SUCCESS',
        v_rows_loaded,
        'ETL refresh completed successfully'
    );
END //

DELIMITER ;
