
-- Frosty Friday Challenge
-- Week 83 - Basic - Qualify
-- https://frostyfriday.org/blog/2024/03/01/week-83-basic/

-------------------------------
-- Environment Configuration

use database CH_FROSTY_FRIDAY;

use warehouse WH_CHASTIE;

create or replace schema WEEK_83;

use schema WEEK_83;

-------------------------------
-- Challenge Setup Script

-- Create SALES_DATA table
create or replace table "SALES_DATA" (
    "PRODUCT_ID" int
  , "QUANTITY_SOLD" int
  , "PRICE" decimal(10,2)
  , "TRANSACTION_DATE" date
)
as
select *
from values
    (1, 10, 15.99, '2024-02-01')
  , (1, 8, 15.99, '2024-02-05')
  , (2, 15, 22.50, '2024-02-02')
  , (2, 20, 22.50, '2024-02-07')
  , (3, 12, 10.75, '2024-02-03')
  , (3, 18, 10.75, '2024-02-08')
  , (4, 5, 30.25, '2024-02-04')
  , (4, 10, 30.25, '2024-02-09')
  , (5, 25, 18.50, '2024-02-06')
  , (5, 30, 18.50, '2024-02-10')
;

-------------------------------
-- Challenge Solution

select
    "PRODUCT_ID"
  , SUM("QUANTITY_SOLD" * "PRICE") as "TOTAL_REVENUE"
from "SALES_DATA"
group by
    "PRODUCT_ID"
qualify row_number() over (
    partition by "PRODUCT_ID"
    order by "TOTAL_REVENUE" desc nulls last
  ) <= 10
order by "TOTAL_REVENUE" desc nulls last
;
