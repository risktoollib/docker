# Use rocker/rstudio as the base image
FROM rocker/rstudio:latest
# Install Ubuntu required library dependencies
RUN apt-get update && apt-get install -y \
    libssl-dev \
    libcurl4-gnutls-dev \
    libxml2-dev

# Install R packages
RUN R -e "install.packages(c('tidyquant', 'plotly'), dependencies = TRUE, repos = 'https://packagemanager.rstudio.com/cran/latest')"

# Add user for RStudio
RUN echo "rstudio:rstudio" | chpasswd

# Change to default home directory when write permissions
RUN chown rstudio:rstudio /home/rstudio
# Set the environment variables for RStudio
ENV USER rstudio
ENV PASSWORD rstudio
ENV ROOT true

# Expose port for RStudio
EXPOSE 8787

# Start the server
CMD ["/init"]