# -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- #
# Name: station-number.R
# Description: creates a dictionary of station numbers between old and new numbers 
# Note: this is run within the station-number script so no packages/data should be needed.
# -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- #

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
station_old <- bks %>% distinct(start_number) 
n_station_old <- n_distinct(station_old$start_number, na.rm = TRUE)




                  # ---------------------------------------------------------#
                  #         create station name-number dictionary            =================
                  # ---------------------------------------------------------#

# create distinct name-number dictionary: this will have duplicates across numbers because 
# there will be stations with different spellings of names with the same number.
namenumb <- bks %>%
  group_by(start_name, start_number) %>%
  summarise() %>%
  filter(start_name != "") %>%   # remove blank entries
  ungroup() %>% group_by(start_number) %>%
  arrange(start_name) %>% # arrnage by alpha within same group number
  mutate(id = row_number()) %>%
  pivot_wider(names_from = id, # pivot wider
              values_from = start_name) %>%
  filter(start_number > 0 ) # remove stations that are disabled
  

# check that there are the same number of unique station numbers as in n_station_old
assertthat::assert_that(
  n_distinct(namenumb$start_number) == n_station_old
)




# add and remove variables ---------------------------------------------------------------------

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




# merge with gps coordinates from "new" stations ----------------------------------------------------

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






            # ---------------------------------------------------------#
            #       incorporate open street map id numbers              =======================
            # ---------------------------------------------------------#

# extract features ------------------------------------------------------------------

# extract bikeshare info as sf object
osm_bike <- getbb("Washington, DC") %>% # query...and add features
  opq() %>%
  add_osm_feature("amenity", "bicycle_rental") %>%
  osmdata_sf()

# set crs
st_crs(osm_bike$osm_points) <- crs


# extract metro stations info, save as sf object
osm_metro <- getbb("Washington, DC") %>% # query and add metro features
  opq() %>%
  add_osm_feature("railway", "station") %>%
  osmdata_sf() 

# set crs
st_crs(osm_metro$osm_points) <- crs



# join features with main dictionary ------------------------------------------------------

# make sf class
station_key <- 
  station_key %>%
  st_as_sf(., coords = c("lng", "lat"), na.fail = FALSE, remove = FALSE) 

# set crs
st_crs(station_key) <- crs

# join station_key <- metro by nearest feature
station_key <- 
  station_key %>%
  st_join(.,  # imported gps coordinates of bikeshare stations from cabi
          osm_metro$osm_points, # bikeshare station info from osm
          join = st_is_within_distance,
          left = TRUE,  # keep all obs from station key
          dist = bike_metro_dist,
          suffix = c(".x", ".y"),
          na_matches = "never",
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



# control for duplicate and na-matches ----------------------------------------------------------
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
  st_as_sf(., coords = c("lng", "lat"), na.fail = FALSE, remove = FALSE) # replace geometry



# check that there are no duplicates in number_old, id_proj -----------------------

# check that id_project is unique project id
assertthat::assert_that(
  n_distinct(station_key$id_proj) == nrow(station_key)
)

# check that the number of rows is the same as before the duplicate checking 
assertthat::assert_that(
  nrow(station_key) == n_station_old
)





# export ---------------------------------------------------------------------------
if (TRUE) {

# export station_key
saveRDS(station_key,
        file = file.path(processed, "keys/station_key.Rda")) 


# export objects we may need later as Rdata
save(
  osm_bike, osm_metro, station_old, cabi_coords,
  n_station_old,
  file = file.path(processed, "data/station-geo-objects.Rdata")
)

# remove objects not needed
remove(bks, cabi_coords, namenumb, names_bks, osm_bike,
       osm_metro, station_key, station_old) 

}
