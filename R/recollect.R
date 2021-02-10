# recollect.R
# generates a new/original dataset by recollecting old data, as Plato might.

# append + export daily rides ===============================================

bks1014 <- readRDS(file.path(processed, "data/stats10-14/bks1014-weather.Rda"))
bks1516 <- readRDS(file.path(processed, "data/stats15-16/bks1516-weather.Rda"))
bks1720 <- readRDS(file.path(processed, "data/stats17-20/bks1720-weather.Rda"))

bks_plato <- bind_rows(
  bks1014, bks1516, bks1720
)


# load the original
bks <- fread(file.path(raw, "bks-import.csv"), na.strings = "")


# if the number of rows hasn't changed from the original, drop original and components
if (assertthat::assert_that(nrow(bks) == nrow(bks_plato))) {
  rm(bks, bks1014, bks1516, bks1720)
}


# export
saveRDS(bks_plato, file = file.path(processed, "data/plato/daily-rides.Rda"), compress = FALSE)
rm(bks_plato)






# append + export sum_stations ===============================================

sum_station1014 <- readRDS(file.path(processed, "data/stats10-14/sum-station.Rda"))
sum_station1516 <- readRDS(file.path(processed, "data/stats15-16/sum-station.Rda"))
sum_station1720 <- readRDS(file.path(processed, "data/stats17-20/sum-station.Rda"))


# Bind Rows 
# Note: can't verify correct row number since no original by-station-day object
sum_station_plato <- bind_rows(
  sum_station1014, sum_station1516, sum_station1720
)


# export
saveRDS(sum_station_plato,
        file = file.path(processed, "data/plato/sum-station.Rda"), compress = FALSE)
rm(sum_station_plato, sum_station1014, sum_station1516, sum_station1720)




# append + export sum_station by year ===============================================

sum_station_yr1014 <- readRDS(file.path(processed, "data/stats10-14/sum-station-yr.Rda"))
sum_station_yr1516 <- readRDS(file.path(processed, "data/stats15-16/sum-station-yr.Rda"))
sum_station_yr1720 <- readRDS(file.path(processed, "data/stats17-20/sum-station-yr.Rda"))


# Bind Rows 
# Note: can't verify correct row number since no original by-station-day object
sum_station_yr_plato <- bind_rows(
  sum_station_yr1014, sum_station_yr1516, sum_station_yr1720
)
nrow.ssyr <- nrow(sum_station_yr_plato)

# merge with station key
key <- readRDS(file.path(processed, "keys/station_key.Rda")) %>% select(id_proj, lat, lng) %>% st_drop_geometry()
sum_station_yr_plato <-
  sum_station_yr_plato %>%
  left_join(key, by = c("id_station" = "id_proj"), na.matches = "never") 

# check merge quality 
assertthat::assert_that(nrow(sum_station_yr_plato) == nrow.ssyr)


# export
saveRDS(sum_station_yr_plato,
        file = file.path(processed, "data/plato/sum-station-yr.Rda"), compress = FALSE)
rm(sum_station_yr_plato, sum_station_yr1014, sum_station_yr1516, sum_station_yr1720, key)







# append + export day summaries ===============================================

days1014 <- readRDS(file.path(processed, "data/stats10-14/days.Rda"))
days1516 <- readRDS(file.path(processed, "data/stats15-16/days.Rda"))
days1720 <- readRDS(file.path(processed, "data/stats17-20/days.Rda"))


# Bind Rows 
# Note: can't verify correct row number since no original by-station-day object
days_plato <- bind_rows(
  days1014, days1516, days1720
)


# export
saveRDS(days_plato,
        file = file.path(processed, "data/plato/days.Rda"), compress = FALSE)
rm(days_plato, days1014, days1516, days1720)

