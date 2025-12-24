-- references to the created fact table 
-- fct_genome_scores

-- columns that fct_genome_scores has: 
-- movie_id, tag_id, relevance_score

-- SELECT
--     movie_id,
--     tag_id, 
--     relevance_score
-- FROM {{ ref('fct_genome_scores') }}
-- WHERE relevance_score <= 0

-- New code after creating no_nulls_in_column.sql in macros folder 
-- still references to fct_genome_scores table 
{{ no_nulls_in_columns(ref('fct_genome_scores'))}}