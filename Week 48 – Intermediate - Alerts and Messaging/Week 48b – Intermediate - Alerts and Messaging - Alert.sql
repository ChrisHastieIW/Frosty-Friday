
-- Frosty Friday Challenge
-- Week 48 – Intermediate - Alerts and Messaging
-- B - Alert
-- https://frostyfriday.org/2023/06/02/week-48-intermediate/

-------------------------------
-- Environment Configuration

use database CH_FROSTY_FRIDAY;

use warehouse WH_CHASTIE;

create or replace schema WEEK_48;

use schema WEEK_48;

-------------------------------
-- Create alert for long-running queries

-- Create the alert
create or replace alert ALERT_CH_LONG_RUNNING_QUERIES
  warehouse = WH_CHASTIE
  schedule = 'USING CRON * * * * * UTC'
if (
  exists (
    select *
    from table(SNOWFLAKE.INFORMATION_SCHEMA.QUERY_HISTORY())
    where EXECUTION_STATUS = 'RUNNING'
      and START_TIME <= current_timestamp() - interval '1 MINUTE'
  )
)
then
  call SYSTEM$SEND_EMAIL (
    'EMAILS_CH',
    'REDACTED',
    'Alert: Long running queries detected in Snowflake!',
    'There are queries running for more than 1 minute in your Snowflake account!'
  )
;

-- Describe the alert
desc alert ALERT_CH_LONG_RUNNING_QUERIES;

-- Activate the alert, requiring the EXECUTE ALERT privilege on the account
alter alert ALERT_CH_LONG_RUNNING_QUERIES resume;

-- Test the alert using a stored procedure from a previous challenge
call WEEK_42.KEEP_AWAKE(2);

-- Monitor the history of alerts sent
select *
from table(INFORMATION_SCHEMA.ALERT_HISTORY(
    scheduled_time_range_start => dateadd('hour',-1,current_timestamp()))
)
order by SCHEDULED_TIME desc
;

-- Disable the alert to avoid the inevitable spam going forwards
alter alert ALERT_CH_LONG_RUNNING_QUERIES suspend;
