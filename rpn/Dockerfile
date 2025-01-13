# Base image from rocker/tidyverse
FROM rocker/tidyverse:latest

# Set environment variables for non-interactive installation
ENV DEBIAN_FRONTEND=noninteractive
ENV PYTHON_VERSION=3.11.11

# Install required system packages
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        build-essential \
        wget \
        curl \
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
        openjdk-17-jdk \
        python3-venv \
        pkg-config \
        libpango1.0-dev \
        libcairo2-dev \
        python3-pip \
        nodejs \
        && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/*

# Set JAVA_HOME for Java installation
ENV JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
ENV PATH=$JAVA_HOME/bin:$PATH

# Install uv using the provided installation script
RUN curl -LsSf https://astral.sh/uv/install.sh | sh

# Add the uv binary location to PATH
ENV PATH="/root/.local/bin:$PATH"

# Create the /home/rstudio/env directory for uv
WORKDIR /home/rstudio/env

# Install Python 3.11 using uv and initialize the environment in /home/rstudio/env
RUN uv python install 3.11 && \
    uv init . && \
    uv add \
        ipython \
        pandas \
        pandas-datareader \
        numpy \
        polars \
        plotly \
        plotnine \
        pyarrow \
        scipy \
        yfinance \
        streamlit \
        manim \
        scikit-misc \
        git+https://github.com/bbcho/risktools-dev.git

# Copy the R package installation script
COPY r_packages.R /home/rstudio/env/

# Install R environment and packages
RUN R CMD javareconf && \
    Rscript /home/rstudio/env/r_packages.R && \
    R -e 'devtools::install_github("risktoollib/RTL")' && \
    R -e 'install.packages(c("mongolite", "snowflakes"), dependencies = TRUE)'

# Install Playwright and related npm packages
RUN curl -fsSL https://deb.nodesource.com/setup_lts.x | bash - && \
    apt-get install -y --no-install-recommends nodejs && \
    npm install -g playwright axios cheerio && \
    npx playwright install-deps && \
    npx playwright install && \
    apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/*

# Configure environment variables
ENV CFLAGS="-I/usr/include/sasl" \
    LDFLAGS="-L/usr/lib" \
    USER=rstudio \
    PASSWORD=rstudio \
    ROOT=true

# User setup and permissions
RUN echo "rstudio:rstudio" | chpasswd && \
    chown -R rstudio:rstudio /home/rstudio && \
    echo "rstudio ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers && \
    echo "copilot-enabled=1" >> /etc/rstudio/rsession.conf && \
    chmod -R 777 /home && \
    quarto install tinytex

# Final settings
WORKDIR /home/rstudio
EXPOSE 8787
CMD ["/init"]
