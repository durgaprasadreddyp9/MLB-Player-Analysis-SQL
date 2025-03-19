-- Duplicate Values 
USE maven_advanced_sql
CREATE TABLE employee_details (
    region VARCHAR(50),
    employee_name VARCHAR(50),
    salary INTEGER
);

INSERT INTO employee_details (region, employee_name, salary) VALUES
	('East', 'Ava', 85000),
	('East', 'Ava', 85000),
	('East', 'Bob', 72000),
	('East', 'Cat', 59000),
	('West', 'Cat', 63000),
	('West', 'Dan', 85000),
	('West', 'Eve', 72000),
	('West', 'Eve', 75000);
    
SELECT * FROM employee_details

-- View duplicate rows
SELECT region,employee_name,salary, count(*) AS dup_count
FROM employee_details
GROUP BY region,employee_name,salary
HAVING count(*) > 1

-- Exclude fully duplicates
SELECT DISTINCT region,employee_name,salary 
FROM employee_details

-- Exclude partially duplicate rows

WITH CTE AS (SELECT region,employee_name,salary,
       ROW_NUMBER() OVER(PARTITION BY region, employee_name ORDER BY salary DESC) AS top_sal
FROM employee_details)

SELECT * 
FROM CTE 
WHERE top_sal = 1

-- TASK 1: Generate a report the students and their emails, and exclude the duplicate student record
WITH CTE AS(SELECT  id, student_name, email, 
        ROW_NUMBER() OVER(PARTITION BY student_name ORDER BY id DESC) AS student_count
FROM students )

SELECT * 
FROM CTE 
WHERE student_count = 1

-- Min / Max Value Filtering 
-- create report of each student with their highest grade for the semester, as well as which class it was in ?

WITH CTE AS(SELECT s.id, s.student_name, MAX(final_grade) AS top_grade, sg.class_name
FROM students s 
LEFT JOIN student_grades sg
ON s.id = sg.student_id
WHERE semester_id = 'F2024'
GROUP BY s.id, s.student_name, sg.class_name
ORDER BY s.student_name),

ranking  AS (SELECT * ,
     DENSE_RANK() OVER(PARTITION BY student_name ORDER BY top_grade DESC ) AS t
FROM CTE )

SELECT *
FROM ranking
WHERE t = 1

-- Pivoting 
-- create a summary that shows the average grade for each department and grade level

SELECT department,
	   AVG(CASE WHEN grade_level = 9 THEN sg.final_grade  END) AS 'freshman',
	   AVG(CASE WHEN grade_level = 10 THEN sg.final_grade  END) AS 'sophmore',
	   AVG(CASE WHEN grade_level = 11 THEN sg.final_grade  END) AS 'junior',
	   AVG(CASE WHEN grade_level = 12 THEN sg.final_grade  END) AS 'senior'
FROM students s 
INNER JOIN student_grades sg 
ON s.id = sg.student_id
GROUP BY department 

-- Rolling Calculations 
-- Can you generate a report that shows the total sales for each month, as well as the cummulative sum of sales and six-month moving averages

WITH CTE AS(SELECT YEAR(order_date) AS year, month(order_date) AS month, SUM(o.units * p.unit_price) AS total_sales
            FROM orders o
            INNER JOIN products p 
            ON o.product_id = p.product_id 
            GROUP BY year, month
            ORDER BY year,month),

         CTE1 AS (SELECT * ,
                 SUM(total_sales) OVER(ORDER BY year,month) AS cummulative_sum,
                 AVG(total_sales) OVER(ORDER BY year, month ROWS BETWEEN 5 PRECEDING AND CURRENT ROW) AS six_month_moving_avg
                 FROM CTE )

SELECT * 
FROM CTE1
























