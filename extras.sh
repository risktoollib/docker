#!/usr/bin/bash

# fix end of line if required
#sed -i 's/\r//' extras.sh

# Update package list
sudo apt update

# Install required packages
sudo apt install -y jags libavfilter-dev librsvg2-dev poppler-utils cargo libmagick++-dev libpoppler-cpp-dev libtesseract-dev libleptonica-dev tesseract-ocr-eng
sudo apt-get autoremove

# OpenBlas
#sudo apt install -y libopenblas-base libopenblas-dev
#export LD_LIBRARY_PATH=/usr/lib/openblas-base/

# rQuantlib
sudo apt install libquantlib0v5 libquantlib0-dev
Rscript -e 'pkgs <- c("RQuantLib", "tesseract", "pdftools"); installed_pkgs <- rownames(installed.packages()); install.packages(pkgs[!(pkgs %in% installed_pkgs)], dependencies = TRUE)'

# node packages
npx playwright install
npm install cheerio axios

# quarto pdf
quarto install tinytex

# fOptions
#Rscript -e 'install.packages("fOptions", repos="http://R-Forge.R-project.org"); install.packages("fExoticOptions", repos="http://R-Forge.R-project.org")'
