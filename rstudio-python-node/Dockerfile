# Base image from rocker/tidyverse
FROM rocker/tidyverse:latest

# Install required system packages
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        build-essential \
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
        libpango1.0-dev \
        libcairo2-dev \
        libglib2.0-dev \
        libharfbuzz-dev \
        libfribidi-dev && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Build Python 3.12 from source with --enable-shared
WORKDIR /usr/src
RUN wget https://www.python.org/ftp/python/3.12.0/Python-3.12.0.tgz && \
    tar -xf Python-3.12.0.tgz && \
    cd Python-3.12.0 && \
    ./configure --enable-optimizations --enable-shared && \
    make -j$(nproc) && \
    make altinstall && \
    ldconfig && \
    cd .. && \
    rm -rf Python-3.12.0 Python-3.12.0.tgz

# Avoid creating redundant symbolic links
RUN ln -sf /usr/local/bin/python3.12 /usr/bin/python3.12 && \
    ln -sf /usr/local/bin/pip3.12 /usr/bin/pip3.12

# Set up Python virtual environment
WORKDIR /home
COPY requirements.txt r_packages.R .
RUN /usr/local/bin/python3.12 -m venv env && \
    . /home/env/bin/activate && \
    pip install --no-cache-dir --upgrade pip setuptools wheel && \
    pip install --no-cache-dir -r requirements.txt

# Install Node.js and npm
RUN curl -fsSL https://deb.nodesource.com/setup_18.x | bash - && \
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
