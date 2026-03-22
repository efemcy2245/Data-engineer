from dotenv import load_dotenv
from pathlib import Path
import os
from sqlalchemy import create_engine, text

env_path = Path(r"D:\Learning 4 Projects\Personal Work\.env")
load_dotenv(dotenv_path=env_path)

print("MYSQL_DB =", os.getenv("MYSQL_DB"))
print("PG_DB =", os.getenv("PG_DB"))

mysql_engine = create_engine(
    f"mysql+pymysql://{os.getenv('MYSQL_USER')}:{os.getenv('MYSQL_PASSWORD')}"
    f"@{os.getenv('MYSQL_HOST')}:{os.getenv('MYSQL_PORT')}/{os.getenv('MYSQL_DB')}"
)

pg_engine = create_engine(
    f"postgresql+psycopg://{os.getenv('PG_USER')}:{os.getenv('PG_PASSWORD')}"
    f"@{os.getenv('PG_HOST')}:{os.getenv('PG_PORT')}/{os.getenv('PG_DB')}"
)

try:
    with mysql_engine.connect() as conn:
        result = conn.execute(text("SELECT DATABASE();"))
        print("MySQL connected ->", result.scalar())

    with pg_engine.connect() as conn:
        result = conn.execute(text("SELECT current_database();"))
        print("PostgreSQL connected ->", result.scalar())

    print("Both connections work correctly.")

except Exception as e:
    print("Connection error:")
    print(e)