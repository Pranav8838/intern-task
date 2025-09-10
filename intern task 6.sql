-- SAFE: create DB if missing and select it
CREATE DATABASE IF NOT EXISTS sales_db;
USE sales_db;

-- SAFE: drop table if it already exists (so script is idempotent)
DROP TABLE IF EXISTS sales;

-- Create table
CREATE TABLE sales (
  sale_id INT AUTO_INCREMENT PRIMARY KEY,
  product_name VARCHAR(100) NOT NULL,
  sale_date DATE NOT NULL,
  quantity INT NOT NULL,
  price DECIMAL(12,2) NOT NULL
);

-- Insert sample rows (don't provide sale_id so auto_increment stays safe)
INSERT INTO sales (product_name, sale_date, quantity, price) VALUES
('Laptop', '2024-01-05', 10, 50000.00),
('Laptop', '2024-01-15', 8, 52000.00),
('Phone',  '2024-01-10', 20, 20000.00),
('Phone',  '2024-02-08', 15, 21000.00),
('Tablet', '2024-02-15', 12, 30000.00),
('Laptop', '2024-02-20', 7, 51000.00),
('Phone',  '2024-03-05', 25, 20500.00),
('Tablet', '2024-03-10', 18, 29000.00),
('Headphones','2024-03-18', 30, 3000.00),
('Monitor','2024-04-02', 5, 15000.00);

-- -----------------------
-- 1) Top 5 products by total_sales using CTE + RANK (correct way)
-- Note: you MUST compute the rank in a subquery/CTE and then filter by the rank column.
WITH product_sales AS (
  SELECT product_name,
         SUM(quantity * price) AS total_sales
  FROM sales
  GROUP BY product_name
),
ranked AS (
  SELECT product_name,
         total_sales,
         RANK() OVER (ORDER BY total_sales DESC) AS sales_rank
  FROM product_sales
)
SELECT product_name, total_sales, sales_rank
FROM ranked
WHERE sales_rank <= 5
ORDER BY sales_rank, total_sales DESC;

-- -----------------------
-- 2) Average monthly sales (aggregated by month)
SELECT
  DATE_FORMAT(sale_date, '%Y-%m') AS month,
  SUM(quantity * price) AS total_sales
FROM sales
GROUP BY DATE_FORMAT(sale_date, '%Y-%m')
ORDER BY month;

-- -----------------------
-- 3) Detect sales dips using LAG over monthly totals
WITH monthly_sales AS (
  SELECT DATE_FORMAT(sale_date, '%Y-%m-01') AS month_start,
         SUM(quantity * price) AS total_sales
  FROM sales
  GROUP BY month_start
)
SELECT
  month_start AS month,
  total_sales,
  LAG(total_sales, 1) OVER (ORDER BY month_start) AS prev_month_sales,
  total_sales - LAG(total_sales, 1) OVER (ORDER BY month_start) AS sales_diff
FROM monthly_sales
ORDER BY month_start;

-- -----------------------
-- 4) 3-month rolling average of monthly totals
WITH monthly_sales AS (
  SELECT DATE_FORMAT(sale_date, '%Y-%m-01') AS month_start,
         SUM(quantity * price) AS total_sales
  FROM sales
  GROUP BY month_start
)
SELECT
  month_start,
  total_sales,
  ROUND(
    AVG(total_sales) OVER (ORDER BY month_start
                           ROWS BETWEEN 2 PRECEDING AND CURRENT ROW)
  ,2) AS rolling_3mo_avg
FROM monthly_sales
ORDER BY month_start;

-- -----------------------
-- ALTERNATIVES if your MySQL version is older than 8.0
-- (no CTEs or window functions). This gives Top-5 only:
SELECT product_name, SUM(quantity*price) AS total_sales
FROM sales
GROUP BY product_name
ORDER BY total_sales DESC
LIMIT 5;

-- Or a simple variable-based ranking (ties not handled like RANK)
SET @r := 0;
SELECT product_name, total_sales, (@r := @r + 1) AS rank_pos
FROM (
  SELECT product_name, SUM(quantity*price) AS total_sales
  FROM sales
  GROUP BY product_name
  ORDER BY total_sales DESC
) AS t;
