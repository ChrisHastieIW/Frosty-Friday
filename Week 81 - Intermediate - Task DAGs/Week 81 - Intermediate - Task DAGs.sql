
-- Frosty Friday Challenge
-- Week 81 - Intermediate - Task DAGs
-- https://frostyfriday.org/blog/2024/02/16/week-81-intermediate/

-------------------------------
-- Environment Configuration

use database CH_FROSTY_FRIDAY;

use warehouse WH_CHASTIE;

create or replace schema WEEK_81;

use schema WEEK_81;

-------------------------------
-- Challenge Setup Script

-- Create the stage
create or replace stage FROSTY_STAGE
  URL = 's3://frostyfridaychallenges/'
;

create or replace file format FF_CSV_SINGLE_RECORD
  type = CSV
  record_delimiter = NONE
  field_delimiter = NONE
  parse_header = FALSE
  compression = NONE
;

-- Read the script
-- NEVER EXECUTE ANYTHING BEFORE KNOWING WHAT IT DOES!
select $1
from @FROSTY_STAGE/challenge_81/starter_code
  (file_format => 'FF_CSV_SINGLE_RECORD')
;

-- The script looks safe (at time of writing)
-- but it creates a schema that does not use
-- our usual naming convention.

-- Instead of directly executing the script,
-- slightly modify it and execute the replacement.

-- First, read the modified script:
select replace($1, 'CREATE OR REPLACE SCHEMA w81_raw', 'CREATE SCHEMA IF NOT EXISTS WEEK_81')
from @FROSTY_STAGE/challenge_81/starter_code.sql
  (file_format => 'FF_CSV_SINGLE_RECORD')
;

-- Insert the script into our own stage
create or replace stage STG__SCRIPT_TO_RUN;
copy into @STG__SCRIPT_TO_RUN/starter_code.sql
from (
  select replace($1, 'CREATE OR REPLACE SCHEMA w81_raw', 'CREATE SCHEMA IF NOT EXISTS WEEK_81')
  from @FROSTY_STAGE/challenge_81/starter_code
    (file_format => 'FF_CSV_SINGLE_RECORD')
)
  file_format = 'FF_CSV_SINGLE_RECORD'
  single = TRUE
;

-- Read the script again to be sure it's output correctly
select $1
from @STG__SCRIPT_TO_RUN/starter_code.sql
  (file_format => 'FF_CSV_SINGLE_RECORD')
;
-- Execute the script
execute immediate from @STG__SCRIPT_TO_RUN/starter_code.sql
;

-------------------------------
-- Challenge Solution

-- Single sproc to execute the desired three SQL statements for Task 1
create or replace procedure INSERT_INTO_RAW_SQL()
  returns TEXT
  language SQL
as
$$
BEGIN

  INSERT INTO w81_raw_product (data)
  SELECT parse_json(column1)
  FROM
  VALUES
      ('{"product_id": 21, "product_name": "Product U", "category": "Electronics", "price": 120.99, "created_at": "2024-02-16"}')
    , ('{"product_id": 22, "product_name": "Product V", "category": "Books", "price": 35.00, "created_at": "2024-02-16"}')
  ;

  INSERT INTO w81_raw_customer (data)
  SELECT parse_json(column1)
  FROM
  VALUES
      ('{"customer_id": 6, "customer_name": "Frank", "email": "frank@example.com", "created_at": "2024-02-16"}')
    , ('{"customer_id": 7, "customer_name": "Grace", "email": "grace@example.com", "created_at": "2024-02-16"}')
  ;

  INSERT INTO w81_raw_sales (data)
  SELECT parse_json(column1)
  FROM
  VALUES
      ('{"sale_id": 11, "product_id": 21, "customer_id": 6, "quantity": 1, "sale_date": "2024-02-17"}') -- New product, new customer
    , ('{"sale_id": 12, "product_id": 22, "customer_id": 1, "quantity": 1, "sale_date": "2024-02-17"}') -- New product, existing customer
    , ('{"sale_id": 13, "product_id": 2, "customer_id": 7, "quantity": 2, "sale_date": "2024-02-17"}') -- Existing product, new customer
    , ('{"sale_id": 14, "product_id": 3, "customer_id": 6, "quantity": 1, "sale_date": "2024-02-17"}') -- Existing product, new customer
    , ('{"sale_id": 15, "product_id": 21, "customer_id": 5, "quantity": 1, "sale_date": "2024-02-17"}') -- New product, existing customer
  ;

END
$$
;

-- Create TASK_1 to populate new data in the tables
create or replace task INSERT_INTO_RAW
  warehouse = WH_CHASTIE
as
  call INSERT_INTO_RAW_SQL()
;

-- Create TASK_2 - Parse sales
create or replace task INSERT_INTO_SALES
  warehouse = WH_CHASTIE
  after INSERT_INTO_RAW
as
  create or replace view SALES
  as
  select
      DATA:"sale_id"::int as sale_id
    , DATA:"product_id"::int as product_id
    , DATA:"customer_id"::int as customer_id
    , DATA:"sale_date"::timestamp as sale_date
    , DATA:"quantity"::int as quantity
  from w81_raw_sales
;

-- Create TASK_3 - Parse products
create or replace task INSERT_INTO_PRODUCT
  warehouse = WH_CHASTIE
  after INSERT_INTO_RAW
as
  create or replace view PRODUCT
  as
  select
      DATA:"product_id"::int as product_id
    , DATA:"category"::string as category
    , DATA:"product_name"::string as product_name
    , DATA:"price"::float as price
    , DATA:"CREATE OR REPLACEd_at"::date as "CREATE OR REPLACEd_at"
  from w81_raw_product
;

-- Create TASK_4 - Parse customers
create or replace task INSERT_INTO_CUSTOMER
  warehouse = WH_CHASTIE
  after INSERT_INTO_RAW
as
  create or replace view CUSTOMER
  as
  select
      DATA:"customer_id"::int as customer_id
    , DATA:"customer_name"::string as customer_name
    , DATA:"email"::string as email
  from w81_raw_customer
;

-- Create TASK_5 - Aggregate
create or replace task AGGREGATE_SALES
  warehouse = WH_CHASTIE
  after INSERT_INTO_SALES, INSERT_INTO_PRODUCT, INSERT_INTO_CUSTOMER
as
  create or replace view AGGREGATED_SALES
  as
  select
      c.customer_name
    , p.product_name
    , SUM(s.quantity) as total_quantity
    , SUM(s.quantity * p.price) as total_sales
  from SALES s
    join PRODUCT p
      on s.product_id = p.product_id
    join CUSTOMER c
      on s.customer_id = c.customer_id
  group by
      c.customer_name
    , p.product_name
;

-- Final query to show task predecessors
select t.NAME, t.PREDECESSORS
from table(INFORMATION_SCHEMA.TASK_DEPENDENTS(
    TASK_NAME => 'INSERT_INTO_RAW'
  , RECURSIVE => TRUE
  )) t
;
