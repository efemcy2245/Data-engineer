USE shop_analytics;

DROP PROCEDURE IF EXISTS sp_run_shop_pipeline;

DELIMITER //

CREATE PROCEDURE sp_run_shop_pipeline()
BEGIN
    CALL sp_refresh_shop_analytics();
    CALL sp_validate_shop_analytics();
END //

DELIMITER ;

DROP EVENT IF EXISTS ev_refresh_shop_analytics;

CREATE EVENT ev_refresh_shop_analytics
ON SCHEDULE EVERY 1 DAY
STARTS CURRENT_TIMESTAMP + INTERVAL 5 MINUTE
DO
    CALL shop_analytics.sp_run_shop_pipeline();
