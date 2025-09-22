FROM rocker/tidyverse:latest

LABEL org.opencontainers.image.description="tidyverse + Python 3.12 (shared lib) + optional Node/Quarto"
LABEL org.opencontainers.image.licenses="MIT"

# -----------------------------
# Build args (match your prior names if you had them)
# -----------------------------
ARG DEBIAN_FRONTEND=noninteractive
ARG PYTHON_VERSION=3.12.11
ARG PY_PREFIX=/opt/python/${PYTHON_VERSION}

# -----------------------------
# System deps (C toolchain + common CPython build libs)
# -----------------------------
RUN set -eux; \
  apt-get update; \
  apt-get install -y --no-install-recommends \
    build-essential \
    curl wget ca-certificates gnupg xz-utils \
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

# -----------------------------
# (Optional) Node.js LTS — keep if you had Node in your image name/repo
# Comment this block if you don’t need Node.
# -----------------------------
RUN set -eux; \
  curl -fsSL https://deb.nodesource.com/setup_lts.x | bash -; \
  apt-get update; \
  apt-get install -y --no-install-recommends nodejs; \
  rm -rf /var/lib/apt/lists/*; \
  node --version; npm --version

# -----------------------------
# Build & install CPython from source WITH a shared library
# *** THIS is the critical fix: register ${PY_PREFIX}/lib with ldconfig BEFORE running python ***
# -----------------------------
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
  # Register the shared lib path (so libpython3.12.so.1.0 is found by the loader)
  echo "${PY_PREFIX}/lib" > "/etc/ld.so.conf.d/python${PYTHON_VERSION%.*}.conf"; \
  ldconfig; \
  # Provide a stable shim in PATH
  ln -sf "${PY_PREFIX}/bin/python3" /usr/local/bin/python3.12; \
  # Safe to invoke python now
  "${PY_PREFIX}/bin/python3" -m ensurepip --upgrade; \
  "${PY_PREFIX}/bin/python3" -m pip install --upgrade pip setuptools wheel; \
  cd /; \
  rm -rf /tmp/src

# -----------------------------
# (Optional) Quarto + TinyTeX — keep if you had it previously
# -----------------------------
RUN set -eux; \
  curl -fsSL -o /tmp/quarto.deb https://quarto.org/download/latest/quarto-linux-amd64.deb || true; \
  if [ -s /tmp/quarto.deb ]; then \
    apt-get update && apt-get install -y --no-install-recommends /tmp/quarto.deb && rm -f /tmp/quarto.deb && rm -rf /var/lib/apt/lists/*; \
    quarto --version || true; \
    quarto install tinytex || true; \
  fi

# -----------------------------
# Python packages you likely expect (adjust to taste)
# -----------------------------
RUN set -eux; \
  "${PY_PREFIX}/bin/pip" install --no-cache-dir \
    numpy pandas scipy matplotlib \
    jupyter jupyterlab

# -----------------------------
# Environment (fixes your previous ENV parsing bug)
# - No trailing "\" on the last line
# - No secrets in ENV
# - LD_LIBRARY_PATH not required because we used ldconfig, but harmless if you really need it.
# -----------------------------
ENV PATH="${PY_PREFIX}/bin:${PATH}" \
    PYTHONUNBUFFERED=1 \
    PIP_NO_CACHE_DIR=1 \
    CFLAGS="-I/usr/include/sasl" \
    LDFLAGS="-L/usr/lib" \
    USER=rstudio

# If you insist on LD_LIBRARY_PATH (not needed), do it safely:
# ENV LD_LIBRARY_PATH="${PY_PREFIX}/lib:${LD_LIBRARY_PATH:-}"

# -----------------------------
# RStudio-related bits (safe whether or not rstudio-server is present)
# - Do NOT bake credentials into the image. Pass at runtime:
#     -e PASSWORD=...   (RStudio password)
#     -e ROOT=true      (optional)
# -----------------------------
RUN set -eux; \
  # Ensure rstudio user exists (it should in many rocker images, but make this idempotent)
  if ! id rstudio >/dev/null 2>&1; then useradd -m -s /bin/bash rstudio; fi; \
  echo "rstudio:rstudio" | chpasswd || true; \
  mkdir -p /home/rstudio; chown -R rstudio:rstudio /home/rstudio; \
  echo "rstudio ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers; \
  mkdir -p /etc/rstudio; \
  printf "copilot-enabled=1\n" >> /etc/rstudio/rsession.conf || true; \
  chmod -R 777 /home

# If your original image exposed RStudio’s port, keep this:
EXPOSE 8787

# Default user & workdir (match what you likely had)
USER rstudio
WORKDIR /home/rstudio

# Quick diagnostics on container start (harmless)
CMD ["/bin/bash", "-lc", "echo 'R:' $(R --version | head -n1); echo 'Python:' $(python3.12 --version); echo 'Pip:' $(pip --version); echo 'Node:' $(node --version 2>/dev/null || echo 'Node not installed'); echo 'npm:' $(npm --version 2>/dev/null || echo 'npm not installed'); echo 'Quarto:' $(quarto --version 2>/dev/null || echo 'Quarto not installed'); echo 'Container ready.' ]
