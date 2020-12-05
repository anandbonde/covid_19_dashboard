#!/bin/bash

cd ~/git/covid_19_dashboard/src/R/covid_19_status

echo "[`date`] Starting shiny app deployment"

R -e "rsconnect::setAccountInfo(name='', token='', )" > /dev/null 2>&1

R -e "rsconnect::deployApp()" > /dev/null 2>&1

echo "[`date`] Shiny app deployment complete"
