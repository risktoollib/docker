FROM rocker/tidyverse:latest

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        software-properties-common && \
    add-apt-repository ppa:deadsnakes/ppa && \
    apt-get update && \
    apt-get install -y --no-install-recommends \
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
        python3.11 \
        python3.11-dev \
        python3.11-venv \
        python3-pip \
        pkg-config \
        xz-utils && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Setup python + virtual environment + node + r pacakages
WORKDIR /home
COPY requirements.txt r_packages.R .
RUN python3.11 -m venv env\
    && . /home/env/bin/activate \
    && /home/env/bin/pip3.11 install --no-cache-dir -r requirements.txt \
    && curl -sL https://nodejs.org/dist/v22.11.0/node-v22.11.0-linux-x64.tar.xz -o node.tar.xz \
    && xz -d node.tar.xz \
    && tar -xf node.tar -C /usr/local --strip-components=1 \
    && rm node.tar \
    && npm install -g playwright axios cheerio \
    && npx playwright install-deps \
    && npx playwright install \
    && R CMD javareconf && \
    Rscript r_packages.R && \
    R -e 'devtools::install_github("risktoollib/RTL")' && \
    R -e 'install.packages(c("mongolite", "snowflakes"), dependencies = TRUE)'

# Set environment variables for database connection configuration, user information, and other settings
ENV CFLAGS="-I/usr/include/sasl" \
    LDFLAGS="-L/usr/lib" \
    USER=rstudio \
    PASSWORD=rstudio \
    ROOT=true

# Existing RUN command with modifications for user setup and environment configuration
RUN echo "rstudio:rstudio" | chpasswd && \
    chown rstudio:rstudio /home/rstudio && \
    echo "rstudio ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers && \
    echo "copilot-enabled=1" >> /etc/rstudio/rsession.conf && \
    chmod -R 777 /home && \ 
    quarto install tinytex

WORKDIR /home/rstudio
EXPOSE 8787
CMD ["/init"]
