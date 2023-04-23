
-- Frosty Friday Challenge
-- Week 42 - Intermediate - Tasks
-- https://frostyfriday.org/2023/04/21/week-42-intermediate/

-------------------------------
-- Environment Configuration

use database CH_FROSTY_FRIDAY;

use warehouse WH_CHASTIE;

create or replace schema WEEK_42;

use schema WEEK_42;

-------------------------------
-- Create table to track kid activity

create or replace table KIDS_OUT_OF_BED(
    "TIME"    TIMESTAMP
  , "JOAN"    BOOLEAN    DEFAULT FALSE
  , "MAGGY"   BOOLEAN    DEFAULT FALSE
  , "JASON"   BOOLEAN    DEFAULT FALSE
)
;

select * from KIDS_OUT_OF_BED;

-------------------------------
-- Create procedure to execute a query for a given time
-- to imitate a kid being awake

-- Create procedure
create or replace procedure KEEP_AWAKE(
  AWAKE_TIME_IN_MINUTES INT
)
  returns string null
  language python
  runtime_version = '3.8'
  packages = ('snowflake-snowpark-python')
  handler = 'keep_awake'
as
$$

# Import module for inbound Snowflake session
from snowflake.snowpark import session as snowpark_session

# Import other modules
import time

# Define handler function
def keep_awake(
      snowpark_session: snowpark_session
    , awake_time_in_minutes: int
  ):
  ## It feels ironic using a sleep command
  ## to imitate keeping a child awake
  time.sleep(60*awake_time_in_minutes)
  return
$$
;

-- Test procedure
call KEEP_AWAKE(1);
call KEEP_AWAKE(2);

------------------------------
-- Tasks for the kids

-- Joan
create or replace task CH_FF42_JOAN
  warehouse = 'WH_CHASTIE'
  schedule = '3 minutes'
  comment = 'Chris Hastie - Frosty Friday Week 42'
as
  CALL KEEP_AWAKE(2)
;

-- Maggy
create or replace task CH_FF42_MAGGY
  warehouse = 'WH_CHASTIE'
  schedule = '5 minutes'
  comment = 'Chris Hastie - Frosty Friday Week 42'
as
  CALL KEEP_AWAKE(1)
;

-- JASON
create or replace task CH_FF42_JASON
  warehouse = 'WH_CHASTIE'
  schedule = '13 minutes'
  comment = 'Chris Hastie - Frosty Friday Week 42'
as
  CALL KEEP_AWAKE(1)
;

-------------------------------
-- Create procedure for dad

-- Execute tasks manually whilst testing
execute task CH_FF42_JOAN;
execute task CH_FF42_MAGGY;
execute task CH_FF42_JASON;

-- Create SQL to observe the tasks
-- that can be used to populate the kids
-- table. This will be part of the procedure
with awake_kids as (
  select replace(name, 'CH_FF42_') as kid
  from table(information_schema.task_history(RESULT_LIMIT => 20))
  where
      date_trunc('minute', current_timestamp)
    between
        date_trunc('minute', scheduled_time)
      and
        coalesce(
            date_trunc('minute', completed_time)
          , date_trunc('minute', current_timestamp)
        )
)
select
    date_trunc('minute', current_timestamp) as TIME
  , "'JOAN'" IS NOT NULL as JOAN
  , "'MAGGY'" IS NOT NULL as MAGGY
  , "'JASON'" IS NOT NULL as JASON
from awake_kids
  pivot (max(kid) for kid in ('JOAN', 'MAGGY', 'JASON'))
;

-- Create procedure
create or replace procedure DAD_CHECK()
  returns string null
  language python
  runtime_version = '3.8'
  packages = ('snowflake-snowpark-python')
  handler = 'main'
  execute as caller
as
$$

# Import module for inbound Snowflake session
from snowflake.snowpark import session as snowpark_session

# Define function to check on the kids
def check_on_kids(
      snowpark_session: snowpark_session
  ):

  ## Retrieve list of all kids who are awake
  sf_df_awake_kids = snowpark_session.sql(f'''
        with awake_kids as (
          select replace(name, 'CH_FF42_') as kid
          from table(information_schema.task_history(RESULT_LIMIT => 20))
          where
              date_trunc('minute', current_timestamp)
            between
                date_trunc('minute', scheduled_time)
              and
                coalesce(
                    date_trunc('minute', completed_time)
                  , date_trunc('minute', current_timestamp)
                )
        )
        select
            date_trunc('minute', current_timestamp) as TIME
          , "'JOAN'" IS NOT NULL as JOAN
          , "'MAGGY'" IS NOT NULL as MAGGY
          , "'JASON'" IS NOT NULL as JASON
        from awake_kids
          pivot (max(kid) for kid in ('JOAN', 'MAGGY', 'JASON'))
      ''')

  ## Append to tracker
  sf_df_awake_kids.write.save_as_table("KIDS_OUT_OF_BED", mode="append")

  return 
  
# Define function to check on the kids
def check_if_all_awake(
      snowpark_session: snowpark_session
  ):

  ## Retrieve list of all kids who are awake
  sf_df_all_awake = snowpark_session.sql(f'''
        select
            JOAN and MAGGY and JASON as ALL_AWAKE_FLAG
        from KIDS_OUT_OF_BED
        order by TIME desc
        limit 1
      ''').collect()

  all_awake_flag = sf_df_all_awake[0]["ALL_AWAKE_FLAG"]

  return all_awake_flag
  
# Define function to suspend all kid tasks
def send_all_to_bed(
      snowpark_session: snowpark_session
  ):
  for person in ["JOAN", "MAGGY", "JASON", "DAD"]:
    snowpark_session.sql(f'''
        ALTER TASK CH_FF42_{person} SUSPEND
      ''').collect()

# Define handler function
def main(
      snowpark_session: snowpark_session
  ):

  check_on_kids(snowpark_session=snowpark_session)

  all_awake_flag = check_if_all_awake(snowpark_session=snowpark_session)

  if all_awake_flag == True :
    send_all_to_bed(snowpark_session=snowpark_session)
  
  return all_awake_flag
$$
;

-- Test procedure
call DAD_CHECK();

-- Execute tasks manually whilst testing
execute task CH_FF42_JOAN;
execute task CH_FF42_MAGGY;
execute task CH_FF42_JASON;

truncate table KIDS_OUT_OF_BED;
select * from KIDS_OUT_OF_BED;

-------------------------------
-- Task: Dad

create or replace task CH_FF42_DAD
  warehouse = 'WH_CHASTIE'
  schedule = '1 minute'
  comment = 'Chris Hastie - Frosty Friday Week 42'
as
  call DAD_CHECK();
;

-------------------------------
-- Main test

-- View the tasks
show tasks;

-- Empty table for fresh run
truncate table KIDS_OUT_OF_BED;

-- Enable tasks
alter task CH_FF42_JOAN resume;
alter task CH_FF42_MAGGY resume;
alter task CH_FF42_JASON resume;
alter task CH_FF42_DAD resume;

-- Wait for a while for everything to run
-- then execute the following to see your full
-- activity log, with the most recent entry
-- being when all kids were sent to bed for good
select * from KIDS_OUT_OF_BED order by time desc;
