# -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- #
# Name: station-number.R
# Description: creates a dictionary of station numbers between old and new numbers 
# Note: this is run within the station-number script so no packages/data should be needed.
# -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- #

library(osmdata)
library(mapview)


# settings 
query  = FALSE    # set to TRUE to requery and download OSM data, FALSE to load prev saved query
export = TRUE     # set to TRUE to export/save, FALSE to not

# key variables: first applied after merge with OSM data 
key_df_vars <- c(
    "number_old",
    "id_proj",
    "name_bks", "name_bks2", "name_bks3",
    "lat",       "lng",
    "geometry",
    "osm_id", "metro",    "name_metro"
)




# load csv 
bks <- data.table::fread(
  file.path(raw, "bks-import.csv"),
  header = TRUE,
  na.strings = "" 
)

# make names object 
names_bks <- 
  as_tibble(names(bks)) %>%
  gather()

# determine no of unique stations 
# old numbers are all greater than 30,000; station numbers that are == 0 are disabled, etc. Filter those out.
station_old   <- bks %>% filter(!is.na(start_number)) %>% distinct(start_number) 
n_station_old <- n_distinct(station_old$start_number, na.rm = TRUE)




                  # ---------------------------------------------------------#
                  #         create station name-number dictionary            =================
                  # ---------------------------------------------------------#

## create distinct name-number dictionary: ----
## this will have duplicates across numbers because 
## there will be stations with different spellings of names with the same number.
namenumb <- bks %>%
  group_by(start_name, start_number) %>%
  summarise() %>%
  filter(start_name != "") %>%   # remove blank entries
  ungroup() %>% group_by(start_number) %>%
  arrange(start_name) %>% # arrange by alpha within same group number
  mutate(id = row_number()) %>%
  pivot_wider(names_from = id, # pivot wider
              values_from = start_name)
  

# check that there are the same number of unique station numbers as in n_station_old
assertthat::assert_that(
  n_distinct(namenumb$start_number) == n_station_old
)




## add and remove variables ---------------------------------------------------------------------

# remove misc var, drop unecessary objects 
station_key <- namenumb %>%
  rename(
    number_old = start_number,
    name1 = "1",
    name2 = "2",
    name3 = "3"
  )


# generate project id
station_key <- 
  station_key %>% ungroup() %>%
  arrange(name1) %>% 
  mutate(
    id_proj = row_number()
  ) 




## merge with gps coordinates from "new" stations ----------------------------------------------------

# set random number seed
set.seed(4747) 


# create subset of station numbrs and gps coordinates
cabi_coords <- 
  bks %>%
  filter(is.na(start_lat) == FALSE & is.na(start_lng) == FALSE & is.na(start_number) == FALSE) %>% 
  mutate(r = runif(nrow(.)) ) %>%
  group_by(start_number) %>%
  filter(row_number() == 1) %>% # keep only row of each station, determined by random number generation
  select(start_number, start_lat, start_lng)


# merge coordinates with main key
station_key <- 
  station_key %>%
  left_join(., 
            cabi_coords,
            by = c("number_old" = "start_number")) %>%
  rename(lat = start_lat, lng = start_lng)




## replace missings GPS info ------------------------------------------------------
# note: some stations did not come with valid lat/lon column data, but can either 
# be inferred (reasonably guessed) based on same-named stations with valid GPS data
# or from a simple query on OpenStreetMaps. Thanks to OpenStreetMap and Contributors!

# replace lat/long based on name -- it's possible that id could change as stations are added.

station_key$lat[station_key$name1=="12th & Army Navy Dr"] <- 38.86294 
station_key$lng[station_key$name1=="12th & Army Navy Dr"] <- -77.05276

station_key$lat[station_key$name1=="14th & D St SE"] <- 38.88405 
station_key$lng[station_key$name1=="14th & D St SE"] <- -76.9857

station_key$lat[station_key$name1=="22nd & H  NW (disabled)"] <- 38.8989 # same name, assume lat/long same
station_key$lng[station_key$name1=="22nd & H  NW (disabled)"] <- -77.0489

station_key$lat[station_key$name1=="34th St & Minnesota Ave SE"] <- 38.88362
station_key$lng[station_key$name1=="34th St & Minnesota Ave SE"] <- -76.95782

station_key$lat[station_key$name1=="Solutions & Greensboro Dr"] <- 38.88362
station_key$lng[station_key$name1=="Solutions & Greensboro Dr"] <- -76.95782

station_key$lat[station_key$name1=="Taft St & E Gude Dr"] <- 38.88362
station_key$lng[station_key$name1=="Taft St & E Gude Dr"] <- -76.95782

# assume that the two office have the same coords
station_key$lat[station_key$name1=="Motivate Tech Office"] <- station_key$lat[station_key$name1=="Motivate BX Tech office"]
station_key$lng[station_key$name1=="Motivate Tech Office"] <- station_key$lng[station_key$name1=="Motivate BX Tech office"]



# ensure each station has GPS data 
assert_that(
  sum(is.na(station_key$lat)) == 0
)

assert_that(
  sum(is.na(station_key$lng)) == 0
)




            # ---------------------------------------------------------#
            #       incorporate open street map id numbers              =======================
            # ---------------------------------------------------------#

## extract features ------------------------------------------------------------------

# only re-query-download if set to TRUE
if (query == TRUE) {
  
  ## make boundary box
  bb <- c(-77.5,38.7,-76.75,39.2)
  
  # extract bikeshare info as sf object
  osm_bike <- 
    opq(bbox = bb) %>% # larger box around Washington, DC metro area
    add_osm_feature("amenity", "bicycle_rental") %>%
    osmdata_sf()
  
  # set crs
  st_crs(osm_bike$osm_points) <- crs
  
  
  # extract metro stations info, save as sf object 
  osm_metro_query <- # note this query generates another layer of info
    opq(bbox = bb) %>%
    add_osm_feature(key = "public_transport",
                    value = "station") %>%
    osmdata_sf() # keep only metro stations
  
  osm_metro <- st_as_sf(osm_metro_query$osm_points) %>%
    filter(operator == "Washington Metropolitan Area Transit Authority" |
             operator == "Washington Metro Area Transit Authority") 
  
  # set crs
  st_crs(osm_metro) <- crs
  
  # save files 
  save(
    bb, osm_bike, osm_metro_query, osm_metro,
    file = file.path(data, "bks/data/maps/osm-bks-query.Rdata")
  )
  
} else {
  # otherwise, load saved query objects
  load(file = file.path(data, "bks/data/maps/osm-bks-query.Rdata"))
}





## join features with main dictionary ------------------------------------------------------

# make sf class
station_key <- 
  station_key %>%
  st_as_sf(., 
           coords = c("lng", "lat"), 
           na.fail = TRUE, 
           remove = FALSE) 

# set crs
st_crs(station_key) <- crs

# join station_key <- metro by nearest feature
station_key <- 
  station_key %>%
  st_join(.,  # imported gps coordinates of bikeshare stations from cabi
          osm_metro, # bikeshare station info from osm
          join = st_is_within_distance,
          left = TRUE,  # keep all obs from station key
          dist = bike_metro_dist,
          suffix = c(".x", ".y"),
          largest = FALSE
          ) %>%  # only match first within x meters, otherwise NA.
  rename(  # first rename BEFORE dropping vars
    name_bks   = name1, 
    name_bks2  = name2,
    name_bks3  = name3,
    name_metro = name
  ) %>%
  mutate(
    metro = !is.na(osm_id) # make an indicator if station is close to metro
  ) %>% 
  select(key_df_vars) # keep only vars defined above



## control for duplicate and na-matches ----------------------------------------------------------
# note: st_join doesn't have a way to control for NA matches or duplicates. What this
# means is that if there's an observation with (NA) for geometry, it seems to get
# matched to all observations in y. Also if there are two stations within the distnace
# threshold, I think it creates two lines, one for each station within the threshold.

# replace metro data with missing if geometry is missing (correct for no "na_matches=never")
station_key$osm_id[st_is_empty(station_key$geometry)] <- NA
station_key$metro[st_is_empty(station_key$geometry)] <- NA
station_key$name_metro[st_is_empty(station_key$geometry)] <- NA


# eliminate duplicates with the same project/bike station ID AND osmid
station_key <- 
  station_key %>%
  distinct(id_proj, osm_id, .keep_all = TRUE) # unique across project id for station and osm id




# pivot wider to make mutliple cols for each station within threshold
# note: at this point the duplicates are because there are mutliple stations 
# within the distance threshold, or there are stations with the same name but potentially
# two different entraces, etc -- but they have different ids in OpenStreetMap. We'll make
# all stations listed across horizonally 

station_key <-  
  station_key %>%
  group_by(id_proj) %>%
  st_drop_geometry() %>% # remove geometry to avoid disaster when pivoting
  mutate(n = row_number()) %>%
  pivot_wider(
    names_from =  n,
    values_from = c(osm_id, name_metro),
    values_fill = NA
    ) %>%
  st_as_sf(.,
           coords = c("lng", "lat"),
           na.fail = TRUE,
           remove = FALSE) %>% # replace geometry
  rename(name_metro = name_metro_1) # rename first name of metro station

st_crs(station_key) <- crs



## final name order changes ----
# the way that the names have been ordered has put the actual "colloquial" or more
# common use name in lower status order, so this code will fix that here and there

station_key$name_bks[station_key$name_bks == "Washington-Lee High School / N Stafford St & Generals Way"] <- 
  "Washington-Liberty High School / N Stafford St & Generals Way"
station_key$name_bks2[station_key$name_bks2 == "Washington-Liberty High School / N Stafford St & Generals Way"] <- 
  "Washington-Lee High School / N Stafford St & Generals Way"




## check that there are no duplicates in number_old, id_proj -----------------------

# check that id_project is unique project id
assertthat::assert_that(
  n_distinct(station_key$id_proj) == nrow(station_key)
)

# check that the number of rows is the same as before the duplicate checking 
assertthat::assert_that(
  nrow(station_key) == n_station_old
)

# check that all rows have non-missing geometry 
assertthat::assert_that(
  sum(st_is_empty(station_key$geometry)) == 0
)







                  # ---------------------------------------------------------#
                  #             simple map                           =======================
                  # ---------------------------------------------------------#

station_map <- mapview(station_key, label="name_bks", zcol = "metro")


## export ---------------------------------------------------------------------------
if (export == TRUE) {

# export station_key
saveRDS(station_key,
        file = file.path(processed, "keys/station_key.Rda")) 


# export objects we may need later as Rdata
save(
  osm_bike, osm_metro, osm_metro_query, station_old, cabi_coords,
  n_station_old,
  station_map,
  file = file.path(processed, "keys/station-geo-objects.Rdata")
)

# remove objects not needed
remove(bks, cabi_coords, namenumb, names_bks, osm_bike,
       osm_metro, station_key, station_old) 

gc()

}
