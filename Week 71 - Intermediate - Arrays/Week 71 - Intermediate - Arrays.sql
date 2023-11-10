
-- Frosty Friday Challenge
-- Week 71 - Intermediate - Arrays
-- https://frostyfriday.org/blog/2023/11/10/week-71-intermediate/

-------------------------------
-- Environment Configuration

use database CH_FROSTY_FRIDAY;

use warehouse WH_CHASTIE;

create or replace schema WEEK_71;

use schema WEEK_71;

-------------------------------
-- Challenge Setup Script

-- Create the SALES table
create or replace table SALES (
    SALE_ID int primary key
  , PRODUCT_IDS variant
)
as
-- Inserting sample data into SALES
select $1, parse_json($2)
from values
    (1, '[1, 3]') -- Products A and C in the same sale
  , (2, '[2, 4]') -- Products B and D in the same sale
;

-- Create the PRODUCTS table
create or replace table PRODUCTS (
    PRODUCT_ID int primary key
  , PRODUCT_NAME varchar
  , PRODUCT_CATEGORIES variant
)
as
-- Inserting sample data into PRODUCTS
select $1, $2, array_construct_compact($3, $4)
from values
    (1, 'Product A', 'Electronics', 'Gadgets')
  , (2, 'Product B', 'Clothing', 'Accessories')
  , (3, 'Product C', 'Electronics', 'Appliances')
  , (4, 'Product D', 'Clothing', NULL )
;

-- View setup tables
select * from SALES;
select * from PRODUCTS;

-------------------------------
-- Challenge output view

-- The following solution matches the screenshot
-- in the challenge, however in my interpretation
-- this is not returning the list of common categories,
-- but rather just the connected array of all categories.

-- Create the view
create or replace view CHALLENGE_OUTPUT
as
select
    SALES.SALE_ID
  , array_agg(PRODUCTS.PRODUCT_CATEGORIES) as COMMON_CATEGORIES
from SALES
  inner join PRODUCTS
    on array_contains(PRODUCTS.PRODUCT_ID, SALES.PRODUCT_IDS)
group by SALES.SALE_ID
;

-- Query the view
select * from CHALLENGE_OUTPUT
order by SALE_ID asc
;

-------------------------------
-- Challenge output view 2

-- In my interpretation, the list of common categories
-- should only contain the common categories, and no
-- other categories. The following view achieves this.

-- Create the view
create or replace view CHALLENGE_OUTPUT_2
as
with product_categories_by_sales as (
  select
      SALES.SALE_ID
    , PRODUCTS.PRODUCT_ID
    , PRODUCTS.PRODUCT_CATEGORIES
  from SALES
    inner join PRODUCTS
      on array_contains(PRODUCTS.PRODUCT_ID, SALES.PRODUCT_IDS)
)
, common_categories as (
  select
      SALE_ID
    , PRODUCT_ID
    , flattened_categories.VALUE::string as CATEGORY
  from product_categories_by_sales
    , lateral flatten(PRODUCT_CATEGORIES) as flattened_categories
  qualify count(*) over (partition by SALE_ID, CATEGORY) > 1
)
select
    SALE_ID
  , array_unique_agg(CATEGORY) as COMMON_CATEGORIES
from common_categories
group by SALE_ID
;

-- Query the view
select * from CHALLENGE_OUTPUT_2
order by SALE_ID asc
;
