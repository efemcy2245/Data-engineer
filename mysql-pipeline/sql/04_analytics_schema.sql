USE shop_analytics;

DROP TABLE IF EXISTS fact_order_items;
DROP TABLE IF EXISTS dim_dates;
DROP TABLE IF EXISTS dim_products;
DROP TABLE IF EXISTS dim_categories;
DROP TABLE IF EXISTS dim_customers;

CREATE TABLE dim_customers (
    customer_key INT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT NOT NULL UNIQUE,
    full_name VARCHAR(120) NOT NULL,
    email VARCHAR(120) NOT NULL,
    city VARCHAR(80) NULL,
    country VARCHAR(80) NULL,
    source_created_at DATETIME NOT NULL
);

CREATE TABLE dim_categories (
    category_key INT AUTO_INCREMENT PRIMARY KEY,
    category_id INT NOT NULL UNIQUE,
    category_name VARCHAR(100) NOT NULL
);

CREATE TABLE dim_products (
    product_key INT AUTO_INCREMENT PRIMARY KEY,
    product_id INT NOT NULL UNIQUE,
    category_key INT NOT NULL,
    category_id INT NOT NULL,
    product_name VARCHAR(120) NOT NULL,
    sku VARCHAR(50) NOT NULL,
    current_unit_price DECIMAL(10,2) NOT NULL,
    CONSTRAINT fk_dim_products_category
        FOREIGN KEY (category_key) REFERENCES dim_categories(category_key)
);

CREATE TABLE dim_dates (
    date_key INT PRIMARY KEY,
    full_date DATE NOT NULL UNIQUE,
    day_of_month INT NOT NULL,
    month_number INT NOT NULL,
    month_name VARCHAR(20) NOT NULL,
    quarter_number INT NOT NULL,
    year_number INT NOT NULL,
    weekday_name VARCHAR(20) NOT NULL
);

CREATE TABLE fact_order_items (
    fact_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    order_id INT NOT NULL,
    order_item_id INT NOT NULL UNIQUE,
    date_key INT NOT NULL,
    customer_key INT NOT NULL,
    product_key INT NOT NULL,
    quantity INT NOT NULL,
    unit_price DECIMAL(10,2) NOT NULL,
    line_total DECIMAL(10,2) NOT NULL,
    order_status VARCHAR(30) NOT NULL,
    payment_method VARCHAR(30) NULL,
    payment_status VARCHAR(30) NULL,
    CONSTRAINT fk_fact_dates
        FOREIGN KEY (date_key) REFERENCES dim_dates(date_key),
    CONSTRAINT fk_fact_customers
        FOREIGN KEY (customer_key) REFERENCES dim_customers(customer_key),
    CONSTRAINT fk_fact_products
        FOREIGN KEY (product_key) REFERENCES dim_products(product_key)
);

CREATE INDEX idx_fact_date_key ON fact_order_items(date_key);
CREATE INDEX idx_fact_customer_key ON fact_order_items(customer_key);
CREATE INDEX idx_fact_product_key ON fact_order_items(product_key);
