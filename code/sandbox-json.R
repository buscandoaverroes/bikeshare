# sandbox-json.R
# a sandbox for accessing system data from https://gbfs.capitalbikeshare.com/gbfs/gbfs.json
library(jsonlite)
library(dplyr)

stations <- "https://gbfs.capitalbikeshare.com/gbfs/en/station_information.json"
regions <- "https://gbfs.capitalbikeshare.com/gbfs/en/system_regions.json"

json_stations <- fromJSON(stations)
json_regions <- fromJSON(regions)

stations <- json_stations$data$stations
regions <- json_regions$data$regions
