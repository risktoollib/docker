FROM rocker/rstudio:latest
RUN echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections
RUN apt-get update && apt-get install -y  bash-completion libharfbuzz-dev libfribidi-dev curl wget cmake libcurl4-openssl-dev libicu-dev libssl-dev libv8-dev libxml2-dev make pandoc zlib1g-dev openjdk-17-jdk libfontconfig1-dev gdal-bin libgdal-dev && rm -rf /var/lib/apt/lists/*
RUN apt-get update && apt-get install -y \
    python3.11 \
    python3.11-dev \
    python3-pip
RUN mkdir -p /usr/local/lib/R/etc/ /usr/lib/R/etc/
RUN R CMD javareconf
RUN mkdir -p /usr/local/lib/R/etc/ /usr/lib/R/etc/
RUN echo "options(repos = c(CRAN = 'https://packagemanager.rstudio.com/cran/latest'), download.file.method = 'libcurl', Ncpus = 4)" | tee /usr/local/lib/R/etc/Rprofile.site | tee /usr/lib/R/etc/Rprofile.site
# Installing R packages: core
RUN R -e 'install.packages(c("devtools","remotes","plotly","RCurl","shiny","rmarkdown","knitr","quarto","tidyverse"))'
# Installing R packages: container specific
RUN R -e 'install.packages(c("sf","RTL","reticulate","factoextra","feather","gt","leaflet","lpSolve","lpSolveAPI","optimx","orsm"))'

# Customize Rprofile
## Install the Cobalt theme
RUN R -e "install.packages('cobalt')"
RUN echo 'library(cobalt)' >> /home/rstudio/.Rprofile

# Install Conda
#RUN R -e "reticulate::conda_create('rtenv', python = '3.11')"
#RUN R -e "reticulate::conda_install('rtenv', 'pandas')"
#Download and install Miniconda (you can also use Anaconda)
RUN wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O /tmp/miniconda.sh && \
    /bin/bash /tmp/miniconda.sh -b -p /opt/conda && \
    rm /tmp/miniconda.sh

# Add Conda to the PATH
ENV PATH="/opt/conda/bin:${PATH}"

# Clean up
RUN conda clean -ya

# Create conda environment
WORKDIR /app
COPY environment.yml .
RUN conda env create -f environment.yml
SHELL ["conda", "run", "-n", "rtenv", "/bin/bash", "-c"]

RUN mkdir /build_zone
ADD . /build_zone
WORKDIR /build_zone
RUN rm -rf /build_zone
EXPOSE 8787

# Set the environment variables for RStudio
ENV USER rstudio
ENV PASSWORD rstudio
ENV ROOT true
# Start RStudio server
CMD ["R"]
CMD ["/init"]