use walmartsales;
-- Delete Null Values
DELETE FROM walmartsales.walmart_sales
WHERE COALESCE(
	invoice_id, 
    branch,
	city, 
	customer_type,
	gender, 
	product_line, 
	unit_price,
	quantity,  
	tax_pct,  
	total,  
	date, 
	time,  
	payment, 
	cogs,  
	gross_margin_pct, 
	gross_income, 
	rating) 
    IS NULL;

 -- ------------------------------------------------Feature Engineering-----------------------------------------------------------------------
-- time_of_day
 
SELECT 
time,
(CASE
	WHEN `time` BETWEEN "00:00:00" AND '12:00:00' THEN "Morning"
		WHEN `time` BETWEEN "12:01:00" AND "16:00:00" THEN "Afternoon"
		ELSE "Evening"
	END) AS time_of_day
FROM walmartsales.walmart_sales;
-- add column
ALTER TABLE walmart_sales ADD COLUMN time_of_day VARCHAR(20); 

-- Update data to column
UPDATE walmart_sales
SET time_of_day = (
	CASE
		WHEN `time` BETWEEN "00:00:00" AND '12:00:00' THEN "Morning"
		WHEN `time` BETWEEN "12:01:00" AND "16:00:00" THEN "Afternoon"
		ELSE "Evening"
	END);
  
-- day_name 
SELECT 
	date, dayname(date)
FROM walmart_sales;
-- add column
ALTER TABLE walmart_sales ADD COLUMN day_name VARCHAR(20);
-- Update data to column
UPDATE walmart_sales
SET day_name = dayname(date);

-- month_name
SELECT
	date, monthname(date)
FROM walmart_sales;
-- add column
ALTER TABLE walmart_sales ADD COLUMN month_name VARCHAR(20);
-- Update data to column
UPDATE walmart_sales
SET month_name = monthname(date);
-- day
SELECT
	date, day(date)
FROM walmart_sales;
-- add column
ALTER TABLE walmart_sales ADD COLUMN day VARCHAR(20);
-- Update data to column
UPDATE walmart_sales
SET day = day(date);
-- --------------------------------------------------------------------------------------------------------------------------------------
-- ----------------------------------------------------Generic Question------------------------------------------------------------------
-- 1. How many unique cities does the data have?
SELECT 
	distinct city
FROM walmart_sales;
-- 2. In which city is each branch?
SELECT 
	distinct city,
    branch
FROM walmart_sales;
-- ----------------------------------------------------Product Question------------------------------------------------------------------
-- 1. How many unique product lines does the data have?
SELECT 
	distinct product_line
FROM walmart_sales;

-- What is the most common payment method?
SELECT
	distinct payment, count(payment) as total_payment_method
FROM walmart_sales
GROUP BY payment
ORDER BY 2 desc;

-- What is the most selling product line?
SELECT
	distinct product_line, sum(quantity) as qty
FROM walmart_sales
GROUP BY 1
ORDER by 2 desc;
-- What is the total revenue by month?
SELECT 
	month_name, sum(total) as revenue
FROM walmart_sales
GROUP BY 1
ORDER BY 2 desc;
-- What month had the largest COGS?
SELECT 
	month_name, sum(cogs) as cogs
FROM walmart_sales
GROUP BY 1
ORDER BY 2 desc;
-- What product line had the largest revenue?
SELECT 
	product_line, sum(total) as revenue
FROM walmart_sales
GROUP BY 1
ORDER BY 2 desc;
-- What is the city with the largest revenue?
SELECT
	city, sum(total) as revenue
FROM walmart_sales
GROUP BY 1
ORDER BY 2 desc;
-- What product line had the largest VAT?
SELECT
	product_line,
    avg(tax_pct) as avg_vat
FROM walmart_sales
GROUP BY 1
ORDER BY 2 desc;
-- Fetch each product line and add a column to those product line showing "Good", "Bad". Good if its greater than average sales
SELECT 
	avg(quantity) as avg_qty
FROM walmart_sales;

SELECT 
	product_line,
    CASE 
		WHEN avg(quantity) > 6 then 'Good'
        ELSE 'Bad'
	END as sales_status
FROM walmart_sales
GROUP BY 1;
-- Which branch sold more products than average product sold?
SELECT 
	branch,
    sum(quantity) as qty
FROM walmart_sales
GROUP BY 1
HAVING sum(quantity) > (SELECT avg (quantity) FROM walmart_sales);
-- What is the most common product line by gender?
SELECT 
	product_line,
    gender,
    count(gender)
FROM walmart_sales
GROUP BY 1, 2
ORDER BY 3 desc;
-- What is the average rating of each product line?
SELECT
	product_line,
    avg(rating) as avg_rating
FROM walmart_sales
GROUP BY 1
ORDER BY 2 desc;

-- -----------------------------------------------Sales----------------------------------------------------
-- Number of sales made in each time of the day per weekday
SELECT 
	time_of_day,
    COUNT(*) as total_sales
FROM walmart_sales
WHERE day_name = "Sunday"
GROUP BY 1
ORDER BY 2 desc;
-- -- Evening have most sales, people are pack during that time of day
-- Which of the customer types brings the most revenue?
SELECT 
	customer_type,
    sum(quantity) as revenue
FROM walmart_sales
group by 1
order by 2 desc;
-- Which city has the largest tax percent/ VAT (Value Added Tax)?
SELECT
	city,
    ROUND(AVG(tax_pct),2) as avg_vat
FROM walmart_sales
GROUP BY 1
ORDER BY 2 desc;
-- Which customer type pays the most in VAT?
SELECT
	customer_type,
	ROUND(AVG(tax_pct),2) as avg_vat
FROM walmart_sales
GROUP BY 1
ORDER BY 2 desc;

-- ----------------------------------------------------Customer Question------------------------------------------------------------------
-- How many unique customer types does the data have?
SELECT
	distinct customer_type
FROM walmart_sales;

-- How many unique payment methods does the data have?
SELECT
	distinct payment
FROM walmart_sales;
-- What is the most common customer type?
SELECT 
	customer_type,
    count(customer_type) as count_cust
FROM walmart_sales
GROUP BY 1
ORDER BY 2 desc;
-- Which customer type buys the most?
SELECT 
	customer_type,
    ROUND(sum(total),2) as revenue
FROM walmart_sales
GROUP BY 1
ORDER BY 2 desc;
-- What is the gender of most of the customers?
SELECT
	customer_type,
    gender,
    count(gender)
FROM walmart_sales
GROUP BY 1, 2
ORDER BY 3 desc;
-- What is the gender distribution per branch?
SELECT 
	branch,
    gender,
    count(*) as gender_cnt
FROM walmart_sales
GROUP BY 1, 2
ORDER BY 1;
-- Which time of the day do customers give most ratings?
SELECT
	time_of_day,
    ROUND(avg(rating),2) as avg_rating
FROM walmart_sales
GROUP BY 1
ORDER BY 2 desc;
-- Which time of the day do customers give most ratings per branch?
SELECT
	time_of_day,
    branch,
	round(avg(rating),2) as avg_rating
FROM walmart_sales 
GROUP BY 1,2 
ORDER BY 2, 3;

-- Which day of the week has the best avg ratings?
SELECT
	day_name,
    ROUND(avg(rating),2) as avg_rating
FROM walmart_sales
GROUP BY 1
ORDER BY 2 desc;
-- Which day of the week has the best average ratings per branch?
SELECT
	branch,
    day_name,
    ROUND(avg(rating),2) as avg_rating
FROM walmart_sales
GROUP BY 1,2 
ORDER BY 3 desc;