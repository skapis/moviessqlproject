USE movies

-- create temp table to extract data from csv
DROP TABLE IF EXISTS #movie_data 
CREATE TABLE #movie_data
(
	name varchar(255),
	rating varchar(255),
	genre varchar(255),
	year varchar(255),
	released varchar(255),
	score varchar(255),
	votes varchar(255),
	director varchar(255),
	writer varchar(255),
	star varchar(255),
	country varchar(255),
	budget varchar(255),
	gross varchar(255),
	company varchar(255),
	runtime varchar(255)

)

-- extract data from file with data
BULK INSERT #movie_data
FROM 'C:\Users\jakub\Documents\movies.csv'
WITH(
	FIRSTROW = 2,
	FIELDTERMINATOR = ',',
	FORMAT = 'CSV',
	ROWTERMINATOR = '0x0A',
	CODEPAGE = '65001'
)
GO
PRINT 'Data was succesfully load to temp table #movie_data'


-- cleaning data in temp table

-- 1. split released to release date and release state
/*
SELECT
	released,
	CONVERT(DATE, LEFT(released, CHARINDEX('(',released,1) - 2)) release_date,
	REPLACE(PARSENAME(REPLACE(released,'(','.'), 1),')','') release_state
FROM #movie_data
*/

-- add new columns for release date and release state
ALTER TABLE #movie_data
ADD release_date DATE, release_state VARCHAR(255)


UPDATE #movie_data
SET release_date = CONVERT(DATE, LEFT(released, CHARINDEX('(',released,1) - 2))

UPDATE #movie_data
SET release_state = TRIM(REPLACE(PARSENAME(REPLACE(released,'(','.'), 1),')',''))

PRINT 'Column released was splitted to release_date and release state, release date was transformed to date'

-- convert score, votes and runtime to float datatype
-- set NULL where cell is blank
UPDATE #movie_data
SET score = NULL
WHERE len(score) <= 1

UPDATE #movie_data
SET votes = NULL
WHERE len(votes) <= 1

UPDATE #movie_data
SET runtime = NULL
WHERE len(runtime) <= 1

update #movie_data
SET score = CAST(LEFT(score, CHARINDEX('.', score) - 1) + '.' + SUBSTRING(score, CHARINDEX('.',score)+1,1) as float)
WHERE score IS NOT NULL

update #movie_data
SET votes = CAST(LEFT(votes, CHARINDEX('.', votes) - 1) + '.' + SUBSTRING(votes, CHARINDEX('.',votes)+1,1) as float)
WHERE votes IS NOT NULL

update #movie_data
SET runtime = CAST(LEFT(runtime, CHARINDEX('.', runtime) - 1) + '.' + SUBSTRING(runtime, CHARINDEX('.',runtime)+1,1) as float)
WHERE runtime IS NOT NULL

-- set float datatypes to score, votes, runtime
ALTER TABLE #movie_data
ALTER COLUMN score float

ALTER TABLE #movie_data
ALTER COLUMN votes float

ALTER TABLE #movie_data
ALTER COLUMN runtime float


-- create final table with right datatypes
CREATE TABLE movies_data(
	movie_name varchar(255),
	rating varchar(255),
	genre varchar(255),
	movie_year int,
	release_date date,
	release_state varchar(255),
	score float,
	votes float,
	director varchar(255),
	writer varchar(255),
	star varchar(255),
	country varchar(255),
	budget float,
	gross float,
	company varchar(255),
	runtime float
)


-- load clean data to movie table
INSERT INTO movies_data
SELECT 
	name movie_name,
	rating,
	genre,
	CAST(year AS INT) movie_year,
	release_date,
	release_state,
	score,
	votes,
	director,
	writer,
	star,
	country,
	cast(budget as float),
	cast(gross as float),
	company,
	runtime
FROM #movie_data

-- now the data is prepared for next processing
SELECT * FROM movies_data
DROP TABLE #movie_data


