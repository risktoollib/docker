# Base image with R, tidyverse, RStudio Server, s6 /init
FROM rocker/tidyverse:latest

ENV DEBIAN_FRONTEND=noninteractive
ARG PYTHON_VERSION=3.12.11
ENV PYTHON_VERSION=${PYTHON_VERSION}
ENV PY_PREFIX=/opt/python/${PYTHON_VERSION}

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

# ---- Build Python 3.12 (shared) ----
WORKDIR /tmp
RUN set -eux; \
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
  ln -sf "${PY_PREFIX}/bin/python3" /usr/local/bin/python3.12 && \
  "${PY_PREFIX}/bin/python3" -m ensurepip && \
  "${PY_PREFIX}/bin/python3" -m pip install --upgrade pip setuptools wheel && \
  cd /tmp && rm -rf "Python-${PYTHON_VERSION}" "Python-${PYTHON_VERSION}.tgz"

# Make libpython discoverable at runtime
ENV LD_LIBRARY_PATH="${PY_PREFIX}/lib:${LD_LIBRARY_PATH}"
ENV PATH="/opt/pyenv/bin:${PATH}"

# App workspace
WORKDIR /home
COPY r_packages.R ./

RUN python3.12 -m venv env \
&& source ./env/bin/activate \
&& pip install uv \
&& uv pip install ipython requests pandas pandas-datareader numpy polars plotly plotnine pyarrow scipy yfinance streamlit manim setuptools playwright beautifulsoup4 lxml html5lib openpyxl \
&& uv pip install git+https://github.com/bbcho/risktools-dev.git \
&& python -m playwright install chromium

# Node / Playwright
RUN curl -fsSL https://deb.nodesource.com/setup_lts.x | bash - \
 && apt-get update && apt-get install -y --no-install-recommends nodejs \
 && npm install -g playwright axios cheerio \
 && npx playwright install-deps \
 && npx playwright install \
 && rm -rf /var/lib/apt/lists/*

# R: Java config + packages
RUN R CMD javareconf

# Make sure devtools exists before install_github(); avoid failing on missing "snowflakes"
RUN R -q -e 'if (!requireNamespace("devtools", quietly=TRUE)) install.packages("devtools", repos="https://cloud.r-project.org")' \
 && R -q -e 'source("r_packages.R")' \
 && R -q -e 'devtools::install_github("risktoollib/RTL", upgrade="never")' \
 && R -q -e 'pkgs <- c("mongolite"); install.packages(pkgs[!pkgs %in% rownames(installed.packages())], repos="https://cloud.r-project.org")' \
 || true
# ^ `|| true` keeps the build going if a GitHub or CRAN hiccup occurs. Remove if you prefer hard-fail.

# Quarto/TinyTeX: only run if quarto is present; otherwise fall back to R tinytex
RUN if command -v quarto >/dev/null 2>&1; then \
      quarto install tinytex; \
    else \
      R -q -e 'if (!requireNamespace("tinytex", quietly=TRUE)) install.packages("tinytex", repos="https://cloud.r-project.org"); tinytex::install_tinytex()'; \
    fi

# Rocker / RStudio defaults
ENV USER=rstudio PASSWORD=rstudio ROOT=true

# Permissions + quality-of-life
RUN echo "rstudio:rstudio" | chpasswd \
 && chown -R rstudio:rstudio /home/rstudio || true \
 && echo "rstudio ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers \
 && echo "copilot-enabled=1" >> /etc/rstudio/rsession.conf

WORKDIR /home/rstudio
EXPOSE 8787
CMD ["/init"]
