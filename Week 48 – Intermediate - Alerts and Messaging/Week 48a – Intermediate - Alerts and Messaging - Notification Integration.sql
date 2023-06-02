
-- Frosty Friday Challenge
-- Week 48 – Intermediate - Alerts and Messaging
-- A - Notification Integration
-- https://frostyfriday.org/2023/06/02/week-48-intermediate/

-------------------------------
-- Create notification integration for emails

-- Create the integration
create or replace notification integration EMAILS_CH
  type = email
  enabled = TRUE
  allowed_recipients = ('REDACTED')
  comment = 'Testing email functionality through Snowflake'
;

-- Grant the integration to our role for frosty friday
grant usage on integration EMAILS_CH to role REDACTED;

-- Send a test email
call SYSTEM$SEND_EMAIL(
    'EMAILS_CH'
  , 'REDACTED'
  , 'Snowflake Test Email'
  , 'Test'
)
;

-- Grant the ability to execute alerts to our role for frosty friday
grant execute alert on account to role REDACTED;
