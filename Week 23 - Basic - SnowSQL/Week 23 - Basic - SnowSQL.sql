
-- Frosty Friday Challenge
-- Week 23 - Basic - SnowSQL
-- https://frostyfriday.org/2022/11/18/week-23-basic/

-------------------------------
-- Environment Configuration

use database CH_FROSTY_FRIDAY;

use warehouse WH_CHASTIE;

create or replace schema WEEK_23;

use schema WEEK_23;

-------------------------------
-- Create internal stage

create or replace stage STG_WEEK_23
;

-- View files in stage
list @STG_WEEK_23;

-- This is empty to start, so we
-- need to upload our set of files
-- into this stage. We only wish
-- to ingest files which end in
-- "1.csv", which we can achieve
-- leveraging wildcards.

-- This is achieved with the
-- following commands in a local
-- SnowSQL console:
/* --snowsql
snowsql -a my.account -u my_user -r my_role --private-key-path "path\to\my\ssh\key.p8"
PUT 'FILE://C:/My/Path/To/Files to ingest/data_batch_*1.csv' @CH_FROSTY_FRIDAY.WEEK_23.STG_WEEK_23;
*/

-- View files in stage
list @STG_WEEK_23;
