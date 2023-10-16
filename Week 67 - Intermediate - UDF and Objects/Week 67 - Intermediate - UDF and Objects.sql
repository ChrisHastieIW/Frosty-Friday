
-- Frosty Friday Challenge
-- Week 67 - Intermediate - UDF and Objects
-- https://frostyfriday.org/blog/2023/10/13/week-67-intermediate/

-------------------------------
-- Environment Configuration

use database CH_FROSTY_FRIDAY;

use warehouse WH_CHASTIE;

create or replace schema WEEK_67;

use schema WEEK_67;

-------------------------------
-- Test challenge query

-- First, navigate through the marketplace
-- to access the Cybersyn US Patent Grants
-- dataset, which I have named:
-- SHARE_CYBERSYN_US_PATENT_GRANTS

-- Now test that the query provided
-- in the challenge works successfully
select
    PATENT_INDEX.PATENT_ID
  , PATENT_INDEX.INVENTION_TITLE
  , PATENT_INDEX.PATENT_TYPE
  , PATENT_INDEX.APPLICATION_DATE 
  , PATENT_INDEX.DOCUMENT_PUBLICATION_DATE
from SHARE_CYBERSYN_US_PATENT_GRANTS.CYBERSYN.USPTO_CONTRIBUTOR_INDEX AS CONTRIBUTOR_INDEX
  inner join SHARE_CYBERSYN_US_PATENT_GRANTS.CYBERSYN.USPTO_PATENT_CONTRIBUTOR_RELATIONSHIPS AS RELATIONSHIPS
    on CONTRIBUTOR_INDEX.CONTRIBUTOR_ID = RELATIONSHIPS.CONTRIBUTOR_ID
  inner join SHARE_CYBERSYN_US_PATENT_GRANTS.CYBERSYN.USPTO_PATENT_INDEX AS PATENT_INDEX
    on RELATIONSHIPS.PATENT_ID = PATENT_INDEX.PATENT_ID
where CONTRIBUTOR_INDEX.CONTRIBUTOR_NAME ilike 'NVIDIA CORPORATION'
  and RELATIONSHIPS.CONTRIBUTION_TYPE = 'Assignee - United States Company Or Corporation'
limit 10
;

-------------------------------
-- Define challenge UDF

-- Create the UDF
create or replace function TEST_PATENT (
      application_date timestamp
    , publication_date timestamp
    , patent_type string
  )
  returns variant
  language python
  runtime_version = '3.8'
  packages = ('python-dateutil')
  handler = 'main'
as
$$
## Import the required modules 
from datetime import datetime
from dateutil.relativedelta import relativedelta

## Define the main function.
def main(
      application_date: datetime
    , publication_date: datetime
    , patent_type: str
  ):

  ### Determine difference between
  ### publication date and application date
  ### in days
  days_difference = (publication_date - application_date).days
  
  ### Determine if the difference is
  ### inside the projection based on
  ### the patent type condition
  if patent_type.lower() == "reissue":
    inside_of_projection = (publication_date - application_date).days <= 365
  elif patent_type.lower() == "design":
    inside_of_projection = relativedelta(publication_date, application_date).years < 2
  else:
    inside_of_projection = False

  ### Construct output object
  output_object = {
      "days_difference": days_difference
    , "inside_of_projection": inside_of_projection
  }
  
  ### Return the final output
  return output_object
$$
;

-- Test the UDF functionally
select
    TEST_PATENT('2023-09-07'::timestamp, '2024-09-06'::timestamp, 'Reissue') as EXPECT_TRUE_1
  , TEST_PATENT('2023-09-07'::timestamp, '2024-09-07'::timestamp, 'Reissue') as EXPECT_FALSE_1
  , TEST_PATENT('2023-09-07'::timestamp, '2025-09-06'::timestamp, 'Design') as EXPECT_TRUE_2
  , TEST_PATENT('2023-09-07'::timestamp, '2025-09-07'::timestamp, 'Design') as EXPECT_FALSE_2
;

-- Test the UDF with the data
select
    PATENT_INDEX.PATENT_ID
  , PATENT_INDEX.INVENTION_TITLE
  , PATENT_INDEX.PATENT_TYPE
  , PATENT_INDEX.APPLICATION_DATE 
  , PATENT_INDEX.DOCUMENT_PUBLICATION_DATE
  , TEST_PATENT(PATENT_INDEX.APPLICATION_DATE, PATENT_INDEX.DOCUMENT_PUBLICATION_DATE, PATENT_INDEX.PATENT_TYPE) as OBJECT_AS_OUTPUT
  , OBJECT_AS_OUTPUT:"inside_of_projection"::boolean as INSIDE_OF_PROJECTION
from SHARE_CYBERSYN_US_PATENT_GRANTS.CYBERSYN.USPTO_CONTRIBUTOR_INDEX AS CONTRIBUTOR_INDEX
  inner join SHARE_CYBERSYN_US_PATENT_GRANTS.CYBERSYN.USPTO_PATENT_CONTRIBUTOR_RELATIONSHIPS AS RELATIONSHIPS
    on CONTRIBUTOR_INDEX.CONTRIBUTOR_ID = RELATIONSHIPS.CONTRIBUTOR_ID
  inner join SHARE_CYBERSYN_US_PATENT_GRANTS.CYBERSYN.USPTO_PATENT_INDEX AS PATENT_INDEX
    on RELATIONSHIPS.PATENT_ID = PATENT_INDEX.PATENT_ID
where CONTRIBUTOR_INDEX.CONTRIBUTOR_NAME ilike 'NVIDIA CORPORATION'
  and RELATIONSHIPS.CONTRIBUTION_TYPE = 'Assignee - United States Company Or Corporation'
limit 10
;

-------------------------------
-- Challenge output view

-- Create the view
create or replace view CHALLENGE_OUTPUT
as
select
    PATENT_INDEX.PATENT_ID
  , PATENT_INDEX.INVENTION_TITLE
  , PATENT_INDEX.PATENT_TYPE
  , PATENT_INDEX.APPLICATION_DATE 
  , PATENT_INDEX.DOCUMENT_PUBLICATION_DATE
  , TEST_PATENT(PATENT_INDEX.APPLICATION_DATE, PATENT_INDEX.DOCUMENT_PUBLICATION_DATE, PATENT_INDEX.PATENT_TYPE) as OBJECT_AS_OUTPUT
  , OBJECT_AS_OUTPUT:"inside_of_projection"::boolean as INSIDE_OF_PROJECTION
from SHARE_CYBERSYN_US_PATENT_GRANTS.CYBERSYN.USPTO_CONTRIBUTOR_INDEX AS CONTRIBUTOR_INDEX
  inner join SHARE_CYBERSYN_US_PATENT_GRANTS.CYBERSYN.USPTO_PATENT_CONTRIBUTOR_RELATIONSHIPS AS RELATIONSHIPS
    on CONTRIBUTOR_INDEX.CONTRIBUTOR_ID = RELATIONSHIPS.CONTRIBUTOR_ID
  inner join SHARE_CYBERSYN_US_PATENT_GRANTS.CYBERSYN.USPTO_PATENT_INDEX AS PATENT_INDEX
    on RELATIONSHIPS.PATENT_ID = PATENT_INDEX.PATENT_ID
where CONTRIBUTOR_INDEX.CONTRIBUTOR_NAME ilike 'NVIDIA CORPORATION'
  and RELATIONSHIPS.CONTRIBUTION_TYPE = 'Assignee - United States Company Or Corporation'
;

-- Query the view
select * from CHALLENGE_OUTPUT limit 10;
