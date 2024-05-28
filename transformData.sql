USE ROLE accountadmin;
USE WAREHOUSE compute_wh;
USE DATABASE job_data;
USE SCHEMA job_schema;
SELECT COUNT(*) as row_count
FROM job_info;
SELECT *
FROM job_info
LIMIT 10;

CREATE OR REPLACE TEMPORARY TABLE temp_job_info AS
SELECT * FROM 
(
    SELECT 
        ROW_NUMBER() OVER (PARTITION BY title, description ORDER BY salary ASC) AS rn,
        job_info.*
    FROM 
        job_info
    WHERE title IS NOT NULL AND salary IS NOT NULL
)
WHERE rn = 1;

TRUNCATE TABLE job_info;
INSERT INTO job_info
SELECT title,description,salary,date_posted FROM temp_job_info;

DROP TABLE temp_job_info;

SELECT COUNT(*) AS row_count
FROM job_info;
ALTER TABLE job_info ADD COLUMN posted_on DATE;
UPDATE job_info
SET posted_on = CASE
    WHEN LOWER(date_posted) LIKE '%today%' THEN CURRENT_DATE()
    WHEN LOWER(date_posted) LIKE '%minute%' THEN DATEADD(minute, -IFF(NULLIF(REGEXP_REPLACE(date_posted, '[^0-9]', ''), '') IS NOT NULL, TO_NUMBER(REGEXP_REPLACE(date_posted, '[^0-9]', '')), 0), CURRENT_DATE())
    WHEN LOWER(date_posted) LIKE '%hour%' THEN DATEADD(hour, -IFF(NULLIF(REGEXP_REPLACE(date_posted, '[^0-9]', ''), '') IS NOT NULL, TO_NUMBER(REGEXP_REPLACE(date_posted, '[^0-9]', '')), 0), CURRENT_DATE())
    WHEN LOWER(date_posted) LIKE '%day%' THEN DATEADD(day, -IFF(NULLIF(REGEXP_REPLACE(date_posted, '[^0-9]', ''), '') IS NOT NULL, TO_NUMBER(REGEXP_REPLACE(date_posted, '[^0-9]', '')), 0), CURRENT_DATE())
    ELSE NULL
END;
SELECT *
FROM job_info
LIMIT 10;

SELECT
    CASE
        WHEN salary LIKE '%$%' THEN REPLACE(REPLACE(salary, '$', ''), ',', '')
        ELSE salary
    END AS cleaned_salary
FROM job_info
LIMIT 10;
SELECT *
FROM JOB_INFO
limit 10;