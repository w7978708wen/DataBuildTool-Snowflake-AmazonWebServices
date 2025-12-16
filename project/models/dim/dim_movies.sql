-- "src_movies" refers to the data output  
-- of DBT model "src_ratings.sql" in models/staging folders
WITH src_movies AS (
    SELECT * FROM {{ ref('src_movies') }}
)

-- execute desired transformation logic
-- Refers to this DBT model to create a dependency graph  
SELECT
    movie_id,
    INITCAP(TRIM(title)) AS movie_title,
    --split genre by |
    SPLIT(genre, '|') AS genre_array,
    genre
FROM src_movies