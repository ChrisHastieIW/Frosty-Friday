
# Test connection to Snowpark leveraging environment variables

## Import required function
from ..interworks_snowpark_python.snowpark_session_builder import build_snowpark_session_via_environment_variables as build_snowpark_session

'''
## Optional section to set specific environment variables temporarily
import os

os.environ[SNOWFLAKE_ACCOUNT] = "<account>[.<region>][.<cloud provider>]"
os.environ[SNOWFLAKE_USER] = "<username>"
os.environ[SNOWFLAKE_DEFAULT_ROLE] = "<default role>" ## Enter "None" if not required
os.environ[SNOWFLAKE_DEFAULT_WAREHOUSE] = "<default warehouse>" ## Enter "None" if not required
os.environ[SNOWFLAKE_DEFAULT_DATABASE] = "<default database>" ## Enter "None" if not required
os.environ[SNOWFLAKE_DEFAULT_SCHEMA] = "<default schema>" ## Enter "None" if not required
os.environ[SNOWFLAKE_PRIVATE_KEY_PATH] =  "path\\to\\private\\key" ## Enter "None" if not required, in which case private key plain text or password will be used
os.environ[SNOWFLAKE_PRIVATE_KEY_PLAIN_TEXT] =  "-----BEGIN PRIVATE KEY-----\nprivate\nkey\nas\nplain\ntext\n-----END PRIVATE KEY-----" ## Not best practice but may be required in some cases. Ignored if private key path is provided
os.environ[SNOWFLAKE_PRIVATE_KEY_PASSPHRASE] = "<passphrase>" ## Enter "None" if not required
os.environ[SNOWFLAKE_PASSWORD] = "<password>" ## Enter "None" if not required, ignored if private key path or private key plain text is provided
'''

## Generate Snowpark session
snowpark_session = build_snowpark_session()

## Simple commands to test the connection by listing the databases in the environment
df_test = snowpark_session.sql('SHOW DATABASES')
df_test.show()
