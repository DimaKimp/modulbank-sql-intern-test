# Modulbank — SQL & Python Internship Test

A reproducible technical assignment project for the Modulbank SQL / Data Engineering internship.

**Stack:** PostgreSQL 18 (verified locally) or PostgreSQL 17 via Docker Compose; Python 3.10+, psycopg 3, pytest.

## Project contents

- `tests/test_db_connection.py`: connects to PostgreSQL, runs `SELECT NOW()`, and asserts a non-null result.
- `sql/interview_tasks.sql`: solutions to all seven interview practice SQL tasks.
- `sql/schema_demo.sql`: optional empty table schema for running the SQL exercises locally.
- `docker-compose.yml`: local PostgreSQL Docker service.
- `screenshots/`: add actual success/failure screenshots after running the tests yourself.

## Verified results (local PostgreSQL on Windows, 25 October 2026)

- PostgreSQL 18.6 on `127.0.0.1:5432`, database `modulbank_test`, role `test_user`.
- `SELECT NOW()` completed successfully using `psql` as `test_user`.
- Python 3.14.7 and pytest 9.1.1: successful database connection test completed (`1 passed in 0.20s`).
- Intentionally invalid password: connection refused as expected (`1 failed`); this verifies the negative scenario, not a regression.
- [Successful pytest run](screenshots/pytest_success.png).

No credentials or `.env` files should be committed. This project was actually tested using a locally installed PostgreSQL server, *without* Docker. Docker Compose remains an optional alternative.

## Windows PowerShell quick start

Prerequisites: Git and Python 3.10+ installed; choose either an existing local PostgreSQL server or Docker Desktop.

1. Clone and enter the repository:

   ```powershell
   git clone https://github.com/DimaKimp/modulbank-sql-intern-test.git
   cd modulbank-sql-intern-test
   ```

2. Copy the safe local example credentials:

   ```powershell
   Copy-Item .env.example .env
   ```

3. Choose a database setup:

   **Option A — local PostgreSQL (verified):** install/start PostgreSQL; create role `test_user` with a password and database `modulbank_test` owned by that role. Edit `.env` to use `POSTGRES_HOST=127.0.0.1`, `POSTGRES_PORT=5432` and the password you assigned to `test_user`.

   **Option B — Docker Compose:** run:

   ```powershell
   docker compose up -d
   docker compose ps
   ```

   Use the matching `.env.example` port `55432`, and keep host access restricted to localhost.

4. Create a Python virtual environment and install packages:

   ```powershell
   python -m venv .venv
   .\.venv\Scripts\python.exe -m pip install -r requirements.txt
   ```

5. Run the expected successful test:

   ```powershell
   .\.venv\Scripts\python.exe -m pytest -v
   ```

   Expected result: `1 passed`. Capture a screenshot for the recruiter.

6. Demonstrate an intentional failure using a wrong password:

   ```powershell
   $env:POSTGRES_PASSWORD = 'intentionally_wrong_password'
   try { .\.venv\Scripts\python.exe -m pytest -q --tb=line } finally { Remove-Item Env:POSTGRES_PASSWORD -ErrorAction SilentlyContinue }
   ```

   Expected result: `1 failed` (authentication error). An intentionally failing run is expected here. Use concise traceback output and ensure screenshots reveal no credentials.

7. Recheck successful execution:

   ```powershell
   .\.venv\Scripts\python.exe -m pytest -v
   ```

8. Optionally create the sample schema (choose ONE method):

   ```powershell
   # Local installation (psql in PATH):
   psql -h 127.0.0.1 -p 5432 -U test_user -d modulbank_test -f sql/schema_demo.sql

   # Or Docker Compose:
   Get-Content -Raw sql/schema_demo.sql | docker compose exec -T postgres psql -U test_user -d modulbank_test
   ```

   This creates empty tables only. SQL aggregation examples need sample records to return meaningful rows.

9. When using Docker, stop containers with `docker compose down`. Do **not** add `-v` unless you want to delete the stored database volume. With local PostgreSQL, no Docker shutdown is necessary.

## Security

Never commit `.env` or real database passwords. `.gitignore` excludes local configuration and Python environment files. The values in `.env.example` are for local development only.

## SQL assumptions

The model uses incoming and outgoing transactions identified by `tx_type = 'in'/'out'`, with nonnegative `amount`. For the top-3 query, `ROW_NUMBER` breaks ties by client ID and returns at most three people per month; replace it with `DENSE_RANK` if all ties must be included.

## Verification status

A full local PostgreSQL + pytest run was performed on Windows on 25 October 2026. The screenshot above documents the passing test; an invalid-password run also produced the expected authentication failure. Tests using the Docker Compose alternative have not been verified.
