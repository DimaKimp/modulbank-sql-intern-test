# Modulbank — SQL & Python Internship Test

A reproducible technical assignment project for the Modulbank SQL / Data Engineering internship.

**Stack:** PostgreSQL 17, Docker Compose, Python 3.10+, psycopg 3, pytest.

## Project contents

- `tests/test_db_connection.py`: connects to PostgreSQL, runs `SELECT NOW()`, and asserts a non-null result.
- `sql/interview_tasks.sql`: solutions to all seven interview practice SQL tasks.
- `sql/schema_demo.sql`: optional empty table schema for running the SQL exercises locally.
- `docker-compose.yml`: local PostgreSQL Docker service.
- `screenshots/`: add actual success/failure screenshots after running the tests yourself.

## Windows PowerShell quick start

Prerequisites: Docker Desktop running, Git and Python 3.10+ installed.

1. Clone and enter the repository:

   ```powershell
   git clone https://github.com/DimaKimp/modulbank-sql-intern-test.git
   cd modulbank-sql-intern-test
   ```

2. Copy the safe local example credentials:

   ```powershell
   Copy-Item .env.example .env
   ```

3. Launch PostgreSQL:

   ```powershell
   docker compose up -d
   docker compose ps
   ```

   The postgres service should become healthy. Host port 55432 is restricted to localhost.

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
   $env:POSTGRES_PASSWORD = 'wrong_password'
   .\.venv\Scripts\python.exe -m pytest -v
   Remove-Item Env:POSTGRES_PASSWORD
   ```

   Expected result: `1 failed` (authentication error). Capture a screenshot. An intentionally failing negative run is part of the assignment.

7. Recheck successful execution:

   ```powershell
   .\.venv\Scripts\python.exe -m pytest -v
   ```

8. Optionally create the sample schema:

   ```powershell
   Get-Content -Raw sql/schema_demo.sql | docker compose exec -T postgres psql -U test_user -d modulbank_test
   ```

   This creates empty tables only. SQL aggregation examples need sample records to return meaningful rows.

9. Stop PostgreSQL when done: `docker compose down`. Do **not** add `-v` unless you want to delete the stored database volume.

## Security

Never commit `.env` or real database passwords. `.gitignore` excludes local configuration and Python environment files. The values in `.env.example` are for local development only.

## SQL assumptions

The model uses incoming and outgoing transactions identified by `tx_type = 'in'/'out'`, with nonnegative `amount`. For the top-3 query, `ROW_NUMBER` breaks ties by client ID and returns at most three people per month; replace it with `DENSE_RANK` if all ties must be included.

## Verification status

Source code is prepared and Python syntax was checked. A full PostgreSQL + pytest run and screenshots require running the project on your Windows machine; do not claim these have passed before testing.
