
-- Frosty Friday Challenge
-- Week 76 - Intermediate - Tasks
-- https://frostyfriday.org/blog/2024/01/12/week-76-intermediate/

-------------------------------
-- Environment Configuration

use database CH_FROSTY_FRIDAY;

use warehouse WH_CHASTIE;

create or replace schema WEEK_76;

use schema WEEK_76;

-------------------------------
-- Challenge Setup Script

create or replace table TASK_TABLE (EXECUTED_TIMESTAMP timestamp, MESSAGE varchar);

create or replace task MAIN_TASK
  schedule = '1 minute'
  warehouse = 'WH_CHASTIE' -- Modified to a user managed task to match privileges I have on the account
as
  select case
    when random() < 0 then 1/0
    else 1
  end
;

create or replace task CHILD_TASK
  warehouse = 'WH_CHASTIE' -- Modified to a user managed task to match privileges I have on the account
  after MAIN_TASK
as
  insert into TASK_TABLE (EXECUTED_TIMESTAMP, MESSAGE) values (current_timestamp, 'MAIN_TASK success!')
;

-------------------------------
-- Challenge Solution

-- Create the task
create or replace task FINALIZER_TASK
  warehouse = 'WH_CHASTIE' -- Modified to a user managed task to match privileges I have on the account
  finalize = MAIN_TASK
as
  insert into TASK_TABLE (EXECUTED_TIMESTAMP, MESSAGE) values (current_timestamp, 'MAIN_TASK ran!')
;

-- Activate the tasks
alter task FINALIZER_TASK resume;
alter task CHILD_TASK resume;
alter task MAIN_TASK resume;

-- Query the table
select * from TASK_TABLE;

-- Deactive the tasks to clean up
alter task MAIN_TASK suspend;
alter task CHILD_TASK suspend;
alter task FINALIZER_TASK suspend;
