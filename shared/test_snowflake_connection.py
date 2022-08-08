
# Test connection to Snowflake through various methods

## Test connection leveraging locally-stored JSON file
from shared.snowpark.snowpark_session_builder import build_snowpark_session_via_parameters_json

snowpark_session_via_parameters_json = build_snowpark_session_via_parameters_json()

### Simple commands to test the connection by listing the databases in the environment
df_test_via_parameters_json = snowpark_session_via_parameters_json.sql('SHOW DATABASES')
df_test_via_parameters_json.show()

## Test connection leveraging Streamlit secrets

from shared.snowpark.snowpark_session_builder import build_snowpark_session_via_streamlit_secrets

snowpark_session_via_streamlit_secrets = build_snowpark_session_via_streamlit_secrets()

### Simple commands to test the connection by listing the databases in the environment
df_test_via_streamlit_secrets = snowpark_session_via_streamlit_secrets.sql('SHOW DATABASES')
df_test_via_streamlit_secrets.show()
