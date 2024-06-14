
-- Frosty Friday Challenge
-- Week 98 - Intermediate - data_transfer_history
-- https://frostyfriday.org/blog/2024/06/14/week-98-intermediate/

-------------------------------
-- Environment Configuration

use database "CH_FROSTY_FRIDAY";

use warehouse "WH_CHASTIE";

create or replace schema "WEEK_98";

use schema "WEEK_98";

-------------------------------
-- Challenge Solution

-- General recent history over the last 14 days
select *
from table("INFORMATION_SCHEMA"."DATA_TRANSFER_HISTORY"(
    DATE_RANGE_START => dateadd('days', -14, current_timestamp())
  , DATE_RANGE_END => current_timestamp()
))
;

-- Aggregated to hourly totals per source and target
-- over the last 14 days
select
    "START_TIME"
  , "END_TIME"
  , "SOURCE_CLOUD"
  , "TARGET_CLOUD"
  , sum("BYTES_TRANSFERRED") as "TOTAL_BYTES_TRANSFERRED"
from table("INFORMATION_SCHEMA"."DATA_TRANSFER_HISTORY"(
    DATE_RANGE_START => dateadd('days', -14, current_timestamp())
  , DATE_RANGE_END => current_timestamp()
))
group by all
order by
    "START_TIME" desc
  , "SOURCE_CLOUD"
  , "TARGET_CLOUD"
;

-- Aggregated to full total over the last 24 hours
select
    sum("BYTES_TRANSFERRED") as "TOTAL_BYTES_TRANSFERRED"
from table("INFORMATION_SCHEMA"."DATA_TRANSFER_HISTORY"(
    DATE_RANGE_START => dateadd('hours', -24, current_timestamp())
  , DATE_RANGE_END => current_timestamp()
))
;

-- Largest transfer operation(s) over the last 14 days.
-- Shows multiple records if there is a tie.
select
    "START_TIME"
  , "END_TIME"
  , "SOURCE_CLOUD"
  , "TARGET_CLOUD"
  , "BYTES_TRANSFERRED"
from table("INFORMATION_SCHEMA"."DATA_TRANSFER_HISTORY"(
    DATE_RANGE_START => dateadd('days', -14, current_timestamp())
  , DATE_RANGE_END => current_timestamp()
))
qualify "BYTES_TRANSFERRED" = max("BYTES_TRANSFERRED") over ()
;
