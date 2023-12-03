#!/usr/bin/bash

# Update package list
sudo apt update

# Install required packages
sudo apt install -y libavfilter-dev librsvg2-dev poppler-utils cargo libmagick++-dev libpoppler-cpp-dev libtesseract-dev libleptonica-dev tesseract-ocr-eng
npx playwright install
npm install cheerio
