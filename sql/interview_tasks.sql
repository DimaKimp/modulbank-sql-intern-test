-- Решения семи SQL-заданий — PostgreSQL.
-- Структура таблиц из условия:
-- clients(client_id PK, full_name, city, registered_at DATE)
-- accounts(account_id PK, client_id FK, currency, opened_at DATE, closed_at DATE NULL)
-- transactions(tx_id PK, account_id FK, tx_date TIMESTAMP, amount NUMERIC, tx_type)

-- 1. Клиенты из Новосибирска, зарегистрированные в 2025 году.
-- Сортировка по дате регистрации, затем по идентификатору клиента.
SELECT client_id, full_name, city, registered_at
FROM clients
WHERE city = 'Новосибирск'
  AND registered_at >= DATE '2025-01-01'
  AND registered_at < DATE '2026-01-01'
ORDER BY registered_at, client_id;

-- 2. Количество действующих (незакрытых) счетов по валютам.
SELECT currency, COUNT(*) AS open_accounts_count
FROM accounts
WHERE closed_at IS NULL
GROUP BY currency
ORDER BY currency;

-- 3. Общая сумма входящих операций каждого клиента.
-- Учитываются также клиенты без входящих операций (сумма = 0).
-- Предполагается, что amount неотрицателен; направление определяется по tx_type.
SELECT c.client_id, c.full_name,
       COALESCE(SUM(t.amount) FILTER (WHERE t.tx_type = 'in'), 0) AS total_incoming
FROM clients AS c
LEFT JOIN accounts AS a ON a.client_id = c.client_id
LEFT JOIN transactions AS t ON t.account_id = a.account_id
GROUP BY c.client_id, c.full_name
ORDER BY total_incoming DESC, c.client_id;

-- 4. Клиенты, у которых нет ни одного счёта.
SELECT c.client_id, c.full_name
FROM clients AS c
WHERE NOT EXISTS (
  SELECT 1 FROM accounts AS a WHERE a.client_id = c.client_id
)
ORDER BY c.client_id;

-- 5. Клиенты, у которых больше двух счетов.
SELECT c.client_id, c.full_name, COUNT(a.account_id) AS account_count
FROM clients AS c
JOIN accounts AS a ON a.client_id = c.client_id
GROUP BY c.client_id, c.full_name
HAVING COUNT(a.account_id) > 2
ORDER BY account_count DESC, c.client_id;

-- 6. Повторяющиеся транзакции (совпадают account_id, tx_date и amount).
-- Показываются одинаковые комбинации полей и число их повторений.
SELECT account_id, tx_date, amount, COUNT(*) AS occurrences
FROM transactions
GROUP BY account_id, tx_date, amount
HAVING COUNT(*) > 1
ORDER BY occurrences DESC, account_id, tx_date;

-- 7. Три клиента с наибольшей суммой исходящих операций в каждом месяце.
-- При равной сумме порядок определяется по client_id; не более трёх строк на месяц.
-- Предполагается, что amount неотрицателен, а tx_type = 'out' обозначает расход.
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
