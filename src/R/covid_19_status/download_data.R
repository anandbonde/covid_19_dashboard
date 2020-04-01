library(tidyverse)
library(data.table)

#dev.off()

########### CONFIGS ###########
orig_wd <-
  "~/git/covid_19_dashboard/src/R/covid_19_status"
today_wd <-
  "~/git/covid_19_dashboard/src/R/covid_19_status/today"
github_url <-
  "https://github.com/CSSEGISandData/COVID-19/archive/master.zip"
daily_csvs_path <-
  file.path(today_wd,
            "COVID-19-master/csse_covid_19_data/csse_covid_19_daily_reports")


########### FUNCTIONS ###########
create_wd <- function(dir_path) {
  if (dir.exists(dir_path)) {
    unlink(x = dir_path,
           recursive = T,
           force = T)
  }
  dir.create(path = dir_path, recursive = T)
}

dwld_data <- function(url, today_wd, outfile) {
  download.file(url = url,
                destfile = outfile,
                quiet = T)
}

prep_data <- function(file) {
  unzip(zipfile = file)
  unlink(x = file)
}

prep_work_env <- function(data_dir) {
  create_wd(data_dir)
  setwd(dir = data_dir)
}

get_and_prepare_data <- function(data_dir, url) {
  prep_work_env(data_dir)
  dwld_data(url = url,
            today_wd = data_dir,
            outfile = "tmp_master.zip")
  prep_data("tmp_master.zip")
}

fpath_to_date <- function(fpath) {
  fname <- sub(pattern = ".csv",
               replacement = "",
               x = basename(fpath))
  return(as.Date(fname, "%m-%d-%y"))
}

combine_daily_reps <- function(dir_path) {
  full_daily_report = data.frame()

  for (fpath in list.files(path = dir_path, pattern = "*.csv")) {

    fpath <- file.path(dir_path, fpath)

    daily_rep <- fread(input = fpath)

    reported_date <- fpath_to_date(fpath)

    if ("Country/Region" %in% names(daily_rep)){
      daily_rep <- daily_rep %>%
        mutate(Country_Region = `Country/Region`, Province_State = `Province/State`)
    }

    daily_rep <- daily_rep %>%
      mutate(reported_date = rep(x = reported_date, n = nrow(daily_rep))) %>%
      select(c(
        Province_State,
        Country_Region,
        Confirmed,
        Deaths,
        Recovered,
        reported_date
      ))

    full_daily_report <- rbind(full_daily_report, daily_rep)
  }
  return(full_daily_report)
}

########### SCRIPT ###########
setwd(orig_wd)
get_and_prepare_data(data_dir = today_wd, url = github_url)
full_daily_report <-
  combine_daily_reps(dir_path = daily_csvs_path)
dim(full_daily_report)

full_daily_report <-
  full_daily_report %>%
  mutate(Country_Region = replace(Country_Region, Country_Region == "Mainland China", "China"))

setwd(orig_wd)
save(full_daily_report, file = "full_daily_report.RData")

file.copy(from = "today/COVID-19-master/csse_covid_19_data/csse_covid_19_time_series/time_series_covid19_confirmed_global.csv",
          to = "time_series_covid19_confirmed_global.csv",
          overwrite = T)

unlink(x = today_wd,
       recursive = T,
       force = T)
rm(list = ls())
