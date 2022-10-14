
# InterWorks Snowpark for Python

This package has been created to simplify the creation of Snowpark for Python sessions and Snowpipe Ingest Manager objects. This package heavily leverages the main `snowflake-snowpark-python[pandas]` and `snowflake-ingest` packages from Snowflake.

## Contents

- [InterWorks Snowpark for Python](#interworks-snowpark-for-python)
  - [Contents](#contents)
  - [Articles](#articles)
  - [Third Party Packages from Anaconda](#third-party-packages-from-anaconda)
  - [Local Installation](#local-installation)
    - [Quick Conda Environment Creation](#quick-conda-environment-creation)
    - [Additional Package Installation using the Conda Snowflake Channel](#additional-package-installation-using-the-conda-snowflake-channel)
    - [Configuring Conda for Visual Studio Code](#configuring-conda-for-visual-studio-code)
  - [Connection Parameters](#connection-parameters)
    - [Connection parameters in a local JSON file](#connection-parameters-in-a-local-json-file)
    - [Connection parameters via Streamlit secrets](#connection-parameters-via-streamlit-secrets)
    - [Connection parameters via environment variables](#connection-parameters-via-environment-variables)
  - [Testing your Snowpark connection](#testing-your-snowpark-connection)
    - [Testing your Snowpark connection with a parameters JSON file](#testing-your-snowpark-connection-with-a-parameters-json-file)
    - [Testing your Snowpark connection with streamlit secrets](#testing-your-snowpark-connection-with-streamlit-secrets)
    - [Testing your Snowpark connection with environment variables](#testing-your-snowpark-connection-with-environment-variables)
  - [Testing your Snowpipe connection](#testing-your-snowpipe-connection)
    - [Testing your Snowpipe connection with a parameters JSON file](#testing-your-snowpipe-connection-with-a-parameters-json-file)
    - [Testing your Snowpipe connection with streamlit secrets](#testing-your-snowpipe-connection-with-streamlit-secrets)
    - [Testing your Snowpipe connection with environment variables](#testing-your-snowpipe-connection-with-environment-variables)

## Articles

Much of the content in this README is also discussed in the [Definitive Guide to Snowflake Sessions with Snowpark for Python](https://interworks.com/blog/2022/09/05/a-definitive-guide-to-snowflake-sessions-with-snowpark-for-python), which is part of the [Snowflake with Python series on the InterWorks blog](https://interworks.com/blog/series/snowflake-with-python).

## Third Party Packages from Anaconda

To leverage third party packages from Anaconda within Snowflake, an ORGADMIN must first accept the [third party terms of usage](https://www.snowflake.com/legal/third-party-terms/). More details can be found [here](https://docs.snowflake.com/en/developer-guide/udf/python/udf-python-packages.html#using-third-party-packages-from-anaconda). This only needs to be enabled once for the entire organisation.

1. Using the ORGADMIN role in the SnowSight UI, navigate to `Admin` > `Billing` to accept the third party terms of usage

    ![Snowpark Anaconda Terms](./images/Snowpark_Anaconda_Terms_1.png)

2. Confirm acknowledgement

    ![Snowpark Anaconda Terms](./images/Snowpark_Anaconda_Terms_2.png)

3. The screen will then update to reflect the accepted terms

    ![Snowpark Anaconda Terms](./images/Snowpark_Anaconda_Terms_3.png)

## Local Installation

To align your local Python environment with a typical Snowpark environment, leverage [Anaconda](https://docs.conda.io/projects/conda/en/latest/user-guide/install/index.html) or [Miniconda](https://docs.conda.io/projects/conda/en/latest/user-guide/install/index.html) and configure an environment with the [Snowflake channel](https://docs.snowflake.com/en/developer-guide/udf/python/udf-python-packages.html#local-development-and-testing).

Snowpark for Python supports [these packages](https://repo.anaconda.com/pkgs/snowflake) which are all part of a single Anaconda channel.

Follow [these steps](https://docs.snowflake.com/en/developer-guide/snowpark/python/setup.html) to set up your development environment.

### Quick Conda Environment Creation

To setup a Conda environment, simply leverage the following code to create your Anaconda Python environment, using a conda terminal. This will leverage the `conda_requirements.yml` file in this directory to install the required Python packages.

```powershell
conda env create --name py38_snowpark --file path/to/this/directory/conda_requirements.yml
```

### Additional Package Installation using the Conda Snowflake Channel

If you wish to install further packages using the [Snowflake channel](https://docs.snowflake.com/en/developer-guide/udf/python/udf-python-packages.html#local-development-and-testing), or maybe leverage a requirements.txt file, the following commands will be useful.

Install a specific package into your environment, using the main Snowpark package as an example:

```powershell
conda install --name py38_snowpark --channel https://repo.anaconda.com/pkgs/snowflake snowflake-snowpark-python[pandas]
```

Install and leverage `pip` to install a package that is not available through a Conda channel, using `snowflake-ingest` as an example:

```powershell
conda activate py38_snowpark
conda install --name py38_snowpark pip
"path\to\.conda\envs\py38_snowpark\Scripts\pip.exe" install snowflake-ingest
```

Create a new environment using a requirements file (note that this will fail as this will attempt to install `snowflake-ingest` which is not part of a [Snowflake channel](https://docs.snowflake.com/en/developer-guide/udf/python/udf-python-packages.html#local-development-and-testing) or the [default channel](https://repo.anaconda.com/pkgs/main/win-64/) at time of writing). This is why the recommendation above is to use the `conda_requirements.yml` file.

```powershell
conda create --name py38_snowpark --file path/to/this/directory/requirements.txt --channel https://repo.anaconda.com/pkgs/snowflake python=3.8
```

### Configuring Conda for Visual Studio Code

> Disclaimer: I am using VSCode but other IDEs are available

Configuring Conda to work with Python through VSCode requires you to set up a bespoke terminal profile within your VSCode settings. You can do so by following these steps within VSCode:

1. Open the commands shortcut (`CTRL+SHIFT+P`) and select `Terminal: Select Default Profile`
2. Select the small settings cog to the right of one of the existing PowerShell profiles
3. In the naming window, enter the name "Windows PowerShell Conda" or any other name if you prefer
4. Use the same commands shortcut (`CTRL+SHIFT+P`) and select `Preferences: Open Settings (JSON)`
5. Steps 1-3 will have added a new key to your `settings.json` file called "terminal.integrated.profiles.windows", which lists a set of different terminal profiles. The final entry on this list should be your new profile, which we called "Windows PowerShell Conda". Modify this profile to match the following settings:

    ```json
    "Windows PowerShell Conda": {
        "source": "PowerShell",
        "args": [
            "-NoExit",
            "Path\\to\\conda-hook.ps1"
        ],
        "icon": "terminal-powershell"
    }
    ```

    The desired path to `conda-hook.ps1` depends on where you installed Conda. Usually this will be one of the following two options:

    1. When Conda was installed to the C drive for all users:

        ```raw
        "C:\\ProgramData\\Anaconda3\\shell\\condabin\\conda-hook.ps1"
        ```

    2. When Conda was installed for a single user, where %USERPROFILE% should be expanded out to the full path:

        ```raw
        "%USERPROFILE%\\Anaconda3\\shell\\condabin\\conda-hook.ps1"
        ```

6. Finally, open the commands shortcut (`CTRL+SHIFT+P`) and select `Terminal: Select Default Profile`, then select the new profile as the default. For our example, we would select "Windows PowerShell Conda"

## Connection Parameters

The Python scripts are configured to ingest a snowflake_connection_parameters dictionary and use it to establish connections to Snowflake.

The dictionary may either be provided as a locally stored .json file, as environment variables, or as part of a Streamlit secrets .toml file.

Note that we have included a default role and warehouse here. Unfortunately, at time of writing it appears that Snowpark sessions will leverage your default role in a session without being explicitly told, but it will not leverage a default warehouse unless explicitly told. I find it to be safer and easier to just provide the details of both here, especially if you do not want your Snowpark connection to leverage your Snowflake user's standard default role.

### Connection parameters in a local JSON file

If using a locally stored .json file, this file should be created in the root directory as this repository and should match the format below. This is not synced with git (currently in `.gitignore` to avoid security breaches).

```json
{
  "account": "<account>[.<region>][.<cloud provider>]",
  "user": "<username>",
  "default_role" : "<default role>", // Enter "None" if not required
  "default_warehouse" : "<default warehouse>", // Enter "None" if not required
  "default_database" : "<default database>", // Enter "None" if not required
  "default_schema" : "<default schema>", // Enter "None" if not required
  "private_key_path" : "path\\to\\private\\key", // Enter "None" if not required, in which case private key plain text or password will be used
  "private_key_plain_text" : "-----BEGIN PRIVATE KEY-----\nprivate\nkey\nas\nplain\ntext\n-----END PRIVATE KEY-----", // Not best practice but may be required in some cases. Ignored if private key path is provided
  "private_key_passphrase" : "<passphrase>", // Enter "None" if not required
  "password" : "<password>" // Enter "None" if not required, ignored if private key path or private key plain text is provided
}
```

### Connection parameters via Streamlit secrets

If using a streamlit secrets file, this file should be created in a subdirectory called .streamlit within the root directory as this repository and should match the format below. This is not synced with git (currently in `.gitignore` to avoid security breaches). Alternatively if deploying Streamlit remotely, the secrets should be entered in the Streamlit development interface.

```toml
[snowflake_connection_parameters]
account = "<account>[.<region>][.<cloud provider>]"
user = "<username>"
default_role = "<default role>" ## Enter "None" if not required
default_warehouse = "<default warehouse>" ## Enter "None" if not required
default_database = "<default database>" ## Enter "None" if not required
default_schema = "<default schema>" ## Enter "None" if not required
private_key_path =  "path\\to\\private\\key" ## Enter "None" if not required, in which case private key plain text or password will be used
private_key_plain_text =  "-----BEGIN PRIVATE KEY-----\nprivate\nkey\nas\nplain\ntext\n-----END PRIVATE KEY-----" ## Not best practice but may be required in some cases. Ignored if private key path is provided
private_key_passphrase = "<passphrase>" ## Enter "None" if not required
password = "<password>" ## Enter "None" if not required, ignored if private key path or private key plain text is provided
```

### Connection parameters via environment variables

If using environment variables, they should match the format below.

```shell
SNOWFLAKE_ACCOUNT : "<account>[.<region>][.<cloud provider>]"
SNOWFLAKE_USER : "<username>"
SNOWFLAKE_DEFAULT_ROLE : "<default role>" ## Enter "None" if not required
SNOWFLAKE_DEFAULT_WAREHOUSE : "<default warehouse>" ## Enter "None" if not required
SNOWFLAKE_DEFAULT_DATABASE : "<default database>" ## Enter "None" if not required
SNOWFLAKE_DEFAULT_SCHEMA : "<default schema>" ## Enter "None" if not required
SNOWFLAKE_PRIVATE_KEY_PATH :  "path\\to\\private\\key" ## Enter "None" if not required, in which case private key plain text or password will be used
SNOWFLAKE_PRIVATE_KEY_PLAIN_TEXT :  "-----BEGIN PRIVATE KEY-----\nprivate\nkey\nas\nplain\ntext\n-----END PRIVATE KEY-----" ## Not best practice but may be required in some cases. Ignored if private key path is provided
SNOWFLAKE_PRIVATE_KEY_PASSPHRASE : "<passphrase>" ## Enter "None" if not required
SNOWFLAKE_PASSWORD : "<password>" ## Enter "None" if not required, ignored if private key path or private key plain text is provided
```

## Testing your Snowpark connection

This section contains steps to simplify testing of your Snowpark connection. Naturally, these tests will only be successful if you have configured the corresponding parameters as detailed above.

### Testing your Snowpark connection with a parameters JSON file

Execute the following steps in an Anaconda terminal, or directly run the `connection_tests/test_snowpark_connection_via_parameters_json.py` file step by step through VSCode or similar.

```powershell
conda activate py38_snowpark
cd path/to/this/directory
python run "connection_tests/test_snowpark_connection_via_parameters_json.py"
```

### Testing your Snowpark connection with streamlit secrets

Execute the following steps in an Anaconda terminal, or directly run the `connection_tests/test_snowpark_connection_via_streamlit_secrets.py` file step by step through VSCode or similar.

```powershell
conda activate py38_snowpark
cd path/to/this/directory
python run "connection_tests/test_snowpark_connection_via_streamlit_secrets.py"
```

### Testing your Snowpark connection with environment variables

Execute the following steps in an Anaconda terminal, or directly run the `connection_tests/test_snowpark_connection_via_environment_variables.py` file step by step through VSCode or similar.

```powershell
conda activate py38_snowpark
cd path/to/this/directory
python run "connection_tests/test_snowpark_connection_via_environment_variables.py"
```

## Testing your Snowpipe connection

This section contains steps to simplify testing of your Snowpipe connection. Naturally, these tests will only be successful if you have configured the corresponding parameters as detailed above.

### Testing your Snowpipe connection with a parameters JSON file

Execute the following steps in an Anaconda terminal, or directly run the `connection_tests/test_snowpipe_connection_via_parameters_json.py` file step by step through VSCode or similar.

```powershell
conda activate py38_snowpark
cd path/to/this/directory
python run "connection_tests/test_snowpipe_connection_via_parameters_json.py"
```

### Testing your Snowpipe connection with streamlit secrets

Execute the following steps in an Anaconda terminal, or directly run the `connection_tests/test_snowpipe_connection_via_streamlit_secrets.py` file step by step through VSCode or similar.

```powershell
conda activate py38_snowpark
cd path/to/this/directory
python run "connection_tests/test_snowpipe_connection_via_streamlit_secrets.py"
```

### Testing your Snowpipe connection with environment variables

Execute the following steps in an Anaconda terminal, or directly run the `connection_tests/test_snowpipe_connection_via_environment_variables.py` file step by step through VSCode or similar.

```powershell
conda activate py38_snowpark
cd path/to/this/directory
python run "connection_tests/test_snowpipe_connection_via_environment_variables.py"
```
