
-- Frosty Friday Challenge
-- Week 33 - Hard - Multiple
-- https://frostyfriday.org/2023/02/10/week-33-hard/

-------------------------------
-- Environment Configuration

use database CH_FROSTY_FRIDAY;

use warehouse WH_CHASTIE;

create or replace schema WEEK_33;

use schema WEEK_33;

-------------------------------
-- Create cluster depth monitoring table

create or replace transient table cluster_depth_monitoring (
    database_name varchar
  , schema_name varchar
  , table_name varchar
  , clustering_depth float
  , inserted_at timestamp
  , inserted_by varchar
);

-------------------------------
-- Identify tables that are clustered

-- Initial query
select *
from snowflake_sample_data.information_schema.tables
where clustering_key is not null
;

-- Stored Procedure to create table of clustered tables
CREATE OR REPLACE PROCEDURE retrieve_clustered_tables(
      database_name string
    , query_tag string
  )
  returns string
  language python
  runtime_version = '3.8'
  packages = ('snowflake-snowpark-python')
  handler = 'main'
  execute as caller -- Required for ALTER SESSION for query tags
as
$$

# Import required modules
import snowflake.snowpark
import json

# Define main function for the stored procedure
def main(
      snowpark_session : snowflake.snowpark.Session
    , database_name : str
    , query_tag : str
  ):
  snowpark_session.query_tag = query_tag
  snowpark_session.sql(f'''
      create or replace transient table clustered_tables
      as
      select *
      from "{database_name}".information_schema.tables
      where clustering_key is not null
    ''').collect()
  return 'Complete'
$$
;

-- Test stored procedure
call retrieve_clustered_tables('SNOWFLAKE_SAMPLE_DATA', 'cluster_depth_monitoring');

select * from clustered_tables;

-- create task
create or replace task IDENTIFY_TABLES
  warehouse = 'WH_CHASTIE'
as
  call retrieve_clustered_tables('SNOWFLAKE_SAMPLE_DATA', 'cluster_depth_monitoring')
;

-------------------------------
-- Insert the clustering depth details for each table

-- Initial query
select system$clustering_depth('SNOWFLAKE_SAMPLE_DATA.TPCDS_SF100TCL.CATALOG_PAGE');

-- Stored Procedure to create table of clustered tables
CREATE OR REPLACE PROCEDURE insert_cluster_details(
      database_name string
    , query_tag string
  )
  returns string
  language python
  runtime_version = '3.8'
  packages = ('snowflake-snowpark-python')
  handler = 'main'
  execute as caller -- Required for ALTER SESSION for query tags
as
$$

# Import required modules
import snowflake.snowpark
import json
 
# Define main function for the stored procedure
def main(
      snowpark_session : snowflake.snowpark.Session
    , database_name : str
    , query_tag : str
  ):
  
  snowpark_session.query_tag = query_tag
  
  df_sf_clustered_tables = snowpark_session.table("CLUSTERED_TABLES").collect()

  for row in df_sf_clustered_tables :
    schema_name = row.as_dict()["TABLE_SCHEMA"]
    table_name = row.as_dict()["TABLE_NAME"]
    snowpark_session.sql(f'''
      insert into cluster_depth_monitoring
      select
          '{database_name}'
        , '{schema_name}'
        , '{table_name}'
        , system$clustering_depth('"{database_name}"."{schema_name}"."{table_name}"')            , current_timestamp()
        , SYSTEM$CURRENT_USER_TASK_NAME()
     ''').collect()
  
  return 'Complete'
$$
;

-- Test stored procedure
call insert_cluster_details('SNOWFLAKE_SAMPLE_DATA', 'cluster_depth_monitoring');

select * from cluster_depth_monitoring;

-- create task
create or replace task INSERT_DETAILS
  warehouse = 'WH_CHASTIE'
  after IDENTIFY_TABLES
as
  call insert_cluster_details('SNOWFLAKE_SAMPLE_DATA', 'cluster_depth_monitoring')
;


-------------------------------
-- Insert the clustering depth details for each table

-- Stored Procedure to create table of clustered tables
CREATE OR REPLACE PROCEDURE clean_up(
      query_tag string
  )
  returns string
  language python
  runtime_version = '3.8'
  packages = ('snowflake-snowpark-python')
  handler = 'main'
  execute as caller -- Required for ALTER SESSION for query tags
as
$$

# Import required modules
import snowflake.snowpark
import json
 
# Define main function for the stored procedure
def main(
      snowpark_session : snowflake.snowpark.Session
    , query_tag : str
  ):
  snowpark_session.query_tag = query_tag
  snowpark_session.sql(f'''
      drop table if exists clustered_tables
    ''').collect()
  return 'Complete'
$$
;

-- Test stored procedure
call clean_up('cluster_depth_monitoring');

-- create task
create or replace task CLEAN_UP
  warehouse = 'WH_CHASTIE'
  after INSERT_DETAILS
as
  call clean_up('cluster_depth_monitoring')
;

-------------------------------
-- Review final architecture

-- Execute task
alter task CLEAN_UP resume;
alter task INSERT_DETAILS resume;
EXECUTE TASK IDENTIFY_TABLES;

-- Show complete graphs
select *
  from table(information_schema.complete_task_graphs(
    root_task_name => 'IDENTIFY_TABLES'
  ))
  order by scheduled_time
;

-- Show current graphs
select *
  from table(information_schema.current_task_graphs(
    root_task_name => 'IDENTIFY_TABLES'
  ))
  order by scheduled_time
;

select * from cluster_depth_monitoring;