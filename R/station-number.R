# -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- #
# Name: station-number.R
# Description: creates a dictionary of station numbers between old and new numbers 
# Note: this is run within the station-number script so no packages/data should be needed.
# -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- #

# key variables: first applied after merge with OSM data 
key_df_vars <- c(
    "name_bks",   "number_old",
    "number_new","idproj",
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
station_old <- bks %>% filter(start_number > 30000) %>% distinct(start_number) # old numbers are all greater than 30,000
n_station_old <- n_distinct(station_old$start_number, na.rm = TRUE)

station_new <- bks %>% filter(start_number < 30000) %>% distinct(start_number) # old numbers are all less than 30,000
n_station_new <- n_distinct(station_new$start_number, na.rm = TRUE)








                  # ---------------------------------------------------------#
                  #  create unique internal cabi key for name string to old-new number =================
                  # ---------------------------------------------------------#

# create old/new from bks
# this should have dup strings with first row as "new" number and second "old" number
namenumb <- bks %>%
  group_by(start_name, start_number) %>%
  summarise() %>%
  filter(start_name != "")   # remove blank entries

# generate group id 
namenumb$group <- group_indices(namenumb)

# generate id within groups 
nn <- namenumb %>%
  group_by(group) %>%
  mutate(id = row_number() ## why will this not generate! apparently it will
  )

# pivot to wider 
nn.w <- spread(nn,
               key = id, 
               value = start_number) %>%
  rename(new = "1" , # change names
         old = "2",
         misc = "3")

# move values to correct new and old columns ---------------------------------

# move low old values to new 
for (i in seq_along(nn.w$new)) {
  nn.w$new[i] <- ifelse((nn.w$old[i] < 30000) 
                        & (!is.na(nn.w$old[i])) , # old value should be < 30000
                        nn.w$old[i], # if true, replace new with old
                        nn.w$new[i]) # if false, replace with self, true for row 120
}

# move high values in new to old
for (i in seq_along(nn.w$old)) {
  nn.w$old[i] <- ifelse((nn.w$new[i] > 30000) 
                        & (!is.na(nn.w$new[i])) , # old value should be < 30000
                        nn.w$new[i], # 
                        nn.w$old[i]) # 
}

# do for column 3 
for (i in seq_along(nn.w$old)) {
  nn.w$old[i] <- ifelse((nn.w$misc[i[]] > 30000) & 
                          (!is.na(nn.w$misc[i])), # old value should be < 30000
                        nn.w$misc[i], #
                        nn.w$old[i]) # 
}

# (for those with no 'new' value) replace new with missing
for (i in seq_along(nn.w$new)) {
  nn.w$new[i] <- ifelse((nn.w$new[i] > 30000) & (!is.na(nn.w$new[i])) , # old value should be < 30000
                        NA, #  replace with missing, indicating not in new cat system
                        nn.w$new[i]) # otherwise replace with valid, new number 
}


# add and remove variables -----------------------------------------------------------

# remove misc var, drop unecessary objects 
station_key <- data.frame(nn.w) %>%
  select(start_name, old, new) %>%
  rename(
    number_old = old,
    number_new = new,
    name = start_name
  )


# generate project id
station_key <- 
  station_key %>%
  arrange(name) %>% 
  mutate(
    idproj = row_number()
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
            by = c("number_new" = "start_number")) %>%
  rename(lat = start_lat, lng = start_lng)






# eliminate duplicates ------------------------------------------------------------
# if there are two different station name strings under the same old or new station
# number, just keep the row with the valid gps coords since the authoritative 
# source will be the station number anyway


station_key <- 
  station_key %>%
  add_count(number_old) %>% # add number of rows with same number_old
  group_by(number_old) %>%
  arrange(number_new, .by_group = TRUE) %>% # sorting by number_new always puts NA last
  filter( # keep if theres only one value per id OR if there are more than 1 value, keep only 
    (n == 1) |     # those that have lat not missing
      (is.na(lat) == FALSE & n>1)
    ) %>%
  select(-n) # remove n column


# checking unique station numbers in the background

# math
n_distinct(station_key$number_new) # 613, should be 614
n_distinct(station_key$number_old, na.rm = TRUE) # 587, should be 587

# what is the station id that is not in this key but in bks?
station_new$start_number %in% station_key$number_new # it's new station number 285
bks %>% filter(start_number == 285) # identify obs at station 285

# final checks 
# note that new station number 285 is the motivate tech office, with only 8 observations 
# and no GPS info. We will omit this station. Therefore, the unique new station number count
# should be 1 fewer than station_new object

# new stations
assertthat::assert_that(
  n_distinct(station_key$number_new) + 1 == n_station_new
)

# old stations
assertthat::assert_that(
  n_distinct(station_key$number_old, na.rm = TRUE) == n_station_old
)


# store number of rows 
rowcheck1 <- nrow(station_key)

            
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
    name_bks   = name.x, 
    name_metro = name.y
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
  distinct(idproj, osm_id, .keep_all = TRUE) # unique across project id for station and osm id




# pivot wider to make mutliple cols for each station within threshold
# note: at this point the duplicates are because there are mutliple stations 
# within the distance threshold, or there are stations with the same name but potentially
# two different entraces, etc -- but they have different ids in OpenStreetMap. We'll make
# all stations listed across horizonally 

station_key <-  
  station_key %>%
  group_by(idproj) %>%
  st_drop_geometry() %>% # remove geometry to avoid disaster when pivoting
  mutate(n = row_number()) %>%
  pivot_wider(
    names_from =  n,
    values_from = c(osm_id, name_metro),
    values_fill = NA
    ) %>%
  st_as_sf(., coords = c("lng", "lat"), na.fail = FALSE, remove = FALSE) # replace geometry


# check that the number of rows is the same as before the duplicate checking 
assertthat::assert_that(
  nrow(station_key) == rowcheck1
)



# pivot wider to accomodate for stations with multiple names
# some stations appear to have name changes over time but do
# not seem to move locations in any practical sense (it may be
# that the stations move across the street, for example, but  
# not 3 blocks away, etc). For these cases, we want to make sure
# that there are no duplicate old or new id numbers for each row
# of the station names. Thus, we'll pivot wider to allow for 
# multiple name columns. 

# store subset of dataset that does not have a valid value for number_new
station_key_newmiss <- 
  station_key %>%
  filter(is.na(number_new))


# remove this subset from the main dataset, spread across new number
# Note: this will only work properly if you have a nonmissing value 
# for number_new
station_key <- 
  station_key %>%
  filter(!is.na(number_new)) %>%
  ungroup() %>% # undo previous grouping
  #mutate(row = row_number()) %>%
  st_drop_geometry() %>% # remove geometry to avoid disaster when pivoting
  group_by(number_new) %>% # is this right?
  arrange(idproj) %>% # keep the project id of the lowest one
  mutate( # make numbers for each of the unique names per number_new, only if number_new is nonmissing
    it = if_else(!is.na(number_new), # condition
                true = row_number(),
                false= as.integer(1))
  ) %>%
  ungroup() %>%
  pivot_wider(
    names_from =  it,
    values_from = c(name_bks, idproj, number_old), # should be number_old, but get not unique
    values_fill = NA
  ) %>%
  st_as_sf(., coords = c("lng", "lat"), na.fail = FALSE, remove = FALSE) %>% # replace geometry
  rename(  # rename old variables
    name_bks = name_bks_1,
    name_metro = name_metro_1,
    osm_id = osm_id_1,
    idproj = idproj_1,
    number_old = number_old_1
    ) %>%
  bind_rows(station_key_newmiss) %>% # reincorporate 
  select(key_df_vars, everything()) %>% # reorder
  arrange(idproj) # sort 
  
# check that there are no duplicates in number_old, number_new, idproj -----------------------

# final checks 
# note that new station number 285 is the motivate tech office, with only 8 observations 
# and no GPS info. We will omit this station. Therefore, the unique new station number count
# should be 1 fewer than station_new object

# new stations
assertthat::assert_that(
  n_distinct(station_key$number_new) + 1 == n_station_new
)

# old stations
assertthat::assert_that(
  # note: must include id's in the second column
  n_distinct(c(station_key$number_old, station_key$number_old_2), na.rm = TRUE) == n_station_old
)

# check that idproject is unique project id
assertthat::assert_that(
  n_distinct(station_key$idproj) == nrow(station_key)
)




# export ---------------------------------------------------------------------------
  
# export station_key
saveRDS(station_key,
        file = file.path(processed, "keys/station_key.Rda")) 


# export objects we may need later as Rdata
save(
  osm_bike, osm_metro, station_new, station_old, cabi_coords,
  station_new, station_old,
  file = file.path(processed, "data/station-geo-objects.Rdata")
)

# remove objects not needed
remove(cabi_coords, namenumb, names_bks, nn, nn.w, osm_bike,
       osm_metro, station_key, station_new, station_old, bks) 

