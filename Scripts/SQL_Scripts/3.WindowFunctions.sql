-- Window Functions

-- ROW NUMBERS
SELECT country, year, happiness_score,
	   ROW_NUMBER() over(PARTITION BY country ORDER BY happiness_score) AS row_num
FROM happiness_scores
ORDER BY country,row_num

-- RANK and DENSE_RANK

SELECT customer_id, transaction_id,
       ROW_NUMBER() OVER(PARTITION BY customer_id) AS transaction_num,
       RANK() OVER(ORDER BY customer_id) AS rn,
       DENSE_RANK() OVER(ORDER BY customer_id) AS dense_rn
FROM orders

-- Task 1: Which products are most popular within each other
SELECT order_id,product_id,units,
ROW_NUMBER() OVER(PARTITION BY order_id ORDER BY units DESC) as product_rn
FROM orders
ORDER BY order_id,product_id

-- FIRST_VALUE , LAST_VALUE, & NTH_VALUE
SELECT order_id, product_id, units,
NTH_VALUE(product_id,2) OVER(PARTITION BY order_id ORDER BY units) AS second_popular
FROM orders

-- LAG and LEAD 
SELECT * ,
LAG(happiness_score) OVER(PARTITION BY country ORDER BY year) AS previous_value
FROM happiness_scores

SELECT * ,
LEAD(happiness_score) OVER(PARTITION BY country ORDER BY year) AS next_value
FROM happiness_scores

-- Difference in happiness_score 
WITH CTE AS(
SELECT country,year,happiness_score,
LAG(happiness_score) OVER(PARTITION BY country ORDER BY year) AS previous_value
FROM happiness_scores) 

SELECT country,year,happiness_score, previous_value,
happiness_score - previous_value AS diff
FROM CTE

-- TASK 2: How orders changed overtime for each customer 
WITH CTE AS(SELECT customer_id,order_id,MIN(transaction_id) AS min_tid,SUM(units) AS total_units
			FROM orders
            GROUP BY customer_id,order_id
            ORDER BY customer_id, min_tid),
            
	prior_CTE AS(SELECT customer_id, order_id,total_units,
				LAG(total_units) OVER(PARTITION BY customer_id ORDER BY min_tid) AS prior_units
                FROM CTE) 

SELECT customer_id, order_id,total_units,
	   prior_units,total_units - prior_units AS diff_units
FROM prior_CTE

-- NTILE For each region, return the top 25% of countries, in terms of happiness score
WITH CTE AS(SELECT region, country, happiness_score, year,
             NTILE(4) OVER(PARTITION BY region ORDER BY happiness_score) AS hs_percentile
             FROM happiness_scores
			 WHERE year = 2023)
             
SELECT *
FROM CTE
WHERE  hs_percentile = 1

-- TASK 3: Can you pull a list of the top 1% of customers in terms of how much they've spent with us?
WITH CTE AS(SELECT o.customer_id, SUM(o.units * p.unit_price) AS total_spent
			FROM orders o
            LEFT JOIN products p
            ON o.product_id = p.product_id
            GROUP BY o.customer_id
			ORDER BY total_spent DESC),
            
	 sp AS(SELECT *,
           NTILE(100) OVER(ORDER BY total_spent DESC ) AS spend_pct
           FROM CTE )
SELECT * 
FROM sp 
WHERE spend_pct = 1




















