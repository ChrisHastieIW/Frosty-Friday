
-- Frosty Friday Challenge
-- Week 46 - Advanced - Recursive CTE and Array
-- https://frostyfriday.org/2023/05/19/week-46-intermediate/

-------------------------------
-- Environment Configuration

use database CH_FROSTY_FRIDAY;

use warehouse WH_CHASTIE;

create or replace schema WEEK_46;

use schema WEEK_46;

-------------------------------
-- Create challenge data

-- Create the original shopping cart.

-- This has been made a bit more complex
-- than strictly needed so that the
-- array members are integers instead of
-- strings. You could just use the
-- array_as_strings CTE to create this
-- with strings in the array instead.
-- You also could have created this in
-- several other ways, but I found this
-- approach to be more fun.
create or replace table ORIGINAL_SHOPPING_CART (
    CART_NUMBER int
  , CONTENTS array
)
as
with input_values as (
  select
      $1 as CART_NUMBER
    , $2 as CONTENTS_AS_SINGLE_STRING
  from values
      (1, '5,10,15,20')
    , (2, '8,9,10,11,12,13,14')
)
, array_as_strings as (
  select
      CART_NUMBER
    , split(CONTENTS_AS_SINGLE_STRING, ',') as CONTENTS
  from input_values
)
select
    CART_NUMBER
  , array_agg(values_as_rows.VALUE::int)
from input_values
  , table(split_to_table(CONTENTS_AS_SINGLE_STRING, ',')) as values_as_rows
group by CART_NUMBER
;

-- Verify the original shopping cart
select * from ORIGINAL_SHOPPING_CART;

-- Create the table that determines the order
-- to unpack the shopping from the cart
create or replace table ORDER_TO_UNPACK (
    CART_NUMBER int
  , CONTENT_TO_REMOVE int
  , ORDER_TO_REMOVE_IN int
)
as
select *
from values
    (1, 10, 1)
  , (1, 15, 2)
  , (1, 5, 3)
  , (1, 20, 4)
  , (2, 8, 1)
  , (2, 14, 2)
  , (2, 11, 3)
  , (2, 12, 4)
  , (2, 9, 5)
  , (2, 10, 6)
  , (2, 13, 7)
;

-- Verify the table that determines the order
-- to unpack the shopping from the cart
select * from ORDER_TO_UNPACK;

-------------------------------
-- Create recursive CTE of unpacked shopping

-- Create the view with a recursive CTE.
-- This works the same 
create or replace view TRACKED_UNPACKING_OF_SHOPPING
as
with recursive rcte_shopping_cart_unpacking as (
    select
        otu.ORDER_TO_REMOVE_IN as REMOVAL_ITERATION
      , osc.CART_NUMBER
      , array_remove(osc.CONTENTS, otu.CONTENT_TO_REMOVE) as CURRENT_CONTENTS_OF_CART
      , otu.CONTENT_TO_REMOVE as CONTENT_LAST_REMOVED
    from ORIGINAL_SHOPPING_CART as osc
      left join ORDER_TO_UNPACK as otu
        on  osc.CART_NUMBER = otu.CART_NUMBER
    where otu.ORDER_TO_REMOVE_IN = 1
  union all
    select
        otu.ORDER_TO_REMOVE_IN as REMOVAL_ITERATION
      , rscu.CART_NUMBER
      , array_remove(rscu.CURRENT_CONTENTS_OF_CART, otu.CONTENT_TO_REMOVE) as CURRENT_CONTENTS_OF_CART
      , otu.CONTENT_TO_REMOVE as CONTENT_LAST_REMOVED
    from rcte_shopping_cart_unpacking as rscu
      left join ORDER_TO_UNPACK as otu
        on  rscu.CART_NUMBER = otu.CART_NUMBER
        and rscu.REMOVAL_ITERATION + 1 = otu.ORDER_TO_REMOVE_IN
    where array_size(rscu.CURRENT_CONTENTS_OF_CART) > 0
)
select
    CART_NUMBER
  , CURRENT_CONTENTS_OF_CART
  , CONTENT_LAST_REMOVED
from rcte_shopping_cart_unpacking
order by
    CART_NUMBER
  , REMOVAL_ITERATION
;

-- Verify the view with a recursive CTE
select * from TRACKED_UNPACKING_OF_SHOPPING
