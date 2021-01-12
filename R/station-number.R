# -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- #
# Name: station-number.R
# Description: creates a dictionary of station numbers between old and new numbers 
# Note: this is run within the station-number script so no packages/data should be needed.
# -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- #

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
    )


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





            
            # ---------------------------------------------------------#
            #       incorporate open street map id numbers              =======================
            # ---------------------------------------------------------#

# extract features ------------------------------------------------------------------

# extract bikeshare info as sf object
osm_bike <- getbb("Washington, DC") %>% # query...and add features
  opq() %>%
  add_osm_feature("amenity", "bicycle_rental") %>%
  osmdata_sf()

# extract metro stations info, save as sf object
osm_metro <- getbb("Washington, DC") %>% # query and add metro features
  opq() %>%
  add_osm_feature("railway", "station") %>%
  osmdata_sf()




# join features with main dictionary ------------------------------------------------------

# join by closest name

station_key <- 
  st_join(stngps,  # imported gps coordinates of bikeshare stations from cabi
          osm_bike$osm_points, # bikeshare station info from osm
          join = st_nearest_feature, # merge by nearest proximity
          left = TRUE # return the left join
  )





# export as Rda ---------------------------------------------------------------------------
  saveRDS(station_key,
          file = file.path(processed, "station_key.Rda")) 

remove(nn, nn.w, namenumb)

