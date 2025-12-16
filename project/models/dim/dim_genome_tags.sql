-- "src_tags" CTE takes the output of the DBT model "src_genome_tags" from "src_genome_tags.sql"
-- Then selects everything
-- And store the results as a temporary CTE called "ratings"

WITH src_tags AS (
    SELECT * FROM {{ ref('src_genome_tags') }}
)


-- select columns from CTE "src_tags"
-- transformation is applied to the second selected column:
-- TRIM(tag) removes leading and trailing spaces 
-- INITCAP(...) capitalizes the first letter of each word
SELECT
    tag_id,
    INITCAP(TRIM(tag)) AS tag_name
FROM src_tags