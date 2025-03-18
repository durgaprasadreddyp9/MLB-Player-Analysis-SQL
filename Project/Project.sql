-- School Analysis 

-- TASK 1. In each decade, how many schools were there that produced players? 

SELECT ROUND(yearID, -1) AS decade, COUNT(DISTINCT schoolID) AS num_schools
FROM schools
GROUP BY decade
ORDER by decade

-- TASK2: What are the names of the top 5 schools that produced the most players?

SELECT sd.name_full, COUNT(DISTINCT s.playerID) AS num_players
FROM schools s 
INNER JOIN school_details sd 
ON s.schoolID = sd.schoolID
GROUP BY sd.name_full
ORDER by num_players DESC
LIMIT 5;

-- TASK 3: For each decade, what were the names of the top 3 schools that produced the most players?
WITH CTE AS (SELECT ROUND(s.yearID, -1) AS decade, sd.name_full AS full_name, COUNT(DISTINCT s.playerID) AS num_players 
             FROM schools s
             LEFT JOIN school_details sd
             ON s.schoolID = sd.schoolID
             GROUP BY decade, sd.name_full),
             
	  CTE1 AS (SELECT decade, full_name, num_players,
       ROW_NUMBER() OVER(PARTITION BY decade ORDER BY num_players DESC) AS rn 
       FROM CTE)
	
SELECT decade, full_name, num_players
FROM CTE1 
WHERE rn IN (1,2,3)
ORDER BY decade DESC, rn

-- Salary Analysis 

-- TASK1: Return the top 20% of teams in terms of average annual spending

WITH top_salary AS (SELECT yearID, teamID, SUM(salary) AS total_spend
             FROM salaries 
             GROUP BY yearID, teamID),
	 
     top_percentage AS (SELECT teamID, AVG(total_spend) AS avg_spend,
                        NTILE(5) OVER(ORDER BY AVG(total_spend) DESC) as NT
                        FROM top_salary
                        GROUP BY teamID)

SELECT teamID, ROUND(avg_spend/1000000,1) AS spending_millions
FROM top_percentage
WHERE NT = 1

-- TASK 2: For each team, show the cumulative sum of spending over the years

WITH ts AS(SELECT yearID, teamID, SUM(salary) AS total_spend
           FROM salaries
		   GROUP BY yearID, teamID
           ORDER BY yearID)

SELECT teamID, yearID,
       ROUND(SUM(total_spend) OVER(PARTITION BY teamID ORDER BY yearID) / 1000000,1) AS cummulative_sum
FROM ts 

-- TASK 3: Return the first year that each team's cumulative spending surpassed 1 billion

WITH ts AS(SELECT yearID, teamID, sum(salary) AS total_spend
           FROM salaries 
           GROUP BY yearID, teamID),
		
       cummulative AS(SELECT teamID, yearID,
                      ROUND(SUM(total_spend) OVER(PARTITION BY teamID ORDER BY yearID) / 1000000,1) AS cummulative_sum
                      FROM ts ),
	
CTE AS (SELECT teamID, yearID,cummulative_sum,
       ROW_NUMBER() OVER(PARTITION BY teamID ORDER BY cummulative_sum) AS rn 
       FROM cummulative 
       WHERE cummulative_sum > 1000)
	
SELECT teamID, yearID, cummulative_sum
FROM CTE 
WHERE rn = 1

-- Player Analysis 

-- TASK 1: For each player, calculate their age at their first (debut) game,
--  their last game, and their career length (all in years). Sort from longest career to shortest career.

SELECT nameFirst, YEAR(debut) - birthYear AS first_game,  YEAR(finalGame) - birthYear AS last_game, 
       YEAR(finalGame) - YEAR(debut) AS carrer_length 
FROM players
ORDER BY carrer_length DESC 

-- TASK 2: What team did each player play on for their starting and ending years?

SELECT p.nameGiven, s.teamID AS starting_team, s.yearID AS starting_year, e.yearID AS ending_year, e.teamID AS ending_team
FROM players p
INNER JOIN salaries s 
ON p.playerID = s.playerID AND YEAR(p.debut) = s.yearID
INNER JOIN salaries e
ON p.playerID = e.playerID AND YEAR(p.finalGame) = e.yearID

-- TASK 3: How many players started and ended on the same team and also played for over a decade?
WITH CTE AS(SELECT p.nameGiven, s.teamID AS starting_team, s.yearID AS starting_year, e.yearID AS ending_year, e.teamID AS ending_team
            FROM players p
            INNER JOIN salaries s 
            ON p.playerID = s.playerID AND YEAR(p.debut) = s.yearID
            INNER JOIN salaries e
			ON p.playerID = e.playerID AND YEAR(p.finalGame) = e.yearID)
            
SELECT * 
FROM CTE 
WHERE starting_team = ending_team and ending_year - starting_year >=10

-- Player Comparison Analysis

-- TASK 1: Which players have the same birthday?
WITH CTE AS (SELECT CAST(CONCAT(birthYear,'-',birthMonth,'-',birthDay)AS DATE) AS birthdate, nameGiven  
            FROM players)
            
SELECT birthdate, GROUP_CONCAT(nameGiven SEPARATOR ',')  AS players, COUNT(nameGiven)
FROM CTE 
WHERE birthdate IS NOT NULL AND year(birthdate) BETWEEN 1980 AND 1990
GROUP BY birthdate


-- TASK 2: Create a summary table that shows for each team, what percent of players bat right, left and both.

SELECT  s.teamID,
       ROUND(SUM(CASE WHEN bats ='R' THEN 1 ELSE 0 END) / count(s.playerID)* 100,1) AS bats_right,
       ROUND(SUM(CASE WHEN bats ='L' THEN 1 ELSE 0 END) / count(s.playerID)* 100,1) AS bats_left,
       ROUND(SUM(CASE WHEN bats ='B' THEN 1 ELSE 0 END)  / count(s.playerID)* 100,1) AS bats_both
FROM players p 
LEFT JOIN salaries s 
ON p.playerID = s.playerID
GROUP BY s.teamID

-- TASK 3: How have average height and weight at debut game changed over the years, and what's the decade-over-decade difference?

WITH CTE AS(SELECT  ROUND(YEAR(debut),-1) AS decade, AVG(height) AS avg_height, AVG(weight) AS avg_weight
            FROM players 
            GROUP BY decade)
            
SELECT decade,
       avg_height - LAG(avg_height) OVER(ORDER BY decade) AS height_diff,
       avg_weight - LAG(avg_weight) OVER(order by decade) AS weight_diff
FROM CTE 
WHERE decade IS NOT NULL;















