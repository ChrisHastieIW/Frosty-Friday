
-- Frosty Friday Challenge
-- Week 36 - Intermediate - Stored Procedure
-- https://frostyfriday.org/2023/03/03/week-36-intermediate/

-------------------------------
-- Environment Configuration

use database CH_FROSTY_FRIDAY;

use warehouse WH_CHASTIE;

create or replace schema WEEK_36;

use schema WEEK_36;

-------------------------------
-- Create challenge input

CREATE OR REPLACE TABLE table_1 (id INT);
CREATE OR REPLACE VIEW view_1 AS (SELECT * FROM table_1);
CREATE OR REPLACE TABLE table_2 (id INT);
CREATE OR REPLACE VIEW view_2 AS (SELECT * FROM table_2);
CREATE OR REPLACE TABLE table_6 (id INT);
CREATE OR REPLACE VIEW view_6 AS (SELECT * FROM table_6);
CREATE OR REPLACE TABLE table_5 (id INT);
CREATE OR REPLACE VIEW view_5 AS (SELECT * FROM table_5);
CREATE OR REPLACE TABLE table_4 (id INT);
CREATE OR REPLACE VIEW view_4 AS (SELECT * FROM table_4);
CREATE OR REPLACE TABLE table_3 (id INT);
CREATE OR REPLACE VIEW view_3 AS (SELECT * FROM table_3);
CREATE OR REPLACE VIEW my_union_view AS
SELECT * FROM table_1
UNION ALL
SELECT * FROM table_2
UNION ALL
SELECT * FROM table_3
UNION ALL
SELECT * FROM table_4
UNION ALL
SELECT * FROM table_5
UNION ALL
SELECT * FROM table_6;

-- Additional one for testing that does not have a dependent object
CREATE OR REPLACE TABLE table_X (id INT);

-------------------------------
-- References

-- Simple and fast way to see all references for a view
select *
from table(GET_OBJECT_REFERENCES(
      database_name => 'CH_FROSTY_FRIDAY'
    , schema_name => 'WEEK_36'
    , object_name => 'MY_UNION_VIEW' 
  ))
where REFERENCED_OBJECT_TYPE = 'TABLE'
  and REFERENCED_DATABASE_NAME = 'CH_FROSTY_FRIDAY'
  and REFERENCED_SCHEMA_NAME = 'WEEK_36'
--   and REFERENCED_OBJECT_NAME = ''
;

-- After the SNOWFLAKE shared database has synced,
-- this is a quick way to determine if a given table is referenced
-- by any objects
select *
from SNOWFLAKE.ACCOUNT_USAGE.OBJECT_DEPENDENCIES
where REFERENCED_OBJECT_DOMAIN = 'TABLE'
  and REFERENCED_DATABASE = 'CH_FROSTY_FRIDAY'
  and REFERENCED_SCHEMA = 'WEEK_36'
--   and REFERENCED_OBJECT_NAME = ''
;

-- Use this query to directly retrieve
-- fully qualified names of dependent objects
select distinct concat(
    '"'
  , REFERENCING_DATABASE
  , '"."'
  , REFERENCING_SCHEMA
  , '"."'
  , REFERENCING_OBJECT_NAME
  , '"'
) as OBJECT_FQN
from SNOWFLAKE.ACCOUNT_USAGE.OBJECT_DEPENDENCIES
where REFERENCED_OBJECT_DOMAIN = 'TABLE'
  and REFERENCED_DATABASE = 'CH_FROSTY_FRIDAY'
  and REFERENCED_SCHEMA = 'WEEK_36'
  and REFERENCED_OBJECT_NAME = 'TABLE_1'
;

-------------------------------
-- Automated solution options

-- If you wish to build a stored procedure which first
-- checks for dependencies on a table, then drops the table
-- of no dependencies exist, there are two options:
--
--   1. Identify any entries in SNOWFLAKE.ACCOUNT_USAGE.OBJECT_DEPENDENCIES
--      and return the list of views if any exist. Drop the table if no values
--      views are returned. This will only work for views which have not been
--      created or modified in the last 2 hours.
--   2. Execute a function to list all views in your entire account, then iterate
--      through this list to execute the GET_OBJECT_REFERENCES table function for
--      each of these views and combine the results. Return the list of views if any
--      exist. Drop the table if no values are returned. This allows you to ensure all
--      views are examined, including those created or modified in the last 2 hours.
--
-- Personally, I prefer the thought of option (1) as it scales to larger Snowflake
-- platforms more robustly. This is the solution I have put together below.

-- Create the stored procedure
CREATE OR REPLACE PROCEDURE ATTEMPT_TABLE_DROP(
      TABLE_DATABASE STRING
    , TABLE_SCHEMA STRING
    , TABLE_NAME STRING
  )
  returns string not null
  language python
  runtime_version = '3.8'
  packages = ('snowflake-snowpark-python')
  handler = 'attempt_table_drop'
as
$$

# Import module for inbound Snowflake session
from snowflake.snowpark import session as snowpark_session

# Define function to retrieve list of dependent objects for given table
def retrieve_dependencies_for_table(
      snowpark_session: snowpark_session
    , table_database: str
    , table_schema: str
    , table_name: str
  ):
  
  ## Retrieve grants on schema
  ## using ''' for a multi-line string input
  sf_df_dependent_objects = snowpark_session.sql(f'''
      select distinct concat(
          '"'
        , REFERENCING_DATABASE
        , '"."'
        , REFERENCING_SCHEMA
        , '"."'
        , REFERENCING_OBJECT_NAME
        , '"'
      ) as OBJECT_FQN
      from SNOWFLAKE.ACCOUNT_USAGE.OBJECT_DEPENDENCIES
      where REFERENCED_OBJECT_DOMAIN = 'TABLE'
        and REFERENCED_DATABASE = '{table_database}'
        and REFERENCED_SCHEMA = '{table_schema}'
        and REFERENCED_OBJECT_NAME = '{table_name}'
      ;
    ''').collect()

  list_dependent_objects = []
  if sf_df_dependent_objects is not None \
    and len(sf_df_dependent_objects) > 0 :
      list_dependent_objects = [row["OBJECT_FQN"] for row in sf_df_dependent_objects]
  
  return list_dependent_objects

# Define function to drop the table
def drop_table(
      snowpark_session: snowpark_session
    , table_database: str
    , table_schema: str
    , table_name: str
  ):

  ## Execute drop command
  ## using ''' for a multi-line string input
  snowpark_session.sql(f'''
      DROP TABLE IF EXISTS "{table_database}"."{table_schema}"."{table_name}"
    ''').collect()
  
  return
  
# Define main function to clone a schema with grants
def attempt_table_drop(
      snowpark_session: snowpark_session
    , table_database: str
    , table_schema: str
    , table_name: str
  ):

  ## Execute function to retrieve list of dependent objects for given table
  list_dependent_objects = retrieve_dependencies_for_table(
        snowpark_session = snowpark_session
      , table_database = table_database
      , table_schema = table_schema
      , table_name = table_name
    )
    
  ## If dependencies are found, return the list.
  ## Otherwise, drop the table
  if len(list_dependent_objects) > 0 :
    return 'Could not drop. The following dependent objects were found: \n  ' + '\n  '.join(list_dependent_objects)
  else :
    ### Execute function to drop the table
    drop_table(
        snowpark_session = snowpark_session
      , table_database = table_database
      , table_schema = table_schema
      , table_name = table_name
    )

    return 'Table dropped'
$$
;

------------------------------------------------------------------
-- Testing

-- Test with dependencies
call ATTEMPT_TABLE_DROP(
      'CH_FROSTY_FRIDAY'
    , 'WEEK_36'
    , 'TABLE_1'
  )
;

-- Output was:
/*
Could not drop. The following dependent objects were found: 
  "CH_FROSTY_FRIDAY"."WEEK_36"."MY_UNION_VIEW"
  "CH_FROSTY_FRIDAY"."WEEK_36"."VIEW_1"
*/

-- Test without dependencies
call ATTEMPT_TABLE_DROP(
      'CH_FROSTY_FRIDAY'
    , 'WEEK_36'
    , 'TABLE_X'
  )
;
-- Output was:
/*
Table dropped
*/
