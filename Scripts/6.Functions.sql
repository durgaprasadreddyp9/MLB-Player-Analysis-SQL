-- FUNCTION BASICS

SELECT ROUND(happiness_score) AS score
FROM happiness_scores

SELECT CURRENT_DATE()

-- Aggregate Functions 
SELECT AVG(happiness_score)
FROM happiness_scores

-- General Functions 
SELECT UPPER(country) AS country
FROM happiness_scores

-- Numeric  Functions 
-- Applying a log transform to the population of each country 
SELECT country, ROUND(LOG(population),2) AS log_pop
FROM country_stats


SELECT country, population/5
FROM country_stats

-- TASK1: How many customers have spent $0-$10 on our products and so on for every $10 range.
WITH CTE AS(SELECT o.customer_id, sum(o.units * p.unit_price) AS total,
       FLOOR(sum(o.units * p.unit_price) / 10) *10 AS total_bin
FROM orders o 
LEFT JOIN products p 
ON o.product_id = p.product_id
GROUP BY o.customer_id)

SELECT total_bin, count(customer_id) AS num_count
FROM CTE 
GROUP BY total_bin
ORDER BY total_bin

-- DATE TIME FUNCTIONS 
SELECT CURRENT_TIMESTAMP()

-- Create a my events table
WITH CTE AS(SELECT event_name, event_date, event_datetime, 
            YEAR(event_date) AS event_year,
            MONTH(event_date) AS event_month,
            DAYOFWEEK(event_date) AS event_day
            FROM my_events)

SELECT *,
       CASE WHEN event_day = 1 THEN 'Sun'
            WHEN event_day = 2 THEN 'Mon'
			WHEN event_day = 3 THEN 'Tue'
            WHEN event_day = 4 THEN 'Wed'
            WHEN event_day = 5 THEN 'Thu'
            WHEN event_day = 6 THEN 'Fri'
            WHEN event_day = 7 THEN 'Sat'
       ELSE 'none' END AS event_day_name
FROM CTE

-- Calculate Interval between dates 
SELECT event_name, event_date, CURRENT_DATE(),
       DATEDIFF(event_date, CURRENT_DATE()) AS diff,
       DATE_ADD(event_date, INTERVAL 1 day) AS ADD_one_day
FROM my_events

-- Deep Dive on the q2 2024 orders data we currently have!
SELECT order_id,order_date AS order_year,
       DATE_ADD(order_date, INTERVAL 2 day) AS ship_date
FROM orders
WHERE  YEAR(order_date) = 2024 AND MONTH(order_date) BETWEEN 4 AND 6;

-- STRING FUNCTIONS 
SELECT event_name, REPLACE(TRIM(event_type), '!', '') AS event_type_clean , LENGTH(event_desc ) AS len
FROM my_events

-- TASK 2: Updating our product_ids to include the factory name and product name
WITH CTE AS(SELECT factory,product_id, REPLACE(REPLACE(factory, "'", '')," ","-") AS factory_clean 
			FROM products)
            
SELECT factory, CONCAT(factory_clean, product_id) AS clean
FROM CTE 


-- PATTERN MATCHING 
-- Getiing the first letter from event name column 

WITH CTE AS(SELECT event_name, 
			SUBSTR(event_name, 1, INSTR(event_name, ' ')) AS first_word 
            FROM my_events) 

SELECT *,
       CASE WHEN INSTR(event_name, ' ') = 0 THEN event_name
       ELSE first_word
       END AS first
FROM CTE 
       
-- REMOVE Wonka Bar
SELECT product_name, REPLACE(product_name, 'Wonka Bar -','') AS new_product
FROM products 
ORDER BY product_name
























