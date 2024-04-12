
-- Frosty Friday Challenge
-- Week 89 - Easy - Budgets
-- https://frostyfriday.org/blog/2024/03/29/week-87-basic/

-------------------------------
-- Environment Configuration

use database CH_FROSTY_FRIDAY;

use warehouse WH_CHASTIE;

create or replace schema WEEK_89;

use schema WEEK_89;

-------------------------------
-- Challenge Solution
-- Custom budget only as my account
-- is shared with other people

-- Create the budget
create SNOWFLAKE.CORE.BUDGET "MY_BUDGET"();

-- Assign spending limit
call "MY_BUDGET"!SET_SPENDING_LIMIT(1);

-- View budget details
select SYSTEM$SHOW_BUDGETS_IN_ACCOUNT();

-- Test email integration created in week 26
call SYSTEM$SEND_EMAIL(
    'EMAILS_CH'
  , '<my email>'
  , 'Snowflake Frosty Friday Week 89'
  , 'Test message'
)
;

-- Grant email integration to budget (requires elevated role)
grant usage on integration "EMAILS_CH" to application "SNOWFLAKE";

-- Configure email integration for budget
call "MY_BUDGET"!SET_EMAIL_NOTIFICATIONS(
    'EMAILS_CH'
  , '<my email>'
);

-- View linked resources
call "MY_BUDGET"!GET_LINKED_RESOURCES();

-- Create dummy warehouse to monitor
create or replace warehouse "WH__CH__FF__WEEK_89"
  warehouse_size = 'XSMALL'
  initially_suspended = TRUE
  comment = 'Warehouse for Chris Hastie when completing Frosty Friday challenge 89'
;

-- Apply budget to warehouse
call "MY_BUDGET"!ADD_RESOURCE(
  SYSTEM$REFERENCE('WAREHOUSE', 'WH__CH__FF__WEEK_89', 'SESSION', 'applybudget'))
;

-- Run a quick query to start the warehouse
use warehouse "WH__CH__FF__WEEK_89";
select 1 + 1;

-- Finally, monitor the activity in Snowsight
