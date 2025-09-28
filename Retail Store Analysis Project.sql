-- Creating the table
DROP TABLE IF EXISTS retail
CREATE TABLE retail (
       transactions_id INT PRIMARY KEY,
       sale_date DATE,
       sale_time TIME,
       customer_id INT,
       gender VARCHAR(10),
       age INT,
       category VARCHAR(15),
       quantiy INT,
       price_per_unit FLOAT,
       cogs FLOAT,
       total_sale FLOAT 
);

-- Checking whether the tabel is made or not 
SELECT * FROM retail

-- Importing data into the table we made through csv file 
-- Checking whether the table is imported or not 
SELECT * FROM retail

-- To verify the no.of rows and column from the csv file
SELECT 
    (SELECT COUNT(*) FROM retail) AS row_count,
    (SELECT COUNT(*) 
     FROM information_schema.columns 
     WHERE table_name = 'retail') AS column_count;

------------------------------------  DATA CLEANING   -------------------------------------------------------------------

-- Finding the NULL values
	SELECT * FROM retail
	   WHERE
	   transactions_id IS NULL
	   OR
	   sale_date IS NULL OR sale_time IS NULL OR customer_id IS NULL OR gender IS NULL OR age IS NULL OR 
	   category IS NULL OR quantiy IS NULL OR price_per_unit IS NULL OR cogs IS NULL OR total_sale IS NULL ;

-- We found that 5 columns have null values and one of them is age
SELECT COUNT(*) FROM retail WHERE age IS NULL 

--Calculating the Average of the age column 
SELECT AVG(age)FROM retail WHERE age IS NOT NULL
SELECT ROUND(AVG(age))FROM retail WHERE age IS NOT NULL 

-- Replacing the NULL Values of the age column with the Average of the the column  
UPDATE retail
SET age = (SELECT AVG(age) 
    FROM retail )
    WHERE age IS  NULL

-- Verifying the above query 
SELECT COUNT(*) FROM retail WHERE age IS NULL;

-- Deleting the rest of the Null Values because they were only 3 null values in all the columns
DELETE FROM retail
   WHERE
   transactions_id IS NULL
   OR
   sale_date IS NULL OR sale_time IS NULL OR customer_id IS NULL OR gender IS NULL OR age IS NULL OR 
   category IS NULL OR quantiy IS NULL OR price_per_unit IS NULL OR cogs IS NULL OR total_sale IS NULL ;

-- Verifying the above query
SELECT COUNT(*) FROM retail_sales 

---------- DATA EXPLORATORY ANALYSIS (EDA) ---------------------------------------------
-- How many sales did we make 
SELECT COUNT(*) FROM retail

-- How many uniuque customers we have ?
SELECT DISTINCT(customer_id) FROM retail
SELECT COUNT(DISTINCT customer_id) FROM retail

-- A spelling mistage in the name of column quantity
ALTER TABLE retail RENAME COLUMN quantiy TO quantity;


-------- DATA ANALYSIS AND BUSINESS KEY PROBLEMS WITH ANSWERS -------------------------

-- My Analysis & Findings

-- Q.1 Write a SQL query to retrieve all columns for sales made on '2022-11-05
-- Q.2 Write a SQL query to retrieve all transactions where the category is 'Clothing' and the quantity sold is more than 10 in the month of Nov-2022
-- Q.3 Write a SQL query to calculate the total sales (total_sale) for each category.
-- Q.4 Write a SQL query to find the average age of customers who purchased items from the 'Beauty' category.
-- Q.5 Write a SQL query to find all transactions where the total_sale is greater than 1000.
-- Q.6 Write a SQL query to find the total number of transactions (transaction_id) made by each gender in each category.
-- Q.7 Write a SQL query to calculate the average sale for each month. Find out best selling month in each year
-- Q.8 Write a SQL query to find the top 5 customers based on the highest total sales 
-- Q.9 Write a SQL query to find the number of unique customers who purchased items from each category.
-- Q.10 Write a SQL query to create each shift and number of orders (Example Morning <=12, Afternoon Between 12 & 17, Evening >17)

SELECT * FROM retail

-- Q.1 Write a SQL query to retrieve all columns for sales made on '2022-11-05
SELECT * FROM retail
WHERE sale_date = '2022-11-05'

-- Q.2 Write a SQL query to retrieve all transactions where the category is 'Clothing' and the quantity sold is more than or equal 4 in the month of Nov-2022
SELECT * FROM retail
WHERE 
category = 'Clothing'
AND quantity >= 4
AND sale_date BETWEEN '2022-11-01' AND '2022-11-30'

SELECT * FROM retail 
WHERE category = 'Clothing' AND quantity >= 4
AND
TO_CHAR(sale_date , 'YYYY-MM') = '2022-11'

SELECT category, SUM(quantity) AS total_quantity
FROM retail
WHERE quantity >= 4
AND TO_CHAR(sale_date, 'YYYY-MM') = '2022-11'
GROUP BY category;

-- Q.3 Write a SQL query to calculate the total sales (total_sale) for each category.
SELECT category , SUM(total_sale) AS revenue ,
COUNT(*) AS total_orders
FROM retail
GROUP BY category
ORDER BY revenue DESC 

-- Q.4 Write a SQL query to find the average age of customers who purchased items from the 'Beauty' category.
SELECT ROUND(AVG(age),2) AS average_age
FROM retail
WHERE category = 'Beauty'

-- Q.5 Write a SQL query to find all transactions where the total_sale is greater than 1000.
SELECT * FROM retail
WHERE total_sale > 1000

-- Q.6 Write a SQL query to find the total number of transactions (transaction_id) made by each gender in each category.
SELECT gender, category , COUNT(transactions_id) AS total_count
FROM retail
GROUP BY gender , category
ORDER BY 2

-- Q.7 Write a SQL query to calculate the average sale for each month. Find out best selling month in each year
SELECT
EXTRACT (YEAR FROM sale_date) AS year,
EXTRACT (MONTH FROM sale_date) AS month,
ROUND (CAST(AVG(total_sale) AS NUMERIC), 2) AS average_revenue
FROM retail
GROUP BY
EXTRACT (YEAR FROM sale_date),
EXTRACT (MONTH FROM sale_date)
ORDER BY
year, month;

-- In the above query we have found the avg revenue for each and each month 
-- and now we will find the month for each month having Highest average revenue 
SELECT * FROM
( SELECT 
  EXTRACT (YEAR FROM sale_date) AS year,
  EXTRACT (MONTH FROM sale_date) AS month,
  AVG(total_sale) AS average_revenue,
  RANK() OVER (PARTITION BY EXTRACT(YEAR FROM sale_date) ORDER BY AVG(total_sale) DESC )AS ranking 
  FROM retail
  GROUP BY 1,2 
) AS t1  
WHERE ranking = 1

-- Q.8 Write a SQL query to find the top 5 customers based on the highest total sales 
SELECT customer_id, SUM(total_sale) AS total_revenue
FROM retail
GROUP BY customer_id
ORDER BY 2 DESC
LIMIT 5

-- Q.9 Write a SQL query to find the number of unique customers who purchased items from each category.
SELECT category, COUNT(DISTINCT customer_id) AS no_of_unique_customers
FROM retail
GROUP BY category

-- Q.10 Write a SQL query to create each shift and number of orders (Example Morning <12, Afternoon Between 12 & 17, Evening >17)
WITH hourly_sales AS 
(
SELECT * , 
      CASE 
	      WHEN EXTRACT(HOUR FROM sale_time) <12 THEN 'MORNING'
		  WHEN EXTRACT(HOUR FROM sale_time) BETWEEN 12 AND 17 THEN 'AFTERNOON'
		  ELSE 'EVENING'
	  END AS shift
FROM retail	  
)
SELECT shift,
COUNT(*) AS total_orders
FROM hourly_sales
GROUP BY shift


--- Just to Practice Common Table Expression
WITH hourlyy_sale AS 
( SELECT *,
CASE 
    WHEN EXTRACT(HOUR FROM sale_time) <9 THEN 'SHIFT 1'
	WHEN extract(HOUR FROM sale_time) BETWEEN 9 AND 12 THEN 'SHIFT 2'
	WHEN EXTRACT (HOUR FROM sale_time) BETWEEN 12 AND 15 THEN 'SHIFT 3'
	WHEN EXTRACT (HOUR FROM sale_time) BETWEEN 15 AND 18 THEN 'SHIFT 4'
    WHEN EXTRACT (HOUR FROM sale_time) BETWEEN 18 AND 21 THEN 'SHIFT 4'
	ELSE 'SHIFT 5'
END AS shift_timming
FROM retail
)
SELECT COUNT(*) AS total_orders, SHIFT_TIMMING
FROM hourlyy_sale
GROUP BY shift_timming
ORDER BY total_orders DESC


