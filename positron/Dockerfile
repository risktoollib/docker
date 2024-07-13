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

RUN if getent passwd $USER_UID > /dev/null; then \
        USER_UID=$(($USER_UID + 1)); \
    fi \
    && if ! getent group $USER_GID; then \
        groupadd --gid $USER_GID $USERNAME; \
    fi \
    && useradd --uid $USER_UID --gid $USER_GID -m $USERNAME \
    && usermod -aG sudo $USERNAME \
    && echo "$USERNAME ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/$USERNAME \
    && chmod 0440 /etc/sudoers.d/$USERNAME

# Switch to the non-root user
USER $USERNAME

# Set up the working directory
WORKDIR /home/$USERNAME

# Copy requirements and R script files into the working director
