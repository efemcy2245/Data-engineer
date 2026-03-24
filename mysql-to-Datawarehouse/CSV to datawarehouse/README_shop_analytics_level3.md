# Shop Analytics Level 3 - BigQuery Data Warehouse Project

## Project Overview

This project is a **Level 3 data engineering warehouse project** built on **Google BigQuery**.

The goal is to move from a simple reporting database approach to a real cloud warehouse architecture based on layered modeling:

**Source -> Raw -> Staging -> Marts -> Analytics**

In this project, the original source data comes from a shop dataset previously modeled in MySQL, and the warehouse has been rebuilt inside BigQuery using a multi-layer approach.

---

## Architecture

The project uses the following BigQuery structure:

- **Project**: `shop-analytics-level-3`
- **Datasets**:
  - `raw`
  - `staging`
  - `marts`

### Layer logic

#### 1. Raw layer
The `raw` dataset stores the source tables loaded into BigQuery.
This is the landing layer, where data is kept close to the original source structure.

Tables loaded into `raw`:

- `raw_categories`
- `raw_customers`
- `raw_customers_addresses`
- `raw_order_items`
- `raw_orders`
- `raw_payments`
- `raw_products`

#### 2. Staging layer
The `staging` dataset contains SQL views created on top of the raw tables.
This layer is used to standardize naming and prepare data for dimensional modeling.

Views created in `staging`:

- `stg_categories`
- `stg_customers`
- `stg_customer_addresses`
- `stg_order_items`
- `stg_orders`
- `stg_payments`
- `stg_products`

#### 3. Marts layer
The `marts` dataset contains the final analytical tables used for reporting and business queries.

Tables created in `marts`:

- `dim_customers`
- `dim_products`
- `dim_dates`
- `fact_order_items`

---

## Steps Completed

### Step 1 - Create the Google Cloud project
A dedicated Google Cloud project was created for the warehouse:

- **Project name**: `Shop Analytics Level 3`
- **Project ID**: `shop-analytics-level-3`

### Step 2 - Open BigQuery Studio
BigQuery Studio was used as the warehouse interface inside Google Cloud.

### Step 3 - Create the warehouse datasets
Three datasets were created to support a layered warehouse architecture:

- `raw`
- `staging`
- `marts`

### Step 4 - Load source tables into the raw layer
The source tables were uploaded into BigQuery under the `raw` dataset.

A row-count validation query was executed to check the main raw tables:

- `raw_categories` = 4 rows
- `raw_customers` = 7 rows
- `raw_order_items` = 12 rows
- `raw_orders` = 6 rows
- `raw_payments` = 6 rows
- `raw_products` = 12 rows

During validation, the customer address table name was checked with `INFORMATION_SCHEMA.TABLES`, and the correct table name was confirmed as:

- `raw_customers_addresses`

### Step 5 - Create staging views
Views were created in the `staging` dataset using `CREATE OR REPLACE VIEW` statements.

The staging layer mirrors the raw layer but with cleaner semantic naming.

### Step 6 - Create marts tables
The following mart tables were created:

#### `dim_customers`
Customer dimension including:

- `customer_id`
- `first_name`
- `last_name`
- `full_name`
- `email`
- `phone`
- `country`
- `city`
- `signup_date`

#### `dim_products`
Product dimension enriched with category information.

#### `dim_dates`
Date dimension derived from the order dates.

#### `fact_order_items`
Fact table combining order items, orders, and payments, including:

- `order_item_id`
- `order_id`
- `customer_id`
- `product_id`
- `order_date`
- `order_status`
- `payment_method`
- `payment_status`
- `quantity`
- `unit_price`
- `line_total`
- `header_order_total`
- `payment_amount`

### Step 7 - Run analytical validation queries
A final analytical query was executed successfully to calculate **daily revenue** from the fact table:

```sql
SELECT
  order_date,
  SUM(line_total) AS daily_revenue
FROM `shop-analytics-level-3.marts.fact_order_items`
GROUP BY order_date
ORDER BY order_date;
```

Result:

- `2026-03-15` -> `206.95`
- `2026-03-16` -> `296.69`
- `2026-03-17` -> `714.47`

This confirmed that the full warehouse flow works end-to-end.

---

## Warehouse Flow Achieved

The project now implements the following complete flow:

**MySQL source data -> BigQuery raw -> BigQuery staging -> BigQuery marts -> Business analytics queries**

This means the warehouse is no longer just a reporting copy of a source database. It is now a real layered analytical model in the cloud.

---

## Example BigQuery Object Tree

```text
shop-analytics-level-3/
├── raw/
│   ├── raw_categories
│   ├── raw_customers
│   ├── raw_customers_addresses
│   ├── raw_order_items
│   ├── raw_orders
│   ├── raw_payments
│   └── raw_products
├── staging/
│   ├── stg_categories
│   ├── stg_customers
│   ├── stg_customer_addresses
│   ├── stg_order_items
│   ├── stg_orders
│   ├── stg_payments
│   └── stg_products
└── marts/
    ├── dim_customers
    ├── dim_products
    ├── dim_dates
    └── fact_order_items
```

---

## Why this is a Level 3 project

This project qualifies as a Level 3 architecture because:

- it uses a **dedicated cloud warehouse platform**
- it separates the model into **raw**, **staging**, and **marts**
- it creates **dimension** and **fact** tables for analytics
- it supports final **business reporting queries**
- it is ready to evolve toward **automation with Python + dbt**

---

## Current Status

### Completed

- Google Cloud project created
- BigQuery warehouse created
- Raw layer loaded
- Staging layer created
- Mart tables created
- First analytical query validated

### Next steps

To make the project more professional, the next steps are:

1. automate data loading from MySQL to BigQuery using Python
2. migrate manual SQL transformations to **dbt**
3. add data quality checks
4. add more analytical queries and dashboard outputs
5. publish the project on GitHub with screenshots and SQL scripts

---

## Suggested Business Queries

Possible final queries for this warehouse include:

- daily revenue
- revenue by customer
- revenue by product
- units sold by product
- orders by status
- payments by method

---

## Tech Stack

- **Source system**: MySQL
- **Cloud platform**: Google Cloud
- **Data warehouse**: BigQuery
- **Transformation layer**: SQL views and mart tables
- **Future orchestration / transformation**: Python + dbt

---

## Summary

This project demonstrates how to build a basic but real cloud data warehouse in BigQuery using a layered architecture.

It starts from source shop data, lands it in a raw layer, transforms it in staging, models it into marts, and finally answers analytical business questions.

