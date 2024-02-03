FROM rocker/tidyverse:latest

# Set noninteractive frontend for automated installs
RUN echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections

# Install system dependencies and clean up in the same step
RUN apt-get update && apt-get install -y \
    libjq-dev libprotobuf-dev protobuf-compiler git libudunits2-dev bash-completion libharfbuzz-dev libfribidi-dev curl wget make cmake htop \
    libcurl4-openssl-dev libicu-dev libssl-dev libsasl2-dev libv8-dev libxml2-dev tcl tk pandoc \
    zlib1g-dev openjdk-17-jdk libfontconfig1-dev gdal-bin libgdal-dev python3.11 python3.11-dev libncurses5-dev libreadline-dev \
    jags libavfilter-dev librsvg2-dev poppler-utils cargo libmagick++-dev libpoppler-cpp-dev libtesseract-dev libleptonica-dev tesseract-ocr-eng \
    python3.11-venv python3-pip libglpk-dev && rm -rf /var/lib/apt/lists/*

# Setup Python virtual environment
WORKDIR /home
COPY requirements.txt .
RUN python3.11 -m venv env && ./env/bin/pip3 install --no-cache-dir -r requirements.txt
ENV PATH="/home/env/bin:$PATH"

# Install Node.js and npm packages
RUN curl -sL https://nodejs.org/dist/latest-v20.x/node-v20.11.0-linux-x64.tar.xz -o node.tar.xz \
    && tar -xJf node.tar.xz -C /usr/local --strip-components=1 \
    && rm node.tar.xz \
    && npm install -g playwright axios cheerio \
    && npx playwright install-deps \
    && npx playwright install

# R configuration and package installation
COPY r_packages.R /tmp/r_packages.R
RUN R CMD javareconf && \
    mkdir -p /usr/local/lib/R/etc/ /usr/lib/R/etc/ && \
    R CMD javareconf && \
    echo "options(repos = c(CRAN = 'https://packagemanager.rstudio.com/cran/latest'), download.file.method = 'libcurl', Ncpus = 8)" \
    | tee /usr/local/lib/R/etc/Rprofile.site | tee /usr/lib/R/etc/Rprofile.site && \
    Rscript /tmp/r_packages.R && \
    R -e 'devtools::install_github("risktoollib/RTL")' && \
    R -e 'install.packages(c("mongolite","snowflakes","QuantLib"), dependencies = TRUE)'

# Database connection configuration
RUN pkg-config --cflags --libs libsasl2 
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
