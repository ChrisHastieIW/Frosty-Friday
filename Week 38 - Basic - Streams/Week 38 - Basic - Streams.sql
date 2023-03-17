
-- Frosty Friday Challenge
-- Week 38 - Basic - Streams
-- https://frostyfriday.org/2023/03/17/week-38-basic/

-------------------------------
-- Environment Configuration

use database CH_FROSTY_FRIDAY;

use warehouse WH_CHASTIE;

create or replace schema WEEK_38;

use schema WEEK_38;

-------------------------------
-- Create challenge stage

-- Create first table
create or replace table employees (
    id INT
  , name VARCHAR(50)
  , department VARCHAR(50)
)
as
select *
from values
    (1, 'Alice', 'Sales')
  , (2, 'Bob', 'Marketing')
;

-- Create second table
create or replace table sales (
    id INT
  , employee_id INT
  , sale_amount DECIMAL(10, 2)
)
as
select * from values
    (1, 1, 100.00)
  , (2, 1, 200.00)
  , (3, 2, 150.00)
;

-- Create view that combines both tables
create or replace view employee_sales 
as
select e.id, e.name, e.department, s.sale_amount
from employees e
  join sales s 
    on e.id = s.employee_id
;

-- Query the view to verify the data
select * from employee_sales;

-------------------------------
-- Create stream for the challenge

-- Create stream
create or replace stream challenge_stream
on view employee_sales
  append_only = false
  show_initial_rows = false
;

-------------------------------
-- Test the stream

-- Delete reocrds
delete from sales
where id = 3
;

-- View stream
select * from challenge_stream
where "METADATA$ACTION"  = 'DELETE'
;

-- Output deletions to new table
create or replace table deleted_sales
as
select * from challenge_stream
where "METADATA$ACTION"  = 'DELETE'
;

-- Confirm table contents
select * from deleted_sales;
