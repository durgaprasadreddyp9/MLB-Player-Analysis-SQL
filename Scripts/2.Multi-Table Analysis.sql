-- Basics Join 
SELECT * FROM happiness_scores;
SELECT * FROM country_stats;

SELECT hs.year,hs.country,hs.happiness_score,cs.continent
FROM happiness_scores hs
INNER JOIN country_stats cs
ON hs.country = cs.country

-- Join Types

-- LEFT JOIN

SELECT hs.year,hs.country,hs.happiness_score,cs.country,cs.continent
FROM happiness_scores hs
LEFT JOIN country_stats cs
ON hs.country = cs.country
WHERE cs.country IS NULL;

-- RIGHT JOIN

SELECT hs.year,hs.country,hs.happiness_score,cs.country,cs.continent
FROM happiness_scores hs
RIGHT JOIN country_stats cs
ON hs.country = cs.country
WHERE hs.country IS NULL;

-- TASK 1 Figure out which product exist in one table, but not the other ?

SELECT p.product_id, p.product_name, o.product_id
FROM products p 
LEFT JOIN orders o 
ON p.product_id = o.product_id
WHERE o.product_id IS NULL

-- Joining Multiple columns
SELECT * 
FROM happiness_scores hs
INNER JOIN inflation_rates ir
ON hs.country = ir.country_name AND hs.year = ir.year
  
-- Joining Multiple Tables
SELECT hs.year, hs.country, hs.happiness_score, cs.continent, ir.inflation_rate
FROM happiness_scores hs 
LEFT JOIN country_stats cs 
ON hs.country = cs.country
LEFT JOIN inflation_rates ir 
ON hs.year = ir.year and hs.country = ir.country_name;

-- SELF JOIN
CREATE TABLE IF NOT EXISTS employees (
      employee_id INT PRIMARY KEY,
      employee_name VARCHAR(100),
      salary INT,
      manager_id INT 
);

INSERT INTO employees (employee_id, employee_name, salary, manager_id) VALUES
    (1, 'Ava', 85000, NULL),
    (2, 'Bob', 72000, 1),
    (3, 'Cat', 59000, 2),
    (4, 'Dan', 85000, 2);
 
-- Employees with the same salary 
SELECT e1.employee_id, e1.employee_name, e1.salary,e2.employee_id, e2.employee_name, e2.salary
FROM employees e1
INNER JOIN employees e2
ON e1.salary = e2.salary
WHERE e1.employee_name <> e2.employee_name AND e1.employee_id > e2.employee_id

-- Employees that have a greater salary 
SELECT e1.employee_id, e1.employee_name, e1.salary,e2.employee_id, e2.employee_name, e2.salary
FROM employees e1
INNER JOIN employees e2
ON e1.salary > e2.salary
ORDER BY e1.employee_id

-- Employees and their managers
SELECT * 
FROM employees e1 
LEFT JOIN employees e2 
ON e1.manager_id = e2.employee_id

-- TASK 2 Query to determine which products are within 25 cents of each other in terms of unit price and return a list of all candy pairs?
SELECT p1.product_name, p1.unit_price, p2.product_name, p2.unit_price, p1.unit_price - p2.unit_price as price_diff
FROM products p1 
INNER JOIN products p2 
ON p1.product_id <> p2.product_id
WHERE ABS(p1.unit_price - p2.unit_price) < 0.25

-- UNION AND UNION ALL 
SELECT year, country, happiness_score 
FROM happiness_scores
UNION ALL
SELECT 2024, country, ladder_score
FROM happiness_scores_current















































































