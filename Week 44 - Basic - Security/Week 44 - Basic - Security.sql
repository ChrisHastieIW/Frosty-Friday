
-- Frosty Friday Challenge
-- Week 44 - Basic - Security
-- https://frostyfriday.org/2023/05/05/week-44-basic/

-------------------------------
-- Environment Configuration

use database CH_FROSTY_FRIDAY;

use warehouse WH_CHASTIE;

create or replace schema WEEK_44;

use schema WEEK_44;

-------------------------------
-- Create initial challenge table with security

-- Create table
create or replace table MOCK_DATA (
    id INT
  , salary INT
  , teamnumber INT
)
as
select * from values
    (1, 781767, 2)
  , (2, 701047, 5)
  , (3, 348497, 2)
  , (4, 555275, 2)
  , (5, 144962, 3)
  , (6, 832979, 4)
  , (7, 387404, 1)
  , (8, 427563, 3)
  , (9, 788928, 3)
  , (10, 257613, 1)
  , (11, 483792, 4)
  , (12, 720679, 3)
  , (13, 452976, 4)
  , (14, 541193, 2)
  , (15, 159377, 1)
  , (16, 825003, 4)
  , (17, 362209, 3)
  , (18, 291622, 5)
  , (19, 646774, 3)
  , (20, 971930, 1)
;

-- Create security
CREATE OR REPLACE ROW ACCESS POLICY demo_policy
AS (teamnumber int) RETURNS BOOLEAN ->
CURRENT_ROLE() = 'HR'
OR LEFT(CURRENT_ROLE(),13) = 'MANAGER_TEAM_' AND RIGHT(CURRENT_ROLE(),1) = RIGHT(teamnumber, 1)
;

-- Apply security
alter table MOCK_DATA add row access policy demo_policy on (teamnumber);

-- Test the access
select * from MOCK_DATA;

-------------------------------
-- Perform "The Hack"

CREATE OR REPLACE PROCEDURE totally_not_a_suspicious_procedure()
RETURNS VARCHAR
LANGUAGE JAVASCRIPT
AS
$$
var stmt = snowflake.createStatement({
sqlText: "alter table MOCK_DATA drop row access policy demo_policy;"
});
stmt.execute();
return "Row access policy dropped successfully.";
$$;

CALL totally_not_a_suspicious_procedure();

select * from MOCK_DATA;

CREATE OR REPLACE PROCEDURE totally_not_a_suspicious_procedure2()
RETURNS VARCHAR
LANGUAGE JAVASCRIPT
AS
$$
var stmt = snowflake.createStatement({
sqlText: "alter table MOCK_DATA add row access policy demo_policy on (teamnumber);;"
});
stmt.execute();
return "Row access policy dropped successfully.";
$$;

CALL totally_not_a_suspicious_procedure2();

drop procedure totally_not_a_suspicious_procedure();
drop procedure totally_not_a_suspicious_procedure2();

-------------------------------
-- Investigate the hack!

-- Query to observe whenever the table
-- has been queried without a policy
select
    query_start_time
  , user_name
  , *
from snowflake.account_usage.access_history
  , lateral flatten (base_objects_accessed) as base_objects_accessed
where base_objects_accessed.value:"objectName"::string ilike '%MOCK_DATA%'
  and array_size(policies_referenced) = 0
order by 1 desc
limit 10
;