#!/bin/bash

cd ~/git/covid_19_dashboard/src/scripts/cron/

./download.sh >> ~/git/covid_19_dashboard/logs/cron/update_shiny_dashboard.log
./deploy.sh >> ~/git/covid_19_dashboard/logs/cron/update_shiny_dashboard.log
