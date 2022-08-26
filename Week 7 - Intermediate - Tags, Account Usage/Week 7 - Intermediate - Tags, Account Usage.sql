
-- Frosty Friday Challenge
-- Week 7 - Intermediate - Tags, Account Usage
-- https://frostyfriday.org/2022/07/29/week-7-intermediate/

-------------------------------
-- Environment Configuration

use database CH_FROSTY_FRIDAY;

use warehouse WH_CHASTIE;

create or replace schema WEEK_7;

use schema WEEK_7;

-------------------------------
-- Query account usage based on tag

select 
    tf.tag_name
  , tf.tag_value
  , ah.query_id
  , boa.value:"objectName"::string as table_name
  , qh.role_name
from snowflake.account_usage.access_history as ah
  left join snowflake.account_usage.tag_references as tf
  left join snowflake.account_usage.query_history as qh
    on ah.query_id = qh.query_id
  , lateral flatten(BASE_OBJECTS_ACCESSED) as boa
where boa.value:"objectDomain"::string = 'Table'
  and tf.tag_name = 'SECURITY_CLASS'
  and tf.tag_value = 'Level Super Secret A+++++++'
  and split(table_name, '.')[0]::string = tf.object_database
  and split(table_name, '.')[1]::string = tf.object_schema
  and split(table_name, '.')[2]::string = tf.object_name
;
