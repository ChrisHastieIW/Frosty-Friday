
-- Frosty Friday Challenge
-- Week 49 - Intermediate - Parsing XML
-- https://frostyfriday.org/2023/06/09/week-49-intermediate/

-------------------------------
-- Environment Configuration

use database CH_FROSTY_FRIDAY;

use warehouse WH_CHASTIE;

create or replace schema WEEK_49;

use schema WEEK_49;

-------------------------------
-- Create challenge data

create or replace table CHALLENGE_DATA (
    "DATA" variant
)
as
select parse_xml('<?xml version="1.0" encoding="UTF-8"?>
<library>
    <book>
        <title>The Great Gatsby</title>
        <author>F. Scott Fitzgerald</author>
        <year>1925</year>
        <publisher>Scribner</publisher>
    </book>
    <book>
        <title>To Kill a Mockingbird</title>
        <author>Harper Lee</author>
        <year>1960</year>
        <publisher>J. B. Lippincott & Co.</publisher>
    </book>
    <book>
        <title>1984</title>
        <author>George Orwell</author>
        <year>1949</year>
        <publisher>Secker & Warburg</publisher>
    </book>
</library>
')
;

-- View challenge data
select * from CHALLENGE_DATA;

-------------------------------
-- Parsed view

-- Important things to remember when parsing XML:
-- - "$" retrieves the value of the element
-- - "@" retrieves the name of the element
-- - XMLGET allows you to retrieve a child of an element

-- Create the view
create or replace view CHALLENGE_OUTPUT
as
select
    XMLGET(book.value, 'title'):"$"::string as TITLE
  , XMLGET(book.value, 'author'):"$"::string as AUTHOR
  , XMLGET(book.value, 'year'):"$"::int as YEAR
  , XMLGET(book.value, 'publisher'):"$"::string as PUBLISHER
from CHALLENGE_DATA
  , lateral flatten ("DATA":"$") as book
;

-- Query the view
select * from CHALLENGE_OUTPUT;
