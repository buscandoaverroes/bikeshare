# sandbox.R
# exploring what to do after query.R

library(scales)
library(mapview)
library(leaflet)
library(leafpop)
library(ineq)

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


# try station summary with altered standard deviation forumla
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

# join two summary files 
sum <- 
  sum_station_end %>%
  select(-departures, -n_dest) %>% # already in sum_station
  left_join(sum_station,
            .,
            by = c("id_start", "year")) # note, we lose 4 obs, why?


# create top proportion
# tells us what percent of departures from a station go to a station that is in the 
# top 5% most gone-to stations
top05p <-
  bks2020 %>%
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


# create top n=3
# tells us what percent of departures from a station go to a station that is in the 
# top 3 most gone-to stations
top3n <-
  bks2020 %>%
  #create list of total departures by station 
  group_by(id_start, id_end, year) %>%
  summarize(
    n_trip_to_end = n() # by destination number of trips
  ) %>%
  ungroup() %>% group_by(id_start, year) %>%
  slice_max(order_by = n_trip_to_end, n = 3, with_ties = TRUE) %>% # create list of top 5% of destinations
  summarise( # note that using proportion rounds down, so if prop=0.1 and there are fewer than 10 destinations, the station is excluded.
    n_top3 = sum(n_trip_to_end)
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
  left_join(top3n, # join to top percent
            by = c("id_start", "year"),
            na_matches = "never") %>%
  mutate(
    departures_pct_top05 = round( (n_top05/departures), 3), 
    departures_n_top3    = round( (n_top3/departures), 3),
  )

# add gps data 
station_map <- 
  sum_station_end %>%
  left_join(., station_key,
            by = c("id_start" = "id_proj")) %>%
  st_as_sf(coords = c("lng", "lat"), na.fail = FALSE)

  
  


# export =============================================================================================
save(
  station_map,
  bks1820, bks2020,
  station_key,
  sum_station_end, sum_station,
  file = file.path(processed, "data/sandbox.Rdata")
)


# graphing break! ------------------------------------------------------------------------------------


sum_station_end %>%
  filter(departures >= 100) %>% # include only stations at least 100 departures
  ggplot(., aes(n_dest,dep_ineq, size=departures)) +
  geom_point(alpha = 0.5) + 
  ylim(.25,1) 
 # scale_x_log10() +
  facet_grid(rows=vars(year)) 

sum_station_end %>%
  filter(departures >= 100) %>% # include only stations at least 100 departures
  ggplot(., aes(departures, departures_pct_top05, size = n_dest)) +
  geom_point(alpha = 0.5) + 
# scale_x_log10() +
facet_grid(rows=vars(year)) 
  





# graphs =========================================================================

# departure gini histogram
#     most ginis are between 0.5 and .8
ggplot(sum_station_end, aes(dep_ineq)) +
  geom_histogram() 

# destination gini vs top05p
# 
ggplot(sum_station_end, aes(dep_ineq, departures_pct_top05)) +
  geom_point()


# duration histogram
ggplot(bks1820, aes(dur)) +
  geom_histogram() +
  geom_vline(xintercept=30) +
  xlim(0,100)
  

# violin plot of duration on member vs non member
ggplot(bks1820, aes(member, dur)) +
  geom_violin(scale = "area") +
  ylim(0,100)


# station summaries ------------------------------------------------------------
# median duration
ggplot(sum_station, aes(dur_med)) +
  geom_histogram(stat = 'bin', binwidth = 1, alpha = 0.7) + 
  geom_vline(aes(xintercept = 30)) +
  facet_grid(rows = vars(year)) +
  xlim(0,45)

# number of destinations 
ggplot(sum_station, aes(n_dest)) +
  geom_area(stat = 'bin', binwidth = 20, alpha = 0.7) + 
  facet_grid(rows = vars(year))

# departures 
ggplot(sum_station, aes(departures)) +
  geom_histogram(stat = 'bin', binwidth = 1000) + 
  facet_grid(rows = vars(year)) + 
  xlim(0,40000)

# departures/nrides, by year 
bks1820 %>%
  group_by(year) %>% summarize(n = n()) %>%
  ggplot(., aes(year, n)) +
  geom_col() + scale_y_continuous(labels = comma)

# pct of rides going to station near metro 
sum_station %>%
  filter(departures >= 100) %>% # include only stations at least 100 departures
  ggplot(., aes(metro_end_pct)) +
  geom_histogram() + 
  facet_grid(rows=vars(year))

sum_station %>%
  filter(departures >= 100) %>% # include only stations at least 100 departures
  ggplot(., aes(member_pct, metro_end_pct)) +
  geom_point(alpha = 0.4) +
  facet_grid(rows=vars(year))

# member percent vs median duration
sum_station %>%
  filter(departures >= 100) %>% # include only stations at least 100 departures
  ggplot(., aes(member_pct, dur_med, color = metro_end_pct, size = departures)) +
  geom_point(alpha = 0.2) +
  facet_grid(rows=vars(year)) 


# departures vs number of distinct destinations
sum_station %>%
  filter(departures >= 100) %>% # include only stations at least 100 departures
  ggplot(., aes(departures, n_dest, color = metro_end_pct)) +
  geom_point(alpha = 0.5) + 
  scale_x_log10() +
  facet_grid(rows=vars(year)) 

# leafletmaps  ---------------------------------------------------------------------------------------------------

# make station_key into sf
key <- readRDS(file.path(processed, "keys/station_key.Rda")) %>%
  select(name_bks, id_proj, lat, lng, metro, name_metro)  # keep only necessary variables

st_crs(station_map) <- 4326

mapviewOptions(fgb = FALSE, basemaps = "CartoDB.Positron") # i want true, but doesn't work...
mapview(station_map, zcol = c("departures"),
        popup = popupTable(
          station_map,
          zcol = c("name_bks", 
                    "name_metro", 
                    "departures",
                    "n_dest",
                    "sd",
                    "departures_pct_top05")))
