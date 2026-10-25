-- Interview practice — PostgreSQL
-- Schema supplied in the assignment:
-- clients(client_id PK, full_name, city, registered_at DATE)
-- accounts(account_id PK, client_id FK, currency, opened_at DATE, closed_at DATE NULL)
-- transactions(tx_id PK, account_id FK, tx_date TIMESTAMP, amount NUMERIC, tx_type)

-- 1. Clients from Novosibirsk registered in 2025, ordered by registration date.
SELECT client_id, full_name, city, registered_at
FROM clients
WHERE city = 'Новосибирск'
  AND registered_at >= DATE '2025-01-01'
  AND registered_at < DATE '2026-01-01'
ORDER BY registered_at, client_id;

-- 2. Count of active (not closed) accounts by currency.
SELECT currency, COUNT(*) AS open_accounts_count
FROM accounts
WHERE closed_at IS NULL
GROUP BY currency
ORDER BY currency;

-- 3. Total incoming transactions for each client, including those without incoming transactions.
-- Assumption: amount is nonnegative and direction is determined by tx_type.
SELECT c.client_id, c.full_name,
       COALESCE(SUM(t.amount) FILTER (WHERE t.tx_type = 'in'), 0) AS total_incoming
FROM clients AS c
LEFT JOIN accounts AS a ON a.client_id = c.client_id
LEFT JOIN transactions AS t ON t.account_id = a.account_id
GROUP BY c.client_id, c.full_name
ORDER BY total_incoming DESC, c.client_id;

-- 4. Clients who have no accounts.
SELECT c.client_id, c.full_name
FROM clients AS c
WHERE NOT EXISTS (
  SELECT 1 FROM accounts AS a WHERE a.client_id = c.client_id
)
ORDER BY c.client_id;

-- 5. Clients who have more than two accounts.
SELECT c.client_id, c.full_name, COUNT(a.account_id) AS account_count
FROM clients AS c
JOIN accounts AS a ON a.client_id = c.client_id
GROUP BY c.client_id, c.full_name
HAVING COUNT(a.account_id) > 2
ORDER BY account_count DESC, c.client_id;

-- 6. Duplicate transactions (same account_id, tx_date, amount).
-- Shows each duplicate combination and how many times it occurs.
SELECT account_id, tx_date, amount, COUNT(*) AS occurrences
FROM transactions
GROUP BY account_id, tx_date, amount
HAVING COUNT(*) > 1
ORDER BY occurrences DESC, account_id, tx_date;

-- 7. Top 3 clients by outgoing transaction amount in each calendar month.
-- Ties broken by client_id to return exactly three per month.
-- Assumption: amounts are nonnegative; tx_type='out' marks outgoing payments.
WITH monthly_spend AS (
  SELECT DATE_TRUNC('month', t.tx_date)::date AS month,
         c.client_id,
         c.full_name,
         SUM(t.amount) AS total_outgoing
  FROM transactions AS t
  JOIN accounts AS a ON a.account_id = t.account_id
  JOIN clients AS c ON c.client_id = a.client_id
  WHERE t.tx_type = 'out'
  GROUP BY DATE_TRUNC('month', t.tx_date)::date, c.client_id, c.full_name
), ranked AS (
  SELECT *, ROW_NUMBER() OVER (
    PARTITION BY month ORDER BY total_outgoing DESC, client_id
  ) AS position
  FROM monthly_spend
)
SELECT month, position, client_id, full_name, total_outgoing
FROM ranked
WHERE position <= 3
ORDER BY month, position;
