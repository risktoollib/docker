# Purpose

Ready-made DOCKER containers available at [Docker Hub](https://hub.docker.com/repositories/risktoollib) for the following tools:

+ [rstudio-python-node](https://hub.docker.com/repository/docker/risktoollib/rstudio-python-node/general)
+ [vscode-python-node](https://hub.docker.com/repository/docker/risktoollib/vscode-python-node/general)

I recommend using the `rstudio-python-node` container as it has the most features.

+ Working in Rstudio with R and python.
+ If doing webscraping, the `rstudio-python-node` container has nodejs installed. You can execute .js in an R code chunk using the `system()` function and setting the `intern=TRUE` argument to so it returns the output within the session environment.

#### Building Python Envs

-- this is documentation for the package maintainer --

``` bash
python3.11 -m venv env
source ./env/bin/activate
pip3.11 install ipython pandas pandas-datareader numpy polars plotly plotnine pyarrow scipy yfinance streamlit manim 
pip3.11 install git+https://github.com/bbcho/risktools-dev.git
pip3.11 freeze | grep -v "pyobjc" > ~/docker/rstudio-python-node/requirements.txt
pip3.11 freeze | grep -v "pyobjc" > ~/docker/vscode-python-node/requirements.txt
pip3.11 freeze | grep -v "pyobjc" > ~/data/requirements.txt
```