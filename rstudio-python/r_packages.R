p <- c( "bizdays", "broom", "corrplot", "corrr", "curl", "desc", "devtools", "doParallel", "factoextra", "feasts", "feather", "fGarch", "filesstrings", "GGally", "gganimate", "ggcorrplot", "ggfortify", "ggtext", "golem", "gridExtra", "gt", "geojsonio","here", "htmltools", "htmlwidgets", "httr2", "jsonlite", "knitr", "leaflet", "lexicon", "lpSolve", "lpSolveAPI", "magick", "moments", "optimx", "osrm", "pander", "parsnip", "patchwork", "plotly", "png", "prettydoc", "prophet", "quarto", "randomForest", "ranger", "RCurl", "recipes", "remotes", "reticulate", "revealjs", "rhandsontable", "riem", "rjson", "rlang", "rmarkdown", "rpart.plot", "RSelenium", "rstanarm", "rugarch", "rvest", "scales", "sf", "shinipsum", "shiny", "slider", "sp", "splines2", "stringi", "tibbletime", "tidygeocoder", "tidymodels", "tidyquant", "tidytext", "tidyverse", "timetk", "tint", "tinytex", "tm", "tsibble", "usethis", "vembedr", "webshot2", "wordcloud2", "XML")

# print(paste0('"', paste(sort(unique(p)), collapse='", "'), '"'), quote=F)
new.packages <- p[!(p %in% installed.packages()[, "Package"])]
if (length(new.packages)) {
  install.packages(new.packages, dependencies = TRUE)
}