
-- Frosty Friday Challenge
-- Week 13 - Basic - Filldown
-- https://frostyfriday.org/2022/09/09/week-13-basic-snowflake-intermediate-non-snowflake/

-------------------------------
-- Environment Configuration

use database CH_FROSTY_FRIDAY;

use warehouse WH_CHASTIE;

create or replace schema WEEK_13;

use schema WEEK_13;

-------------------------------
-- Create table for the challenge

-- Create empty table
create or replace table TESTING_DATA (
    id int autoincrement start 1 increment 1
  , product string
  , stock_amount int
  , date_of_check date
)
;

-- Populate with values
insert into TESTING_DATA (
    product
  , stock_amount
  , date_of_check
)
select *
from values
    ('Superhero capes',1,'2022-01-01'::date)
  , ('Superhero capes',2,'2022-01-02'::date)
  , ('Superhero capes',NULL,'2022-02-01'::date)
  , ('Superhero capes',NULL,'2022-03-01'::date)
  , ('Superhero masks',5,'2022-01-01'::date)
  , ('Superhero masks',NULL,'2022-02-13'::date)
  , ('Superhero pants',6,'2022-01-01'::date)
  , ('Superhero pants',NULL,'2022-01-01'::date)
  , ('Superhero pants',3,'2022-04-01'::date)
  , ('Superhero pants',2,'2022-07-01'::date)
  , ('Superhero pants',NULL,'2022-01-01'::date)
  , ('Superhero pants',3,'2022-05-01'::date)
  , ('Superhero pants',NULL,'2022-10-01'::date)
  , ('Superhero masks',10,'2022-11-01'::date)
  , ('Superhero masks',NULL,'2022-02-14'::date)
  , ('Superhero masks',NULL,'2022-02-15'::date)
  , ('Superhero masks',NULL,'2022-02-13'::date)
;

-- View testing data
select * from TESTING_DATA;

-------------------------------
-- View using LAG

-- Create the view
create or replace view VIEW_WITH_LAG
as
select 
    PRODUCT
  , STOCK_AMOUNT
  , COALESCE(
        STOCK_AMOUNT
      , LAG(
            STOCK_AMOUNT
          , 1
        ) IGNORE NULLS OVER (
            PARTITION BY PRODUCT
            ORDER BY 
                DATE_OF_CHECK asc
              , ID asc
        ) 
    ) AS STOCK_AMOUNT_FILLED_OUT 
  , DATE_OF_CHECK
from TESTING_DATA
order by 
    PRODUCT
  , DATE_OF_CHECK asc
  , ID asc
;

-- Query the view
select * from VIEW_WITH_LAG;
  
-------------------------------
-- View using CTEs and join

-- Create the view
create or replace view VIEW_USING_CTES_AND_JOIN
as
with populated_stock_amounts as (
  select
      PRODUCT
    , STOCK_AMOUNT
    , DATE_OF_CHECK
  from TESTING_DATA
  where STOCK_AMOUNT IS NOT NULL
)
, most_recent_stock_amount_dates as (
  select
      ID
    , PRODUCT
    , STOCK_AMOUNT
    , DATE_OF_CHECK
    , (
        SELECT max(DATE_OF_CHECK)
        FROM populated_stock_amounts as T2
        WHERE STOCK_AMOUNT IS NOT NULL
          AND T1.PRODUCT = T2.PRODUCT
          AND T1.DATE_OF_CHECK >= T2.DATE_OF_CHECK
      ) AS MOST_RECENT_STOCK_AMOUNT_DATE
  from TESTING_DATA as T1
)
select 
    T1.PRODUCT
  , T1.STOCK_AMOUNT
  , COALESCE(
        T1.STOCK_AMOUNT
      , T2.STOCK_AMOUNT
    ) AS STOCK_AMOUNT_FILLED_OUT 
  , T1.DATE_OF_CHECK
from most_recent_stock_amount_dates as T1
  left join populated_stock_amounts as T2
    ON  T1.PRODUCT = T2.PRODUCT
    AND T1.MOST_RECENT_STOCK_AMOUNT_DATE = T2.DATE_OF_CHECK
order by 
    PRODUCT
  , DATE_OF_CHECK asc
  , ID asc
;

-- Query the view
select * from VIEW_USING_CTES_AND_JOIN;
  