
-- Frosty Friday Challenge
-- Week 88 - Intermediate - Data Governanace
-- https://frostyfriday.org/blog/2024/04/05/week-88-intermediate/

-------------------------------
-- Environment Configuration

use database CH_FROSTY_FRIDAY;

use warehouse WH_CHASTIE;

create or replace schema WEEK_88;

use schema WEEK_88;

-------------------------------
-- Challenge Setup Script

create or replace table "PersonalDetails" (
    "ID" int PRIMARY KEY
  , "FirstName" varchar
  , "LastName" varchar
  , "SSN" varchar
)
as
select * from values
    (1, 'John', 'Doe', '123-45-6789')
  , (2, 'Jane', 'Doe', '987-65-4321')
  , (3, 'Jim', 'Beam', '111-22-3333')
  , (4, 'Jill', 'Valentine', '444-55-6666')
  , (5, 'Leon', 'Kennedy', '777-88-9999')
  , (6, 'Claire', 'Redfield', '222-33-4444')
  , (7, 'Chris', 'Redfield', '555-66-7777')
  , (8, 'Ada', 'Wong', '888-99-0000')
  , (9, 'Albert', 'Wesker', '666-77-8888')
  , (10, 'Rebecca', 'Chambers', '999-00-1111')
  , (11, 'Barry', 'Burton', '333-44-5555')
  , (12, 'Carlos', 'Oliveira', '666-55-4444')
  , (13, 'Nikolai', 'Zinoviev', '777-33-2222')
  , (14, 'Jill', 'Sandwich', '888-44-5555')
  , (15, 'Hunk', 'Unknown', '999-66-7777')
;

create or replace table "EmploymentDetails" (
    "EmploymentID" int PRIMARY KEY
  , "SSN" varchar
  , "CompanyName" varchar
  , "Position" varchar
  , "StartDate" date
  , "Salary" int
)
as
select * from values
    (1, '123-45-6789', 'ACME Corporation', 'Software Engineer', '2018-06-01', 70000)
  , (2, '987-65-4321', 'Globex Corporation', 'Project Manager', '2019-08-15', 75000)
  , (3, '111-22-3333', 'Soylent Corp', 'Quality Assurance Engineer', '2020-02-01', 68000)
  , (4, '444-55-6666', 'Initech', 'IT Support Specialist', '2017-05-23', 62000)
  , (5, '777-88-9999', 'Umbrella Corporation', 'Research Scientist', '2021-03-12', 78000)
  , (6, '222-33-4444', 'Hooli', 'Data Analyst', '2018-07-01', 69000)
  , (7, '555-66-7777', 'Vehement Capital Partners', 'Investment Analyst', '2019-09-09', 71000)
  , (8, '888-99-0000', 'Massive Dynamic', 'Executive Assistant', '2020-01-20', 65000)
  , (9, '666-77-8888', 'Wayne Enterprises', 'Security Consultant', '2017-04-10', 72000)
  , (10, '999-00-1111', 'Stark Industries', 'Mechanical Engineer', '2021-08-05', 83000)
  , (11, '333-44-5555', 'Pied Piper', 'Software Developer', '2019-06-01', 85000)
  , (12, '666-55-4444', 'Bluth Company', 'Sales Manager', '2018-11-01', 64000)
  , (13, '777-33-2222', 'Dunder Mifflin', 'Regional Manager', '2017-12-01', 73000)
  , (14, '888-44-5555', 'Los Pollos Hermanos', 'Operations Manager', '2020-07-15', 55000)
  , (15, '999-66-7777', 'Cyberdyne Systems', 'Systems Analyst', '2019-04-01', 76000)
;

-------------------------------
-- Challenge Solution

-- Create projection policy
create or replace projection policy "BLOCK_ALL"
  as () returns PROJECTION_CONSTRAINT ->
    PROJECTION_CONSTRAINT(ALLOW => FALSE)
;

-- Assign projection policy
alter table "PersonalDetails"
  alter column "SSN"
  set projection policy "BLOCK_ALL"
;

-------------------------------
-- Test queries

-- Should fail
select * from "PersonalDetails";

-- Should work
select p."FirstName", p."LastName", e."CompanyName", e."Position", e."StartDate", e."Salary"
from "PersonalDetails" p
  join "EmploymentDetails" as e
    on p."SSN" = e."SSN"
;