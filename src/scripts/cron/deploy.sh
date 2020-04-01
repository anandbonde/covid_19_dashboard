#!/bin/bash

cd ~/git/covid_19_dashboard/src/R/covid_19_status

echo "[`date`] Starting shiny app deployment"

R -e "rsconnect::setAccountInfo(name='curiotiveme', token='59D8786686492D3EB70C7C5B0ADB413A', secret='5grwmaqmkrjvCdvzzNkJtVuk2yf2NJBHfnnpuaxW')" > /dev/null 2>&1

R -e "rsconnect::deployApp()" > /dev/null 2>&1

echo "[`date`] Shiny app deployment complete"
