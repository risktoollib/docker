# Base: R + RStudio (Ubuntu 22.04 jammy)
FROM rocker/rstudio:jammy

LABEL org.opencontainers.image.source="https://github.com/your/repo"
LABEL org.opencontainers.image.description="RStudio + Python 3.12 (shared lib) + Node + Quarto"
LABEL org.opencontainers.image.licenses="MIT"

# ----- Build args -----
ARG DEBIAN_FRONTEND=noninteractive
ARG PYTHON_VERSION=3.12.11
ARG PY_PREFIX=/opt/python/${PYTHON_VERSION}

# ----- System deps -----
RUN set -eux; \
    apt-get update; \
    apt-get install -y --no-install-recommends \
      build-essential \
      curl wget ca-certificates gnupg \
      xz-utils \
      libssl-dev zlib1g-dev \
      libbz2-dev libreadline-dev libsqlite3-dev \
      libffi-dev liblzma-dev tk-dev \
      libgdbm-dev libnss3-dev uuid-dev \
      libncurses5-dev libncursesw5-dev \
      libxml2-dev libxslt1-dev \
      libsasl2-dev \
      sudo \
      libcurl4-openssl-dev \
      software-properties-common; \
    rm -rf /var/lib/apt/lists/*

# ----- Node.js LTS -----
RUN set -eux; \
    curl -fsSL https://deb.nodesource.com/setup_lts.x | bash -; \
    apt-get update; \
    apt-get install -y --no-install-recommends nodejs; \
    rm -rf /var/lib/apt/lists/*; \
    node --version; npm --version

# ----- Build & install CPython -----
RUN set -eux; \
    mkdir -p /tmp/src && cd /tmp/src; \
    curl -fsSLO "https://www.python.org/ftp/python/${PYTHON_VERSION}/Python-${PYTHON_VERSION}.tgz"; \
    tar -xzf "Python-${PYTHON_VERSION}.tgz"; \
    cd "Python-${PYTHON_VERSION}"; \
    ./configure \
      --prefix="${PY_PREFIX}" \
      --enable-shared \
      --enable-optimizations \
      --with-lto; \
    make -j"$(nproc)"; \
    make install; \
    echo "${PY_PREFIX}/lib" > "/etc/ld.so.conf.d/python${PYTHON_VERSION%.*}.conf"; \
    ldconfig; \
    ln -sf "${PY_PREFIX}/bin/python3" /usr/local/bin/python3.12; \
    "${PY_PREFIX}/bin/python3" -m ensurepip --upgrade; \
    "${PY_PREFIX}/bin/python3" -m pip install --upgrade pip setuptools wheel; \
    cd /; \
    rm -rf /tmp/src

# ----- Quarto -----
RUN set -eux; \
    curl -fsSL -o /tmp/quarto.deb https://quarto.org/download/latest/quarto-linux-amd64.deb || true; \
    if [ -s /tmp/quarto.deb ]; then \
      apt-get update && apt-get install -y --no-install-recommends /tmp/quarto.deb && rm -f /tmp/quarto.deb && rm -rf /var/lib/apt/lists/*; \
      quarto --version || true; \
      quarto install tinytex || true; \
    fi

# ----- Python & R interoperability -----
RUN set -eux; \
    "${PY_PREFIX}/bin/pip" install --no-cache-dir \
      numpy pandas scipy matplotlib jupyter jupyterlab \
      rpy2

# ----- Environment configuration -----
ENV PATH="${PY_PREFIX}/bin:${PATH}" \
    PYTHONUNBUFFERED=1 \
    PIP_NO_CACHE_DIR=1 \
    CFLAGS="-I/usr/include/sasl" \
    LDFLAGS="-L/usr/lib" \
    USER=rstudio

# RStudio Server port
EXPOSE 8787

# ----- User setup -----
# Runtime environment variables (not baked in):
#   -e PASSWORD=...   (RStudio password)
#   -e ROOT=true      (optional, root access)
RUN set -eux; \
    id rstudio >/dev/null 2>&1 || useradd -m -s /bin/bash rstudio; \
    echo "rstudio:rstudio" | chpasswd; \
    chown -R rstudio:rstudio /home/rstudio; \
    echo "rstudio ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers; \
    mkdir -p /etc/rstudio; \
    printf "copilot-enabled=1\n" >> /etc/rstudio/rsession.conf; \
    chmod -R 777 /home

USER rstudio
WORKDIR /home/rstudio

CMD ["/bin/bash", "-lc", "echo 'R:' $(R --version | head -n1); echo 'Python:' $(python3.12 --version); echo 'Pip:' $(pip --version); echo 'Node:' $(node --version); echo 'npm:' $(npm --version); echo 'Quarto:' $(quarto --version 2>/dev/null || echo 'not installed'); echo 'Ready. Start RStudio Server with the base image entrypoint.' ]
