# Use the official Node.js LTS image as the base image
FROM node:lts

# Install dependencies for VS Code remote development, Python, Quarto, and downloading the .deb package
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
    libatk-bridge2.0-0 \
    libatspi2.0-0 \
    libgbm1 \
    libgtk-3-0 \
    libgtk-4-1 \
    libxkbfile1 \
    libxkbcommon0 \
    xdg-utils \
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
    software-properties-common \
    dirmngr \
    && apt-get clean

# Update indices and add CRAN signing key and repository for R 4.0
RUN apt-get update -qq \
    && wget -qO- https://cloud.r-project.org/bin/linux/ubuntu/marutter_pubkey.asc | sudo tee -a /etc/apt/trusted.gpg.d/cran_ubuntu_key.asc \
    && sudo add-apt-repository "deb https://cloud.r-project.org/bin/linux/ubuntu $(lsb_release -cs)-cran40/" \
    && sudo apt update -qq \
    && sudo apt install --no-install-recommends r-base -y

# Download and install Positron
RUN wget https://github.com/posit-dev/positron/releases/download/2024.07.0-41/Positron-2024.07.0-41.deb -O /tmp/positron.deb \
    && sudo dpkg -i /tmp/positron.deb \
    && sudo apt-get install -f \
    && rm /tmp/positron.deb

# Install Quarto
RUN wget https://github.com/quarto-dev/quarto-cli/releases/download/v1.3.361/quarto-1.3.361-linux-amd64.deb -O /tmp/quarto.deb \
    && sudo dpkg -i /tmp/quarto.deb \
    && sudo apt-get install -f \
    && rm /tmp/quarto.deb

# Run R CMD javareconf as root to avoid permission issues
RUN sudo R CMD javareconf

# Create a non-root user with sudo privileges and set password
ARG USERNAME=positron
ARG USER_UID=1000
ARG USER_GID=$USER_UID

RUN if getent passwd $USER_UID > /dev/null; then \
        USER_UID=$(($USER_UID + 1)); \
    fi \
    && if ! getent group $USER_GID; then \
        groupadd --gid $USER_GID $USERNAME; \
    fi \
    && useradd --uid $USER_UID --gid $USER_GID -m $USERNAME \
    && echo "$USERNAME:$USERNAME" | chpasswd \
    && usermod -aG sudo $USERNAME \
    && echo "$USERNAME ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/$USERNAME \
    && chmod 0440 /etc/sudoers.d/$USERNAME

# Switch to the non-root user
USER $USERNAME

# Set up the working directory
WORKDIR /home/$USERNAME

# Copy requirements and R script files into the working directory
COPY requirements.txt r_packages.R .

# Set up Python environment, install dependencies, and run additional setup commands
RUN python3.11 -m venv env \
    && ./env/bin/pip install --no-cache-dir -r requirements.txt \
    && npx playwright install-deps \
    && npx playwright install \
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
