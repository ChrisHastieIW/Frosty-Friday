
-- Frosty Friday Challenge
-- Week 39 - Basic - Column Level Security
-- https://frostyfriday.org/2023/03/24/week-39-basic/

-------------------------------
-- Environment Configuration

use database CH_FROSTY_FRIDAY;

use warehouse WH_CHASTIE;

create or replace schema WEEK_39;

use schema WEEK_39;

-------------------------------
-- Create challenge data

-- Create challenge table
create or replace table customer_details (
    id int
  , name string
  , email string
)
as
select *
from values
    (1, 'Jeff Jeffy', 'jeff.jeffy121@gmail.com')
  , (2, 'Kyle Knight', 'kyleisdabest@hotmail.com')
  , (3, 'Spring Hall', 'hall.yay@gmail.com')
  , (4, 'Dr Holly Ray', 'drdr@yahoo.com')
;
  
-- Query the table to view the data
select * from customer_details;

-------------------------------
-- Create masking policy

-- Create policy
create or replace masking policy customer_emails
  as (input_string string) returns string ->
  case when current_role() = 'SYSADMIN'
    then input_string
    else regexp_replace(input_string,'.+\\@','*****@')
  end
;

-- Assign policy
alter table customer_details
alter column email set masking policy customer_emails
;

-------------------------------
-- Test the policy

-- Query the table to view the data
select * from customer_details;

