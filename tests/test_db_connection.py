"""Modulbank assignment: verify a database connection and SELECT NOW()."""

import os

import psycopg
from dotenv import load_dotenv

load_dotenv()


def test_postgresql_connection_and_simple_query():
    """Passes with valid credentials; fails with a wrong password/host/port."""
    connection_params = {
        "host": os.getenv("POSTGRES_HOST", "localhost"),
        "port": int(os.getenv("POSTGRES_PORT", "55432")),
        "dbname": os.getenv("POSTGRES_DB", "modulbank_test"),
        "user": os.getenv("POSTGRES_USER", "test_user"),
        "password": os.getenv("POSTGRES_PASSWORD", "local_dev_password"),
        "connect_timeout": 5,
    }

    with psycopg.connect(**connection_params) as connection:
        with connection.cursor() as cursor:
            cursor.execute("SELECT NOW()")
            result = cursor.fetchone()

    assert result is not None, "Query returned no row"
    assert result[0] is not None, "NOW() returned NULL"
