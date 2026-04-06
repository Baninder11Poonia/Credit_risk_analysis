-- Credit Risk Analysis Project
-- SQL-based analysis using BigQuery
-- This project analyses customer financial risk using SQL
-- Key Factors: Income, Age, Debt Ratio
-- Step 1: Risk Distribution
-- Counts number of customers in each risk category 
WITH clean_data AS (
  SELECT
    Customer_ID,
    SAFE_CAST(Annual_Income AS FLOAT64) AS income,
    SAFE_CAST(Outstanding_Debt AS FLOAT64) AS debt
  FROM `scientific-axle-484119-q5.credit_risk_project.credit_score_raw`
  WHERE
    SAFE_CAST(Annual_Income AS FLOAT64) IS NOT NULL
    AND SAFE_CAST(Outstanding_Debt AS FLOAT64) IS NOT NULL
    AND SAFE_CAST(Annual_Income AS FLOAT64) > 0
),

customer_ratio AS (
  SELECT
    Customer_ID,
    AVG(debt / income) AS avg_debt_ratio
  FROM clean_data
  GROUP BY Customer_ID
),

risk_category AS (
  SELECT
    CASE
      WHEN avg_debt_ratio < 0.01 THEN 'Low Risk'
      WHEN avg_debt_ratio < 0.05 THEN 'Medium Risk'
      ELSE 'High Risk'
    END AS risk_category
  FROM customer_ratio
)

SELECT
  risk_category,
  COUNT(*) AS total_customers
FROM risk_category
GROUP BY risk_category
ORDER BY total_customers DESC;
--Step 2: Age vs Risk Analysis
-- Show how risk varies across age group
WITH clean_data AS (
  SELECT
    Customer_ID,
    SAFE_CAST(Annual_Income AS FLOAT64) AS income,
    SAFE_CAST(Outstanding_Debt AS FLOAT64) AS debt,
    SAFE_CAST(Age AS INT64) AS age
  FROM `scientific-axle-484119-q5.credit_risk_project.credit_score_raw`
  WHERE
    SAFE_CAST(Annual_Income AS FLOAT64) IS NOT NULL
    AND SAFE_CAST(Outstanding_Debt AS FLOAT64) IS NOT NULL
    AND SAFE_CAST(Age AS INT64) IS NOT NULL
    AND SAFE_CAST(Annual_Income AS FLOAT64) > 0
),

customer_ratio AS (
  SELECT
    Customer_ID,
    AVG(debt / income) AS avg_debt_ratio,
    AVG(age) AS age
  FROM clean_data
  GROUP BY Customer_ID
),

risk_category AS (
  SELECT
    Customer_ID,
    age,
    CASE
      WHEN avg_debt_ratio < 0.01 THEN 'Low Risk'
      WHEN avg_debt_ratio < 0.05 THEN 'Medium Risk'
      ELSE 'High Risk'
    END AS risk_category
  FROM customer_ratio
),
final_group AS(
SELECT
  CASE
    WHEN age < 30 THEN 'Young'
    WHEN age < 60 THEN 'Adult'
    ELSE 'Senior'
  END AS age_group,
  risk_category
FROM
  risk_category
)
SELECT
age_group,
risk_category,
  COUNT(*) AS total_customers
FROM final_group
GROUP BY age_group, risk_category 
ORDER BY age_group, total_customers DESC;
-- Step 3: High Risk Profile Analysis
-- Identifies which income and age groups are most likely to be high risk
WITH clean_data AS (
  SELECT
    Customer_ID,
    SAFE_CAST(Annual_Income AS FLOAT64) AS income,
    SAFE_CAST(Outstanding_Debt AS FLOAT64) AS debt,
    SAFE_CAST(Age AS INT64) AS age
  FROM `scientific-axle-484119-q5.credit_risk_project.credit_score_raw`
  WHERE
    SAFE_CAST(Annual_Income AS FLOAT64) IS NOT NULL
    AND SAFE_CAST(Outstanding_Debt AS FLOAT64) IS NOT NULL
    AND SAFE_CAST(Age AS INT64) IS NOT NULL
    AND SAFE_CAST(Annual_Income AS FLOAT64) > 0
),

customer_ratio AS (
  SELECT
    Customer_ID,
    AVG(debt / income) AS avg_debt_ratio,
    AVG(income) AS income,
    AVG(age) AS age
  FROM clean_data
  GROUP BY Customer_ID
),

risk_category AS (
  SELECT
    Customer_ID,
    income,
    age,
    CASE
      WHEN avg_debt_ratio < 0.01 THEN 'Low Risk'
      WHEN avg_debt_ratio < 0.05 THEN 'Medium Risk'
      ELSE 'High Risk'
    END AS risk_category
  FROM customer_ratio
),
final_group AS(
SELECT
  CASE
    WHEN income <50000 THEN 'Low Income'
    WHEN income <100000 THEN 'Medium Income'
    ELSE 'High Income'
  END AS income_group,

  CASE
    WHEN age < 30 THEN 'Young'
    WHEN age < 60 THEN 'Adult'
    ELSE 'Senior'
  END AS age_group
FROM
  risk_category
WHERE risk_category.risk_category = 'High Risk'
)
SELECT
income_group,
age_group,
  COUNT(*) AS total_customers
FROM final_group
GROUP BY income_group, age_group
ORDER BY total_customers DESC;
-- Step 4: Income vs Risk Analysis
-- Show relationship between income level and financial risk
WITH clean_data AS (
  SELECT
    Customer_ID,
    SAFE_CAST(Annual_Income AS FLOAT64) AS income,
    SAFE_CAST(Outstanding_Debt AS FLOAT64) AS debt
  FROM `scientific-axle-484119-q5.credit_risk_project.credit_score_raw`
  WHERE
    SAFE_CAST(Annual_Income AS FLOAT64) IS NOT NULL
    AND SAFE_CAST(Outstanding_Debt AS FLOAT64) IS NOT NULL
    AND SAFE_CAST(Annual_Income AS FLOAT64) > 0
),

customer_ratio AS (
  SELECT
    Customer_ID,
    AVG(debt / income) AS avg_debt_ratio,
    AVG(income) AS income
  FROM clean_data
  GROUP BY Customer_ID
),

risk_data AS (
  SELECT
  CASE
    WHEN income < 50000 THEN 'Low Income'
    WHEN income < 100000 THEN 'Medium Income'
    ELSE 'High Income'
  END AS income_group,
  CASE
      WHEN avg_debt_ratio < 0.01 THEN 'Low Risk'
      WHEN avg_debt_ratio < 0.05 THEN 'Medium Risk'
      ELSE 'High Risk'
    END AS risk_category
  FROM customer_ratio
)

SELECT
income_group,
risk_category,
  COUNT(*) AS total_customers
FROM risk_data
GROUP BY income_group, risk_category 
ORDER BY income_group, total_customers DES
