USE shop_analytics;

DROP TABLE IF EXISTS dq_check_log;
DROP TABLE IF EXISTS etl_run_log;

CREATE TABLE etl_run_log (
    run_id INT AUTO_INCREMENT PRIMARY KEY,
    process_name VARCHAR(100) NOT NULL,
    run_start DATETIME NOT NULL,
    run_end DATETIME NULL,
    status VARCHAR(20) NOT NULL,
    rows_loaded INT DEFAULT 0,
    message VARCHAR(255) NULL
);

CREATE TABLE dq_check_log (
    dq_id INT AUTO_INCREMENT PRIMARY KEY,
    run_id INT NOT NULL,
    check_name VARCHAR(100) NOT NULL,
    expected_value DECIMAL(18,2) NULL,
    actual_value DECIMAL(18,2) NULL,
    status VARCHAR(20) NOT NULL,
    message VARCHAR(255) NULL,
    created_at DATETIME NOT NULL DEFAULT NOW(),
    CONSTRAINT fk_dq_run
        FOREIGN KEY (run_id) REFERENCES etl_run_log(run_id)
);
