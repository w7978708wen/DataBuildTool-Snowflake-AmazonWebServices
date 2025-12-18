-- Wrote configuation to enable incremental materialization
-- on_schema_change='fail' means if source table changes, we won't be able to incrementally update this track table
-- This configuration overwrites any configuration written on dbt_profile.yml
-- on dbt_profile.yml, fact table are assigned to materialize as 'table', 
-- but this configuration lets fct_ratings.sql to materialize as 'incremental'
{{
  config(
    materialized = 'incremental',
    on_schema_change='fail'
  )
}}

-- "src_ratings" CTE takes the output of the DBT model "src_ratings" from "src_ratings.sql"
-- Then selects everything
-- And store the results as a temporary CTE called "src_ratings"
WITH src_ratings AS (
  SELECT * FROM {{ ref('src_ratings') }}
)


-- select columns from CTE "src_ratings"
SELECT
  user_id,
  movie_id,
  rating,
  rating_timestamp
FROM src_ratings
WHERE rating IS NOT NULL

-- The last code snippet automates incremental loading of only new data into fct_ratings .
-- is_incremental() is a dbt macro that returns true when the model is materialized as incremental
-- and that the target table (fct_ratings) already exists

-- {{ this }} is a dbt variable that resolves to the current model's relation 
-- {{ this }} = fct_ratings becuase {{ this }} -> schema.fct_ratings

-- the filter "AND .. > ..." means only insert rows whose rating_timestamp is newer 
-- than the latest timestamp already stored in fct_ratings 
{% if is_incremental() %}
  AND rating_timestamp > (SELECT MAX(rating_timestamp) FROM {{ this }})
{% endif %}

