-- Optional schema for testing SQL exercises locally (not required by the original task).
CREATE TABLE IF NOT EXISTS clients (
  client_id bigint PRIMARY KEY,
  full_name text NOT NULL,
  city text NOT NULL,
  registered_at date NOT NULL
);
CREATE TABLE IF NOT EXISTS accounts (
  account_id bigint PRIMARY KEY,
  client_id bigint NOT NULL REFERENCES clients(client_id),
  currency text NOT NULL,
  opened_at date NOT NULL,
  closed_at date
);
CREATE TABLE IF NOT EXISTS transactions (
  tx_id bigint PRIMARY KEY,
  account_id bigint NOT NULL REFERENCES accounts(account_id),
  tx_date timestamp NOT NULL,
  amount numeric NOT NULL,
  tx_type text NOT NULL CHECK (tx_type IN ('in', 'out'))
);
