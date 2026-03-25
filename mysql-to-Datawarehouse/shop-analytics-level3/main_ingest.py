from __future__ import annotations

import logging
import os
import sys
import time
from dataclasses import dataclass
from decimal import Decimal
from pathlib import Path
from typing import Dict, List, Tuple
from urllib.parse import quote_plus

import pandas as pd
from dotenv import load_dotenv
from google.cloud import bigquery
from sqlalchemy import create_engine, text


TABLE_MAP: List[Tuple[str, str]] = [
    ("categories", "raw_categories"),
    ("customers", "raw_customers"),
    ("customers_addresses", "raw_customers_addresses"),
    ("order_items", "raw_order_items"),
    ("orders", "raw_orders"),
    ("payments", "raw_payments"),
    ("products", "raw_products"),
]


@dataclass
class TableLoadResult:
    source_table: str
    target_table: str
    status: str
    row_count: int
    duration_seconds: float
    error_message: str = ""


def setup_logging() -> None:
    log_dir = Path("logs")
    log_dir.mkdir(exist_ok=True)

    log_file = log_dir / "ingestion.log"

    logging.basicConfig(
        level=logging.INFO,
        format="%(asctime)s | %(levelname)s | %(message)s",
        handlers=[
            logging.StreamHandler(sys.stdout),
            logging.FileHandler(log_file, encoding="utf-8"),
        ],
    )


def load_config() -> Dict[str, str]:
    env_path = Path(r"D:\Learning 4 Projects\Personal Work\.env")

    if not env_path.exists():
        raise FileNotFoundError(f".env file non trovato in: {env_path}")

    load_dotenv(dotenv_path=env_path)

    print("Loading .env from:", env_path)
    print("MYSQL_DB =", os.getenv("MYSQL_DB"))
    print("GCP_PROJECT_ID =", os.getenv("GCP_PROJECT_ID"))

    config = {
        "MYSQL_HOST": os.getenv("MYSQL_HOST", ""),
        "MYSQL_PORT": os.getenv("MYSQL_PORT", "3306"),
        "MYSQL_DB": os.getenv("MYSQL_DB", ""),
        "MYSQL_USER": os.getenv("MYSQL_USER", ""),
        "MYSQL_PASSWORD": os.getenv("MYSQL_PASSWORD", ""),
        "GCP_PROJECT_ID": os.getenv("GCP_PROJECT_ID", ""),
        "BQ_DATASET_RAW": os.getenv("BQ_DATASET_RAW", "raw"),
        "BQ_LOCATION": os.getenv("BQ_LOCATION", "EU"),
        "GOOGLE_APPLICATION_CREDENTIALS": os.getenv("GOOGLE_APPLICATION_CREDENTIALS", ""),
        "ONLY_TABLE": os.getenv("ONLY_TABLE", "").strip(),
    }

    required = [
        "MYSQL_HOST",
        "MYSQL_PORT",
        "MYSQL_DB",
        "MYSQL_USER",
        "MYSQL_PASSWORD",
        "GCP_PROJECT_ID",
        "BQ_DATASET_RAW",
        "BQ_LOCATION",
    ]

    missing = [key for key in required if not config[key]]
    if missing:
        raise RuntimeError(f"Variabili mancanti nel .env: {', '.join(missing)}")

    if config["GOOGLE_APPLICATION_CREDENTIALS"]:
        credentials_path = Path(config["GOOGLE_APPLICATION_CREDENTIALS"])
        if not credentials_path.exists():
            raise FileNotFoundError(
                f"File credenziali Google non trovato: {credentials_path}"
            )
        os.environ["GOOGLE_APPLICATION_CREDENTIALS"] = config["GOOGLE_APPLICATION_CREDENTIALS"]

    return config


def get_mysql_engine(config: Dict[str, str]):
    password = quote_plus(config["MYSQL_PASSWORD"])
    url = (
        f"mysql+pymysql://{config['MYSQL_USER']}:{password}"
        f"@{config['MYSQL_HOST']}:{config['MYSQL_PORT']}/{config['MYSQL_DB']}"
    )
    return create_engine(url, pool_pre_ping=True)


def get_bigquery_client(config: Dict[str, str]) -> bigquery.Client:
    return bigquery.Client(project=config["GCP_PROJECT_ID"])


def normalize_dataframe(df: pd.DataFrame) -> pd.DataFrame:
    df = df.copy()

    for col in df.columns:
        series = df[col].dropna()

        if series.empty:
            continue

        if series.map(lambda x: isinstance(x, Decimal)).all():
            df[col] = df[col].astype(float)

    return df


def extract_mysql_table(engine, source_table: str) -> pd.DataFrame:
    query = text(f"SELECT * FROM `{source_table}`")
    with engine.connect() as conn:
        df = pd.read_sql_query(query, conn)
    return normalize_dataframe(df)


def load_to_bigquery(
    client: bigquery.Client,
    df: pd.DataFrame,
    project_id: str,
    dataset_id: str,
    target_table: str,
    location: str,
) -> int:
    table_id = f"{project_id}.{dataset_id}.{target_table}"

    if df.empty:
        logging.warning("La tabella %s è vuota. Skip del caricamento.", target_table)
        return 0

    job_config = bigquery.LoadJobConfig(
        write_disposition=bigquery.WriteDisposition.WRITE_TRUNCATE
    )

    load_job = client.load_table_from_dataframe(
        df,
        table_id,
        job_config=job_config,
        location=location,
    )
    load_job.result()

    table = client.get_table(table_id)
    logging.info("Caricate %s righe in %s", table.num_rows, table_id)
    return table.num_rows


def filter_tables(table_map: List[Tuple[str, str]], only_table: str) -> List[Tuple[str, str]]:
    if not only_table:
        return table_map

    filtered = [
        (source, target)
        for source, target in table_map
        if only_table in {source, target}
    ]

    if not filtered:
        raise RuntimeError(
            f"ONLY_TABLE='{only_table}' non corrisponde a nessuna tabella source o target."
        )

    return filtered


def print_summary(results: List[TableLoadResult]) -> None:
    success_count = sum(1 for r in results if r.status == "SUCCESS")
    failed_count = sum(1 for r in results if r.status == "FAILED")
    total_rows = sum(r.row_count for r in results if r.status == "SUCCESS")

    print("\n" + "=" * 80)
    print("RIEPILOGO FINALE INGESTION")
    print("=" * 80)
    print(f"Totale tabelle processate: {len(results)}")
    print(f"Tabelle riuscite:         {success_count}")
    print(f"Tabelle fallite:          {failed_count}")
    print(f"Totale righe caricate:    {total_rows}")
    print("-" * 80)

    for result in results:
        status_symbol = "OK" if result.status == "SUCCESS" else "KO"
        print(
            f"[{status_symbol}] "
            f"{result.source_table} -> {result.target_table} | "
            f"rows={result.row_count} | "
            f"time={result.duration_seconds:.2f}s"
        )
        if result.error_message:
            print(f"     Errore: {result.error_message}")

    print("=" * 80 + "\n")


def main() -> None:
    setup_logging()
    config = load_config()

    tables_to_load = filter_tables(TABLE_MAP, config["ONLY_TABLE"])

    logging.info("Starting ingestion...")
    logging.info("Project: %s", config["GCP_PROJECT_ID"])
    logging.info("Dataset: %s", config["BQ_DATASET_RAW"])
    logging.info("Tables to load: %s", [t[0] for t in tables_to_load])

    mysql_engine = get_mysql_engine(config)
    bq_client = get_bigquery_client(config)

    results: List[TableLoadResult] = []
    start_total = time.perf_counter()

    for source_table, target_table in tables_to_load:
        start_table = time.perf_counter()

        try:
            logging.info("Extracting MySQL table: %s", source_table)
            df = extract_mysql_table(mysql_engine, source_table)
            logging.info("Extracted %s rows from %s", len(df), source_table)

            logging.info("Loading into BigQuery table: %s", target_table)
            loaded_rows = load_to_bigquery(
                client=bq_client,
                df=df,
                project_id=config["GCP_PROJECT_ID"],
                dataset_id=config["BQ_DATASET_RAW"],
                target_table=target_table,
                location=config["BQ_LOCATION"],
            )

            duration = time.perf_counter() - start_table
            results.append(
                TableLoadResult(
                    source_table=source_table,
                    target_table=target_table,
                    status="SUCCESS",
                    row_count=loaded_rows,
                    duration_seconds=duration,
                )
            )

        except Exception as e:
            duration = time.perf_counter() - start_table
            logging.exception("Errore durante il caricamento di %s", source_table)

            results.append(
                TableLoadResult(
                    source_table=source_table,
                    target_table=target_table,
                    status="FAILED",
                    row_count=0,
                    duration_seconds=duration,
                    error_message=str(e),
                )
            )

    total_duration = time.perf_counter() - start_total
    logging.info("Durata totale run: %.2f secondi", total_duration)

    print_summary(results)

    failed_count = sum(1 for r in results if r.status == "FAILED")
    if failed_count > 0:
        raise RuntimeError(f"Ingestion completata con {failed_count} tabella/e fallite.")

    logging.info("Ingestion completed successfully.")


if __name__ == "__main__":
    main()