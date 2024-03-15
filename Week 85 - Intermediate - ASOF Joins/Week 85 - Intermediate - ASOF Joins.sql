
-- Frosty Friday Challenge
-- Week 85 - intermediate - ASOF Joins
-- https://frostyfriday.org/blog/2024/03/15/week-85-intermediate/

-------------------------------
-- Environment Configuration

use database CH_FROSTY_FRIDAY;

use warehouse WH_CHASTIE;

create or replace schema WEEK_85;

use schema WEEK_85;

-------------------------------
-- Challenge Setup Script

create or replace temporary table TRADES (
    TYPE varchar
  , ID int
  , TICKER varchar
  , DATETIME timestamp_tz
  , PRICE float
  , VOLUME int
)
as
select * from values
    ('trade', 2, 'AAPL', '2020-01-06 09:00:30.000+09:00', 305, 1)
  , ('trade', 2, 'AAPL', '2020-01-06 09:01:00.000+09:00', 310, 2)
  , ('trade', 2, 'AAPL', '2020-01-06 09:01:30.000+09:00', 308, 1)
  , ('trade', 3, 'GOOGL', '2020-01-06 09:02:00.000+09:00', 1500, 2)
  , ('trade', 3, 'GOOGL', '2020-01-06 09:03:00.000+09:00', 1520, 3)
  , ('trade', 3, 'GOOGL', '2020-01-06 09:03:30.000+09:00', 1515, 1)
;



create or replace temporary table QUOTES(
    TYPE varchar
  , ID int
  , TICKER varchar
  , DATETIME timestamp_tz
  , ASK float
  , BID float
)
as
select * from values
    ('quote', 2, 'AAPL', '2020-01-06 08:59:59.999+09:00', 305, 304)
  , ('quote', 2, 'AAPL', '2020-01-06 09:02:00.000+09:00', 311, 309)
  , ('quote', 3, 'GOOGL', '2020-01-06 09:01:00.000+09:00', 1490, 1485)
  , ('quote', 3, 'GOOGL', '2020-01-06 09:04:00.000+09:00', 1530, 1528)
  , ('quote', 2, 'AAPL', '2020-01-06 09:00:30.000+09:00', 307, 305)
  , ('quote', 2, 'AAPL', '2020-01-06 09:01:30.000+09:00', 308, 306)
  , ('quote', 3, 'GOOGL', '2020-01-06 09:02:00.000+09:00', 1502, 1498)
  , ('quote', 3, 'GOOGL', '2020-01-06 09:03:30.000+09:00', 1518, 1513)
;

-------------------------------
-- Challenge Solution

select TRADES.* exclude ("TYPE"), QUOTES.ASK, QUOTES.BID
from TRADES
  asof join QUOTES
    match_condition(TRADES.DATETIME >= QUOTES.DATETIME)
    on TRADES.ID = QUOTES.ID
;
