USE ROLE accountadmin;
USE WAREHOUSE compute_wh;
CREATE OR REPLACE DATABASE job_data;
CREATE OR REPLACE SCHEMA job_data.job_schema;
CREATE OR REPLACE TABLE job_data.job_schema.job_info
(
    title VARCHAR(16777216),
    description VARCHAR(16777216),
    salary VARCHAR(16777216),
    date_posted VARCHAR(16777216)
);
CREATE OR REPLACE STAGE job_data.job_schema.stage_one
file_format = (type = csv, SKIP_HEADER=1,FIELD_OPTIONALLY_ENCLOSED_BY='"');

PUT file:///Users/macmini/Desktop/coding/job_trends/builtInData.csv @job_data.job_schema.stage_one AUTO_COMPRESS=TRUE;
PUT file:///Users/macmini/Desktop/coding/job_trends/jobcubeData.csv @job_data.job_schema.stage_one AUTO_COMPRESS=TRUE;

COPY INTO job_data.job_schema.job_info
FROM @JOB_DATA.JOB_SCHEMA.STAGE_ONE
FILES = ('jobcubeData.csv.gz', 'builtInData.csv.gz');

SELECT COUNT(*) as row_count
FROM JOB_DATA.JOB_SCHEMA.JOB_INFO;
SELECT *
FROM JOB_DATA.JOB_SCHEMA.JOB_INFO
LIMIT 10;