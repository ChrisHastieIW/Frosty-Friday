
-- Frosty Friday Challenge
-- Week 78 - Basic - Session Variables
-- https://frostyfriday.org/blog/2024/01/26/week-78-basic/

-------------------------------
-- Environment Configuration

use database CH_FROSTY_FRIDAY;

use warehouse WH_CHASTIE;

create or replace schema WEEK_78;

use schema WEEK_78;

-------------------------------
-- Challenge Setup Script

-- Create challenge table
create or replace table SALES
as
select
    seq4() as SALES_ID
  , case  mod(seq4(), 4)
      when 0 then 'Product A'
      when 1 then 'Product B'
      when 2 then 'Product C'
      else 'Product D'
    end as PRODUCT_NAME
  , uniform(1, 10, random())::integer as QUANTITY_SOLD
  , dateadd('day', -uniform(1, 365, RANDOM())::integer, current_date()) as SALES_DATE
  , uniform(20, 100, random())::float * uniform(1, 10, random())::integer as SALES_AMOUNT
from table(generator(ROWCOUNT => 1000))
;

-- View challenge table
select * from SALES;

-------------------------------
-- Challenge Solution

-- Set the variable
set sales_average = (select avg(SALES_AMOUNT) from SALES);

select *
from SALES
where SALES_AMOUNT between $sales_average - 50 and $sales_average + 50
;
