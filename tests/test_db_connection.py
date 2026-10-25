"""Тестовое задание Модульбанка: подключение к БД и запрос SELECT NOW()."""

import os

import psycopg
from dotenv import load_dotenv

load_dotenv()


def test_postgresql_connection_and_simple_query():
    """Проверка проходит с верными параметрами; с неверным паролем — завершается ошибкой."""
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

    assert result is not None, "Запрос не вернул строку"
    assert result[0] is not None, "Функция NOW() вернула NULL"
