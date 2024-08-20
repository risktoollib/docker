FROM rocker/tidyverse:latest

# System dependencies
RUN echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections && \
    apt-get update && apt-get install -y \
    git libudunits2-dev bash-completion libharfbuzz-dev libfribidi-dev curl wget make cmake htop \
    libcurl4-openssl-dev libicu-dev libssl-dev libsasl2-dev libv8-dev libxml2-dev tcl tk pandoc \
    zlib1g-dev openjdk-17-jdk libfontconfig1-dev gdal-bin libgdal-dev libhiredis-dev \
    firefox gnupg2 software-properties-common libfontconfig1 libxrender1 libxtst6 libxi6 \
    jags libavfilter-dev librsvg2-dev poppler-utils cargo libmagick++-dev libpoppler-cpp-dev libtesseract-dev libleptonica-dev tesseract-ocr-eng \
    xz-utils python3.11 python3.11-dev python3.11-venv python3-pip libglpk-dev tar \
    && rm -rf /var/lib/apt/lists/*

# Setup Python environment
WORKDIR /home
COPY requirements.txt .
RUN python3.11 -m venv env && ./env/bin/pip3 install --no-cache-dir -r requirements.txt
ENV PATH="/home/env/bin:$PATH"

# Install Node.js and npm packages
RUN curl -sL https://nodejs.org/dist/v20.16.0/node-v20.16.0-linux-x64.tar.xz -o node.tar.xz \
    && xz -d node.tar.xz \
    && tar -xf node.tar -C /usr/local --strip-components=1 \
    && rm node.tar \
    && npm install -g playwright axios cheerio \
    && npx playwright install-deps \
    && npx playwright install

# R setup and package installation
COPY r_packages.R /tmp/r_packages.R
RUN R CMD javareconf && \
    mkdir -p /usr/local/lib/R/etc/ /usr/lib/R/etc/ && \
    echo "options(repos = c(CRAN = 'https://packagemanager.rstudio.com/cran/latest'), download.file.method = 'libcurl', Ncpus = 8)" \
    | tee /usr/local/lib/R/etc/Rprofile.site | tee /usr/lib/R/etc/Rprofile.site && \
    Rscript /tmp/r_packages.R && \
    R -e 'devtools::install_github("risktoollib/RTL")' && \
    R -e 'install.packages(c("mongolite","snowflakes","RQuantLib"), dependencies = TRUE)'

# Database connection configuration
RUN pkg-config --cflags --libs libsasl2 
ENV CFLAGS="-I/usr/include/sasl" \
    LDFLAGS="-L/usr/lib"

RUN R -e 'install.packages(c("mongolite","snowflake"), dependencies = TRUE)'


# Install code-server (VS Code in the browser)
RUN curl -fsSL https://code-server.dev/install.sh | sh

# Expose the code-server port
EXPOSE 8080

# Set the startup command to launch code-server
CMD ["code-server", "--bind-addr", "0.0.0.0:8080", "--auth", "none"]
