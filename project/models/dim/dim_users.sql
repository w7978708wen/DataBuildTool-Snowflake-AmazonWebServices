--"ratings" CTE takes the output of the DBT model "src_ratings" from "src_ratings.sql"
--Then get the distinct user_ID's 
--And store the results as a temporary CTE called "ratings"

WITH ratings AS (
  SELECT DISTINCT user_ID FROM {{ ref('src_ratings') }}
),

--"tags" CTE takes the output of the DBT model "src_tags" from "src_tags.sql"
--Then get the distinct user_ID's 
--And store the results as a temporary CTE called "tags"
tags AS (
  SELECT DISTINCT user_ID FROM {{ ref('src_tags') }}
)

-- The final SELECT statement combines both "ratings" and "tags" CTEs 
-- to get the distinct user_ID that appears any of the CTE's
SELECT DISTINCT user_ID
FROM (
  SELECT * FROM ratings
  UNION
  SELECT * FROM tags
)