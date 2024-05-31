
-- Frosty Friday Challenge
-- Week 96 - Basic - Create or alter
-- https://frostyfriday.org/blog/2024/05/31/week-96-basic/

-------------------------------
-- Environment Configuration

use database "CH_FROSTY_FRIDAY";

use warehouse "WH_CHASTIE";

create or replace schema "WEEK_96";

use schema "WEEK_96";

-------------------------------
-- Challenge Setup Script

-- Create a table named CONFERENCE_ATTENDEES
create or replace table "CONFERENCE_ATTENDEES" (
    "ATTENDEE_ID" int
  , "FIRST_NAME" string
  , "LAST_NAME" string
  , "EMAIL" string
  , "REGISTRATION_DATE" date
  , "TICKET_TYPE" string
  , "CONFERENCE_ID" int
)
;

-- Insert the initial values
insert into "CONFERENCE_ATTENDEES"
values
    (1, 'John', 'Doe', 'john.doe@example.com', '2024-06-01', 'DSH', 101)
  , (2, 'Jane', 'Smith', 'jane.smith@example.com', '2024-06-02', 'Regular', 101)
  , (3, 'Alice', 'Johnson', 'alice.johnson@example.com', '2024-06-03', 'DSH', 102)
  , (4, 'Bob', 'Brown', 'bob.brown@example.com', '2024-06-04', 'Regular', 102)
  , (5, 'Charlie', 'Davis', 'charlie.davis@example.com', '2024-06-05', 'Partner', 103)
  , (6, 'Diana', 'Martinez', 'diana.martinez@example.com', '2024-06-06', 'Regular', 101)
  , (7, 'Evan', 'Garcia', 'evan.garcia@example.com', '2024-06-07', 'DSH', 103)
  , (8, 'Fiona', 'Wilson', 'fiona.wilson@example.com', '2024-06-08', 'Regular', 102)
  , (9, 'George', 'Moore', 'george.moore@example.com', '2024-06-09', 'Partner', 103)
  , (10, 'Hannah', 'Taylor', 'hannah.taylor@example.com', '2024-06-10', 'DSH', 101)
;

-- Review the table
select * from "CONFERENCE_ATTENDEES";

-------------------------------
-- Challenge Solution

-- Update the table structure
create or alter table "CONFERENCE_ATTENDEES" (
    "ATTENDEE_ID" int
  , "FIRST_NAME" string
  , "LAST_NAME" string
  , "EMAIL" string
  , "REGISTRATION_DATE" date
  , "TICKET_TYPE" string
  , "CONFERENCE_NAME" string
)
;

-- Insert the new values
insert into "CONFERENCE_ATTENDEES"
values
    (11, 'Irene', 'Lee', 'irene.lee@example.com', '2024-06-11', 'DSH', 'Summit 2024')
  , (12, 'Jack', 'Harris', 'jack.harris@example.com', '2024-06-12', 'Regular', 'Summit 2024')
  , (13, 'Karen', 'Clark', 'karen.clark@example.com', '2024-06-13', 'DSH', 'Summit 2024')
  , (14, 'Larry', 'Lewis', 'larry.lewis@example.com', '2024-06-14', 'Regular', 'Summit 2024')
  , (15, 'Monica', 'Walker', 'monica.walker@example.com', '2024-06-15', 'Partner', 'Summit 2024')
  , (16, 'Nina', 'Hall', 'nina.hall@example.com', '2024-06-16', 'Regular', 'Summit 2024')
  , (17, 'Oscar', 'Young', 'oscar.young@example.com', '2024-06-17', 'DSH', 'Summit 2024')
  , (18, 'Paula', 'King', 'paula.king@example.com', '2024-06-18', 'Regular', 'Summit 2024')
  , (19, 'Quinn', 'Wright', 'quinn.wright@example.com', '2024-06-19', 'Partner', 'Summit 2024')
  , (20, 'Rachel', 'Lopez', 'rachel.lopez@example.com', '2024-06-20', 'DSH', 'Summit 2024')
;

-- Review the table
select * from "CONFERENCE_ATTENDEES";
