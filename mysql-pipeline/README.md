# MySQL Level 1 Data Engineering Lab

This repository contains a practical Level 1 Data Engineering project built in MySQL.

The project simulates a simple analytical pipeline inside the same MySQL environment by separating:
- `source_shop` as the OLTP-style source schema
- `shop_analytics` as the OLAP / warehouse-style target schema

The pipeline uses SQL views, stored procedures, validation checks, and the MySQL Event Scheduler.

## Project goal

Build a small end-to-end ELT workflow that:
1. stores normalized operational data in `source_shop`
2. transforms that data into an analytical model in `shop_analytics`
3. refreshes the target through a stored procedure
4. logs each ETL run
5. validates data quality after each refresh
6. exposes reporting-ready views

## Architecture

`source_shop` -> SQL views / stored procedures / event -> `shop_analytics`

This is a **Level 1 architecture**:
- same MySQL server / environment
- logically separated source and analytics schemas
- full-refresh ELT approach
- no staging layer yet
- no incremental load yet

## Main objects

### Source schema: `source_shop`
Tables:
- `customers`
- `categories`
- `products`
- `customers_addresses`
- `orders`
- `order_items`
- `payments`

Views:
- `v_order_details`
- `v_daily_revenue`
- `v_customer_revenue`
- `v_product_sales`

### Analytics schema: `shop_analytics`
Dimensions / fact:
- `dim_customers`
- `dim_categories`
- `dim_products`
- `dim_dates`
- `fact_order_items`

Pipeline / controls:
- `etl_run_log`
- `dq_check_log`
- `sp_refresh_shop_analytics()`
- `sp_validate_shop_analytics()`
- `sp_run_shop_pipeline()`
- `ev_refresh_shop_analytics`

## Fact grain

The fact grain is:

**one row per order item**

This is the key design rule for the warehouse and the validation logic.

## Repository structure

```text
mysql-level1-data-engineering-lab/
├── README.md
├── .gitignore
├── docs/
│   ├── architecture.md
│   └── lab-checklist.md
└── sql/
    ├── 00_create_databases.sql
    ├── 01_source_schema.sql
    ├── 02_source_sample_data.sql
    ├── 03_source_views.sql
    ├── 04_analytics_schema.sql
    ├── 05_logging_tables.sql
    ├── 06_refresh_procedure.sql
    ├── 07_validation_procedure.sql
    ├── 08_pipeline_wrapper_and_event.sql
    ├── 09_reporting_views.sql
    └── 10_test_queries.sql
```

## Recommended execution order

Run the SQL files in this order:

1. `sql/00_create_databases.sql`
2. `sql/01_source_schema.sql`
3. `sql/02_source_sample_data.sql`
4. `sql/03_source_views.sql`
5. `sql/04_analytics_schema.sql`
6. `sql/05_logging_tables.sql`
7. `sql/06_refresh_procedure.sql`
8. `sql/07_validation_procedure.sql`
9. `sql/08_pipeline_wrapper_and_event.sql`
10. `sql/09_reporting_views.sql`
11. `sql/10_test_queries.sql`

## How to run manually

```sql
CALL shop_analytics.sp_run_shop_pipeline();
```

Then inspect:

```sql
SELECT * FROM shop_analytics.etl_run_log ORDER BY run_id DESC;
SELECT * FROM shop_analytics.dq_check_log ORDER BY dq_id DESC;
```

## Notes

- The refresh uses `DELETE` instead of `TRUNCATE` so rollback behavior remains consistent inside the transaction.
- The project is intentionally simple and educational.
- If your live schema already has slightly different column names, align the scripts before executing in production.

## What this lab demonstrates

- OLTP vs OLAP separation
- source-to-analytics ELT in MySQL
- dimension / fact modeling
- fact grain definition
- stored procedure orchestration
- scheduled refresh with MySQL events
- ETL logging
- data quality validation
- reporting-ready warehouse outputs

