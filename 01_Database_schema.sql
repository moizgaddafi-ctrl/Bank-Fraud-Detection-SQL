-- Database Creation

CREATE DATABASE bank_fraud_detection;

USE bank_fraud_detection;

CREATE TABLE customers (
customer_id INT PRIMARY KEY,
first_name VARCHAR(50),
last_name VARCHAR(50),
gender VARCHAR(10),
city VARCHAR(50)
);

CREATE TABLE accounts (
account_id INT PRIMARY KEY,
customer_id INT,
account_type VARCHAR(20),
balance DECIMAL(12,2),
account_status VARCHAR(20),
FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);

CREATE TABLE transactions (
transaction_id INT PRIMARY KEY,
account_id INT,
transaction_date DATETIME,
transaction_type VARCHAR(30),
amount DECIMAL(12,2),
transaction_status VARCHAR(20),
payment_method VARCHAR(30),
merchant VARCHAR(100),
location VARCHAR(50),
FOREIGN KEY (account_id) REFERENCES accounts(account_id)
);

ALTER TABLE transactions DROP COLUMN transaction_date;

CREATE TABLE fraud_alerts (
alert_id INT PRIMARY KEY,
transaction_id INT,
alert_type VARCHAR(50),
risk_score INT,
investigation_status VARCHAR(30),
FOREIGN KEY (transaction_id) REFERENCES transactions(transaction_id)
); 
