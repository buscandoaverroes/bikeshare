# sandbox.R
# exploring what to do after query.R

library(scales)
library(mapview)
library(leaflet)
library(leafpop)
library(ineq)
library(leafsync)

# load 2020 + stations ----------------------------------------------------------------------------------
bks2020 <- readRDS(file.path(processed, "data/years/bks_2020.Rda"))
bks1820 <- readRDS(file.path(processed, "data/years/bks_2018-20.Rda"))

station_key <- readRDS(file.path(processed, "keys/station_key.Rda")) %>%
  select(name_bks, id_proj, lat, lng, metro, name_metro) %>% # keep only necessary variables
  st_drop_geometry() # remove sf object

#

# merege with stations information -----------------------------------------------------------------------

bks2020 <-
  left_join( # join to start station
    bks2020, station_key, 
    by = c("id_start" = "id_proj"),
    na_matches = "never"
  ) %>% 
  left_join( # join to end, change suffix
    station_key, 
    by = c("id_end" = "id_proj"),
    na_matches = "never", 
    suffix = c("_st", "_end")
  )



bks1820 <-
  left_join( # join to start station
    bks1820, station_key, 
    by = c("id_start" = "id_proj"),
    na_matches = "never"
  ) %>% 
  left_join( # join to end, change suffix
    station_key, 
    by = c("id_end" = "id_proj"),
    na_matches = "never", 
    suffix = c("_st", "_end")
  )


# descriptive stats =============================================================

# station summaries
sum_station <- 
  bks1820 %>%
  mutate(metro_end_int = as.integer(metro_end),
         member_int    = as.integer(member)) %>%
  group_by(id_start, year) %>%
  summarize(
    name_bks_st= first(na.omit(name_bks_st)),
    metro      = first(na.omit(metro_st)),
    dur_med    = median(dur, na.rm = TRUE),
    dur_sd     = sd(dur, na.rm = TRUE),
    departures = n(),
    n_dest     = n_distinct(id_end),
    metro_end_pct= round(mean(metro_end_int, na.rm = TRUE), 3),
    member_pct = round(mean(member_int, na.rm = TRUE), 3)
  )


# try station summary with altered standard deviation formulas
sum_station_end <-
  bks1820 %>%
  filter(!is.na(id_start)) %>%
  group_by(id_start, id_end, year) %>%
  summarize(
    n_trip_to_end = n() # by destination number of trips
  ) %>%
  ungroup() %>% group_by(id_start, year) %>% # ungroup, regroup only by start id and year
  summarise(
    departures = sum(n_trip_to_end), # if you add all the by-destination number of trips = total number of station departures
    n_dest   = n_distinct(id_end), # number of distinct end stations
    sd       = round(sd(n_trip_to_end, na.rm = TRUE), 2), # this is our temporary measure of 'parity' in destination distribution
    dep_ineq = Gini(n_trip_to_end, na.rm = TRUE)
    )



# create top proportion
# tells us what percent of departures from a station go to a station that is in the 
# top 5% most gone-to stations
top05p <-
  bks1820 %>%
    #create list of total departures by station 
    group_by(id_start, id_end, year) %>%
    summarize(
      n_trip_to_end = n() # by destination number of trips
    ) %>%
    ungroup() %>% group_by(id_start, year) %>%
    slice_max(order_by = n_trip_to_end, prop = 0.05, with_ties = TRUE) %>% # create list of top 5% of destinations
    summarise( # note that using proportion rounds down, so if prop=0.1 and there are fewer than 10 destinations, the station is excluded.
      n_top05 = sum(n_trip_to_end)
    )


# join sum_station_end with top, create pct top p variable 
# This variable will tell us: what percent of rides that leave
# a station go to one of the stations in the top 5 % of destinations
# for that station. This is one measure of flow 'parity'.
sum_station_end <- 
  sum_station_end %>%
  left_join(top05p, # join to top percent
            by = c("id_start", "year"),
            na_matches = "never") %>%
  mutate(
    departures_pct_top05 = round( (n_top05/departures), 3) 
  )


# join two summary files 
sum <- 
  sum_station_end %>%
  select(-departures, -n_dest) %>% # already in sum_station
  left_join(sum_station,
            .,
            by = c("id_start", "year"))  # note, we lose 4 obs, why?
 



# add gps data 
station_map <- 
  sum %>%
  left_join(., station_key,
            by = c("id_start" = "id_proj")) %>%
  select(-metro.y) %>% rename(metro = metro.x) %>% # keep only one metro var
  st_as_sf(coords = c("lng", "lat"), na.fail = FALSE)

  
  


# export =============================================================================================
save(
  station_map,
  bks1820, bks2020,
  station_key,
  sum,
  sum_station_end, sum_station,
  file = file.path(processed, "data/sandbox.Rdata")
)







# graphs =========================================================================
# note, the only graphs I'll put here are ones that cannot be embedded in rmarkdown

# leafletmaps  ---------------------------------------------------------------------------------------------------

# make station_key into sf
key <- readRDS(file.path(processed, "keys/station_key.Rda")) %>%
  select(name_bks, id_proj, lat, lng, metro, name_metro)  # keep only necessary variables


# 4 pane map

st_crs(station_map) <- 4326

mapviewOptions(fgb = FALSE, basemaps = "CartoDB.Positron")
at_scale <- c(0, 500, 2000,5000,10000,20000,50000,100000)


# years
mv2018 <- mapview(station_map[station_map$year==2018,], 
                  zcol = c("departures"),
                  at = at_scale,
                  alpha.regions = 0.2,
                  layer.name = "2018",
                  popup = popupTable(
                    station_map,
                    zcol = c("name_bks", 
                             "name_metro", 
                             "departures",
                             "n_dest",
                             "sd",
                             "departures_pct_top05"))) 
mv2019 <- mapview(station_map[station_map$year==2019,], 
                  zcol = c("departures"),
                  at = at_scale,
                  alpha.regions = 0.2,
                  layer.name = "2019",
                  popup = popupTable(
                    station_map,
                    zcol = c("name_bks", 
                             "name_metro", 
                             "departures",
                             "n_dest",
                             "sd",
                             "departures_pct_top05"))) 
mv2020 <- mapview(station_map[station_map$year==2020,], 
                  zcol = c("departures"),
                  at = at_scale,
                  alpha.regions = 0.2,
                  layer.name = "2020",
                  popup = popupTable(
                    station_map,
                    zcol = c("name_bks", 
                             "name_metro", 
                             "departures",
                             "n_dest",
                             "sd",
                             "departures_pct_top05"))) 

mv2020_ineq <- mapview(station_map[station_map$year==2020,], 
                       zcol = c("dep_ineq"),
                       at = c(0, 0.5, 0.6, 0.7, 0.8, 0.9, 1),
                       alpha.regions = 0.2,
                       layer.name = "2020 Dest. Disparity",
                       popup = popupTable(
                         station_map,
                         zcol = c("name_bks", 
                                  "name_metro", 
                                  "departures",
                                  "n_dest",
                                  "sd",
                                  "departures_pct_top05"))) 

sync(mv2018, mv2019, mv2020, mv2020_ineq)
