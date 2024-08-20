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
pip3 install scipy pandas numpy plotly pyarrow pandas-datareader yfinance kaleido plotnine streamlit
pip3 install git+https://github.com/bbcho/risktools-dev.git
pip3 freeze > ~/docker/rstudio-python-node/requirements.txt
pip3 freeze > ~/docker/vscode-python-node/requirements.txt
```