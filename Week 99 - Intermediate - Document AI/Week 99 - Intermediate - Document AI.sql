
-- Frosty Friday Challenge
-- Week 99 - Intermediate - Document AI
-- https://frostyfriday.org/blog/2024/06/28/week-99-intermediate/

-------------------------------
-- Environment Configuration

use database "CH_FROSTY_FRIDAY";

use warehouse "WH_CHASTIE";

create or replace schema "WEEK_99";

use schema "WEEK_99";

-------------------------------
-- Grants for Document AI

-- Must use ACCOUNTADMIN to perform grant
use role "ACCOUNTADMIN";

-- Grant access to database role
grant database role "SNOWFLAKE"."DOCUMENT_INTELLIGENCE_CREATOR" to role "<my role>";

-- Explicit grants for the schema and warehouse.
-- Note that ownership is not enough and these specific
-- grants are still required, at time of writing.
grant usage on database "CH_FROSTY_FRIDAY" to role "<my role>";
grant usage on schema "CH_FROSTY_FRIDAY"."WEEK_99" to role "<my role>";
grant create "SNOWFLAKE"."ML"."DOCUMENT_INTELLIGENCE" on schema "CH_FROSTY_FRIDAY"."WEEK_99" to role "<my role>";
grant usage, operate on warehouse "WH_CHASTIE" to role "<my role>";

-- Grant access to run tasks
grant execute task on account to role "<my role>";

-- Return to main role
use role "<my role>";

-------------------------------
-- Stage the files

-- Create the stage.
-- Encryption is required for internal stages
-- when using presigned URLs
create or replace stage "STG__FILES"
  encryption = (type = 'SNOWFLAKE_SSE')
;

-- Upload file to stage
-- Using the VSCode extension, we can run this directly
-- without needing to outsource to SnowSQL or SnowCLI!
put 'FILE://Week 99 - Intermediate - Document AI/files/*.pdf' @"STG__FILES" overwrite=true auto_compress=false;

-- View files in stage
list @"STG__FILES";

-- Now use Document AI via the UI
-- to set up the build.

-- Note to self:
-- Name the doc AI build better next time!

-- Extract information from a single document
with doc_ai_execution as (
  select
      '"RELATIVE_PATH"' as "FILE_NAME"
    , '"FILE_URL"' as "SNOWFLAKE_FILE_URL"
    , "CH_FROSTY_FRIDAY_WEEK_99"!predict(
          get_presigned_url(@"STG__FILES", 'FROSTY_FRIDAY_invoice_001.pdf')
        , 7 -- Doc AI build version
      ) as "DOC_AI_RESULTS"
)
select
    "FILE_NAME"
  , "SNOWFLAKE_FILE_URL"
  , "DOC_AI_RESULTS":"BILL_TO"[0]:"value"::string as "BILL_TO"
  , "DOC_AI_RESULTS":"DESCRIPTION"[descriptions."INDEX"]:"value"::string as "DESCRIPTION"
  , "DOC_AI_RESULTS":"DUE_DATE"[0]:"value"::timestamp as "DUE_DATE"
  , "DOC_AI_RESULTS":"INVOICE_DATE"[0]:"value"::timestamp as "INVOICE_DATE"
  , "DOC_AI_RESULTS":"INVOICE_NUMBER"[0]:"value"::string as "INVOICE_NUMBER"
  , "DOC_AI_RESULTS":"QUANTITY"[descriptions."INDEX"]:"value"::int as "QUANTITY"
  , "DOC_AI_RESULTS":"SHIPPING"[0]:"value"::number(38, 2) as "SHIPPING"
  , "DOC_AI_RESULTS":"SUB_TOTAL"[0]:"value"::number(38, 2) as "SUB_TOTAL"
  , "DOC_AI_RESULTS":"TAX"[0]:"value"::number(38, 2) as "TAX"
  , "DOC_AI_RESULTS":"TOTAL"[descriptions."INDEX"]:"value"::number(38, 2) as "TOTAL"
  , "DOC_AI_RESULTS":"TOTAL_INVOICE_DUE"[0]:"value"::number(38, 2) as "TOTAL_INVOICE_DUE"
  , "DOC_AI_RESULTS":"UNIT_PRICE"[descriptions."INDEX"]:"value"::number(38, 2) as "UNIT_PRICE"
from doc_ai_execution
  , lateral flatten (input => "DOC_AI_RESULTS":"DESCRIPTION") as descriptions
;

-- Enable directory for the stage
alter stage "STG__FILES"
  set directory = (enable = TRUE)
;
alter stage "STG__FILES"
  refresh
;

-- Extract information from multiple documents
with doc_ai_execution as (
  select
      "RELATIVE_PATH" as "FILE_NAME"
    , "FILE_URL" as "SNOWFLAKE_FILE_URL"
    , "CH_FROSTY_FRIDAY_WEEK_99"!predict(
          get_presigned_url(@"STG__FILES", "RELATIVE_PATH")
        , 7 -- Doc AI build version
      ) as "DOC_AI_RESULTS"
  from DIRECTORY(@"STG__FILES")
)
select
    "FILE_NAME"
  , "SNOWFLAKE_FILE_URL"
  , "DOC_AI_RESULTS":"BILL_TO"[0]:"value"::string as "BILL_TO"
  , "DOC_AI_RESULTS":"DESCRIPTION"[descriptions."INDEX"]:"value"::string as "DESCRIPTION"
  , "DOC_AI_RESULTS":"DUE_DATE"[0]:"value"::timestamp as "DUE_DATE"
  , "DOC_AI_RESULTS":"INVOICE_DATE"[0]:"value"::timestamp as "INVOICE_DATE"
  , "DOC_AI_RESULTS":"INVOICE_NUMBER"[0]:"value"::string as "INVOICE_NUMBER"
  , "DOC_AI_RESULTS":"QUANTITY"[descriptions."INDEX"]:"value"::int as "QUANTITY"
  , "DOC_AI_RESULTS":"SHIPPING"[0]:"value"::number(38, 2) as "SHIPPING"
  , "DOC_AI_RESULTS":"SUB_TOTAL"[0]:"value"::number(38, 2) as "SUB_TOTAL"
  , "DOC_AI_RESULTS":"TAX"[0]:"value"::number(38, 2) as "TAX"
  , "DOC_AI_RESULTS":"TOTAL"[descriptions."INDEX"]:"value"::number(38, 2) as "TOTAL"
  , "DOC_AI_RESULTS":"TOTAL_INVOICE_DUE"[0]:"value"::number(38, 2) as "TOTAL_INVOICE_DUE"
  , "DOC_AI_RESULTS":"UNIT_PRICE"[descriptions."INDEX"]:"value"::number(38, 2) as "UNIT_PRICE"
from doc_ai_execution
  , lateral flatten (input => "DOC_AI_RESULTS":"DESCRIPTION") as descriptions
;
