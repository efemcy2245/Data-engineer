from dotenv import load_dotenv
from pathlib import Path
import os
import pandas as pd
from sqlalchemy import create_engine, text

# Load .env from current project folder
#env_path = Path(__file__).resolve().parent / ".env"
env_path = Path(r"D:\Learning 4 Projects\Personal Work\.env")
load_dotenv(dotenv_path=env_path)

# MySQL connection
mysql_engine = create_engine(
    f"mysql+pymysql://{os.getenv('MYSQL_USER')}:{os.getenv('MYSQL_PASSWORD')}"
    f"@{os.getenv('MYSQL_HOST')}:{os.getenv('MYSQL_PORT')}/{os.getenv('MYSQL_DB')}"
)

# PostgreSQL connection
pg_engine = create_engine(
    f"postgresql+psycopg://{os.getenv('PG_USER')}:{os.getenv('PG_PASSWORD')}"
    f"@{os.getenv('PG_HOST')}:{os.getenv('PG_PORT')}/{os.getenv('PG_DB')}"
)

EXTRACT_QUERY = """
SELECT
    order_id,
    order_item_id,
    order_day,
    order_status,
    customer_id,
    customer_name,
    customer_email,
    customer_country,
    customer_city,
    product_id,
    product_name,
    sku,
    category_id,
    category_name,
    quantity,
    unit_price,
    line_total,
    payment_id,
    payment_method,
    payment_status,
    payment_amount,
    payment_date
FROM v_order_details
"""


def extract_data() -> pd.DataFrame:
    df = pd.read_sql(EXTRACT_QUERY, mysql_engine)

    if df.empty:
        raise ValueError("No data extracted from MySQL.")

    dupes = df[df["order_item_id"].duplicated(keep=False)]
    if not dupes.empty:
        sample_ids = dupes["order_item_id"].drop_duplicates().tolist()[:10]
        raise ValueError(
            f"Duplicate order_item_id found in v_order_details. Sample duplicate IDs: {sample_ids}"
        )

    return df


def build_dim_dates(df: pd.DataFrame) -> pd.DataFrame:
    dates = pd.to_datetime(df["order_day"]).dt.normalize().drop_duplicates().sort_values()

    dim_dates = pd.DataFrame({"full_date": dates})
    dim_dates["date_key"] = dim_dates["full_date"].dt.strftime("%Y%m%d").astype(int)
    dim_dates["day_num"] = dim_dates["full_date"].dt.day
    dim_dates["month_num"] = dim_dates["full_date"].dt.month
    dim_dates["month_name"] = dim_dates["full_date"].dt.month_name()
    dim_dates["quarter_num"] = dim_dates["full_date"].dt.quarter
    dim_dates["year_num"] = dim_dates["full_date"].dt.year
    dim_dates["weekday_name"] = dim_dates["full_date"].dt.day_name()

    return dim_dates[
        [
            "date_key",
            "full_date",
            "day_num",
            "month_num",
            "month_name",
            "quarter_num",
            "year_num",
            "weekday_name",
        ]
    ]


def build_dim_customers(df: pd.DataFrame) -> pd.DataFrame:
    dim_customers = (
        df[
            [
                "customer_id",
                "customer_name",
                "customer_email",
                "customer_city",
            ]
        ]
        .drop_duplicates(subset=["customer_id"])
        .copy()
    )

    dim_customers["first_name"] = None
    dim_customers["last_name"] = None
    dim_customers["full_name"] = dim_customers["customer_name"]
    dim_customers["email"] = dim_customers["customer_email"]
    dim_customers["city"] = dim_customers["customer_city"]
    dim_customers["created_at"] = pd.NaT

    return dim_customers[
        [
            "customer_id",
            "first_name",
            "last_name",
            "full_name",
            "email",
            "city",
            "created_at",
        ]
    ]


def build_dim_products(df: pd.DataFrame) -> pd.DataFrame:
    dim_products = (
        df[
            [
                "product_id",
                "product_name",
                "category_name",
                "unit_price",
            ]
        ]
        .drop_duplicates(subset=["product_id"])
        .copy()
    )

    dim_products = dim_products.rename(
        columns={
            "category_name": "category",
            "unit_price": "source_unit_price"
        }
    )

    dim_products["created_at"] = pd.NaT

    return dim_products[
        [
            "product_id",
            "product_name",
            "category",
            "source_unit_price",
            "created_at",
        ]
    ]


def reset_reporting_tables() -> None:
    with pg_engine.begin() as conn:
        conn.execute(text("TRUNCATE TABLE fact_order_items RESTART IDENTITY;"))
        conn.execute(text("TRUNCATE TABLE dim_customers RESTART IDENTITY CASCADE;"))
        conn.execute(text("TRUNCATE TABLE dim_products RESTART IDENTITY CASCADE;"))
        conn.execute(text("TRUNCATE TABLE dim_dates RESTART IDENTITY CASCADE;"))


def load_dimensions(dim_dates: pd.DataFrame, dim_customers: pd.DataFrame, dim_products: pd.DataFrame) -> None:
    dim_products_to_load = dim_products.rename(columns={"source_unit_price": "unit_price"})

    dim_dates.to_sql("dim_dates", pg_engine, if_exists="append", index=False)
    dim_customers.to_sql("dim_customers", pg_engine, if_exists="append", index=False)
    dim_products_to_load.to_sql("dim_products", pg_engine, if_exists="append", index=False)


def build_fact_table(df: pd.DataFrame) -> pd.DataFrame:
    date_map = pd.read_sql("SELECT date_key, full_date FROM dim_dates", pg_engine)
    customer_map = pd.read_sql("SELECT customer_key, customer_id FROM dim_customers", pg_engine)
    product_map = pd.read_sql("SELECT product_key, product_id FROM dim_products", pg_engine)

    date_map["full_date"] = pd.to_datetime(date_map["full_date"]).dt.normalize()

    fact = df.copy()
    fact["full_date"] = pd.to_datetime(fact["order_day"]).dt.normalize()
    fact["line_total"] = fact["quantity"] * fact["unit_price"]

    fact = fact.merge(date_map, on="full_date", how="left")
    fact = fact.merge(customer_map, on="customer_id", how="left")
    fact = fact.merge(product_map, on="product_id", how="left")

    if fact["date_key"].isna().any():
        raise ValueError("Some rows could not map to dim_dates.")
    if fact["customer_key"].isna().any():
        raise ValueError("Some rows could not map to dim_customers.")
    if fact["product_key"].isna().any():
        raise ValueError("Some rows could not map to dim_products.")

    fact = fact[
        [
            "order_id",
            "order_item_id",
            "date_key",
            "customer_key",
            "product_key",
            "quantity",
            "unit_price",
            "line_total",
            "order_status",
            "payment_method",
            "payment_status",
        ]
    ].copy()

    fact["date_key"] = fact["date_key"].astype(int)
    fact["customer_key"] = fact["customer_key"].astype(int)
    fact["product_key"] = fact["product_key"].astype(int)

    return fact


def load_fact_table(fact_df: pd.DataFrame) -> None:
    fact_df.to_sql("fact_order_items", pg_engine, if_exists="append", index=False)


def main() -> None:
    print("Starting ETL...")

    df = extract_data()
    print(f"Extracted rows from MySQL: {len(df)}")

    dim_dates = build_dim_dates(df)
    dim_customers = build_dim_customers(df)
    dim_products = build_dim_products(df)

    print(f"dim_dates rows: {len(dim_dates)}")
    print(f"dim_customers rows: {len(dim_customers)}")
    print(f"dim_products rows: {len(dim_products)}")

    reset_reporting_tables()
    print("Reporting tables truncated.")

    load_dimensions(dim_dates, dim_customers, dim_products)
    print("Dimensions loaded into PostgreSQL.")

    fact_df = build_fact_table(df)
    print(f"fact_order_items rows: {len(fact_df)}")

    load_fact_table(fact_df)
    print("Fact table loaded into PostgreSQL.")

    print("ETL completed successfully.")


if __name__ == "__main__":
    main()