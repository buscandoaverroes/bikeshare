# sandbox-json.R
# a sandbox for accessing system data from https://gbfs.capitalbikeshare.com/gbfs/gbfs.json
library(jsonlite)
library(dplyr)
library(RCurl)

url <- "https://gbfs.capitalbikeshare.com/gbfs/en/station_information.json"
json <- fromJSON(url)

stations <- json$data$stations
