FROM rocker/rstudio:latest
RUN echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections
RUN apt-get update && apt-get install -y \
apt-utils bowtie2 bwidget cargo cmake coinor-libclp-dev dcraw default-jdk gdal-bin git gsfonts \
haveged imagej imagemagick jags libapparmor-dev libarchive-dev libcairo2-dev \
libcurl4-openssl-dev libfftw3-dev libfontconfig1-dev libfreetype6-dev libfribidi-dev \
libgdal-dev libgeos-dev libgit2-dev libgl1-mesa-dev libglib2.0-dev libglpk-dev \
libglu1-mesa-dev libgmp3-dev libgpgme11-dev libgsl0-dev libharfbuzz-dev libhdf5-dev \
libicu-dev libimage-exiftool-perl libjpeg-dev libjq-dev libleptonica-dev libmagick++-dev \
libmpfr-dev libmysqlclient-dev libnetcdf-dev libopenmpi-dev libpng-dev libpoppler-cpp-dev \
libpq-dev libproj-dev libprotobuf-dev librsvg2-dev libsasl2-dev libsndfile1-dev \
libsodium-dev libssh2-1-dev libssl-dev libtesseract-dev libtiff-dev libudunits2-dev \
libv8-dev libwebp-dev libxft-dev libxml2-dev libxslt-dev libzmq3-dev make bwidget \
ocl-icd-opencl-dev pandoc pari-gp perl protobuf-compiler python3 rustc saga tcl \
tesseract-ocr-eng texlive tk tk-dev tk-table unixodbc-dev zlib1g-dev htop wget \
&& rm -rf /var/lib/apt/lists/*v
RUN R CMD javareconf
RUN mkdir -p /usr/local/lib/R/etc/ /usr/lib/R/etc/
RUN echo "options(repos = c(REPO_NAME = 'https://packagemanager.rstudio.com/cran/latest'), download.file.method = 'libcurl', Ncpus = 4)" | tee /usr/local/lib/R/etc/Rprofile.site | tee /usr/lib/R/etc/Rprofile.site
RUN R -e 'install.packages(c("devtools","remotes","tidyverse","plotly","RCurl","rvest","rgdal","terra","sp","RTL","doParallel"))'
EXPOSE 8787
CMD ["/init"]
