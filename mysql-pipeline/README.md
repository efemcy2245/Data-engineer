# MySQL Pipeline Learning Project

This project is a hands-on learning path to build core Data Engineering skills starting from MySQL and SQL, then growing into Python ingestion, data modeling, testing, orchestration, and warehouse transformations.

## Goal

Build a small end-to-end data pipeline with this progression:

1. **SQL + MySQL foundations**
2. **Python ingestion and cleaning**
3. **Raw / staging / marts modeling**
4. **Data quality checks**
5. **Airflow orchestration**
6. **dbt transformations**

## Current phase

Phase 1 focuses on:

- databases and tables
- primary keys and foreign keys
- inserts, updates, deletes
- joins and aggregations
- CTEs and window functions
- basic indexing and query inspection

## Project structure

```text
mysql-pipeline/
├─ README.md
├─ .gitignore
├─ docs/
├─ sql/
│  ├─ ddl/
│  ├─ dml/
│  ├─ queries/
│  └─ views/
├─ data/
├─ python/
├─ tests/
├─ airflow/
├─ dbt/
└─ screenshots/
```

## How to use in MySQL Workbench

1. Open a new SQL tab.
2. Run `sql/ddl/01_create_database.sql`.
3. Run `sql/ddl/02_create_tables.sql`.
4. Run `sql/dml/01_insert_sample_data.sql`.
5. Practice with the files in `sql/queries/`.

## Main practice database

- `de_learning` for the core e-commerce project
- `school_lab` can be used as a separate sandbox for interface exercises

## Next milestones

- add indexes in `sql/ddl/03_indexes.sql`
- add views in `sql/views/`
- add Python loaders in `python/`
- connect transformations with dbt
- orchestrate with Airflow
