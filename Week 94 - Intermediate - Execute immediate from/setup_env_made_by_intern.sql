--!jinja2

-- Define environments and schemas
-- depedning on the input deployment type
{% if deployment_type.upper() == 'PROD' %}
  {% set list_environments = ['PROD_1', 'PROD_2'] %}
  {% set list_schemas = ['FINANCE', 'SALES', 'HR'] %}
{% else %}
  {% set list_environments = ['DEV', 'QA', 'STAGING'] %}
  {% set list_schemas = ['DEVELOPMENT', 'TESTING', 'SUPPORT'] %}
{% endif %}

-- Iterate over environments
{% for environment in list_environments %}

  -- Set database name
  {% set database_name = 'CH_FF_W94__' ~ environment %}

  -- Create the database
  create or replace database "{{database_name}}" comment = 'Chris Hastie - Database for Frosty Friday challenge 94';

  -- Iterate over schemas
  {% for schema in list_schemas %}

    -- Create the schema
    create or replace schema "{{database_name}}"."{{schema}}";

    -- Create table - orders
    create or replace table "{{database_name}}"."{{schema}}"."{{ environment }}_{{schema}}_ORDERS" (
        "ID"              integer
      , "ITEM"            string
      , "QUANTITY"        integer
      , "ORDER_DATE"      date
    )
    ;

    -- Create table - customers
    create or replace table "{{database_name}}"."{{schema}}"."{{ environment }}_{{schema}}_CUSTOMERS" (
        "ID"              integer
      , "NAME"            string
      , "EMAIL"           string
    )
    ;

    -- Create table - products
    create or replace table "{{database_name}}"."{{schema}}"."{{ environment }}_{{schema}}_PRODUCTS" (
        "PRODUCT_ID"      integer
      , "PRODUCT_NAME"    string
      , "PRICE"           integer
    )
    ;

    -- Create table - employees
    create or replace table "{{database_name}}"."{{schema}}"."{{ environment }}_{{schema}}_EMPLOYEES" (
        "EMPLOYEE_ID"     integer
      , "EMPLOYEE_NAME"   string
      , "POSITION"        string
    )
    ;

  -- Stop iterating over schemas
  {% endfor %}

-- Stop iterating over environments
{% endfor %}

-- Production-specific component
{% if deployment_type.upper() == 'PROD' %}
  
  -- Create database
  create or replace database "CH_FF_W94__PROD_ANALYTICS" comment = 'Chris Hastie - Database for Frosty Friday challenge 94';
  
  -- Create table
  create or replace table "CH_FF_W94__PROD_ANALYTICS"."PUBLIC"."ANALYTICS_REPORTS"(
      "REPORT_ID"       integer
    , "REPORT_NAME"     string
    , "CREATED_DATE"    date
  )
  ;
  
{% endif %}