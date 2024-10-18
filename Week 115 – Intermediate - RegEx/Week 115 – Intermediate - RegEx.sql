
-- Frosty Friday Challenge
-- Week 115 – Intermediate - RegEx
-- https://frostyfriday.org/blog/2024/10/18/week-115-intermediate/

-------------------------------
-- Environment Configuration

use database "CH_FROSTY_FRIDAY";

use warehouse "WH_CHASTIE";

create or replace schema "WEEK_115";

use schema "WEEK_115";

-------------------------------
-- Challenge 1: Validate Complex Email Addresses

----------------
-- Challenge Setup Script

-- Create table
create or replace table "USERS" (
    "USER_ID" int autoincrement primary key
  , "EMAIL" varchar
)
;

-- Include values with overvwrite for idempotence
insert overwrite into "USERS" ("EMAIL")
values
    ('john.doe@example.com')
  , ('invalid-email@.com')
  , ('alice_smith@sub-domain.co.uk')
  , ('bob@domain.com')
  , ('bob+folder@domain.com') -- Added a plus address for testing
  , ('folder@bob.domain.com') -- Added a subdomain address for testing
  , ('user@invalid_domain@com')
;

----------------
-- Challenge Solution

select
    *
  , regexp_like("EMAIL", $$[a-zA-Z0-9.-]+[+]?[a-zA-Z0-9.-]*@[a-zA-Z0-9.-]+[.][a-zA-Z0-9]{2,6}$$) as "IS_VALID_EMAIL" 
  -- I am pretty sure the  2-6 length top-level domain is not a true requirement based on the list available from ICANN,
  -- but I appreciate it being included for the extra challenge
from "USERS"
;

-------------------------------
-- Challenge 2: Extract Valid Dates in Multiple Formats

----------------
-- Challenge Setup Script

-- Create table
create or replace table "DOCUMENTS" (
    "DOC_ID" int autoincrement primary key
  , "TEXT_COLUMN" varchar(500)
)
;

-- Include values with overvwrite for idempotence
insert overwrite into "DOCUMENTS" ("TEXT_COLUMN")
values
    ('This document was created on 15/03/2023.')
  , ('The report is due by 04-15-2022.')
  , ('Version 1.0 released on 2021.08.30.')
  , ('No date provided in this text.')
  , ('Invalid date 32/13/2020.')
;

----------------
-- Challenge Solution

with regex_patterns as (
  select
      $$(0[1-9]|[1-2][0-9]|3[0-1])$$ as "REGEX__DD"
    , $$(0[1-9]|1[0-2])$$ as "REGEX__MM"
    , $$\d{4}$$ as "REGEX__YYYY"
    , concat("REGEX__DD", $$\/$$, "REGEX__MM", $$\/$$, "REGEX__YYYY") as "REGEX__DD/MM/YYYY"
    , concat("REGEX__MM", $$-$$, "REGEX__DD", $$-$$, "REGEX__YYYY") as "REGEX__MM-DD-YYYY"
    , concat("REGEX__YYYY", $$[.]$$, "REGEX__MM", $$[.]$$, "REGEX__DD") as "REGEX__YYYY.MM.DD"
    , concat(
          '(' -- Start first capturing group
        , array_to_string(
              array_construct("REGEX__DD/MM/YYYY", "REGEX__MM-DD-YYYY", "REGEX__YYYY.MM.DD") -- Array of regex patterns
            , ')|(' -- OR in regex, combined with closing the capturing group and starting the next
          )
        , ')' -- End last capturing group
      ) as "REGEX__COMBINED"
)
select
    "DOCUMENTS".*
  , regexp_substr("TEXT_COLUMN", "REGEX__COMBINED") as "EXTRACTED_DATE_FROM_SINGLE_REGEX_PATTERN_AS_STRING"
  , coalesce(
        try_to_date("EXTRACTED_DATE_FROM_SINGLE_REGEX_PATTERN_AS_STRING", 'DD/MM/YYYY')
      , try_to_date("EXTRACTED_DATE_FROM_SINGLE_REGEX_PATTERN_AS_STRING", 'MM-DD-YYYY')
      , try_to_date("EXTRACTED_DATE_FROM_SINGLE_REGEX_PATTERN_AS_STRING", 'YYYY.MM.DD')
    ) as "EXTRACTED_DATE_FROM_SINGLE_REGEX_PATTERN"
  , coalesce(
        try_to_date(regexp_substr("TEXT_COLUMN", "REGEX__DD/MM/YYYY"), 'DD/MM/YYYY')
      , try_to_date(regexp_substr("TEXT_COLUMN", "REGEX__MM-DD-YYYY"), 'MM-DD-YYYY')
      , try_to_date(regexp_substr("TEXT_COLUMN", "REGEX__YYYY.MM.DD"), 'YYYY.MM.DD')
    ) as "EXTRACTED_DATE_FROM_MULTIPLE_REGEX_PATTERNS"
from "DOCUMENTS"
  cross join regex_patterns
;

-------------------------------
-- Challenge 3: Mask Credit Card Numbers

----------------
-- Challenge Setup Script

-- Create table
create or replace table "TRANSACTIONS" (
    "TRANSACTION_ID" int autoincrement primary key
  , "CARD_NUMBER" varchar(50)
)
;

-- Include values with overvwrite for idempotence
insert overwrite into "TRANSACTIONS" ("CARD_NUMBER")
values
    ('1234-5678-9012-3456')
  , ('9876 5432 1098 7654')
  , ('1111222233334444')
  , ('4444-3333-2222-1111')
  , ('Invalid number 12345678901234567')
  , ('Valid number 1111222233334444') -- Added so we can verify replacement only happens on the card number itself
;

----------------
-- Challenge Solution

select
    *
  , regexp_replace("CARD_NUMBER", $$(\D|^)(\d{4}-|\d{4}){3}(\d{4})(\D|$)$$, '\\1************\\3\\4') as "MASKED_CARD_NUMBER" 
from "TRANSACTIONS"
;


-------------------------------
-- Challenge 4: Extract Hashtags from a Text Block

----------------
-- Challenge Setup Script

-- Create table
create or replace table "SOCIAL_POSTS" (
    "POST_ID" int autoincrement primary key
  , "TEXT_COLUMN" varchar(500)
)
;

-- Include values with overvwrite for idempotence
insert overwrite into "SOCIAL_POSTS" ("TEXT_COLUMN")
values
    ('Check out our new product! #launch #excited')
  , ('Loving the weather today! #sunnyDay #relax')
  , ('Follow us at #example_page for more updates!')
  , ('No hashtags in this sentence.')
;

----------------
-- Challenge Solution

select
    *
  , regexp_substr_all("TEXT_COLUMN", $$(#[a-zA-Z0-9_]+)$$) as "ALL_HASH_TAGS"
from "SOCIAL_POSTS"
;
