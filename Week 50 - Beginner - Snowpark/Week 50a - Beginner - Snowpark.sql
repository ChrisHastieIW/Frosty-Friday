
-- Frosty Friday Challenge
-- Week 50 - Beginner - Snowpark
-- https://frostyfriday.org/2023/06/16/week-50-beginner/

-------------------------------
-- Environment Configuration

use database CH_FROSTY_FRIDAY;

use warehouse WH_CHASTIE;

create or replace schema WEEK_50;

use schema WEEK_50;

-------------------------------
-- Create challenge data

create or replace table CHALLENGE_DATA (
    ID int
  , FIRST_NAME varchar(50)
  , LAST_NAME varchar(50)
  , EMAIL varchar(50)
)
as
select *
from values
    (1, 'Arly', 'Lissaman', 'alissaman0@auda.org.au')
  , (2, 'Cary', 'Baggalley', 'cbaggalley1@aol.com')
  , (3, 'Kimbell', 'Bertrand', 'kbertrand2@twitpic.com')
  , (4, 'Peria', 'Deery', 'pdeery3@addtoany.com')
  , (5, 'Edmund', 'Caselli', 'ecaselli4@prweb.com')
  , (6, 'Davin', 'Daysh', 'ddaysh5@liveinternet.ru')
  , (7, 'Starla', 'Legging', 'slegging6@soundcloud.com')
  , (8, 'Maud', 'Jaggers', 'mjaggers7@businesswire.com')
  , (9, 'Barn', 'Campsall', 'bcampsall8@is.gd')
  , (10, 'Marcelia', 'Yearn', 'myearn9@moonfruit.com')
;

-- View challenge data
select * from CHALLENGE_DATA;
