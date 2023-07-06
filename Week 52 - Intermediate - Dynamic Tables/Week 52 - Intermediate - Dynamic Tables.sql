
-- Frosty Friday Challenge
-- Week 52 - Intermediate - Dynamic Tables
-- https://frostyfriday.org/2023/06/30/week-52-intermediate/

-------------------------------
-- Environment Configuration

use database CH_FROSTY_FRIDAY;

use warehouse WH_CHASTIE;

create or replace schema WEEK_52;

use schema WEEK_52;

-------------------------------
-- Startup function

-- Create startup function
create or replace procedure CHECK_AND_GENERATE_DATA(tableName STRING)
returns string
language javascript
execute as caller
as
$$
  try {
    var tableName = TABLENAME;
    
    var command1 = `SELECT count(*) as count FROM information_schema.tables WHERE table_schema = CURRENT_SCHEMA() AND table_name = '${tableName.toUpperCase()}'`;
    var statement1 = snowflake.createStatement({sqlText: command1});
    var result_set1 = statement1.execute();
    
    result_set1.next();
    var count = result_set1.getColumnValue('COUNT');
    
    if (count == 0) {
      var command2 = `CREATE TABLE ${tableName} (payload VARIANT, ingested_at TIMESTAMP_NTZ default CURRENT_TIMESTAMP())`;
      var statement2 = snowflake.createStatement({sqlText: command2});
      statement2.execute();
    
      return `Table ${tableName} has been created.`;
    } else {
      for(var i=0; i<40; i++) {
        var jsonObject = {
          "id": i,
          "name": "Name_" + i,
          "address": "Address_" + i,
          "email": "email_" + i + "@example.com",
          "transactionValue": Math.floor(Math.random() * 10000) + 1
        };
        var jsonString = JSON.stringify(jsonObject);

        var command3 = `INSERT INTO ${tableName} (payload) SELECT PARSE_JSON(column1) FROM VALUES ('${jsonString}')`;
        var statement3 = snowflake.createStatement({sqlText: command3});
        statement3.execute();
      }
  
      return `40 records have been inserted into the ${tableName} table.`;
  }
  
  } catch (err) {
    return "Failed: " + err;
  }
$$;

-- Execute startup function
-- Run this twice to generate data
call CHECK_AND_GENERATE_DATA('RAW_DATA');

-- Sample initial data
select * from RAW_DATA;

-------------------------------
-- Dynamic table

-- Create dynamic table
create or replace dynamic table CLEAN_DATA
  target_lag = '1 minute'
  warehouse = WH_CHASTIE
as
  select
      PAYLOAD:"address"::string as ADDRESS
    , PAYLOAD:"email"::string as EMAIL
    , PAYLOAD:"id"::string as ID
    , PAYLOAD:"name"::string as TRANSACTION_VALUE
    , PAYLOAD:"transactionValue"::string as NAME
    , INGESTED_AT
  from RAW_DATA
  -- Adding a qualify as I'm not sure if our intention here is to dedupe?
  qualify row_number() over (
      partition by ID
      order by INGESTED_AT desc
    ) = 1
;

-- Manually refresh the table to avoid waiting
alter dynamic table CLEAN_DATA refresh;

-- Query the dynamic table
select * from CLEAN_DATA;

-- From this point, you can keep executing the procedure
-- and querying the dynamic table to watch it grow!
call CHECK_AND_GENERATE_DATA('RAW_DATA');
select * from CLEAN_DATA;