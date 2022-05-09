# sandbox-json.R
# a sandbox for accessing system data from https://gbfs.capitalbikeshare.com/gbfs/gbfs.json
library(jsonlite)
library(dplyr)
library(mapview)
library(sf)


url_stations <- "https://gbfs.capitalbikeshare.com/gbfs/en/station_information.json"
url_regions <- "https://gbfs.capitalbikeshare.com/gbfs/en/system_regions.json"
url_freebikes <- "https://gbfs.capitalbikeshare.com/gbfs/en/free_bike_status.json"

json_stations <- fromJSON(url_stations)
json_regions <- fromJSON(url_regions)
json_freebikes <- fromJSON(url_freebikes)

stations <- json_stations$data$stations
regions <- json_regions$data$regions
freebikes <- json_freebikes$data$bikes 

# is legacy_id same as station_id?
stations %>%
  mutate(same = (legacy_id == station_id)) %>%
  count(same)
    # yes

# freebikes appears to have locations of current undocked electric bikes 

leaflet(data = freebikes) %>%
  addTiles() %>%
  addCircleMarkers(lat = ~lat, lng = ~lon)
