
-- Frosty Friday Challenge
-- Week 65 - Basic - UDF and Marketplace
-- https://frostyfriday.org/blog/2023/09/29/week-65-basic/

-------------------------------
-- Environment Configuration

use database CH_FROSTY_FRIDAY;

use warehouse WH_CHASTIE;

create or replace schema WEEK_65;

use schema WEEK_65;

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
  returns boolean
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

  ### Determine result based on
  ### patent type condition
  if patent_type.lower() == "reissue":
    result = (publication_date - application_date).days <= 365
  elif patent_type.lower() == "design":
    result = relativedelta(publication_date, application_date).years < 2
  else:
    result = False
  
  ### Return the final output
  return result
$$
;

-- Test the UDF functionally
select
    TEST_PATENT('2023-09-05'::timestamp, '2023-09-06'::timestamp, 'Reissue') as EXPECT_TRUE
  , TEST_PATENT('2023-09-07'::timestamp, '2023-09-06'::timestamp, 'Design') as EXPECT_FALSE
;

-- Test the UDF with the data
select
    PATENT_INDEX.PATENT_ID
  , PATENT_INDEX.INVENTION_TITLE
  , PATENT_INDEX.PATENT_TYPE
  , PATENT_INDEX.APPLICATION_DATE 
  , PATENT_INDEX.DOCUMENT_PUBLICATION_DATE
  , TEST_PATENT(PATENT_INDEX.APPLICATION_DATE, PATENT_INDEX.DOCUMENT_PUBLICATION_DATE, PATENT_INDEX.PATENT_TYPE) as TEST_PATENT
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
  , TEST_PATENT(PATENT_INDEX.APPLICATION_DATE, PATENT_INDEX.DOCUMENT_PUBLICATION_DATE, PATENT_INDEX.PATENT_TYPE) as TEST_PATENT
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
