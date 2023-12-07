FROM rocker/tidyverse:latest
RUN echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections && \
    apt-get update && apt-get install -y git libudunits2-dev bash-completion libharfbuzz-dev libfribidi-dev curl wget make cmake htop libcurl4-openssl-dev libicu-dev libssl-dev libsasl2-dev libv8-dev libxml2-dev tcl tk pandoc zlib1g-dev openjdk-17-jdk libfontconfig1-dev gdal-bin libgdal-dev python3.11 python3.11-dev python3.11-venv python3-pip && \
    rm -rf /var/lib/apt/lists/* && \
    R CMD javareconf && \
    mkdir -p /usr/local/lib/R/etc/ /usr/lib/R/etc/ && \
    R CMD javareconf && \
    echo "options(repos = c(CRAN = 'https://packagemanager.rstudio.com/cran/latest'), download.file.method = 'libcurl', Ncpus = 8)" | tee /usr/local/lib/R/etc/Rprofile.site | tee /usr/lib/R/etc/Rprofile.site

WORKDIR /home
COPY requirements.txt .
RUN python3.11 -m venv env && \
    ./env/bin/pip3 install -r requirements.txt && \
    rm -rf ~/.cache/pip

ENV PATH="/home/env/bin:$PATH"

COPY r_packages.R /tmp/r_packages.R
RUN Rscript /tmp/r_packages.R && \
    R -e 'devtools::install_github("risktoollib/RTL")' && \
    R -e 'install.packages(c("mongolite","snowflakes"), dependencies = TRUE)' && \
    rm -rf /tmp/downloaded_packages/ /tmp/*.rds

# Add user for RStudio
RUN echo "rstudio:rstudio" | chpasswd && \
    chown rstudio:rstudio /home/rstudio && \
    echo "rstudio ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers && \
    echo "copilot-enabled=1" >> /etc/rstudio/rsession.conf

WORKDIR /home/rstudio
EXPOSE 8787
CMD ["/init"]

