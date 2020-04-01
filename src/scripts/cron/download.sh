#!/bin/bash

echo "[`date`] Starting data download R script"

Rscript ~/git/covid_19_dashboard/src/R/covid_19_status/download_data.R > /dev/null 2>&1

echo "[`date`] Data download complete"
