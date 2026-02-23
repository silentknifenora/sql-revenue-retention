CREATE DATABASE customer_revenue_analysis;
USE customer_revenue_analysis;
CREATE TABLE customers (
    customer_id INT PRIMARY KEY AUTO_INCREMENT,
    signup_date DATE NOT NULL,
    customer_segment VARCHAR(50),
    region VARCHAR(50)
);

CREATE TABLE subscriptions (
    subscription_id INT PRIMARY KEY AUTO_INCREMENT,
    customer_id INT,
    plan_type VARCHAR(50),
    monthly_fee DECIMAL(10,2),
    start_date DATE,
    end_date DATE,
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);

CREATE TABLE payments (
    payment_id INT PRIMARY KEY AUTO_INCREMENT,
    subscription_id INT,
    payment_date DATE,
    amount_paid DECIMAL(10,2),
    payment_status VARCHAR(20),
    FOREIGN KEY (subscription_id) REFERENCES subscriptions(subscription_id)
);

CREATE TABLE customer_activity (
    activity_id INT PRIMARY KEY AUTO_INCREMENT,
    customer_id INT,
    activity_date DATE,
    logins_count INT,
    feature_usage_score INT,
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);

SHOW TABLES;
DESCRIBE customers;

INSERT INTO customers (signup_date, customer_segment, region) VALUES
('2023-01-15', 'SMB', 'West'),
('2023-02-10', 'Mid-Market', 'East'),
('2023-03-05', 'Enterprise', 'Central'),
('2023-03-20', 'SMB', 'East'),
('2023-04-12', 'Mid-Market', 'West');

SELECT * FROM customers;

INSERT INTO subscriptions (customer_id, plan_type, monthly_fee, start_date, end_date) VALUES
(1, 'Basic', 29.99, '2023-01-15', NULL),
(2, 'Pro', 59.99, '2023-02-10', NULL),
(3, 'Enterprise', 199.99, '2023-03-05', NULL),
(4, 'Basic', 29.99, '2023-03-20', '2023-06-20'),
(5, 'Pro', 59.99, '2023-04-12', NULL);

INSERT INTO payments (subscription_id, payment_date, amount_paid, payment_status) VALUES
(1, '2023-02-15', 29.99, 'Paid'),
(1, '2023-03-15', 29.99, 'Paid'),
(2, '2023-03-10', 59.99, 'Paid'),
(2, '2023-04-10', 59.99, 'Paid'),
(3, '2023-04-05', 199.99, 'Paid'),
(4, '2023-04-20', 29.99, 'Paid'),
(4, '2023-05-20', 29.99, 'Failed'),
(5, '2023-05-12', 59.99, 'Paid');

INSERT INTO customer_activity (customer_id, activity_date, logins_count, feature_usage_score) VALUES
(1, '2023-03-01', 20, 80),
(1, '2023-04-01', 18, 78),
(2, '2023-03-01', 25, 85),
(2, '2023-04-01', 22, 82),
(3, '2023-04-01', 30, 90),
(4, '2023-04-01', 5, 40),
(4, '2023-05-01', 2, 25),
(5, '2023-05-01', 21, 75);

SELECT * FROM customers;
SELECT * FROM subscriptions;
SELECT * FROM payments;
SELECT * FROM customer_activity;

-- Do a small number of customers generate most of the revenue?
-- Basic Revenue per Customer
SELECT
    c.customer_id,
    SUM(p.amount_paid) AS total_revenue
FROM customers c
JOIN subscriptions s
    ON c.customer_id = s.customer_id
JOIN payments p
    ON s.subscription_id = p.subscription_id
WHERE p.payment_status = 'Paid'
GROUP BY c.customer_id;

-- Rank Customers by Revenue
SELECT
    c.customer_id,
    SUM(p.amount_paid) AS total_revenue,
    RANK() OVER (ORDER BY SUM(p.amount_paid) DESC) AS revenue_rank
FROM customers c
JOIN subscriptions s
    ON c.customer_id = s.customer_id
JOIN payments p
    ON s.subscription_id = p.subscription_id
WHERE p.payment_status = 'Paid'
GROUP BY c.customer_id;

-- REVENUE CONCENTRATION (80/20 Analysis)--
-- Create Revenue CTE
WITH revenue_per_customer AS (
    SELECT
        c.customer_id,
        SUM(p.amount_paid) AS total_revenue
    FROM customers c
    JOIN subscriptions s
        ON c.customer_id = s.customer_id
    JOIN payments p
        ON s.subscription_id = p.subscription_id
    WHERE p.payment_status = 'Paid'
    GROUP BY c.customer_id
    )
-- Cumulative Revenue Calculation
SELECT
    customer_id,
    total_revenue,
    SUM(total_revenue) OVER (ORDER BY total_revenue DESC) AS cumulative_revenue,
    ROUND(
        SUM(total_revenue) OVER (ORDER BY total_revenue DESC) /
        SUM(total_revenue) OVER () * 100, 2
    ) AS cumulative_revenue_pct
FROM revenue_per_customer
ORDER BY total_revenue DESC;

-- RETENTION & COHORT ANALYSIS
-- Identify Signup Cohort--
SELECT
    customer_id,
    DATE_FORMAT(signup_date, '%Y-%m') AS signup_cohort
FROM customers;

-- Combine Cohort + Subscription Status--
WITH cohort_data AS (
    SELECT
        c.customer_id,
        DATE_FORMAT(c.signup_date, '%Y-%m') AS signup_cohort,
        s.start_date,
        s.end_date
    FROM customers c
    JOIN subscriptions s
        ON c.customer_id = s.customer_id
)
SELECT * FROM cohort_data;

-- Calculate Retention by Cohort--
WITH cohort_data AS (
    SELECT
        c.customer_id,
        DATE_FORMAT(c.signup_date, '%Y-%m') AS signup_cohort,
        s.end_date
    FROM customers c
    JOIN subscriptions s
        ON c.customer_id = s.customer_id
)
SELECT
    signup_cohort,
    COUNT(DISTINCT customer_id) AS total_customers,
    COUNT(DISTINCT CASE WHEN end_date IS NULL THEN customer_id END) AS active_customers,
    ROUND(
        COUNT(DISTINCT CASE WHEN end_date IS NULL THEN customer_id END) /
        COUNT(DISTINCT customer_id) * 100, 2
    ) AS retention_rate_pct
FROM cohort_data
GROUP BY signup_cohort
ORDER BY signup_cohort;

-- REVENUE AT RISK FROM CHURN--
-- Revenue per Customer--

WITH revenue_per_customer AS (
    SELECT
        c.customer_id,
        SUM(p.amount_paid) AS total_revenue
    FROM customers c
    JOIN subscriptions s
        ON c.customer_id = s.customer_id
    JOIN payments p
        ON s.subscription_id = p.subscription_id
    WHERE p.payment_status = 'Paid'
    GROUP BY c.customer_id
)
SELECT * FROM revenue_per_customer;

-- Identify Churned Customers--
SELECT
    customer_id
FROM subscriptions
WHERE end_date IS NOT NULL;

-- Revenue at Risk Calculation--
WITH revenue_per_customer AS (
    SELECT
        c.customer_id,
        SUM(p.amount_paid) AS total_revenue
    FROM customers c
    JOIN subscriptions s
        ON c.customer_id = s.customer_id
    JOIN payments p
        ON s.subscription_id = p.subscription_id
    WHERE p.payment_status = 'Paid'
    GROUP BY c.customer_id
)
SELECT
    SUM(r.total_revenue) AS revenue_at_risk
FROM revenue_per_customer r
JOIN subscriptions s
    ON r.customer_id = s.customer_id
WHERE s.end_date IS NOT NULL;

-- SEGMENT-LEVEL REVENUE CONCENTRATION--
-- Revenue by Segment--

SELECT
    c.customer_segment,
    SUM(p.amount_paid) AS segment_revenue
FROM customers c
JOIN subscriptions s
    ON c.customer_id = s.customer_id
JOIN payments p
    ON s.subscription_id = p.subscription_id
WHERE p.payment_status = 'Paid'
GROUP BY c.customer_segment
ORDER BY segment_revenue DESC;

-- Revenue Contribution % by Segment--
SELECT
    customer_segment,
    SUM(amount_paid) AS segment_revenue,
    ROUND(
        SUM(amount_paid) /
        SUM(SUM(amount_paid)) OVER () * 100, 2
    ) AS revenue_pct
FROM customers c
JOIN subscriptions s
    ON c.customer_id = s.customer_id
JOIN payments p
    ON s.subscription_id = p.subscription_id
WHERE p.payment_status = 'Paid'
GROUP BY customer_segment;


