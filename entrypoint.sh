#!/bin/sh -l

Rscript -e "rsconnect::setAccountInfo(name='michaelgao', token='${SHINYAPPS_TOKEN}', secret='${SHINYAPPS_SECRET}')"
sh -c "Rscript $*"
