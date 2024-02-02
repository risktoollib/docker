# Use rocker/rstudio as the base image
FROM rocker/rstudio:latest
# Install Ubuntu required library dependencies
RUN apt-get update && apt-get install -y \
    libssl-dev \
    libcurl4-gnutls-dev \
    libxml2-dev

# Install R packages
RUN R -e "install.packages(c('tidyquant', 'plotly','quantmod'), dependencies = TRUE, repos = 'https://packagemanager.rstudio.com/cran/latest')"

# Add user for RStudio
RUN echo "rstudio:rstudio" | chpasswd
RUN chown rstudio:rstudio /home/rstudio
ENV USER rstudio
ENV PASSWORD rstudio
ENV ROOT true

# Expose port for RStudio
EXPOSE 8787

# Start the server
CMD ["/init"]
