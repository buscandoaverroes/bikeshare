# recollect.R
# generates a new/original dataset by recollecting old data, as Plato might.


key <- readRDS(file.path(processed, "keys/station_key.Rda"))

# append + export daily rides ===============================================

bks1014 <- readRDS(file.path(processed, "data/stats10-14/bks1014-weather.Rda"))
bks1516 <- readRDS(file.path(processed, "data/stats15-16/bks1516-weather.Rda"))
bks1721 <- readRDS(file.path(processed, "data/stats17-21/bks1721-weather.Rda"))

bks_plato <- bind_rows(
  bks1014, bks1516, bks1721
)


# load the Rdata file containing the original number of rows
load(file.path(processed, "data/bks-full-misc-data.Rda")) # opens `n_rides`

# if the number of rows hasn't changed from the original, drop original and components
if (assert_that(n_rides == nrow(bks_plato))) {
  rm(bks1014, bks1516, bks1721)
  
  # filter out motivate office
  bks_plato <- bks_plato %>%
    ungroup() %>% 
    filter(if_all(c("id_start", "id_end"), 
                  ~ . != 433 & 
                    . != 432))
}


# export
saveRDS(bks_plato, file = file.path(processed, "data/plato/daily-rides.Rda"), compress = FALSE)


# create light version 
bks_plato %>%
  select(year, hour, id_start, id_end, member) %>%
  saveRDS(., file = file.path(processed, "data/plato/daily-rides-light.Rda"), compress = FALSE)

# create by hour version 
loc <- select(key, id_proj, name_bks) # extract location info

station_hr <- bks_plato %>%
  group_by(id_start, year, hour) %>%
  summarize(hourly_dep = n(),
            member_pct = 100*round(mean(member),3)) %>%
  left_join(loc, by = c('id_start'='id_proj'))

saveRDS(station_hr, file = file.path(processed, "data/plato/station-hour.Rda"), compress = FALSE)



rm(bks_plato, loc, station_hr)



# append + export sum_stations ===============================================

sum_station1014 <- readRDS(file.path(processed, "data/stats10-14/sum-station.Rda"))
sum_station1516 <- readRDS(file.path(processed, "data/stats15-16/sum-station.Rda"))
sum_station1721 <- readRDS(file.path(processed, "data/stats17-21/sum-station.Rda"))


# Bind Rows 
# Note: can't verify correct row number since no original by-station-day object
sum_station_plato <- bind_rows(
  sum_station1014, sum_station1516, sum_station1721
)

# filter out motivate office
sum_station_plato <- sum_station_plato %>%
  ungroup() %>% 
  filter(if_all(c("id_station"), 
                ~ . != 433 & 
                  . != 432))

# export
saveRDS(sum_station_plato,
        file = file.path(processed, "data/plato/sum-station.Rda"), compress = FALSE)
rm(sum_station_plato, sum_station1014, sum_station1516, sum_station1721)




# append + export sum_station by year ===============================================

sum_station_yr1014 <- readRDS(file.path(processed, "data/stats10-14/sum-station-yr.Rda"))
sum_station_yr1516 <- readRDS(file.path(processed, "data/stats15-16/sum-station-yr.Rda"))
sum_station_yr1721 <- readRDS(file.path(processed, "data/stats17-21/sum-station-yr.Rda"))


# Bind Rows 
# Note: can't verify correct row number since no original by-station-day object
sum_station_yr_plato <- bind_rows(
  sum_station_yr1014, sum_station_yr1516, sum_station_yr1721
)
nrow.ssyr <- nrow(sum_station_yr_plato)

# merge with station key
key <- readRDS(file.path(processed, "keys/station_key.Rda")) %>% select(id_proj, lat, lng) 
sum_station_yr_plato <-
  sum_station_yr_plato %>%
  left_join(key, by = c("id_station" = "id_proj"), na.matches = "never") 

# check merge quality 
assertthat::assert_that(nrow(sum_station_yr_plato) == nrow.ssyr)


# filter out motivate office
sum_station_yr_plato <- sum_station_yr_plato %>%
  ungroup() %>% 
  filter(if_all(c("id_station"), 
                ~ . != 433 & 
                  . != 432))

# export
saveRDS(sum_station_yr_plato,
        file = file.path(processed, "data/plato/sum-station-yr.Rda"), compress = FALSE)
rm(sum_station_yr_plato, sum_station_yr1014, sum_station_yr1516, sum_station_yr1721, key)







# append + export day summaries ===============================================
# note that to/from motivate rides will be kept here for the time being...
days1014 <- readRDS(file.path(processed, "data/stats10-14/days.Rda"))
days1516 <- readRDS(file.path(processed, "data/stats15-16/days.Rda"))
days1721 <- readRDS(file.path(processed, "data/stats17-21/days.Rda"))


# Bind Rows 
# Note: can't verify correct row number since no original by-station-day object
days_plato <- bind_rows(
  days1014, days1516, days1721
)


# export
saveRDS(days_plato,
        file = file.path(processed, "data/plato/days.Rda"), compress = FALSE)
rm(days_plato, days1014, days1516, days1721)

