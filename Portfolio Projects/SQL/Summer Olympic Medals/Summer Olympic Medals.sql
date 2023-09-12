-- Check data
SELECT *
FROM summer_olympic_medals 
LIMIT 10;

-- Returns the number of Olympic games in which each country has participated
SELECT country_code, COUNT(DISTINCT year) AS games
FROM summer_olympic_medals
GROUP BY country_code 
ORDER BY games DESC;


-- Return each athlete by the number of medals they've earned with the rank
WITH athlete_medals AS (
	SELECT athlete, COUNT(*) AS medals
	FROM summer_olympic_medals
	GROUP BY athlete)
SELECT athlete, medals, 
	RANK() OVER (ORDER BY medals DESC) AS Rank_N
FROM athlete_medals
ORDER BY medals DESC;

-- Rank athletes in each country (USA, RUS) by the medals they've won
WITH athlete_country_medals AS (
	SELECT country_code, athlete, COUNT(*) AS medals
	FROM summer_olympic_medals
	WHERE country_code IN ('USA', 'RUS')
    AND year >= 1996
    GROUP BY country_code, athlete
    HAVING COUNT(*) > 1)
SELECT country_code, athlete,
	DENSE_RANK() OVER (PARTITION BY country_code ORDER BY medals DESC) AS rank_n
FROM athlete_country_medals
ORDER BY country_code, rank_n;

-- Return the previous champions of each year's event by gender in 100m event
WITH sprint_gold AS (
	SELECT DISTINCT gender, year, country
	FROM summer_olympic_medals
	WHERE event  = '100m' AND medal = 'Gold')
SELECT gender, year, country AS champion,
	LAG(country) OVER (PARTITION BY gender ORDER BY year ASC) AS last_champion
FROM sprint_gold
ORDER BY gender, year;

-- For each year, fetch the current and future women high jump medalists.
WITH high_jump_medalists AS (
	SELECT DISTINCT year, athlete
	FROM summer_olympic_medals
	WHERE medal = 'Gold'
    AND event = 'high jump'
    AND gender = 'Women')
SELECT year, athlete,
	LEAD(athlete) OVER (ORDER BY year ASC) AS future_champion
FROM high_jump_medalists
ORDER BY year ASC;

-- Split results into thirds, count average number of medals per thirds
WITH country_medals AS (
  	SELECT country_code, COUNT(*) AS medals
  	FROM summer_olympic_medals
  	GROUP BY country_code
  	ORDER BY medals DESC),
thirds AS (
	SELECT country_code, medals,
	NTILE(3) OVER(ORDER BY medals DESC) AS third
	FROM country_medals)
SELECT third, ROUND(AVG(medals),2) AS avg_medals 	
FROM thirds
GROUP BY third
ORDER BY third;

-- Count cumulative sum of gold medals Poland won 
WITH poland_medals AS (
	SELECT year, COUNT(*) medals
	FROM summer_olympic_medals
	WHERE country_code = 'POL'
	AND medal = 'Gold'
	GROUP BY YEAR)
SELECT year, medals,
SUM(medals) OVER(ORDER BY year) AS cumulative_sum
FROM poland_medals;

-- Return the maximum medals number Poland, USA and Russia earned since 1996
WITH country_medals AS (
	SELECT year, country_code, COUNT(*) AS medals
	FROM summer_olympic_medals
	WHERE country_code IN ('USA', 'POL', 'RUS')
    AND Medal = 'Gold' 
    AND Year >= 1996
	GROUP BY year, country_code)
SELECT year, country_code, medals,
	MAX(medals) OVER (PARTITION BY country_code ORDER BY year) AS max_medals
FROM country_medals
ORDER BY country_code, year;

-- Get the last "Olympic" city
SELECT DISTINCT city, year,
LAST_VALUE(city) OVER(ORDER BY YEAR RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING)
FROM summer_olympic_medals
WHERE year IS NOT NULL
ORDER BY year;

-- Return max gold medals of Eastern EU countries between current and next year
WITH eastern_eu_medals AS (
	SELECT year, COUNT(*) AS medals
    FROM summer_olympic_medals
    WHERE country_code IN ('BUL', 'CRO', 'CZE', 'HUN', 'POL', 'ROU', 'SRB', 'SVK', 'BLR', 'RUS', 'UKR', 'LTU', 'LAT', 'EST')
    AND medal = 'Gold'
    GROUP BY year)
SELECT year, medals,
   MAX(medals) OVER (ORDER BY YEAR ASC ROWS BETWEEN CURRENT ROW
             AND 1 FOLLOWING) AS max_medals
FROM eastern_eu_medals
ORDER BY year ASC;


-- Group-level Totals
-- Chinese and Russian medals in the 2008 Summer Olympics per medal class
SELECT COALESCE(country_code, 'Both countries'), 
	COALESCE(medal, 'All medals'), COUNT(medal) AS awards
FROM summer_olympic_medals
WHERE country_code IN ('RUS', 'CHN')
AND year = 2008
GROUP BY ROLLUP(country_code, medal) 
ORDER BY country_code; 
