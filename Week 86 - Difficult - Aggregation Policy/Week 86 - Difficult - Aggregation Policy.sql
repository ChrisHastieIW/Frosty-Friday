
-- Frosty Friday Challenge
-- Week 86 - Difficult - Aggregation Policy
-- https://frostyfriday.org/blog/2024/03/22/week-86-difficult/

-------------------------------
-- Environment Configuration

use database CH_FROSTY_FRIDAY;

use warehouse WH_CHASTIE;

create or replace schema WEEK_86;

use schema WEEK_86;

-------------------------------
-- Challenge Setup Script

-- Create the Sales_Records table
create or replace table "SALES_RECORDS" (
    "ORDER_ID" int
  , "PRODUCT_NAME" varchar(50)
  , "PRODUCT_CATEGORY" varchar(50)
  , "QUANTITY" int
  , "UNIT_PRICE" decimal(10,2)
  , "CUSTOMER_ID" int
)
as
select * from values
    (1, 'Laptop', 'Electronics', 2, 1200.00, 101)
  , (2, 'Smartphone', 'Electronics', 1, 800.00, 102)
  , (3, 'Headphones', 'Electronics', 5, 50.00, 103)
  , (4, 'T-shirt', 'Apparel', 3, 20.00, 104)
  , (5, 'Jeans', 'Apparel', 2, 30.00, 105)
  , (6, 'Sneakers', 'Footwear', 1, 80.00, 106)
  , (7, 'Backpack', 'Accessories', 4, 40.00, 107)
  , (8, 'Sunglasses', 'Accessories', 2, 50.00, 108)
  , (9, 'Watch', 'Accessories', 1, 150.00, 109)
  , (10, 'Tablet', 'Electronics', 3, 500.00, 110)
  , (11, 'Jacket', 'Apparel', 2, 70.00, 111)
  , (12, 'Dress', 'Apparel', 1, 60.00, 112)
  , (13, 'Sandals', 'Footwear', 4, 25.00, 113)
  , (14, 'Belt', 'Accessories', 2, 30.00, 114)
  , (15, 'Speaker', 'Electronics', 1, 150.00, 115)
  , (16, 'Wallet', 'Accessories', 3, 20.00, 116)
  , (17, 'Hoodie', 'Apparel', 2, 40.00, 117)
  , (18, 'Running Shoes', 'Footwear', 1, 90.00, 118)
  , (19, 'Earrings', 'Accessories', 4, 15.00, 119)
  , (20, 'Ring', 'Accessories', 2, 50.00, 120)
;

-------------------------------
-- Challenge Solution

-- Create the aggregation policy
create or replace aggregation policy "MY_AGG_POLICY"
  as ()
  returns aggregation_constraint -> aggregation_constraint(MIN_GROUP_SIZE => 5)
;

-- Attach the aggregation policy to the table
alter table "SALES_RECORDS"
set aggregation policy "MY_AGG_POLICY"
;

-- This query now fails as it is blocked
-- by the aggregation policy for not
-- aggregating enough
select *
from "SALES_RECORDS"
;

-- This query also fails as it is blocked
-- by the aggregation policy for attempting
-- a function that applies at the row level
select
    "PRODUCT_CATEGORY"
  , sum("QUANTITY" * "UNIT_PRICE") as "TOTAL_SALES"
from "SALES_RECORDS"
group by all
;

-- This query still works
select
    "PRODUCT_CATEGORY"
  , count(distinct "PRODUCT_NAME") as "NUMBER_OF_PRODUCTS"
  , count(*) as "TOTAL_VOLUME_OF_SALES"
from "SALES_RECORDS"
group by all
;