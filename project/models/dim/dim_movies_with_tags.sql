-- Wrote configuation to enable ephemeral materialization
-- This configuration overwrites any configuration written on dbt_profile.yml
-- on dbt_profile.yml, dim table are assigned to materialize as views, 
-- but this configuration lets dim_movies_with_tags.sql to materialize as 'ephemeral'

{{
    config(
        materialized = 'ephemeral'
    )
}}


-- CTE creation: each CTE is a temporary table/view that exists only for this query
-- CTE "movies" uses data output from model dim_movies.sql
WITH movies AS (
    SELECT * FROM {{ ref("dim_movies") }}
),
tags AS (
    SELECT * FROM {{ ref("dim_genome_tags") }}
),
scores AS (
    SELECT * FROM {{ ref("fct_genome_score") }}
)

-- Do left joins using the 3 CTEs
SELECT
    m.movie_id,
    m.movie_title,
    m.genre,
    t.tag_name,
    s.relevance_score
FROM movies m
LEFT JOIN scores s ON m.movie_id = s.movie_id
LEFT JOIN tags t ON t.tag_id = s.tag_id