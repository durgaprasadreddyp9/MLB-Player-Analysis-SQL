-- Subquery in the SELECT cluase

-- Happiness Score deviation from the average
SELECT country, happiness_score, (SELECT AVG(happiness_score) FROM happiness_scores) AS average ,
happiness_score - (SELECT AVG(happiness_score) FROM happiness_scores) AS average_hs
FROM happiness_scores

-- TASK 1 Give me a list of our products from most to least expensive, along with how much each product differs from the average unit price?
SELECT product_id, product_name,unit_price, (select AVG(unit_price) FROM products)  AS average, 
unit_price - (select AVG(unit_price) FROM products) AS average_diff
FROM products
ORDER BY average DESC 

-- Subqueries in the FROM CLAUSE

-- Return a country happiness score for the year as well as the average happiness score for the country across years.
SELECT hs.year, hs.country, hs.happiness_score,avg_hs_country
FROM happiness_scores hs
LEFT JOIN 
(SELECT country, AVG(happiness_score) AS avg_hs_country
		FROM happiness_scores 
        GROUP BY country) AS country_hs
ON hs.country = country_hs.country

-- MULTIPLE SUBQUERIES 

-- Return years where the hapiness score is a whole point greater than the country's average score
SELECT *
FROM
(SELECT hs.year, hs.country, hs.happiness_score, country_hs.average
FROM (SELECT year, country, happiness_score FROM happiness_scores
	   UNION ALL 
       SELECT 2024, country, ladder_score FROM happiness_scores_current) hs
LEFT JOIN 
	    (SELECT country, AVG(happiness_score) as average 
		FROM happiness_scores
		GROUP BY country) AS country_hs
ON hs.country = country_hs.country) AS hs_country_hs
WHERE happiness_score > average +1 

-- TASK 2 Give me a list of our factories, along with the names of the products they produce and the number of products they produce

SELECT fp.factory, fp.product_name, fn.num_product
FROM 
(SELECT factory,product_name
FROM products ) fp
LEFT JOIN 
(SELECT factory, count(product_name) AS num_product
FROM products
GROUP BY factory) fn
ON fp.factory = fn.factory
ORDER BY fp.factory, fp.product_name

-- SUBQUERIES IN WHERE AND HAVING

-- Calculating above average score for each region
SELECT region, avg(happiness_score) AS hs
FROM happiness_scores
GROUP BY region
HAVING hs > (SELECT avg(happiness_score) FROM happiness_scores)

-- SUBQUERIES IN ANY and ALL 

-- Return happiness scores that are greater than ANY or ALL of the current happiness score
SELECT *
FROM happiness_scores
WHERE happiness_score > ANY (SELECT ladder_score FROM happiness_scores_current)

SELECT *
FROM happiness_scores
WHERE happiness_score > ALL (SELECT ladder_score FROM happiness_scores_current)

-- EXISTS 

-- Return happiness scores of countries that exist in the inflation rate table.
SELECT *
FROM happiness_scores hs 
WHERE EXISTS (SELECT country_name 
			  FROM inflation_rates ir
              WHERE ir.country_name = hs.country)
              
-- TASK 3: 
  
-- Return products where the unit price is less than ALL the unit price of all products from wicked choccy's
SELECT * 
FROM products 
WHERE unit_price < ALL(SELECT unit_price
                       FROM products 
                       WHERE factory = "Wicked Choccy's")

-- Common Table Expression (CTE)

WITH CTE AS (SELECT country,
			 AVG(happiness_score) AS avg_hs_country
             FROM happiness_scores
             GROUP BY country)

SELECT hs.year, hs.country, hs.happiness_score, CTE.avg_hs_country
FROM happiness_scores hs
LEFT JOIN CTE 
ON hs.country = CTE.country;

-- For each Country, return countries from the same region with a lower happiness score in 2023
WITH hs AS(SELECT *
           FROM happiness_scores
           WHERE year = 2023)

SELECT hs1.region, hs1.country, hs1.happiness_score,
hs2.country, hs2.happiness_score
FROM hs hs1
INNER JOIN hs hs2
ON hs1.region = hs2.region
WHERE hs1.country < hs2.country

-- TASK 4: Return the number of orders over 200$

WITH CTE AS (SELECT o.order_id, SUM(o.units * p.unit_price) AS total_amount
FROM orders o 
LEFT JOIN products p
ON o.product_id = p.product_id
GROUP BY o.order_id
HAVING total_amount > 200)

SELECT COUNT(*)
FROM CTE 

-- TASK 5: (MULTIPLE CTE's) Give me a list of factories, along with the names of the products they produce and the number of products they produce?
WITH CTE AS(SELECT factory, product_name
			FROM products),
	CTE1 AS (SELECT factory, COUNT(product_name) FROM products GROUP BY factory)

SELECT *
FROM CTE 
LEFT JOIN CTE1
on CTE.factory = CTE1.factory
	




















