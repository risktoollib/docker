# syntax=docker/dockerfile:1
# Base image with R, tidyverse, RStudio Server, s6 /init
FROM rocker/tidyverse:latest

ENV DEBIAN_FRONTEND=noninteractive

# System deps for building Python + common R/Python builds
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential curl wget ca-certificates \
    libssl-dev libffi-dev zlib1g-dev libbz2-dev libreadline-dev libsqlite3-dev \
    libncurses5-dev libncursesw5-dev libgdbm-dev liblzma-dev libnss3-dev tk-dev uuid-dev xz-utils \
    pkg-config libpango1.0-dev libcairo2-dev \
    openjdk-17-jdk \
    && rm -rf /var/lib/apt/lists/*

# Java
ENV JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
ENV PATH=$JAVA_HOME/bin:$PATH

# ---- Build Python 3.12 (shared) - auto-detects latest 3.12.x patch ----
WORKDIR /tmp
RUN set -eux; \
  PYTHON_VERSION=$(curl -fsSL https://www.python.org/ftp/python/ | \
    grep -oP '3\.12\.[0-9]+/' | \
    sed 's/\///' | \
    sort -V | \
    tail -1) && \
  PY_PREFIX=/opt/python/${PYTHON_VERSION} && \
  echo "Building Python ${PYTHON_VERSION}" && \
  curl -fsSLO "https://www.python.org/ftp/python/${PYTHON_VERSION}/Python-${PYTHON_VERSION}.tgz" && \
  tar -xzf "Python-${PYTHON_VERSION}.tgz" && \
  cd "Python-${PYTHON_VERSION}" && \
  ./configure \
    --prefix="${PY_PREFIX}" \
    --enable-shared \
    --enable-optimizations \
    --with-lto && \
  make -j"$(nproc)" && make install && \
  echo "${PY_PREFIX}/lib" > /etc/ld.so.conf.d/python${PYTHON_VERSION}.conf && ldconfig && \
  ln -sf "${PY_PREFIX}/bin/python3" /usr/local/bin/python3 && \
  ln -sf "${PY_PREFIX}/bin/pip3" /usr/local/bin/pip3 && \
  "${PY_PREFIX}/bin/python3" -m ensurepip && \
  "${PY_PREFIX}/bin/python3" -m pip install --upgrade pip setuptools wheel && \
  echo "PYTHON_VERSION=${PYTHON_VERSION}" > /etc/python_version && \
  echo "PY_PREFIX=${PY_PREFIX}" >> /etc/python_version && \
  cd /tmp && rm -rf "Python-${PYTHON_VERSION}" "Python-${PYTHON_VERSION}.tgz"

# Make libpython discoverable at runtime
RUN . /etc/python_version && \
    echo "LD_LIBRARY_PATH=${PY_PREFIX}/lib:\${LD_LIBRARY_PATH}" >> /etc/environment && \
    echo "PATH=${PY_PREFIX}/bin:\${PATH}" >> /etc/environment

ENV PATH="/usr/local/bin:${PATH}"

# App workspace
WORKDIR /home/rstudio
COPY r_packages.R ./

# Create Python virtual environment and install packages with uv
RUN --mount=type=cache,target=/root/.cache/uv \
    . /etc/python_version && \
    ${PY_PREFIX}/bin/python3 -m venv env && \
    . ./env/bin/activate && \
    pip install uv && \
    uv pip install ipython requests pandas pandas-datareader numpy polars plotly plotnine pyarrow scipy yfinance streamlit manim setuptools playwright beautifulsoup4 lxml html5lib openpyxl && \
    (uv pip install --no-deps git+https://github.com/bbcho/risktools-dev.git || echo "Skipping risktools due to macOS dependencies") && \
    python -m playwright install chromium

# Node / Playwright
ENV NODE_VERSION=20
RUN curl -fsSL https://deb.nodesource.com/setup_${NODE_VERSION}.x | bash - && \
    apt-get install -y --no-install-recommends nodejs && \
    npm install -g playwright axios cheerio && \
    npx playwright install-deps && \
    npx playwright install && \
    rm -rf /var/lib/apt/lists/*

# R: Java config + packages
RUN R CMD javareconf

# Configure reticulate to use our venv BEFORE installing packages
ENV RETICULATE_PYTHON=/home/rstudio/env/bin/python
ENV RETICULATE_PYTHON_ENV=/home/rstudio/env

# Make sure devtools exists before install_github(); avoid failing on missing "snowflakes"
RUN R -q -e 'options(Ncpus=parallel::detectCores()); if (!requireNamespace("devtools", quietly=TRUE)) install.packages("devtools", repos="https://cloud.r-project.org")' && \
    R -q -e 'options(Ncpus=parallel::detectCores()); source("r_packages.R")' && \
    R -q -e 'devtools::install_github("risktoollib/RTL", upgrade="never")' && \
    R -q -e 'options(Ncpus=parallel::detectCores()); pkgs <- c("mongolite"); install.packages(pkgs[!pkgs %in% rownames(installed.packages())], repos="https://cloud.r-project.org")' && \
    rm -f /usr/local/lib/R/site-library/00LOCK* \
    || true
# ^ `|| true` keeps the build going if a GitHub or CRAN hiccup occurs. Remove if you prefer hard-fail.

# Quarto/TinyTeX: only run if quarto is present; otherwise fall back to R tinytex
RUN if command -v quarto >/dev/null 2>&1; then \
      quarto install tinytex; \
    else \
      R -q -e 'if (!requireNamespace("tinytex", quietly=TRUE)) install.packages("tinytex", repos="https://cloud.r-project.org"); tinytex::install_tinytex()'; \
    fi

# Final cleanup: purge build dependencies after all compilations are complete
RUN apt-get purge -y build-essential && \
    apt-get autoremove -y && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Rocker / RStudio defaults - hardcoded password
ENV USER=rstudio ROOT=true
ENV PASSWORD=rstudio

# Permissions + quality-of-life
RUN echo "rstudio:${PASSWORD}" | chpasswd && \
    chown -R rstudio:rstudio /home/rstudio || true && \
    echo "rstudio ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers && \
    echo "copilot-enabled=1" >> /etc/rstudio/rsession.conf && \
    rm -f /usr/local/lib/R/site-library/00LOCK* /home/rstudio/R/*/00LOCK* || true

WORKDIR /home/rstudio
EXPOSE 8787
CMD ["/init"]