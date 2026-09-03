-- ============================================
-- 1. BASIC TRANSACTION ANALYSIS
-- ============================================

-- Transaction Overview
SELECT transaction_id,account_id,transaction_type,amount,transaction_status
FROM transactions
WHERE transaction_status='Completed';

-- High Value Transactions
SELECT transaction_id,account_id,amount,transaction_status
FROM transactions
WHERE amount>100000
order by amount DESC;

-- Transaction Type Analysis
SELECT transaction_type,
sum(amount) as total_amount ,
count(transaction_id) as transaction_count
from transactions 
group by transaction_type 
order by total_amount DESC;

-- Fraud Risk Classification
SELECT transaction_id,account_id,amount,(
CASE
WHEN amount>=200000 THEN 'High Risk'
WHEN amount>=100000 THEN 'Medium Risk'
ELSE 'Low Risk'
END
) as risk_level
FROM transactions;

-- Potential Fraud Transactions
SELECT
transaction_id,account_id,amount,transaction_status,payment_method,location 
FROM transactions
WHERE amount >150000 or transaction_status='Failed';

-- Transaction Status Analysis 
SELECT count(transaction_id) as no_of_transactions,
sum(amount) as total_trans_amount,
avg(amount) as avg_trans_amount
FROM transactions
group by transaction_status 
order by total_trans_amount DESC;

-- Payment Method Analysis 
SELECT payment_method,
count(transaction_id) as transaction_count,
sum(amount) as total_amount
FROM transactions
group by payment_method
having sum(amount)>200000;

-- City Transaction Analysis 
SELECT location,
sum(amount) as total_transaction_amount 
FROM transactions
group by location
order by total_transaction_amount DESC;

-- Identify Suspicious Transactions
SELECT 
transaction_id,account_id,amount,payment_method,location,transaction_status
FROM transactions
WHERE amount > 100000 and payment_method='Online Banking' and location in ('Dubai','London')
order by amount DESC;

-- Risk Category Analysis
SELECT
CASE 
WHEN amount>=250000 THEN "Critical"
WHEN amount>=100000 THEN "High"
WHEN amount>=75000 THEN "Medium"
ELSE "Low"
END  as Risk_Category,
count(*) as transaction_count
FROM transactions 
group by Risk_Category;

-- ============================================
-- 2. CUSTOMER & FRAUD ANALYSIS USING JOINS
-- ============================================

-- Customer Transaction Details
SELECT c.customer_id,c.first_name,c.last_name
,a.account_id,t.transaction_id,t.amount
FROM customers c 
inner join accounts a 
on a.customer_id=c.customer_id
inner join transactions t 
on a.account_id=t.account_id
order by amount DESC;

-- Customer Total Transaction Amount
SELECT c.customer_id,c.first_name,c.last_name
,sum(t.amount) as total_transaction_amount
FROM customers c 
inner join accounts a 
on a.customer_id=c.customer_id
inner join transactions t 
on a.account_id=t.account_id
group by c.customer_id
order by total_transaction_amount DESC;

-- Customers With High Transaction Activity
SELECT c.customer_id,c.first_name,c.last_name
,sum(t.amount) as total_transaction_amount
FROM customers c 
inner join accounts a 
on a.customer_id=c.customer_id
inner join transactions t 
on a.account_id=t.account_id
group by c.customer_id
having total_transaction_amount > 300000
order by total_transaction_amount DESC;

-- Fraud Alert Investigation
SELECT t.transaction_id,t.account_id,t.amount,t.transaction_status,
f.alert_type,f.risk_score,f.investigation_status
FROM transactions t 
right join fraud_alerts f 
on t.transaction_id=f.transaction_id
order by risk_score DESC;

-- Customer Fraud Exposure
SELECT c.customer_id,c.first_name,c.last_name,
t.transaction_id,t.amount,
f.alert_type,f.risk_score,f.investigation_status
FROM customers c 
join accounts a 
on a.customer_id=c.customer_id
join transactions t 
on a.account_id=t.account_id
join fraud_alerts f 
on t.transaction_id=f.transaction_id
order by risk_score DESC;

-- ============================================
-- 3. CTE Analysis
-- ============================================

-- Customer Transaction Totals
with total_transactions AS(
SELECT c.customer_id,c.first_name,c.last_name
,sum(t.amount) as total_transaction_amount
FROM customers c 
join accounts a 
on a.customer_id=c.customer_id
join transactions t 
on a.account_id=t.account_id
group by customer_id,first_name,last_name
order by total_transaction_amount DESC
)
SELECT * FROM total_transactions;

-- High-Value Customers
with total_transactions AS(
SELECT c.customer_id,c.first_name,c.last_name
,sum(t.amount) as total_transaction_amount
FROM customers c 
join accounts a 
on a.customer_id=c.customer_id
join transactions t 
on a.account_id=t.account_id
group by customer_id,first_name,last_name
order by total_transaction_amount DESC
)
SELECT * FROM total_transactions
where total_transaction_amount > 500000;

-- Customer Transaction Statistics
with customer_transactions AS(
SELECT c.customer_id,c.first_name,c.last_name,
sum(t.amount) as total_transaction_amount,
count(t.transaction_id) as number_of_transaction,
avg(t.amount) as avg_amount
FROM customers c 
join accounts a 
on a.customer_id=c.customer_id
join transactions t 
on a.account_id=t.account_id
group by c.customer_id,c.first_name,c.last_name
) 
SELECT * FROM customer_transactions
where avg_amount > 100000;

-- High-Risk Transaction Summary 
WITH classification AS (
SELECT transaction_id,amount,
CASE 
WHEN amount >= 200000 THEN 'High Risk'
WHEN amount >= 100000 THEN 'Medium Risk'
ELSE 'Low Risk'
END AS risk_level
FROM transactions
),
transaction_summary AS (
SELECT risk_level,
COUNT(transaction_id) AS transaction_count,
SUM(amount) AS total_amount
FROM classification
GROUP BY risk_level
)
SELECT risk_level,transaction_count,total_amount
FROM transaction_summary
ORDER BY total_amount DESC;

-- Fraud Alert Customer Analysis
with customerr AS(
SELECT c.customer_id,c.first_name,c.last_name,f.alert_id
FROM customers c
JOIN accounts a
on a.customer_id=c.customer_id
JOIN transactions t 
on t.account_id=a.account_id
JOIN fraud_alerts f
on t.transaction_id=f.transaction_id
),count_customers AS(
SELECT customer_id,first_name,last_name,
count(alert_id) as fraud_alert_count
FROM customerr
group by first_name,last_name,customer_id 
)

SELECT customer_id,first_name,last_name,
fraud_alert_count
FROM count_customers
order by   fraud_alert_count DESC;

-- ============================================
-- 4. Window Functions Analysis
-- ============================================

-- Rank Transactions by Amount
SELECT transaction_id,account_id,amount,transaction_status,
rank() over(order by amount DESC) as transaction_rank
FROM transactions;

-- Rank Customers by Total Transaction Amount
With total_transactions AS(
SELECT c.customer_id,c.first_name,c.last_name,
sum(t.amount) as total_transaction_amount
FROM customers c 
JOIN accounts a
ON a.customer_id = c.customer_id
JOIN transactions t
ON t.account_id = a.account_id
Group by c.customer_id,first_name,last_name
) 
SELECT 
customer_id,first_name,last_name,total_transaction_amount,
rank() over(order by total_transaction_amount DESC) as customer_rank
FROM total_transactions;

-- Rank Customers Within Each City
with customer_total AS (
SELECT c.customer_id,c.first_name,c.last_name,c.city,
sum(t.amount) as total_transaction_amount 
FROM customers c 
JOIN accounts a
ON a.customer_id = c.customer_id
JOIN transactions t
ON t.account_id = a.account_id
group by c.customer_id,first_name,last_name
) 
SELECT customer_id,first_name,last_name,city,total_transaction_amount
, dense_rank()over(partition by city
order by total_transaction_amount DESC) 
as rankkk
FROM customer_total;

-- Detect Tied Transaction Amounts
SELECT transaction_id,amount,
rank()over(order by amount DESC) as transaction_rank
FROM transactions;

-- Running Transaction Total
SELECT transaction_id,amount,
sum(amount)
over(order by transaction_id ASC ) as running_total 
FROM transactions;

-- ============================================
-- 5. Subqueries Analysis
-- ============================================

-- Above Average Transaction
SELECT transaction_id,account_id,amount,transaction_status 
FROM transactions 
WHERE amount >(SELECT avg(amount) as avg_amount 
FROM transactions ) ;

-- Customer with high value transactions
SELECT distinct c.customer_id,c.first_name,c.last_name
FROM customers c
join accounts a  
on a.customer_id=c.customer_id
join transactions t 
on t.account_id=a.account_id
WHERE a.account_id in
(SELECT account_id from transactions where amount>200000);

-- Customers Above Average Transaction Value
SELECT c.customer_id,c.first_name,c.last_name,
avg(t.amount) as average_transaction_amount
FROM customers c 
JOIN accounts a
ON a.customer_id = c.customer_id
JOIN transactions t
ON t.account_id = a.account_id
GROUP BY c.customer_id,c.first_name,c.last_name
HAVING avg(t.amount) > (
SELECT avg(amount) 
FROM transactions);

-- Customers With No Fraud Alerts
SELECT DISTINCT c.customer_id,c.first_name,c.last_name
FROM customers c
JOIN accounts a
ON a.customer_id = c.customer_id
JOIN transactions t
ON t.account_id = a.account_id
WHERE c.customer_id NOT IN (
SELECT a.customer_id
FROM accounts a
JOIN transactions t
ON t.account_id = a.account_id
JOIN fraud_alerts f
ON f.transaction_id = t.transaction_id
);

-- Correlated Fraud Detection
SELECT t1.transaction_id,t1.account_id,t1.amount
FROM transactions t1
WHERE t1.amount > (
SELECT AVG(t2.amount)
FROM transactions t2
WHERE t2.account_id = t1.account_id
)
ORDER BY t1.account_id, t1.amount DESC;

-- ============================================
-- 6. Advanced Fraud Detection
-- ============================================

-- Top 3 Highest-Risk Transactions
SELECT t.transaction_id,t.account_id,t.amount,t.transaction_status,
CASE 
WHEN amount >=250000 THEN "3"
WHEN amount >=150000 THEN "2"
ELSE "1" 
END as risk_score 
FROM transactions t
ORDER BY amount DESC,risk_score DESC
limit 3 ;

-- Most Suspicious Customers
with associated_fa AS (
select c.customer_id,c.first_name,c.last_name,
sum(t.amount) as fraud_transaction_amount
FROM customers c 
Join accounts a 
on a.customer_id=c.customer_id
Join transactions t
on t.account_id=a.account_id
Join fraud_alerts f 
on f.transaction_id=t.transaction_id
group by c.customer_id,c.first_name,c.last_name
order by  fraud_transaction_amount DESC
limit 5
) 
SELECT customer_id,first_name,last_name, fraud_transaction_amount
FROM associated_fa;

-- Above-Account-Average Fraud Transactions
SELECT t1.transaction_id,t1.account_id,t1.amount,
f1.alert_type,f1.risk_score
FROM transactions t1 
JOIN fraud_alerts f1
on f1.transaction_id=t1.transaction_id
WHERE t1.amount >
(select avg(t2.amount)
FROM transactions t2
WHERE t2.account_id=t1.account_id )
ORDER BY amount DESC,
risk_score DESC;

-- Customer Fraud Ranking
with fraud_count AS(
SELECT c.customer_id,c.first_name,c.last_name,
count(f.alert_id) as fraud_alert_count
FROM customers c 
Join accounts a 
on a.customer_id=c.customer_id
Join transactions t
on t.account_id=a.account_id
Join fraud_alerts f 
on f.transaction_id=t.transaction_id
 GROUP BY c.customer_id,c.first_name,c.last_name
)
SELECT customer_id,first_name,last_name,fraud_alert_count,
rank() over(order by fraud_alert_count DESC) as fraud_rank
FROM fraud_count;

-- Ultimate Fraud Analysis Report
SELECT c.customer_id,c.first_name,c.last_name,
count(t.transaction_id) as total_transactions,
sum(t.amount) as total_transaction_amount,
avg(t.amount) as average_transaction_amount,
count(f.alert_id) as fraud_alert_count,
CASE 
WHEN count(f.alert_id) > 2 THEN "High Risk"
WHEN count(f.alert_id) between 1 and 2 THEN "Medium Risk"
ELSE "Low Risk"
END as customer_risk_level
FROM customers c 
Join accounts a 
on a.customer_id=c.customer_id
Join transactions t
on t.account_id=a.account_id
Left Join fraud_alerts f 
on f.transaction_id=t.transaction_id
group by c.customer_id,c.first_name,c.last_name
order by total_transactions DESC,
fraud_alert_count DESC,
total_transaction_amount DESC;
