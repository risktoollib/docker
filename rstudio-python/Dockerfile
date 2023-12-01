FROM rocker/tidyverse:latest
RUN echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections
RUN apt-get update && apt-get install -y  libudunits2-dev bash-completion libharfbuzz-dev libfribidi-dev curl wget make cmake htop libcurl4-openssl-dev libicu-dev libssl-dev libsasl2-dev libv8-dev libxml2-dev tcl tk pandoc zlib1g-dev openjdk-17-jdk libfontconfig1-dev gdal-bin libgdal-dev && rm -rf /var/lib/apt/lists/*
# selelium
RUN apt-get update && apt-get install -y \
    firefox \
    gnupg2 \
    software-properties-common \
    libfontconfig1 \
    libxrender1 \
    libxtst6 \
    libxi6 \
    && rm -rf /var/lib/apt/lists/*

# Install geckodriver
RUN wget https://github.com/mozilla/geckodriver/releases/download/v0.29.0/geckodriver-v0.29.0-linux64.tar.gz \
    && tar -xvzf geckodriver-v0.29.0-linux64.tar.gz \
    && mv geckodriver /usr/local/bin \
    && chmod +x /usr/local/bin/geckodriver \
    && rm geckodriver-v0.29.0-linux64.tar.gz    

# python
RUN apt-get update && apt-get install -y \
    python3.11 \
    python3.11-dev \
    python3.11-venv \
    python3-pip
WORKDIR /home
COPY requirements.txt .
RUN python3.11 -m venv env \
    && ./env/bin/pip3 install -r requirements.txt
ENV PATH="/home/env/bin:$PATH"

# R
RUN R CMD javareconf
RUN mkdir -p /usr/local/lib/R/etc/ /usr/lib/R/etc/
RUN R CMD javareconf
RUN echo "options(repos = c(CRAN = 'https://packagemanager.rstudio.com/cran/latest'), download.file.method = 'libcurl', Ncpus = 8)" | tee /usr/local/lib/R/etc/Rprofile.site | tee /usr/lib/R/etc/Rprofile.site
# Installing R packages
COPY r_packages.R /tmp/r_packages.R
RUN Rscript /tmp/r_packages.R
RUN R -e 'install.packages("Selenium", dependencies = TRUE)'
RUN R -e 'devtools::install_github("risktoollib/RTL")'

# database connection
# config for libsasl2-dev - required for mongolite
RUN pkg-config --cflags --libs libsasl2
RUN export CFLAGS="-I/usr/include/sasl"
RUN export LDFLAGS="-L/usr/lib"
RUN R -e 'install.packages(c("mongolite","snowflakes"), dependencies = TRUE)'

RUN mkdir /build_zone
ADD . /build_zone
WORKDIR /build_zone
RUN rm -rf /build_zone

# Add user for RStudio
RUN echo "rstudio:rstudio" | chpasswd
RUN chown rstudio:rstudio /home/rstudio
ENV USER rstudio
ENV PASSWORD rstudio
ENV ROOT true
RUN chmod -R 777 /home
RUN echo "rstudio ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

WORKDIR /home/rstudio
EXPOSE 8787
CMD ["/init"]
