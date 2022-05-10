# sandbox-json.R
# a sandbox for accessing system data from https://gbfs.capitalbikeshare.com/gbfs/gbfs.json
library(jsonlite)
library(dplyr)
library(mapview)
library(leaflet)
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

leaflet() %>%
  addTiles() %>%
  addCircleMarkers(data = freebikes, 
                   lat = ~lat, 
                   lng = ~lon, 
                   label = ~type) %>%
  addCircleMarkers(data = stations,
                   radius = 5,
                   color = "#000",
                   lat = ~lat,
                   lng = ~lon,
                   label = ~name)

# highlight bikes that are not within 200m of a station
stations_sf <- st_as_sf(stations, 
                        coords = c("lon", "lat"), 
                        crs = st_crs(4326)) %>%
  select(station_id, name, region_id, capacity)

freebikes_sf <- st_as_sf(freebikes, 
                        coords = c("lon", "lat"), 
                        crs = st_crs(4326)) 


close <-  
  st_join(freebikes_sf,  # left side = freebikes
    stations_sf, # right side = stations
    join = st_is_within_distance, # join type
    left = TRUE,  # keep all obs from station key
    dist = 200,
    suffix = c(".x", ".y"),
    largest = FALSE) %>%
  mutate(close = !is.na(station_id)) %>%
  select(bike_id, close, is_disabled, is_reserved, station_id, name.y)


  
mapviewOptions(fgb = FALSE) # fix error https://github.com/r-spatial/mapview/issues/412

mapview(stations_sf, label = "name") +
  mapview(close, zcol = "close", col.regions = c("red", "green"))
