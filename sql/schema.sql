CREATE TABLE lines(
    id INTEGER PRIMARY KEY,
    line INTEGER NOT NULL);

CREATE TABLE accounts(
    id INTEGER PRIMARY KEY,
    name TEXT NOT NULL,
    account_type TEXT NOT NULL);

CREATE TABLE entries(
    id INTEGER PRIMARY KEY,
    ledger INTEGER NOT NULL,
    account INTEGER NOT NULL,
    reference_number TEXT,
    description TEXT NOT NULL,
    memo TEXT,
    pennies INTEGER NOT NULL);
