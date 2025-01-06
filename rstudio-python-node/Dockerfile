FROM rocker/tidyverse:latest

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        software-properties-common \
        libglpk-dev \
        libprotobuf-dev \
        protobuf-compiler \
        libjq-dev \
        git \
        libudunits2-dev \
        bash-completion \
        libharfbuzz-dev \
        libfribidi-dev \
        curl \
        make \
        cmake \
        htop \
        libcurl4-openssl-dev \
        libicu-dev \
        libssl-dev \
        libsasl2-dev \
        libv8-dev \
        libxml2-dev \
        tcl \
        tk \
        pandoc \
        zlib1g-dev \
        openjdk-17-jdk \
        libfontconfig1-dev \
        gdal-bin \
        libgdal-dev \
        libpango1.0-dev \
        pkg-config \
        xz-utils \
        wget \
        build-essential \
        libbz2-dev \
        libreadline-dev \
        libsqlite3-dev \
        libffi-dev \
        liblzma-dev \
        uuid-dev && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Define Python version
ENV PYTHON_VERSION=3.11.11

# Install Python 3.11 from source
RUN wget https://www.python.org/ftp/python/${PYTHON_VERSION}/Python-${PYTHON_VERSION}.tgz && \
    tar -xvf Python-${PYTHON_VERSION}.tgz && \
    cd Python-${PYTHON_VERSION} && \
    ./configure --enable-optimizations --enable-shared && \
    make -j$(nproc) && \
    make altinstall && \
    ldconfig && \
    cd .. && \
    rm -rf Python-${PYTHON_VERSION} Python-${PYTHON_VERSION}.tgz

# Setup Python virtual environment, Node.js, and R packages
WORKDIR /home
COPY requirements.txt r_packages.R .
RUN python3.11 -m venv env && \
    . /home/env/bin/activate && \
    /home/env/bin/pip install --no-cache-dir -r requirements.txt && \
    curl -sL https://nodejs.org/dist/v22.11.0/node-v22.11.0-linux-x64.tar.xz -o node.tar.xz && \
    xz -d node.tar.xz && \
    tar -xf node.tar -C /usr/local --strip-components=1 && \
    rm node.tar && \
    npm install -g playwright axios cheerio && \
    npx playwright install-deps && \
    npx playwright install && \
    R CMD javareconf && \
    Rscript r_packages.R && \
    R -e 'devtools::install_github("risktoollib/RTL")' && \
    R -e 'install.packages(c("mongolite", "snowflakes"), dependencies = TRUE)'

# Set environment variables for database connection configuration, user information, and other settings
ENV CFLAGS="-I/usr/include/sasl" \
    LDFLAGS="-L/usr/lib" \
    USER=rstudio \
    PASSWORD=rstudio \
    ROOT=true

# Configure RStudio and TinyTeX
RUN echo "rstudio:rstudio" | chpasswd && \
    chown rstudio:rstudio /home/rstudio && \
    echo "rstudio ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers && \
    echo "copilot-enabled=1" >> /etc/rstudio/rsession.conf && \
    chmod -R 777 /home && \
    quarto install tinytex

WORKDIR /home/rstudio
EXPOSE 8787
CMD ["/init"]
