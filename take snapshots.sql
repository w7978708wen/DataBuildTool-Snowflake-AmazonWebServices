SELECT * FROM snapshots.snap_tags
ORDER BY user_id, dbt_valid_from DESC;


-- UPDATE src_tags means modify existing rows in table src_tags. 
-- UPDATE fcn only changes values in rows that alredy exist. 
-- SET tag = 'Mark Waters Returns' means change the tag column's value to 'Mark Waters Returns'  
-- regardless of what the old tag name was 
-- tag_timestamp = CAST(CURRENT_TIMESTAMP() AS TIMESTAMP_NTZ) returns the current date & time when query runs
-- CAST(... AS TIMESTAMP_NTZ) converts timestamp into TIMESTAMP_NTZ meaning timestamp with no time zone
-- WHERE user_id = 18 means only apply this to rows with user_id = 18
UPDATE src_tags
SET tag = 'Mark Waters Returns', tag_timestamp = CAST(CURRENT_TIMESTAMP() as TIMESTAMP_NTZ)
WHERE user_id = 18;


-- View table with updated tag (for rows where user_id = 18)
SELECT * from dev.src_tags
WHERE user_id = 18;
ORDER BY user_id DESC;


--You can see 2 versions of row before and after update. View snapshot table 
SELECT * FROM snapshots.snap_tags
WHERE user_id = 18
ORDER BY user_id, dbt_valid_from DESC;