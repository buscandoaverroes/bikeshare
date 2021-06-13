# weather.R
# extracts info from NOAA databases to create by-hour/day dictionary of basic weather info

# key variables: date/time, temp, precipitation
library(tidyverse)
library(rnoaa)
library(lubridate)

# A new search ====================================================================================================
# documentation: https://www1.ncdc.noaa.gov/pub/data/ghcn/daily/readme.txt
# hourly precip: 
# daily temp: Daily summaries (GHCN-Daily), DSI 9101_01, c00681
# datacats <- ncdc_datacats(datasetid = 'GHCND') %>% .$data # temp
# temp_types <- ncdc_datatypes(datasetid = 'GHCND', datacategoryid = 'TEMP') %>% .$data
# stations <- ncdc_stations(datasetid = 'GHCND', locationid = 'FIPS:11', datatypeid = 'TAVG') %>% .$data
# datasets <- ncdc_datasets(datasetid = 'GHCND', datatypeid = 'TAVG', stationid = 'GHCND:USC00186350', startdate = '2010-01-01', enddate = '2010-02-01', limit = 100) %>% .$data
# data <- ncdc(datasetid = 'GHCND',
#             datatypeid = c('TMAX', 'PRCP'),
#              stationid = 'GHCND:USC00186350',
#              startdate = '2010-01-01',
#              enddate = '2010-12-31',
#              limit = 1000) %>%
#   .$data # note, values given in tenths, degrees C (22.1 = 2.21 Celcius), PRCP in tenths of mm (22 = 2.2 mm)
# 


# function for extracting data for a certain year =================================================================
daily_weather <- function(x) {
  
  data <- ncdc(datasetid = 'GHCND',
               datatypeid = c('TMAX', 'PRCP'),
               stationid = 'GHCND:USC00186350',
               startdate = paste0(x, '-01-01'),
               enddate = paste0(x, '-12-31'),
               limit = 1000) %>% .$data
    
  # generate variables
  # includes: more computer-readable date-time variables and human-readable measurements.
  # note that since measurements of temp are recorded in tenth of degrees celsius and precip
  # in tenth of mm, I will convert to degrees celcius and mm accordingly. First I'll pivot
  # to wide format so temp and precip are in different columsn
  data <-
    data %>% 
      pivot_wider(names_from = datatype, values_from = value, id_cols = date) %>% 
    mutate(   
      datetime = ymd_hms(date, tz = 'America/New_York'),
      year     = as.integer(year(datetime)),
      month    = as.integer(month(datetime)),
      wday     = as.integer(wday(datetime)),
      day      = as.integer(day(datetime)),
      day_of_yr= as.integer(yday(datetime)),
      tempmax  = round((TMAX/10), 1), # daily tempmax in celcius
      precip   = round((PRCP/10), 1) # daily precip in mm
    ) 
  
  data
    
}

# extract weather for each year ===================================================================================

weather2010 <- daily_weather(2010)
weather2011 <- daily_weather(2011)
weather2012 <- daily_weather(2012)
weather2013 <- daily_weather(2013)
weather2014 <- daily_weather(2014)

weather2015 <- daily_weather(2015)
weather2016 <- daily_weather(2016)
weather2017 <- daily_weather(2017)
weather2018 <- daily_weather(2018)
weather2019 <- daily_weather(2019)

weather2020 <- daily_weather(2020)
weather2021 <- daily_weather(2021)


# append 
weather_daily <- 
  bind_rows(
  weather2010, weather2011, weather2012, weather2013, weather2014,
  weather2015, weather2016, weather2017, weather2018, weather2019,
  weather2020, weather2021
) 

# check for duplicates
assertthat::assert_that(
  anyDuplicated(weather_daily$datetime) == 0 # no duplicate entries for date
)


# export 
saveRDS(
  weather_daily,
  file = file.path(processed, "data/weather/weather-daily.Rda")
)

