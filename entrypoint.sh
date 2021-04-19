#!/bin/sh -l

Rscript -e "rsconnect::setAccountInfo(name='michaelgao8', token='${SHINYAPPS_TOKEN}', secret='${SHINYAPPS_SECRET}')"
sh -c "Rscript $*"
