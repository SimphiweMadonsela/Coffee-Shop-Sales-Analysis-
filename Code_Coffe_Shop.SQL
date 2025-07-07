SELECT
    store_location,
    product_type,
    hour_start
    SUM(transaction_qty * unit_price) AS revenue
  FROM COFFEE_SHOP.PUBLIC.SALES_TRANSACTIONS
  GROUP BY store_location, product_type
  QUALIFY ROW_NUMBER() OVER (PARTITION BY store_location ORDER BY revenue DESC) = 3;

SELECT DATE_TRUNC('WEEK',transaction_date ) AS week_start_date,
SUM(transaction_qty * unit_price) AS weekly_sales
FROM COFFEE_SHOP.PUBLIC.SALES_TRANSACTIONS;
GROUP BY week_start_date
ORDER BY week_start_date;

SELECT WEEKOFYEAR(transaction_date) AS week_number,
       store_location,
SUM(transaction_qty*unit_price) AS revenue_per_week
FROM COFFEE_SHOP.PUBLIC.SALES_TRANSACTIONS
GROUP BY week_number,
         store_location
ORDER BY week_number;

SELECT DATE_TRUNC('HOUR', TRANSACTION_TIME) + FLOOR(DATE_PART('MINUTE',transaction_date) / 30) * INTERVAL '30 MINUTE' AS interval_start,
         SUM(transaction_qty*unit_price) AS total_revenue
          MIN(transaction_time)
          MAX(transaction_time)
         FROM COFFEE_SHOP.PUBLIC.SALES_TRANSACTIONS
         GROUP BY interval_start
         ORDER BY interval_start;


         SELECT DATE_TRUNC('HOUR', transaction_date) AS hour_start,
                store_location,
         SUM(transaction_qty*unit_price) AS total_revenue
         FROM COFFEE_SHOP.PUBLIC.SALES_TRANSACTIONS
         GROUP BY hour_start,
                  store_location
         ORDER BY hour_start DESC;
--final code for store performance analysis 
--1. Top product types per store location
-- 2. Total sales and quantity by day
--3. Store performance by total sales and transactions
--4. Top selling products by revenue
--5. Sales and quantity by store location
--6. Hourly sales trends
SELECT store_location,
      product_id,
      product_type,
      product_category,
      product_detail,
      transaction_time,
    SUM(transaction_qty * unit_price) AS total_revenue,
    SUM(transaction_qty) AS total_sales,
    COUNT(transaction_id) AS sales_number,
    TO_CHAR(TRANSACTION_DATE,'YYYYMM') AS month_id,
MONTHNAME(TRANSACTION_DATE) AS month_name,
  DAYNAME(TRANSACTION_DATE) AS day_name,
   
    CASE 
  WHEN transaction_time BETWEEN '06:00:00' AND '11:59:59' THEN 'Morning'
  WHEN transaction_time BETWEEN '12:00:00' AND '16:59:59' THEN 'Afternnon'
  WHEN transaction_time BETWEEN '17:00:00' AND '19:59:59' THEN 'Evening'
  ELSE 'night'
  END AS time_bucket,

  CASE
  WHEN SUM(transaction_qty * unit_price) BETWEEN 0 AND 20 THEN  'low'
  WHEN SUM(transaction_qty * unit_price) BETWEEN 21 AND 40 THEN 'Med'
  WHEN SUM(transaction_qty * unit_price) BETWEEN 41 AND 60 THEN 'High'
  
  ELSE 'High'
  END AS spend_bucket

  FROM COFFEE_SHOP.PUBLIC.SALES_TRANSACTIONS
  GROUP BY product_category,
           store_location,
           month_id,
           month_name,
           transaction_time,
           day_name,
           time_bucket,
           product_id,
           product_type,
           product_detail;
