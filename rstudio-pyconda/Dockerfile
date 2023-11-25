FROM rocker/tidyverse:latest
RUN echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections
RUN apt-get update && apt-get install -y  libudunits2-dev bash-completion libharfbuzz-dev libfribidi-dev curl wget make cmake htop libcurl4-openssl-dev libicu-dev libssl-dev libsasl2-dev libv8-dev libxml2-dev tcl tk pandoc zlib1g-dev openjdk-17-jdk libfontconfig1-dev gdal-bin libgdal-dev && rm -rf /var/lib/apt/lists/*
RUN apt-get update && apt-get install -y \
    python3.11 \
    python3.11-dev \
    python3.11-venv \
    python3-pip
RUN mkdir -p /usr/local/lib/R/etc/ /usr/lib/R/etc/
RUN R CMD javareconf

# R
RUN mkdir -p /usr/local/lib/R/etc/ /usr/lib/R/etc/
RUN R CMD javareconf
RUN echo "options(repos = c(CRAN = 'https://packagemanager.rstudio.com/cran/latest'), download.file.method = 'libcurl', Ncpus = 8)" | tee /usr/local/lib/R/etc/Rprofile.site | tee /usr/lib/R/etc/Rprofile.site
# Installing R packages
COPY r_packages.R /tmp/r_packages.R
RUN Rscript /tmp/r_packages.R
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

# python with conda env
ENV CONDA_DIR /opt/conda
ENV PATH=$CONDA_DIR/bin:$PATH
RUN wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh
RUN bash Miniconda3-latest-Linux-x86_64.sh -b -p $CONDA_DIR
RUN rm Miniconda3-latest-Linux-x86_64.sh
RUN conda update -n base -c defaults conda
COPY environment.yml /tmp/environment.yml
RUN conda env create -f /tmp/environment.yml
SHELL ["conda", "run", "-n", "rtenv", "/bin/bash", "-c"]

# python with python env
#WORKDIR /app
#COPY requirements.txt .
# RUN python3 -m venv env
#RUN python3.11 -m venv env
#ENV PATH="./env/bin:$PATH"
# RUN source ./env/bin/activate
#RUN pip3 install -r requirements.txt

# Add user for RStudio
RUN echo "rstudio:rstudio" | chpasswd
RUN chown rstudio:rstudio /home/rstudio
ENV USER rstudio
ENV PASSWORD rstudio
ENV ROOT true
RUN echo "rstudio ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

WORKDIR /home/rstudio
EXPOSE 8787
CMD ["/init"]
