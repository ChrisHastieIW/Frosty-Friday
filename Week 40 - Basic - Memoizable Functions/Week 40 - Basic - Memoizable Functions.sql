
-- Frosty Friday Challenge
-- Week 40 - Basic - Memoizable Functions
-- https://frostyfriday.org/2023/03/31/week-40-basic/

-------------------------------
-- Environment Configuration

use database CH_FROSTY_FRIDAY;

use warehouse WH_CHASTIE;

create or replace schema WEEK_40;

use schema WEEK_40;

-------------------------------
-- Sample challenge data

-- Query the sample data to return desired result
select
  sum(
        LINEITEM.L_QUANTITY
      * LINEITEM.L_EXTENDEDPRICE
      * (1 - LINEITEM.L_DISCOUNT)
    ) as REVENUE
from SNOWFLAKE_SAMPLE_DATA.TPCH_SF100.LINEITEM
  inner join SNOWFLAKE_SAMPLE_DATA.TPCH_SF100.ORDERS
    on LINEITEM.L_ORDERKEY = ORDERS.O_ORDERKEY
  inner join SNOWFLAKE_SAMPLE_DATA.TPCH_SF100.CUSTOMER
    on ORDERS.O_CUSTKEY = CUSTOMER.C_CUSTKEY
  inner join SNOWFLAKE_SAMPLE_DATA.TPCH_SF100.NATION
    on CUSTOMER.C_NATIONKEY = NATION.N_NATIONKEY
  inner join SNOWFLAKE_SAMPLE_DATA.TPCH_SF100.REGION
    on NATION.N_REGIONKEY = REGION.R_REGIONKEY
where REGION.R_NAME = 'EUROPE'
;

-------------------------------
-- Create memoizable function

-- Create function
create or replace function CHALLENGE_FUNCTION()
  returns number(38,2)
  memoizable
  as
  $$
    select
      sum(
            LINEITEM.L_QUANTITY
          * LINEITEM.L_EXTENDEDPRICE
          * (1 - LINEITEM.L_DISCOUNT)
        ) as REVENUE
    from SNOWFLAKE_SAMPLE_DATA.TPCH_SF100.LINEITEM
      inner join SNOWFLAKE_SAMPLE_DATA.TPCH_SF100.ORDERS
        on LINEITEM.L_ORDERKEY = ORDERS.O_ORDERKEY
      inner join SNOWFLAKE_SAMPLE_DATA.TPCH_SF100.CUSTOMER
        on ORDERS.O_CUSTKEY = CUSTOMER.C_CUSTKEY
      inner join SNOWFLAKE_SAMPLE_DATA.TPCH_SF100.NATION
        on CUSTOMER.C_NATIONKEY = NATION.N_NATIONKEY
      inner join SNOWFLAKE_SAMPLE_DATA.TPCH_SF100.REGION
        on NATION.N_REGIONKEY = REGION.R_REGIONKEY
    where REGION.R_NAME = 'EUROPE'

  $$
  ;
  
-------------------------------
-- Test the function

-- Query the table to view the data.
-- Executing this multiple times demonstrates
-- that it reads from cache
select CHALLENGE_FUNCTION();

