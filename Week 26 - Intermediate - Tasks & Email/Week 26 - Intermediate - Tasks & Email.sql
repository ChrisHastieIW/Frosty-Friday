
-- Frosty Friday Challenge
-- Week 26 - Intermediate - Tasks and Email
-- https://frostyfriday.org/2022/12/09/week-26-intermediate/

-------------------------------
-- Environment Configuration

use database CH_FROSTY_FRIDAY;

use warehouse WH_CHASTIE;

create or replace schema WEEK_26;

use schema WEEK_26;

-------------------------------
-- Email Integration

-- Executed by ACCOUNTADMIN
-- create or replace notification integration EMAILS_CH
--   type = email
--   enabled = TRUE
--   allowed_recipients = (<list of recipients>)
--   comment = 'Testing email functionality through Snowflake'
-- ;
-- 
-- grant usage on integration EMAILS to role my_role;

-------------------------------
-- Initial Table

-- Create a table in which to land the data
create or replace table EXECUTED_TIMESTAMPS (
    EXECUTED_TIMESTAMP TIMESTAMP
)
;

-------------------------------
-- Task 1: Insert timestamp into table

create or replace task CH_FF26_INSERT_TIMESTAMP
  warehouse = 'WH_CHASTIE'
  schedule = '5 minutes'
  comment = 'Chris Hastie - Frosty Friday Week 26 - Task to insert timestamp into a table'
as
  insert into EXECUTED_TIMESTAMPS
  select current_timestamp()
;

-------------------------------
-- Send email stored procedure

CREATE OR REPLACE PROCEDURE SEND_EMAIL()
  returns string not null
  language python
  runtime_version = '3.8'
  packages = ('snowflake-snowpark-python')
  handler = 'send_email'
as
$$

# Import module for inbound Snowflake session
from snowflake.snowpark import session as snowpark_session

# Retrieve message from table
def retrieve_message(snowpark_session: snowpark_session):
  sf_df_message = snowpark_session.sql('''
    select
        concat(
            'Task has successfully finished on '
          , current_account()
          , ' which is deployed on '
          , current_region()
          , ' region at '
          , max(EXECUTED_TIMESTAMP)::string
        ) as MESSAGE
    from EXECUTED_TIMESTAMPS
  ''').collect()
  
  message = sf_df_message[0]["MESSAGE"]
  
  return message

# Retrieve message from table
def send_message_in_email(
      snowpark_session: snowpark_session
    , message: str
  ):
  message_as_string = message.replace("'", "\\'")
  result = snowpark_session.sql(f'''
    CALL SYSTEM$SEND_EMAIL(
        'EMAILS_CH'
      , '<my email>'
      , 'Snowflake Frosty Friday Week 26'
      , '{message_as_string}'
    )
  ''').collect()
    
  return result
  
def send_email(snowpark_session: snowpark_session):

  # Read the origin table into a Snowflake dataframe
  message = retrieve_message(snowpark_session)
  
  result = send_message_in_email(snowpark_session, message)
  
  return result
$$
;

-- Test
call SEND_EMAIL();

-------------------------------
-- Task 2: Send email

create or replace task CH_FF26_SEND_EMAIL
  warehouse = 'WH_CHASTIE'
  comment = 'Chris Hastie - Frosty Friday Week 26 - Task to send an email'
  after CH_FF26_INSERT_TIMESTAMP
as
  CALL SEND_EMAIL()
;

alter task CH_FF26_SEND_EMAIL resume;

-------------------------------
-- Testing

-- View the tasks
show tasks;

-- Manually execute the task.
execute task CH_FF26_INSERT_TIMESTAMP;

-- View task history
select *
from table(information_schema.task_history())
order by scheduled_time DESC
;

-- Verify data
select * from EXECUTED_TIMESTAMPS;

