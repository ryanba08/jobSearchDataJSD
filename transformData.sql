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
    WHEN date_posted ILIKE '%today%' THEN CURRENT_DATE()
    WHEN date_posted ILIKE '%minute%' THEN DATEADD(minute, -IFF(NULLIF(REGEXP_REPLACE(date_posted, '[^0-9]', ''), '') IS NOT NULL, TO_NUMBER(REGEXP_REPLACE(date_posted, '[^0-9]', '')), 0), CURRENT_DATE())
    WHEN date_posted ILIKE '%hour%' THEN DATEADD(hour, -IFF(NULLIF(REGEXP_REPLACE(date_posted, '[^0-9]', ''), '') IS NOT NULL, TO_NUMBER(REGEXP_REPLACE(date_posted, '[^0-9]', '')), 0), CURRENT_DATE())
    WHEN date_posted ILIKE '%day%' THEN DATEADD(day, -IFF(NULLIF(REGEXP_REPLACE(date_posted, '[^0-9]', ''), '') IS NOT NULL, TO_NUMBER(REGEXP_REPLACE(date_posted, '[^0-9]', '')), 0), CURRENT_DATE())
    ELSE NULL
END;

ALTER TABLE job_info
ADD COLUMN cleaned_salary TEXT;
UPDATE job_info
SET cleaned_salary = REGEXP_REPLACE(cleaned_salary, '[^0-9-]', '');
SELECT salary,cleaned_salary
FROM job_info
LIMIT 100;

ALTER TABLE job_info
ADD COLUMN IF NOT EXISTS min_salary NUMBER;
ALTER TABLE job_info
ADD COLUMN IF NOT EXISTS max_salary NUMBER;
UPDATE job_info
SET min_salary =
    CASE
        WHEN salary ILIKE '%annually%' THEN TRY_TO_NUMBER(TRIM(SPLIT_PART(cleaned_salary, '-', 1))) * 1000
        WHEN salary ILIKE '%hour' THEN TRY_TO_NUMBER(TRIM(SPLIT_PART(cleaned_salary, '-', 1))) * 40 * 52
        WHEN salary ILIKE '%year%' THEN TRY_TO_NUMBER(SPLIT_PART(cleaned_salary, '-', 1))
        ELSE NULL
        END,
    max_salary =
    CASE
        WHEN salary ILIKE '%annually%' THEN TRY_TO_NUMBER(TRIM(SPLIT_PART(cleaned_salary, '-', 2))) * 1000
        WHEN salary ILIKE '%hour' THEN TRY_TO_NUMBER(TRIM(SPLIT_PART(cleaned_salary, '-', 2))) * 40 * 52
        WHEN salary ILIKE '%year%' THEN TRY_TO_NUMBER(SPLIT_PART(cleaned_salary, '-', 2))
    END;
SELECT COUNT(*) as row_count
FROM job_info

WHERE min_salary is NULL;