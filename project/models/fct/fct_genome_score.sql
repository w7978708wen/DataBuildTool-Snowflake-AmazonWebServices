-- "src_scores" CTE takes the output of the DBT model "src_genome_score" from "src_genome_score.sql"
-- Then selects everything
-- And store the results as a temporary CTE called "src_scores"
WITH src_scores AS (
    SELECT * FROM {{ ref('src_genome_score') }}
)

-- select columns from CTE "src_scores"
-- transformation is applied to the 3rd selected column: round to 4 decimal places
-- only want relevance > 0 because don't want any 0-values
SELECT
    movie_id,
    tag_id,
    ROUND(relevance, 4) AS relevance_score
FROM src_scores
WHERE relevance > 0