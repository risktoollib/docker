# Base image for Ubuntu 24.04
# FROM ubuntu:24.04
FROM mcr.microsoft.com/vscode/devcontainers/base:ubuntu

# build command - where GH_TOKEN is a personal access token with read:packages scope
# saved to your environment variables
# docker build -t bbcho/base:0.0.2a ./base --build-arg GH_TOKEN=$GH_TOKEN

ARG GH_TOKEN

# Clear the APT cache before running apt commands
RUN apt-get clean && rm -rf /var/lib/apt/lists/* && \
    apt-get update -qq && apt-get upgrade -y

# Set environment variables to prevent prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive
ENV PYTHON_VERSION=3.11
ENV R_VERSION=4.4.2
ENV EMAIL=ben.cho@gmail.com
ENV FULLNAME="Ben Cho"

# Install system dependencies
RUN apt-get install -y --no-install-recommends \
    software-properties-common \
    unixodbc-dev \
    dirmngr \
    gnupg \
    curl \
    wget \
    build-essential \
    libssl-dev \
    libcurl4-gnutls-dev \
    libxml2-dev \
    zlib1g-dev \
    libgit2-dev \
    locales \
    ca-certificates \
    xz-utils \
    # needed for tidyverse
    libfontconfig1-dev \
    libharfbuzz-dev \
    libfribidi-dev \
    libfreetype6-dev \
    libpng-dev \
    libtiff5-dev \
    libjpeg-dev \
    && locale-gen en_US.UTF-8 && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Add deadsnakes PPA for Python
RUN add-apt-repository ppa:deadsnakes/ppa && apt-get update -qq

# Install Python
RUN apt-get install -y python${PYTHON_VERSION} python${PYTHON_VERSION}-dev

# Add the signing key for R (by Michael Rutter)
RUN wget -qO- https://cloud.r-project.org/bin/linux/ubuntu/marutter_pubkey.asc | tee /etc/apt/trusted.gpg.d/cran_ubuntu_key.asc

# Add the R repository
RUN add-apt-repository "deb https://cloud.r-project.org/bin/linux/ubuntu $(lsb_release -cs)-cran40/"

# Install R
RUN apt-get update -qq && apt-get install -y r-base=${R_VERSION}-* r-base-dev=${R_VERSION}-*


# Install pip using get-pip.py to avoid system conflicts
RUN wget https://bootstrap.pypa.io/get-pip.py && \
    python${PYTHON_VERSION} get-pip.py && \
    rm get-pip.py


# Install the latest Git
RUN add-apt-repository ppa:git-core/ppa && apt-get update -qq && \
    apt-get install -y git && \
    git --version

# Install Quarto CLI
RUN wget -O quarto.deb https://quarto.org/download/latest/quarto-linux-amd64.deb && \
    dpkg -i quarto.deb && rm quarto.deb

# Install the latest Neovim
RUN wget https://github.com/neovim/neovim/releases/latest/download/nvim-linux64.tar.gz && \
    tar xzvf nvim-linux64.tar.gz && \
    mv nvim-linux64 /opt/neovim && \
    ln -s /opt/neovim/bin/nvim /usr/local/bin/nvim && \
    rm nvim-linux64.tar.gz

# # Clean up
# RUN apt-get clean && rm -rf /var/lib/apt/lists/*

# Install Python packages
RUN pip install pandas plotly ipykernel git+https://$GH_TOKEN@github.com/quantimintelligence/quantimintelligence-dev.git

# Configure R to use the Posit Package Manager for tidyverse installation
RUN echo 'options(repos = c(CRAN = "https://packagemanager.posit.co/cran/latest"))' >> /etc/R/Rprofile.site && \
    R -e "install.packages(c('tidyverse','rmarkdown','renv','RTL','languageserver'))"

RUN pip install radian

RUN git config --global user.email \"$EMAIL\" && \
    git config --global user.name \"$FULLNAME\"

RUN echo "alias python3=python$PYTHON_VERSION" >> /home/vscode/.bash_aliases
RUN echo "alias python=python$PYTHON_VERSION" >> /home/vscode/.bash_aliases

# Set working directory
WORKDIR /workspace

# Default command
CMD ["bash"]

