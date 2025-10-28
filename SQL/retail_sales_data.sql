SELECT * FROM new_schema.retail_sales_copy;

USE new_schema;

SELECT *
FROM retail_sales_copy;


# What are the total annual sales and how do they vary month by month?
# the total revenue for 2023 is 454,470$, sales showed the month of May with the highest perfomance

SELECT
	MONTHNAME(STR_TO_DATE(date, '%m/%d/%Y')) AS month_name, 
    SUM(total_amount) AS monthly_revenue
FROM retail_sales_copy
WHERE YEAR (STR_TO_DATE(date, '%m/%d/%Y')) = 2023
GROUP BY month_name
ORDER BY STR_TO_DATE(CONCAT('2023-', month_name, '-01'), '%Y-%M-%d') 
;

SELECT 
	SUM(total_amount) AS total_revenue_2023
FROM retail_sales_copy
WHERE YEAR(STR_TO_DATE(date, '%m/%d/%Y')) = 2023
;

# since the project it is based on sales 2023, the best decision is to exclude the sales from 2024

DELETE FROM retail_sales_copy
WHERE YEAR (STR_TO_DATE(date, '%m/%d/%Y')) = 2024
;

SELECT *
FROM retail_sales_copy
;

# Which product category generates the highest revenue?
# the category with highest revenue it's electronics

SELECT
	product_category,
	SUM(total_amount) AS total_revenue
FROM retail_sales_copy
GROUP BY product_category
ORDER BY total_revenue DESC
;

SELECT 
	UPPER(TRIM(product_category))    AS product_category, 
    COUNT(DISTINCT transaction_id )  AS transactions, 
    SUM(quantity)                    AS units_sold,
    AVG(price_per_unit)              AS avg_price_per_unit, 
    ROUND(AVG(total_amount), 2)      AS avg_order_value, 
    SUM(total_amount)                AS total_revenue
FROM retail_sales_copy
GROUP BY UPPER(TRIM(product_category))
ORDER BY total_revenue DESC
;

# make sure there is no duplicates on transaction id and customer id 

SELECT 
	transaction_id,
    COUNT(*) AS duplicate_count
FROM retail_sales_copy
GROUP BY transaction_id
HAVING COUNT(*) > 1
;

SELECT 	
	customer_id, 
    COUNT(*) AS transaction_count
FROM retail_sales_copy
GROUP BY customer_id
ORDER BY transaction_count DESC 
;

# Who are the top 10 customers by total spending?

SELECT 
    customer_id,
    gender,
    age,
    COUNT(DISTINCT transaction_id)  AS transactions,
    SUM(quantity)                   AS units_sold,
    SUM(total_amount)               AS total_revenue
FROM retail_sales_copy
GROUP BY customer_id, gender, age
ORDER BY total_revenue DESC
LIMIT 10
;

WITH customer_sales AS (
    SELECT 
        customer_id,
        gender,
        age,
        product_category,
        SUM(total_amount) AS category_revenue
    FROM retail_sales_copy
    GROUP BY customer_id, gender, age, product_category
),
ranked AS (
    SELECT 
        *,
        RANK() OVER (PARTITION BY customer_id ORDER BY category_revenue DESC) AS category_rank
    FROM customer_sales
)
SELECT 
    customer_id,
    gender,
    age,
    product_category AS top_category,
    SUM(category_revenue) AS total_revenue,
    COUNT(*) AS categories_bought
FROM ranked
WHERE category_rank = 1
GROUP BY customer_id, gender, age, product_category
ORDER BY total_revenue DESC
LIMIT 10;

# How does gender affect purchase behavior (average spend and quantity)?
# females customers spent slightly more and bought marginally more items per order than males

SELECT 	
	gender, 
    COUNT(DISTINCT customer_id)     AS unique_customers,
    COUNT(DISTINCT transaction_id)  AS transactions,
    SUM(quantity)                   AS total_units_sold,
    SUM(total_amount)               AS total_revenue,
	ROUND(AVG(total_amount), 2)     AS avg_order_value, 
    ROUND(SUM(total_amount) / COUNT(DISTINCT customer_id), 2) AS avg_revenue_per_customer,
    ROUND(SUM(quantity) / COUNT(DISTINCT customer_id), 2)     AS avg_units_per_customer
FROM retail_sales_copy
GROUP BY gender
ORDER BY total_revenue DESC
;

# Which age group contributes the most to total sales?
# the age group that contributes more in the revenue are the mature adults with a total revenue of 192350$

SELECT 
	CASE
		WHEN age BETWEEN 18 AND 25 THEN 'Young Adults (18 - 25)'
        WHEN age BETWEEN 26 AND 40 THEN 'Adults (26-40)'
        WHEN age BETWEEN 41 AND 60 THEN 'Mature Adults (41-60)'
        WHEN age >= 61 THEN 'Seniors (61+)'
        ELSE 'Unknown'
	END AS age_group,
    COUNT(DISTINCT customer_id)     AS customers,
    COUNT(DISTINCT transaction_id)  AS transactions,
    SUM(quantity)                   AS total_units_sold,
    SUM(total_amount)               AS total_revenue,
    ROUND(AVG(total_amount), 2)     AS avg_order_value
FROM retail_sales_copy
GROUP BY age_group
ORDER BY total_revenue DESC
;

# Are there any seasonal trends or months with unusually high or low sales?
# Sales peaked in May (53,150) and October (46,580), while September (23,620) had the lowest revenue, showing clear seasonal fluctuations throughout 2023.

WITH base AS (
  SELECT STR_TO_DATE(date, '%m/%d/%Y') AS d, 
	transaction_id,
    total_amount
  FROM retail_sales_copy
),
monthly AS (
  SELECT 
    YEAR(d)               AS yr,
    MONTH(d)              AS month_num,
    DATE_FORMAT(d, '%b')  AS month_name,
    COUNT(DISTINCT transaction_id) AS total_orders,
    SUM(total_amount)     AS monthly_revenue
  FROM base
  GROUP BY YEAR(d), MONTH(d), DATE_FORMAT(d, '%b')
)
SELECT *
FROM monthly
WHERE yr = 2023
ORDER BY month_num 
;

# What is the average price per unit and average quantity sold per category?


SELECT 
	UPPER(TRIM(product_category))   AS product_category,
    SUM(total_amount)               AS total_revenue,
    ROUND(AVG(price_per_unit), 2)   AS avg_price_per_unit,
    ROUND(AVG(quantity), 2)         AS avg_quantity_sold
FROM retail_sales_copy
GROUP BY UPPER(TRIM(product_category))
ORDER BY avg_price_per_unit DESC
;








