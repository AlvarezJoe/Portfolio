-- THIS DATASET HAS A BIT OF CLEANING, A BIT OF ADMIN WORK, AND
-- A FEW INTERESTING QUERIES THAT WE'll USE IN TABLEAU

USE NetflixPortfolio;

-- WISH THIS DATASET HAD A SCORING PARAMETER (IE CRITIC/AUDIANCE)


ALTER TABLE netflix_dataset
ALTER COLUMN date_added DATE;

SELECT * FROM netflix_dataset
WHERE NOT type IN('TV Show','Movie');
-- TYPE DATA WAS CLEAN

-- RATIO MOVIES TO TV
SELECT CAST(COUNT(*)/(SELECT COUNT(*)
FROM netflix_dataset
WHERE type LIKE 'TV%') AS DECIMAL(10, 2))
AS movies_to_tv_ratio
FROM netflix_dataset
WHERE type LIKE 'Movie%';

-- SEASONS SCATTER PLOT (TV)
SELECT release_year, LEFT(duration, 1) AS seasons
FROM netflix_dataset
WHERE type LIKE 'TV%'
ORDER BY release_year;

SELECT duration FROM netflix_dataset
WHERE type LIKE 'Movie'
ORDER BY duration ASC;
-- ENSURING DURATION BETWEEN 99 - 999

-- DURATION SCATTER PLOT (MOVIES)
SELECT release_year, TRIM(LEFT(duration, 3)) AS duration_in_minutes
FROM netflix_dataset
WHERE type LIKE 'Movie'
ORDER BY release_year;

-- TIMES DIRECTED
SELECT director, COUNT(*) AS times_directed
FROM netflix_dataset
GROUP BY director 
ORDER BY times_directed DESC;

-- RATING COUNT
SELECT rating, COUNT(*) AS rating_count
FROM netflix_dataset
GROUP BY rating
ORDER BY rating_count DESC;
-- FOUND SOME DIRTY DATA, LETS ISOLATE & CLEAN IT UP

SELECT show_id, rating, duration FROM netflix_dataset
WHERE rating LIKE '%min%';

-- LETS INSERT THIS DATA INTO DURATION
UPDATE netflix_dataset
SET duration = rating
WHERE show_id IN('s5542', 's5795', 's5814');

UPDATE netflix_dataset
SET rating = NULL
WHERE show_id IN('s5542', 's5795', 's5814');

SELECT show_id, rating, duration FROM netflix_dataset
WHERE show_id IN('s5542', 's5795', 's5814');
-- NOW THE OTHER DATA

UPDATE netflix_dataset
SET rating = NULL
WHERE rating = '';
-- LOOKS LIKE THE DATAS BEEN CLEANED

-- LETS CHECK TO MAKE SURE THERES NO REPEATING show_id's
SELECT show_id, COUNT(*) AS id_count
FROM netflix_dataset
GROUP BY show_id
ORDER BY id_count DESC;

-- LOOK FOR DIRTY DATA IN GENERAL
SELECT type FROM netflix_dataset
GROUP BY type;

SELECT date_added FROM netflix_dataset
WHERE date_added = '';

SELECT * FROM netflix_dataset
WHERE duration LIKE ('%m%');
-- FOUND MORE

UPDATE netflix_dataset
SET duration = TRIM(LEFT(duration, 3))
WHERE duration LIKE ('%m%');
-- LOOKS CLEAN

-- LETS ISOLATE SEASONS AND DURATION PERMANENTLY
ALTER TABLE netflix_dataset
ADD seasons SMALLINT NULL;

UPDATE netflix_dataset
SET seasons = LEFT(duration, 1)
WHERE type LIKE 'TV%';

SELECT TOP 10 * FROM netflix_dataset;
-- WORKING CORRECTLY

UPDATE netflix_dataset
SET duration = NULL
WHERE type LIKE 'TV%';
-- RID OURSELVES OF SEASONS IN DURATION

SELECT duration
FROM netflix_dataset
WHERE duration LIKE '%m%';
-- MAKING SURE MINUTES WAS STANDARD

UPDATE netflix_dataset
SET duration = TRIM(LEFT(duration, 1))
WHERE duration LIKE '%m%';

-- NOW THAT OUR DATA APPEARS CLEAN LETS SEPERATE IT INTO QUAL AND QUANT
SELECT show_id, date_added, release_year, duration, seasons -- REALLY WISH THERE WAS A SCORE HERE
INTO quantitative_netflix_data
FROM netflix_dataset;

SELECT show_id, type, title, director, cast, country, rating, listed_in, description
INTO qualitative_netflix_data
FROM netflix_dataset;

-- LETS RENAME A COLUMN TO BE MORE SPECIFIC
EXEC sp_rename 'quantitative_netflix_data.duration', 'duration_in_minutes';

SELECT * FROM qualitative_netflix_data;

SELECT * FROM quantitative_netflix_data;
-- THEY BOTH LOOK GOOD, LETS ESTABLISH SOME TYPES AND KEYS

ALTER TABLE quantitative_netflix_data
ALTER COLUMN seasons SMALLINT;

ALTER TABLE quantitative_netflix_data
ALTER COLUMN show_id VARCHAR(5)NOT NULL;

ALTER TABLE quantitative_netflix_data
ADD PRIMARY KEY(show_id);

ALTER TABLE quantitative_netflix_data
ALTER COLUMN duration_in_minutes SMALLINT;

ALTER TABLE quantitative_netflix_data
ALTER COLUMN seasons SMALLINT;

ALTER TABLE qualitative_netflix_data
ALTER COLUMN show_id VARCHAR(5)NOT NULL;

ALTER TABLE qualitative_netflix_data
ADD PRIMARY KEY(show_id);

-- USING DATABASE DIAGRAMS IN SSMS I CREATED A RELATIONSHIP BETWEEN THE TABLES
-- SSMS WOULD NOT ALLOW ME TO CREATE A PRIMARY_KEY FOR netflix_dataset

-- AVERAGE DURATION PER YEAR
SELECT release_year, AVG(duration_in_minutes) AS average_duration_in_minutes
FROM quantitative_netflix_data
GROUP BY release_year
ORDER BY release_year;

-- AVERAGE SEASONS PER YEAR
SELECT release_year, AVG(seasons) AS average_seasons
FROM quantitative_netflix_data
GROUP BY release_year
ORDER BY release_year;

-- RELEASES BY COUNTRY
SELECT country, COUNT(*) AS total_releases
FROM qualitative_netflix_data
GROUP BY country
ORDER BY total_releases DESC;
-- THATS A LOT OF NON VALUES LETS CHANGE THEM TO NULLS

UPDATE qualitative_netflix_data
SET country = NULL
WHERE country LIKE '';
-- RUN RELEASES BY COUNTRY AGAIN
-- MUCH BETTER

--LETS DO THE SAME FOR CAST AND DIRECTOR
UPDATE qualitative_netflix_data
SET director = NULL
WHERE director LIKE '';

UPDATE qualitative_netflix_data
SET cast = NULL
WHERE cast LIKE '';

SELECT show_id, listed_in
FROM qualitative_netflix_data
WHERE listed_in = '';

SELECT show_id, description
FROM qualitative_netflix_data
WHERE description = '';

SELECT show_id, title
FROM qualitative_netflix_data
WHERE title = '';
-- LOOKS CLEAN

-- LETS RUN THE SAME QUERY EARLIER BUT FILTER OUT ANY MULTICOUNTRY ENTRIES
SELECT country, COUNT(*) AS total_releases
FROM qualitative_netflix_data
WHERE NOT country LIKE '%,%'
GROUP BY country
ORDER BY total_releases DESC;

-- AVERAGE TIME BETWEEN RELEASE AND ACQUSITION
SELECT CAST(AVG((LEFT(date_added, 4) - release_year)) AS DECIMAL(10, 2))
AS time_between_release_and_date_added
FROM quantitative_netflix_data;

-- LETS GET SOME VISULIZATIONS CREATED ON TABLEAU