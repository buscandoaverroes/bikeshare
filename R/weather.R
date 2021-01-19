# weather.R
# extracts info from NOAA databases to create by-hour/day dictionary of basic weather info

# key variables: date/time, temp, precipitation

library(rnoaa)
# first need to obtain api key: https://www.ncdc.noaa.gov/cdo-web/token
# see: https://docs.ropensci.org/rnoaa/articles/rnoaa.html#search-for-data-1