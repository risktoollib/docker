FROM rocker/rstudio:latest
RUN echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections
RUN apt-get update && apt-get install -y  libudunits2-dev bash-completion libharfbuzz-dev libfribidi-dev curl wget cmake libcurl4-openssl-dev libicu-dev libssl-dev libv8-dev libxml2-dev make pandoc zlib1g-dev openjdk-17-jdk libfontconfig1-dev gdal-bin libgdal-dev && rm -rf /var/lib/apt/lists/*
RUN apt-get update && apt-get install -y \
    python3.11 \
    python3.11-dev \
    python3.11-venv \
    python3-pip
RUN mkdir -p /usr/local/lib/R/etc/ /usr/lib/R/etc/
RUN R CMD javareconf

# R
RUN echo "options(repos = c(CRAN = 'https://packagemanager.rstudio.com/cran/latest'), download.file.method = 'libcurl', Ncpus = 4)" | tee /usr/local/lib/R/etc/Rprofile.site | tee /usr/lib/R/etc/Rprofile.site
# Installing R packages: core
RUN R -e 'install.packages(c("devtools","remotes","plotly","RCurl","shiny","rmarkdown","knitr","quarto","tidyverse"))'
# Installing R packages: container specific
RUN R -e 'install.packages(c("sf","RTL","reticulate","factoextra","feather","gt","leaflet","lpSolve","lpSolveAPI","optimx","orsm"), dependencies = TRUE)'

RUN mkdir /build_zone
ADD . /build_zone
WORKDIR /build_zone
RUN rm -rf /build_zone
EXPOSE 8787

# python
WORKDIR /app
COPY requirements.txt .
# RUN python3 -m venv env
RUN python3.11 -m venv env
ENV PATH="./env/bin:$PATH"
# RUN source ./env/bin/activate
RUN pip3 install -r requirements.txt

# Set the environment variables for RStudio
ENV USER rstudio
ENV PASSWORD rstudio
ENV ROOT true
# Start RStudio server
CMD ["R"]
CMD ["/init"]