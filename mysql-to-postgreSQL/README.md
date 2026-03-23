# MySQL to PostgreSQL ETL Project

Level 2 data engineering project.

## Architecture
MySQL (`source_shop`) -> Python ETL -> PostgreSQL (`shop_analytics`)

## Source
- MySQL operational database
- View used for extraction: `v_order_details`

## Reporting
PostgreSQL warehouse tables:
- dim_dates
- dim_customers
- dim_products
- fact_order_items

## Setup
1. Create a `.env` file based on `.env.example`
2. Install dependencies:
   `pip install -r requirements.txt`
3. Run:
   `py main_etl.py`

## Notes
This project demonstrates a Level 2 architecture with source and reporting databases separated across different DBMS systems.