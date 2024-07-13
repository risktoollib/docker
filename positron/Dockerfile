# Use the official Node.js LTS image as the base image
FROM node:lts

# Install dependencies for VS Code remote development, Python, and downloading the .deb package
RUN apt-get update && apt-get install -y \
    sudo \
    git \
    ssh \
    wget \
    && apt-get install -y --no-install-recommends \
    libglpk-dev \
    libprotobuf-dev \
    protobuf-compiler \
    libjq-dev \
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
    python3.11 \
    python3.11-dev \
    python3.11-venv \
    python3-pip \
    pkg-config \
    xz-utils \
    && apt-get clean

# Download and install Positron
RUN wget https://github.com/posit-dev/positron/releases/download/2024.07.0-41/Positron-2024.07.0-41.deb -O /tmp/positron.deb \
    && sudo dpkg -i /tmp/positron.deb \
    && sudo apt-get install -f \
    && rm /tmp/positron.deb

# Create a non-root user and set permissions
ARG USERNAME=positron
ARG USER_UID=1000
ARG USER_GID=$USER_UID

RUN groupadd --gid $USER_GID $USERNAME \
    && useradd --uid $USER_UID --gid $USER_GID -m $USERNAME \
    && usermod -aG sudo $USERNAME \
    && echo "$USERNAME ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/$USERNAME \
    && chmod 0440 /etc/sudoers.d/$USERNAME

# Switch to the non-root user
USER $USERNAME

# Set up the working directory
WORKDIR /home

# Copy requirements and R script files into the working directory
COPY requirements.txt r_packages.R .

# Set up Python environment, install dependencies, and run additional setup commands
RUN python3.11 -m venv env \
    && ./env/bin/pip install --no-cache-dir -r requirements.txt \
    && npm install -g playwright axios cheerio \
    && npx playwright install-deps \
    && npx playwright install \
    && R CMD javareconf \
    && Rscript r_packages.R \
    && R -e 'devtools::install_github("risktoollib/RTL")' \
    && R -e 'install.packages(c("mongolite", "snowflakes", "RQuantLib"), dependencies = TRUE)'

# Set up the working directory for the application
WORKDIR /home/$USERNAME/app

# Copy project files into the working directory
COPY . /home/$USERNAME/app

# Install project dependencies
RUN npm install

# Expose the application port
EXPOSE 3000

# Start the application
CMD ["npm", "start"]