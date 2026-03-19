# Architecture Notes

## Level 1 target

The purpose of this lab is to build a small but complete analytical pipeline in one MySQL environment.

The design separates:
- `source_shop` for operational / transactional data
- `shop_analytics` for analytical / reporting data

This means the project is not mixing OLTP and OLAP in the exact same schema. It uses two logical databases on the same MySQL server.

## Flow

`source_shop` -> views / SQL transformations -> stored procedure -> `shop_analytics`

## ELT logic

This project is closer to **ELT** than classic ETL because:
- data stays inside MySQL
- transformations happen with SQL
- the warehouse is refreshed directly through insert-select logic

## Pipeline components

- `v_order_details` provides a business-ready row set at order-item grain
- `sp_refresh_shop_analytics()` performs the full refresh
- `sp_validate_shop_analytics()` checks if the load is coherent
- `sp_run_shop_pipeline()` runs refresh + validation
- `etl_run_log` stores pipeline execution history
- `dq_check_log` stores data quality results
- `ev_refresh_shop_analytics` schedules execution

## Fact grain

The analytical fact grain is:

**one row per order item**

Because of this grain:
- row counts can be reconciled between `source_shop.v_order_details` and `shop_analytics.fact_order_items`
- duplicate `order_item_id` values are a data quality problem
- revenue checks can be reconciled safely

## Current scope

Included:
- source schema
- target schema
- full-refresh ELT
- logging
- validation
- reporting views

Not included yet:
- staging
- incremental load
- SCD
- CDC
- Airflow / dbt / orchestration outside MySQL
