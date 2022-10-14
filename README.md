
# Frosty Friday

This is my repository of solutions for the weekly [Frosty Friday](https://frostyfriday.org/) set of Snowflake challenges.

Some challenges leverage Snowpark connectivity. To simplify creating Snowpark sessions, a custom module called "interworks_snowpark" has been used. More details can be found in the [InterWorks Snowflake Python Functionality GitHub repository](https://github.com/interworks/Snowflake-Python-Functionality). This repository also contains instructions on how to configure your local environment for Snowpark for Python, and pairs well with this [Definitive Guide to Snowflake Sessions with Snowpark for Python](https://interworks.com/blog/2022/09/02/a-definitive-guide-to-snowflake-sessions-with-snowpark-for-python/).

## Quick Conda Environment Creation

To setup a Conda environment, simply leverage the following code to create your Anaconda Python environment, using a conda terminal. This will leverage the `conda_requirements.yml` file in this directory to install the required Python packages.

```powershell
cd path/to/this/directory
conda env create --name py38_snowpark_frosty_friday --file conda_requirements.yml
```
