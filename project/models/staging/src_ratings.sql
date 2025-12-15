-- "RAW_RATINGS" is the table created from scratch inside folder "RAW"
-- "MOVIELENS" is the database name
-- "RAW" is the folder inside database "MOVIELENS"
-- "RAW_RATINGS" is the table created from scratch inside folder "RAW"

WITH raw_ratings AS (
  SELECT * FROM MOVIELENS.RAW.RAW_RATINGS
)

SELECT
  userId AS user_id,
  movieId AS movie_id,
  rating,
  TO_TIMESTAMP_LTZ(timestamp) AS rating_timestamp
FROM raw_ratings