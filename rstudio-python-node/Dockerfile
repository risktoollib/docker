FROM rocker/tidyverse:latest

# Install system dependencies
RUN apt-get update && \
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
        wget \
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
        python3.11 \
        python3.11-dev \
        python3.11-venv \
        python3-pip \
        pkg-config \
        xz-utils \ 
    && rm -rf /var/lib/apt/lists/*

# Setup Python virtual environment
WORKDIR /home
COPY requirements.txt .
RUN python3.11 -m venv env && \
    ./env/bin/pip3 install --no-cache-dir -r requirements.txt

# Install Node.js and npm packages
RUN curl -sL https://nodejs.org/dist/v20.11.1/node-v20.11.1-linux-x64.tar.xz -o node.tar.xz \
    && xz -d node.tar.xz \
    && tar -xf node.tar -C /usr/local --strip-components=1 \
    && rm node.tar \
    && npm install -g playwright axios cheerio \
    && npx playwright install-deps \
    && npx playwright install

# Install R packages
COPY r_packages.R /tmp/r_packages.R
RUN R CMD javareconf && \
    Rscript /tmp/r_packages.R && \
    R -e 'devtools::install_github("risktoollib/RTL")' && \
    R -e 'install.packages(c("mongolite","snowflakes","QuantLib"), dependencies = TRUE)'

# Database connection configuration
ENV CFLAGS="-I/usr/include/sasl" \
    LDFLAGS="-L/usr/lib"

# Add user for RStudio
# Set environment variables
ENV USER rstudio
ENV PASSWORD rstudio
ENV ROOT true

# Existing RUN command with your modifications
RUN echo "rstudio:rstudio" | chpasswd && \
    chown rstudio:rstudio /home/rstudio && \
    echo "rstudio ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers && \
    echo "copilot-enabled=1" >> /etc/rstudio/rsession.conf && \
    chmod -R 777 /home

WORKDIR /home/rstudio
EXPOSE 8787
CMD ["/init"]
