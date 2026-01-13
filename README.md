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
python3.12 -m venv ~/env
source ~/env/bin/activate
pip3.12 install ipython requests pandas pandas-datareader numpy polars plotly plotnine pyarrow scipy yfinance streamlit manim setuptools playwright beautifulsoup4 lxml html5lib openpyxl QuantLib
pip3.12 install git+https://github.com/bbcho/risktools-dev.git
python -m playwright install chromium
pip3.12 freeze | grep -v "pyobjc" > ~/docker/rstudio-python-node/requirements.txt
pip3.12 freeze | grep -v "pyobjc" > ~/docker/vscode-python-node/requirements.txt
pip3.12 freeze | grep -v "pyobjc" > ~/data/requirements.txt
```

With `uv` MacOS or Linux

``` bash
# python3.12 -m venv ~/env
uv venv ~/env --python 3.12
source ~/env/bin/activate
pip install uv
uv pip install ipython requests pandas pandas-datareader numpy polars plotly plotnine pyarrow scipy yfinance streamlit manim setuptools playwright beautifulsoup4 lxml html5lib openpyxl geopandas nbformat folium QuantLib
uv pip install git+https://github.com/bbcho/risktools-dev.git
python -m playwright install chromium
uv pip freeze --exclude-editable > ~/docker/rstudio-python-node/requirements.txt
```

With `uv` on Windows - use Power Shell 7.

``
# Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass # (one-time) If activation is blocked in this PowerShell window:
py -3.12 -m venv env
.\env\Scripts\Activate.ps1
python -m pip install --upgrade pip
python -m pip install -U uv
uv pip install ipython requests pandas pandas-datareader numpy polars plotly plotnine pyarrow scipy yfinance streamlit manim setuptools playwright beautifulsoup4 lxml html5lib openpyxl
uv pip install git+https://github.com/bbcho/risktools-dev.git
python -m playwright install chromium
``
