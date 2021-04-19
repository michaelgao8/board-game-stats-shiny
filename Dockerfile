FROM rocker/shiny:4.0.4
RUN install2.r rsconnect DT dplyr jsonlite lubridate
WORKDIR /home/shinyusr
COPY app.R app.R
COPY BGStatsExport.json BGStatsExport.json
COPY deploy.R deploy.R
CMD Rscript deploy.R
