CREATE STAGE netflix_stage
  URL='s3://[bucket name]'
  CREDENTIALS=(AWS_KEY_ID='[AWS Key ID]' AWS_SECRET_KEY='[AWS Secret Key]')

--The following 3 lines are optional if want to set default database and schema. Run this code again at the start of every session. 
USE WAREHOUSE COMPUTE_WH;
USE DATABASE MOVIELENS;
USE SCHEMA RAW;

----------------------------------------------------------------------------------------------------------------

-- 1. Load data from movies.csv: 
-- Create a table from scratch
CREATE OR REPLACE TABLE raw_movies (
  movie_ID INTEGER,
  title STRING,
  genre STRING
);

-- Copy data from Amazon S3's movies.csv file into the created table "raw_movies"
COPY INTO raw_movies
FROM '@netflix_stage/movies.csv'
FILE_FORMAT = (TYPE = 'CSV' SKIP_HEADER = 1 FIELD_OPTIONALLY_ENCLOSED_BY = '"');

-- View the entire table
SELECT * FROM raw_movies



-- 2. Load data from ratings.csv: 
-- Create a table from scratch
CREATE OR REPLACE TABLE raw_ratings (
  userId INTEGER,
  movieId INTEGER,
  rating FLOAT,
  timestamp BIGINT
);

-- Copy data from Amazon S3's movies.csv file into the created table "raw_ratings"
COPY INTO raw_ratings
FROM '@netflix_stage/ratings.csv'
FILE_FORMAT = (TYPE = 'CSV' SKIP_HEADER = 1 FIELD_OPTIONALLY_ENCLOSED_BY = '"');

-- View the entire table
SELECT * FROM raw_ratings



-- 3. Load data from tags.csv: 
-- Create a table from scratch
CREATE OR REPLACE TABLE raw_tags (
  userId INTEGER,
  movieId INTEGER,
  tag STRING,
  timestamp BIGINT
);

COPY INTO raw_tags
FROM '@netflix_stage/tags.csv'
FILE_FORMAT = (TYPE = 'CSV' SKIP_HEADER = 1 FIELD_OPTIONALLY_ENCLOSED_BY = '"')
ON_ERROR = 'CONTINUE';

-- View the entire table
SELECT * FROM raw_tags



-- 4. Load data from raw_genome_tags.csv: 
-- Create a table from scratch
CREATE OR REPLACE TABLE raw_genome_tags (
  tagId INTEGER,
  tag STRING
);

COPY INTO raw_genome_tags
FROM '@netflix_stage/genome-tags.csv'
FILE_FORMAT = (TYPE = 'CSV' SKIP_HEADER = 1 FIELD_OPTIONALLY_ENCLOSED_BY = '"')
ON_ERROR = 'CONTINUE';

-- View the entire table
SELECT * FROM raw_genome_tags



-- 5. Load data from links.csv: 
CREATE OR REPLACE TABLE raw_links (
  movieId INTEGER,
  imdbId INTEGER,
  tmdbId INTEGER
);

COPY INTO raw_links
FROM '@netflix_stage/links.csv'
FILE_FORMAT = (TYPE = 'CSV' SKIP_HEADER = 1 FIELD_OPTIONALLY_ENCLOSED_BY = '"')
ON_ERROR = 'CONTINUE';

-- View the entire table
SELECT * FROM raw_links