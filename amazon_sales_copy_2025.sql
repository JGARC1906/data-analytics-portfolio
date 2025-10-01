SELECT * FROM amazon_sales_2025.`amazon_sales_data 2025`;

RENAME TABLE `amazon_sales_data 2025` TO amazon_sales_data_2025; 

CREATE TABLE amazon_sales_copy AS 
SELECT * FROM amazon_sales_data_2025;

#creating a copy from the original source is necessary because that way the main source is not modified 

SELECT * 
FROM amazon_sales_copy;

SHOW TABLES;

SELECT * 
FROM amazon_sales_copy;

#Customer Revenue 
#Who are the top customers (those who have spent the most)?
#Are there customers who place repeat orders, or do most buy only once?

SELECT * 
FROM amazon_sales_copy; 

# Top customers with their payment method used, total orders, total spent and average order value.

WITH top_customers AS (
	SELECT
		UPPER(TRIM(customer_name)) AS customer, 
        SUM(total_sales) AS total_spent
	FROM amazon_sales_copy
    WHERE Status = 'completed'
    GROUP BY UPPER(TRIM(customer_name))
    ORDER BY total_spent DESC
    LIMIT 10
)
SELECT 
	t.customer, 
    a.payment_method, 
    COUNT(*) AS total_orders,
    SUM(a.total_sales) AS total_spent, 
    ROUND(AVG(a.total_sales), 2) AS avg_order_value
FROM top_customers t
JOIN amazon_sales_copy a 
	ON UPPER(TRIM(a.customer_name)) = t.Customer
WHERE a.status = 'completed'
GROUP BY t.customer, a.payment_method
ORDER BY t.customer, total_spent DESC
;

# method spend share pct: identifies the method payment favorite
# methods orders share pct : % of their orders use that method 


WITH top_customers AS (
	SELECT 
		UPPER(TRIM(customer_name)) AS customer, 
        SUM(total_sales) AS  total_spent_overall
	FROM amazon_sales_copy
    WHERE UPPER(status) = 'completed'
    GROUP BY UPPER(TRIM(customer_name))
    ORDER BY total_spent_overall DESC
    LIMIT 10
),
per_customer_method AS (
	SELECT
		UPPER(TRIM(a.customer_name)) AS customer, 
        a.payment_method, 
        COUNT(*) AS total_orders, 
        SUM(a.total_sales) AS total_spent,
        ROUND(AVG(a.total_sales), 2) AS avg_order_value
	FROM amazon_sales_copy a
    JOIN top_customers t
		ON UPPER(TRIM(a.customer_name)) = t.Customer
	WHERE UPPER(status) = 'completed'
    GROUP BY UPPER(TRIM(a.customer_name)), a.payment_method
), 
with_shares AS (
	SELECT
		p. *, 
        SUM(p.total_spent) OVER (PARTITION BY P.customer) AS customer_spent_sum,
        SUM(p.total_orders) OVER (PARTITION BY p.customer) AS customer_orders_sum
	FROM per_customer_method p 
)
SELECT
	customer, 
    payment_method,
    total_orders,
    total_spent, 
    ROUND( 100 * total_spent /NULLIF(customer_spent_sum, 0), 2) AS method_spend_share_pct, 
    ROUND( 100 * total_orders / NULLIF(customer_orders_sum,0), 2) AS method_orders_share_pct,
    avg_order_value
FROM with_shares
ORDER BY customer, method_spend_share_pct DESC, total_spent DESC
;

# clients with the number of repeated orders, their total spent and average order values. 

WITH per_cust AS (
	SELECT
		UPPER(TRIM(customer_name)) AS customer,
		COUNT(*) AS orders_completed,
		SUM(Total_sales) AS total_spent
	FROM amazon_sales_copy
    WHERE UPPER(status) = 'completed'
    GROUP BY UPPER(TRIM(customer_name))
)
SELECT 
	customer,
    orders_completed,
    total_spent,
    ROUND(total_spent / orders_completed, 2) AS avg_order_values 
FROM per_cust
WHERE orders_completed >= 2
ORDER BY orders_completed DESC, total_spent DESC
;
 

#order status
#What is the percentage of delivered, pending, and canceled orders?
#Is there any category with more cancellations than others?

# The total orders and their percentage are grouped by their own status order. 

SELECT Status, 
COUNT(*) AS Total_orders,
ROUND(COUNT(*) * 100 / (SELECT COUNT(*) FROM amazon_sales_copy), 1)  AS percentage
FROM amazon_sales_copy
GROUP BY Status;

# based on the column of cancel rate product the category with more cancellations it's home appliances

WITH totals AS (
	SELECT
		category, 
        COUNT(*) AS total_orders
        FROM amazon_sales_copy
        GROUP BY category
), 
cancels AS (
	SELECT 
		category, 
        COUNT(*) AS cancelled_orders
	FROM amazon_sales_copy
    WHERE status = 'Cancelled'
    GROUP BY category
)
SELECT 
	t.category,
    t.total_orders, 
    coalesce(c.cancelled_orders, 0) AS cancelled_orders, 
    ROUND(
		(COALESCE(c.cancelled_orders, 0) * 100) / NULLIF(t.total_orders, 0), 2)
         AS cancel_rate_product 
FROM totals t
LEFT JOIN cancels c 
	ON t.category = c.category 
ORDER BY cancel_rate_product DESC, t.total_orders DESC
;

#Methods
#Which payment method generates the highest total revenue, not just the most orders? - - PayPal
#Is there a difference in cancellation rates depending on the payment method? - - there is more cancellation products on gifts cards as
# a payment method than debit card, however; debit card has more cancelled orders that gifts cards 

SELECT * 
FROM amazon_sales_copy;

SELECT 
	payment_method,
    COUNT(*) AS orders,
    SUM(Total_Sales) AS revenue_delivered,
    ROUND(AVG(Total_sales), 2) AS avg_ticket,
    ROUND(SUM(Total_sales) * 100
	      / SUM(SUM(Total_sales)) OVER (), 2) AS Revenue_share_product
FROM amazon_sales_copy
WHERE Status = "completed"
GROUP BY Payment_method
ORDER BY revenue_delivered DESC, orders DESC
;

SELECT 
	payment_method,
    COUNT(*) AS total_orders,  
    SUM( CASE WHEN Status = 'Cancelled' THEN 1 ELSE 0 END)            AS cancelled_orders, 
    ROUND(SUM(CASE WHEN Status = 'Cancelled' THEN 1 ELSE 0 END) * 100 
		   / COUNT(*), 2)                                             AS cancelled_rate_product,
	SUM(CASE WHEN Status = 'Cancelled' THEN total_sales ELSE 0 END)   AS cancelled_revenue, 
    SUM(CASE WHEN Status = 'completed' THEN Total_sales ELSE 0 END)   AS delivered_revenue
FROM amazon_sales_copy
GROUP BY Payment_method
ORDER BY Cancelled_rate_product DESC, Cancelled_revenue DESC
;

#Time Analysis
#Which months had the highest sales?

SELECT * 
FROM amazon_sales_copy;

SELECT Date
FROM amazon_sales_copy
ORDER BY Date DESC;

# April would not be considered because there is only 2 days of that month 

# February: less customers, but each customer spend more
# March: more customers, but with purchases of less value in average
# april: few orders (3), the average ticket it's high but the total is low because there are no sells. 


SELECT
	date_format(str_to_date(`Date`, '%d-%m-%y'), '%Y-%m') AS sales_by_month,
    SUM(Total_Sales) AS Revenue,
    COUNT(*) AS total_orders,
    ROUND(AVG(total_sales), 2) AS avg_order_value
FROM amazon_sales_copy
WHERE Status = 'Completed'
GROUP BY sales_by_month
ORDER BY Revenue DESC 
;

#March had a bigger revenue compared with february with a difference of 4280$ 
#probably one of the reasons it's because march had 3 more days to make more sales
SELECT (45145)- (40865);

#Products
#Which products generate the most revenue even if they aren’t the top sellers in quantity?
#Are there products with a high cancellation rate?

SELECT * 
FROM amazon_sales_copy;

#Make sure the consistency of revenue
SELECT SUM(total_sales) AS recorded, SUM(price * quantity) AS recomputed
FROM amazon_sales_copy
WHERE Status = 'completed';

#Which products generate the most revenue even if they aren’t the top sellers in quantity?
# - - the products that generate more revenue despite of not being top sellers are laptops and refrigerators 

WITH agg AS (
	SELECT 
		product, 
		SUM(Quantity)        AS units_sold, 
        SUM(total_sales)     AS revenue, 
        ROUND(AVG(PRICE), 2) AS avg_price 
	FROM amazon_sales_copy
    WHERE status = 'completed' 
    GROUP BY product 
), 
ranked AS ( 
	SELECT 
		product, 
        units_sold, 
        revenue, 
        avg_price, 
        RANK () OVER (ORDER BY revenue DESC) AS revenue_rank,
        RANK () OVER (ORDER BY units_sold DESC ) AS quantity_rank 
	FROM agg
)
SELECT * 
FROM ranked
ORDER BY revenue_rank; 

#Are there products with a high cancellation rate?
# - - the product with higher cancellation rate it's washing machines with 50% of rate

WITH total AS (
	SELECT 
		product, 
        COUNT(*) AS total_orders
	FROM amazon_sales_copy
    GROUP BY product
), 
cancelled AS ( 
	SELECT 
		product, 
        COUNT(*) AS cancelled_orders 
	FROM amazon_sales_copy
    WHERE Status = 'cancelled'
    GROUP BY product 
) 
SELECT 
	t.product, 
    t.total_orders, 
    COALESCE(c.cancelled_orders, 0) AS cancelled_orders, 
    ROUND(
		(COALESCE(c.cancelled_orders, 0) * 100) / NULLIF(t.total_orders,0), 2)
        AS cancel_rate_product 
FROM total t
LEFT JOIN cancelled c 
	ON t.product = c.product
ORDER BY cancel_rate_product DESC, t.total_orders DESC
;

#method payment that generates more revenue
# - - the method payment that generates more revenue it's paypal, it also has the most orders, there must be a reason why PayPal has a higher use of method payment with the customers

SELECT * 
FROM amazon_sales_copy;

SELECT 
	payment_method, 
    COUNT(*)                     AS orders,
    SUM(total_sales)             AS revenue_completed, 
    ROUND(AVG(total_sales), 2)   AS avg_ticket, 
    ROUND (
		SUM(total_sales) * 100 / SUM(SUM(total_sales)) OVER (), 2)                           
        AS revenue_share_product 
FROM amazon_sales_copy
WHERE Status = 'Completed'
GROUP BY payment_method
ORDER BY Revenue_completed DESC, orders DESC
;
    
#cancellation rate by method
# -- the method payment with higher cancellations rates it's gift cards 

# -- the cancel rate product it's higher with gift card, now I want to see the categories and investigate if there is something in common with the type of products that are cancelled

SELECT 
	payment_method, 
    COUNT(*) AS total_orders, 
    SUM(CASE WHEN Status = 'Cancelled' THEN 1 ELSE 0 END) AS cancelled_orders, 
    CONCAT(ROUND(
		SUM(CASE WHEN Status = 'Cancelled' THEN 1 ELSE 0 END) * 100 
        / COUNT(*), 2), '%') AS cancel_rate_product 
	FROM amazon_sales_copy
    GROUP BY Payment_method
    ORDER BY cancel_rate_product DESC, cancelled_orders DESC
    ;

# -- clothing, books, home appliances have a high cancellation rate, but there are a few orders

# -- i like the following table because it shows the highest cancellation rates, but as I said previously
# since the total orders are less than 10, just with one cancelled order the percentage increase considerably
# therefore I want to see the cancellation rate by separated payments methods. 


SELECT 
	Category, 
    Payment_Method,
    CONCAT(ROUND(
		100 * SUM(CASE WHEN Status = 'cancelled' THEN 1 ELSE 0 END) / COUNT(*), 2), '%')
        AS cancellation_rate_product,
	SUM( CASE WHEN Status = 'cancelled' THEN 1 ELSE 0 END) AS cancelled_orders,
	COUNT(*) AS total_orders 
FROM amazon_sales_copy
GROUP BY category, Payment_Method
ORDER BY cancellation_rate_product DESC
;

# -- GIFTS CARDS
# -- most effective purchases with gifts cards are electronics, there could be an improvement between 
# publicity and electronics to increase the sales and reduce loses for cancellations. 
# -- another recommendation would be that amazon could encourage customers to the use of eletronics 
# specially with the sales of electronics products.

SELECT 
	category, 
    SUM( CASE WHEN Status = 'cancelled' THEN 1 ELSE 0 END) AS cancelled_orders,
    COUNT(*) AS total_orders,
    CONCAT(ROUND( 100 * SUM(CASE WHEN Status = 'cancelled' THEN 1 ELSE 0 END) / COUNT(*), 2), '%')
    AS cancellation_rate_product
FROM amazon_sales_copy
WHERE payment_method = 'Gift card'
GROUP BY category
ORDER BY cancellation_rate_product DESC
;

# -- CREDIT CARD 
# -- credit card has a high total orders with 54, but it has 16 cancelled orders

SELECT 
	category,
    SUM(CASE WHEN Status = 'cancelled' THEN 1 ELSE 0 END) AS cancelled_orders,
    COUNT(*) AS total_orders, 
    CONCAT(ROUND( 100 * SUM(CASE WHEN Status = 'cancelled' THEN 1 ELSE 0 END) / COUNT(*), 2), '%')
    AS cancellation_rate_product
FROM amazon_sales_copy
WHERE payment_method = 'credit card'
GROUP BY category
ORDER BY cancellation_rate_product DESC
;

# -- DEBIT CARD 
# -- debit card has a total orders of 53, but it has 20 cancelled orders even more than credit card, electronics is the category with most orders by far
# --  there is more effectiveness in buying electronics with debit card than credit card
# -- there is a few orders in the categories of footwear, clothing and home appliances, among these categories each one have a total of 5 orders therefore I could not give analyze an accurate insight for these orders.

# -- my theory about the footwear and clothing cancellations might be wrong selections for the sizes, I believe that every product within those categories must offer a good information with visualization and a list of sizes for customers and their purchases. 


SELECT 
	category, 
    SUM(CASE WHEN Status = 'cancelled' THEN 1 ELSE 0 END) AS cancelled_orders, 
    COUNT(*) AS total_orders, 
    CONCAT(ROUND( 100 * SUM(CASE WHEN Status = 'cancelled' THEN 1 ELSE 0 END) / COUNT(*), 2), '%')
    AS cancellation_rate_product
FROM amazon_sales_copy
WHERE payment_method = 'debit card'
GROUP BY category
ORDER BY cancellation_rate_product DESC
;

# -- PAYPAL
# -- paymal it's one of the best payment methods with a total of 60 orders and just 16 cancelled orders 
# -- electronics, footwear and clothing shows a good cancellation rate lower than 26% each one. 

SELECT 
	category, 
    SUM(CASE WHEN Status = 'cancelled' THEN 1 ELSE 0 END) AS cancelled_orders, 
    COUNT(*) AS total_orders, 
    CONCAT(ROUND( 100 * SUM(CASE WHEN Status = 'cancelled' THEN 1 ELSE 0 END) / COUNT(*), 2), '%')
    AS cancellation_rate_product
FROM amazon_sales_copy
WHERE payment_method = 'Paypal'
GROUP BY category
ORDER BY cancellation_rate_product DESC
;

# -- AMAZON PAY 
# -- amazon pay has the better results with the total orders with 41 orders and just 7 orders cancelled.
# -- it is the method where most books are purchased, they could increase the interest of customers by showing reviews by showing percentages by people who likes/dislike the book.
# -- since the sales are on amazon app, once customers finished their orders they could offer an advantage/rewards/offers for their customers such as an discount of future purchases, one month free for their streaming apps. 
# -- amazon might have more users of their payment method by giving to the customers kind of rewards, that way people would have that feeling of having something back, that could be one option to reduce future cancellations. 

# -- to prevent more future cancellation orders among all the payment methods withing the categories of footwear and clothing is giving a good list of information about the sizes, if the customers have a easy way to know their sizes the cancellations could decrease in those categories. 
# -- Definitely the publicity must be present in the electronics category where there is the most amount of orders we can see. 

SELECT 
	category, 
    SUM(CASE WHEN Status = 'cancelled' THEN 1 ELSE 0 END) AS cancelled_orders,
    COUNT(*) AS total_orders, 
    CONCAT(ROUND( 100 * SUM(CASE WHEN Status = 'cancelled' THEN 1 ELSE 0 END) / COUNT(*), 2), '%')
    AS cancellation_rate_product
FROM amazon_sales_copy
WHERE payment_method = 'amazon pay'
GROUP BY category
ORDER BY cancellation_rate_product DESC
;

# -- the next query contains the same information showed before, it's a practice to use CTE's by having it all together. 

WITH rates AS (
	SELECT
		payment_method, 
        category,
        SUM(CASE WHEN status = 'cancelled' THEN 1 ELSE 0 END) AS cancelled_orders, 
        COUNT(*) AS total_orders,
        100 * SUM(CASE WHEN status = 'cancelled' THEN 1 ELSE 0 END) / NULLIF(COUNT(*), 0)
        AS cancellation_rate
	FROM amazon_sales_copy
    GROUP BY payment_method, category
), 
ranked AS (
	SELECT 
		payment_method, 
        category, 
        cancelled_orders, 
        total_orders, 
        cancellation_rate,
        ROW_NUMBER () OVER (
			PARTITION BY payment_method
            ORDER BY cancellation_rate DESC, total_orders DESC
		) AS rn 
	FROM rates 
)
SELECT 
	payment_method, 
    category, 
    cancelled_orders, 
    total_orders, 
    CONCAT(ROUND(cancellation_rate, 2), '%') AS cancellation_rate_product
FROM ranked 
WHERE rn <= 5
ORDER BY payment_method,
		cancellation_rate_product DESC, 
        total_orders DESC
;

    
#Location
#Which cities generate the highest sales?
#Are there cities with a high cancellation rate?

#the next query it is being used for these reasons:
# assure that cities are writed down as one to avoid duplicates
# demonstrate the number of orders, revenue and average ticket to bring more backgrond
# demonstrate the revenue share product
# give a clear order with revenue rank 

SELECT * 
FROM amazon_sales_copy;

WITH base AS ( 
	SELECT
		UPPER(TRIM(customer_location)) AS city, 
        total_sales
	FROM amazon_sales_copy
    WHERE UPPER(status) = 'Completed' 
), 
agg AS ( 
	SELECT
		city,
        COUNT(*)  AS orders,
        SUM(total_sales)  AS revenue, 
        ROUND(AVG(total_sales),2)  AS avg_ticket 
	FROM base
    GROUP BY city 
) 
SELECT 
	city, 
    orders, 
    revenue, 
    avg_ticket, 
    ROUND(revenue * 100 / SUM(revenue) OVER (), 2) AS revenue_share_product,
    RANK () OVER ( ORDER BY revenue DESC) AS revenue_rank 
FROM agg 
ORDER BY revenue DESC; 

# cities with high cancelation rate 
# -- based on the cancelled revenue rank, dallas and denver are the cities with more revenue cancelled 
# -- dallas and denver could have a lower cancel rate product compared with other cities, however I believe that the revenue cancelled demonstrates another perspective 


WITH base AS ( 
  SELECT 
    UPPER(TRIM(customer_location)) AS city, 
    status, 
    total_sales 
  FROM amazon_sales_copy
), 
per_city AS (
  SELECT
    city,
    COUNT(*) AS total_orders,
    SUM(CASE WHEN status = 'cancelled' THEN 1 ELSE 0 END)               AS cancelled_orders,
    SUM(total_sales)                                                    AS revenue_total,
    SUM(CASE WHEN status = 'cancelled' THEN total_sales ELSE 0 END)     AS revenue_cancelled,
    SUM(CASE WHEN status = 'completed' THEN total_sales ELSE 0 END)     AS revenue_completed
  FROM base
  GROUP BY city
),
metrics AS (
  SELECT
    city,
    total_orders,
    cancelled_orders,
    revenue_total,
    revenue_cancelled,
    revenue_completed,
    ROUND(cancelled_orders * 100.0 / NULLIF(total_orders, 0), 2) AS cancel_rate_percentage,
    ROUND(revenue_cancelled * 100.0 / NULLIF(revenue_total, 0), 2) AS lost_revenue_percentage,
    ROUND(revenue_cancelled * 100.0 / NULLIF(SUM(revenue_cancelled) OVER (), 0), 2) AS share_of_cancelled_revenue
  FROM per_city
)
SELECT
  city,
  total_orders,
  cancelled_orders,
  cancel_rate_percentage,
  revenue_total,
  revenue_cancelled,
  lost_revenue_percentage,
  share_of_cancelled_revenue,
  ROUND(revenue_total / NULLIF(total_orders,0), 2) AS average_order_value,
  RANK() OVER (ORDER BY cancel_rate_percentage DESC)   AS cancel_rate_rank,
  RANK() OVER (ORDER BY revenue_cancelled DESC) AS cancelled_revenue_rank
FROM metrics
ORDER BY cancel_rate_percentage DESC, revenue_cancelled DESC
;


# insight: Dallas is the city with most loses in revenue cancelled ($15,350, 56.5% of their revenue) 
# while LA has the highest cancellation rate (52.9% of their orders).
# cities such as Denver and Miami appears in both rankings, these are locations that must be improved. 

# recommendation: prioritize campaigns of retention and supervise operations and logistics in Dallas, LA, Miami, Denver to reduce loses.
# improve sales in stable cities such as Seattle and Houston, those places have good sales and low cancellation rates. 


#top categories by revenue 

SELECT 
	category,
    SUM(total_sales) AS total_revenue,
    COUNT(*) AS total_orders,
    ROUND(AVG(total_sales), 2) AS avg_order_value
FROM amazon_sales_copy
WHERE Status = 'completed'
GROUP BY category 
ORDER BY total_revenue DESC;



    



