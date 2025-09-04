# Base image from rocker/tidyverse
FROM rocker/tidyverse:latest

# Set environment variables for non-interactive installation
ENV DEBIAN_FRONTEND=noninteractive
ENV PYTHON_VERSION=3.12.11
ENV PY_PREFIX=/opt/python/${PYTHON_VERSION}

# Install required system packages
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        build-essential \
        curl \
        wget \
        libssl-dev \
        libffi-dev \
        zlib1g-dev \
        libbz2-dev \
        libreadline-dev \
        libsqlite3-dev \
        libncurses5-dev \
        libncursesw5-dev \
        libgdbm-dev \
        liblzma-dev \
        libnss3-dev \
        tk-dev \
        uuid-dev \
        xz-utils \
        openjdk-17-jdk \
        pkg-config \
        libpango1.0-dev \
        libcairo2-dev \
        && apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Set JAVA_HOME for Java installation
ENV JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
ENV PATH=$JAVA_HOME/bin:$PATH

# Build Python 3.12 from source with --enable-shared
WORKDIR /tmp
# Build from source with shared library
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
    ldconfig && \
    ln -sf "${PY_PREFIX}/bin/python3" /usr/local/bin/python3.12 && \
    "${PY_PREFIX}/bin/python3" -m ensurepip && \
    "${PY_PREFIX}/bin/python3" -m pip install --upgrade pip setuptools wheel && \
    cd /tmp && rm -rf "Python-${PYTHON_VERSION}" "Python-${PYTHON_VERSION}.tgz"

# Ensure the runtime can find libpython3.12.so
ENV LD_LIBRARY_PATH="${PY_PREFIX}/lib:${LD_LIBRARY_PATH}"

# Create your global toolbox environment at /env and install uv + audit tool
RUN "${PY_PREFIX}/bin/python3" -m venv /env \
 && /env/bin/python -m pip install --upgrade pip \
 && /env/bin/pip install uv pip-audit

ENV PATH="/env/bin:${PATH}"
RUN chown -R rstudio:rstudio /env

# Set up Python virtual environment using uv
WORKDIR /home
COPY requirements.txt r_packages.R .
RUN python3 -m pip install --upgrade pip setuptools wheel \
 && python3 -m pip install uv pip-audit
RUN python3 -m venv env \
 && . /home/env/bin/activate \
 && uv pip install --upgrade pip setuptools wheel \
 && uv pip install -r requirements.txt
ENV PATH="/home/env/bin:${PATH}"
RUN chown -R rstudio:rstudio /home/env


# Install Node.js and npm
RUN curl -fsSL https://deb.nodesource.com/setup_lts.x | bash - && \
    apt-get install -y --no-install-recommends nodejs && \
    npm install -g playwright axios cheerio && \
    npx playwright install-deps && \
    npx playwright install

# Configure R environment and install packages
RUN R CMD javareconf && \
    Rscript r_packages.R && \
    R -e 'devtools::install_github("risktoollib/RTL")' && \
    R -e 'install.packages(c("mongolite", "snowflakes"), dependencies = TRUE)'

# Configure environment variables
ENV CFLAGS="-I/usr/include/sasl" \
    LDFLAGS="-L/usr/lib" \
    USER=rstudio \
    PASSWORD=rstudio \
    ROOT=true

# User setup and permissions
RUN echo "rstudio:rstudio" | chpasswd && \
    chown rstudio:rstudio /home/rstudio && \
    echo "rstudio ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers && \
    echo "copilot-enabled=1" >> /etc/rstudio/rsession.conf && \
    chmod -R 777 /home && \
    quarto install tinytex

# Final settings
WORKDIR /home/rstudio
EXPOSE 8787
CMD ["/init"]
