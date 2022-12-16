
-- Frosty Friday Challenge
-- Week 27 - Basic - EXCLUDE and RENAME
-- https://frostyfriday.org/2022/12/16/week-27-beginner/

-------------------------------
-- Environment Configuration

use database CH_FROSTY_FRIDAY;

use warehouse WH_CHASTIE;

create or replace schema WEEK_27;

use schema WEEK_27;

-------------------------------
-- Create challenge data

create or replace table CHALLENGE_DATA
(
    icecream_id int
  , icecream_flavour varchar(15)
  , icecream_manufacturer varchar(50)
  , icecream_brand varchar(50)
  , icecreambrandowner varchar(50)
  , milktype varchar(15)
  , region_of_origin varchar(50)
  , recommended_price number
  , wholesale_price number
)
as
select *
from values
    (1, 'strawberry', 'Jimmy Ice', 'Ice Co.', 'Food Brand Inc.', 'normal', 'Midwest', 7.99, 5)
  , (2, 'vanilla', 'Kelly Cream Company', 'Ice Co.', 'Food Brand Inc.', 'dna-modified', 'Northeast', 3.99, 2.5)
  , (3, 'chocolate', 'ChoccyCream', 'Ice Co.', 'Food Brand Inc.', 'normal', 'Midwest', 8.99, 5.5)
;

-------------------------------
-- Create view with EXCLUDE and REPLACE

-- Create the view
create or replace view CHALLENGE_OUTPUT
as
select *
  exclude milktype
  rename icecreambrandowner as ice_cream_brand_owner
from CHALLENGE_DATA
;

-- Query the views
select * from CHALLENGE_OUTPUT;
