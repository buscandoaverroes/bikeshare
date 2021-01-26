# stats17-20.R
# takes the file containting rides from years 2017-2020, processes, adds station info, creates summary
# station info

# sandbox.R
# exploring what to do after query.R

library(scales)
library(mapview)
library(leaflet)
library(leafpop)
library(ineq)
library(leafsync)

# load years 2017-20 file + stations ----------------------------------------------------------------------------------
bks1720 <- readRDS(file.path(processed, "data/years/bks_2017-20.Rda"))

station_key <- readRDS(file.path(processed, "keys/station_key.Rda")) %>%
  select(name_bks, id_proj, lat, lng, metro, name_metro) %>% # keep only necessary variables
  st_drop_geometry() # remove sf object

weather <- readRDS(file.path(processed, "data/weather/weather-daily.Rda"))


# join 2017-2020 file with stations information -----------------------------------------------------------------------

bks1720 <-
  left_join(        # join to start station
    bks1720, station_key, 
    by = c("id_start" = "id_proj"),
    na_matches = "never"
  ) %>% 
  left_join(        # join to end, change suffix
    station_key, 
    by = c("id_end" = "id_proj"),
    na_matches = "never", 
    suffix = c("_st", "_end")
  )


# descriptive stats =============================================================

# station summaries -------------------------------------------------------------

# create summary part a: DEPARTURES ~ - ~ - ~ - ~ - ~ - ~ - ~ - ~ - 
#   group: start station, year
#   stats: from start station -- duration, departures, etc

sum_station_a_dep <- 
  bks1720 %>%
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


# summary part a  -- arrivals + + + + + + + + + + + + + + + + + +
# variables to create:
#     dur_med_arrv   median duration of rides that end up at a given station
#     arrivals       number of all trip arrivals at a given station
#     n_arrv         number of the unique bike stations that bikes arrive from
#     metro_st_pct   percent of rides that arrive at a given station that begin within 250m of a metro station
#     arrv_ineq      the arrival inequity 

sum_station_a_arrv <-  
  bks1720 %>%
  mutate(metro_st_int = as.integer(metro_st),
         member_int    = as.integer(member)) %>%
    group_by(id_end, year) %>%    # group by end station, year
    summarize(
      dur_med_arrv = median(dur, na.rm = TRUE),
      dur_arrv_sd  = sd(dur, na.rm = TRUE),
      arrivals     = n(),
      n_arrv       = n_distinct(id_start),
      metro_st_pct = round(mean(metro_st_int, na.rm = TRUE), 3), # percent of rides that come from metro
      member_arrv_pct= round(mean(member_int, na.rm = TRUE), 3) # percentage of arrivals that are members
    ) 


# create summary part b: DEPARTURES  ~ - ~ - ~ - ~ - ~ - ~ - ~ - ~ -
#   group (2 part): start station, endstation, year //// start, year
#   stats: number to trips from each station to each station, gini
sum_station_b_dep <-
  bks1720 %>%
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



# create summary part b: arrivals + + + + + + + + + + + + + + + + + +
#   group (2 part): start station, endstation, year //// start, year
#   stats: number to trips from each station to each station, gini

sum_station_b_arrv <-
  bks1720 %>%
  filter(!is.na(id_end)) %>%
  group_by(id_start, id_end, year) %>%
  summarize(
    n_trip_to_end = n() # by destination number of trips
  ) %>%
  ungroup() %>% group_by(id_end, year) %>% # ungroup, regroup only by start id and year
  summarise(
    arrv_ineq = Gini(n_trip_to_end, na.rm = TRUE)
  )





# create top proportion
#   tells us what percent of departures from a station go to a station that is in the 
#   top 5% most gone-to stations
top05p <-
  bks1720 %>%
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


# join sum_station_b_dep with top, create pct top p variable 
#   This variable will tell us: what percent of rides that leave
#   a station go to one of the stations in the top 5 % of destinations
#   for that station. This is one measure of flow 'parity'.
sum_station_b_dep <- 
  sum_station_b_dep %>%
  left_join(top05p, # join to top percent
            by = c("id_start", "year"),
            na_matches = "never") %>%
  mutate(
    departures_pct_top05 = round( (n_top05/departures), 3) 
  )


# join four summary files, generate difference variables
sum_station <- 
  sum_station_a_dep %>%
  select(-departures, -n_dest) %>% # already in sum_station_b_dep
  left_join(sum_station_b_dep,
            .,
            by = c("id_start", "year")) %>%  # note, we lose 4 obs, why?
  left_join(.,
            sum_station_a_arrv,
            by = c( "id_start" = "id_end", "year")) %>% 
  left_join(.,
            sum_station_b_arrv,
            by = c("id_start" = "id_end", "year")) %>% 
  rename(id_station = id_start) %>% 
  mutate(   #  compare the equivalent arrival and departure statistic: ARRIVAL - Departure
    net_flow       = arrivals - departures, # positive means more arrivals than departures
    net_med_dur    = dur_med_arrv - dur_med, # pos means median dur is greater coming in than leaving
    dif_member_pct = member_arrv_pct - member_pct, # positive means greater % of incoming rides are members
    dif_metro_pct  = metro_st_pct - metro_end_pct # positive means greater % of incoming ridess are coming from metro
  )   # note, we lose 4 obs, why?


# make an sf version of sum_station with gps coords -----------------------------------------------------
sum_station_sf <- 
  sum_station %>%
  left_join(., station_key,
            by = c("id_station" = "id_proj")) %>%
  select(-metro.y) %>% rename(metro = metro.x) %>% # keep only one metro var
  st_as_sf(coords = c("lng", "lat"), na.fail = FALSE, remove = FALSE)

st_crs(sum_station_sf) <- 4326






# make simple count of start-to-end for all combinations --------------------------------------------------

start_end <-   
  bks1720 %>%
  group_by(year, id_start, id_end) %>%
  summarise(n_depart = n(),
            lat_st   = first(lat_st),
            lng_st   = first(lng_st),
            lat_end  = first(lat_end),
            lng_end  = first(lng_end))





# by-day summary with weather ----------------------------------------------------------------------------
days1720 <- 
  bks1720 %>%
  mutate(day_of_yr = as.integer(yday(leave))) %>%
  group_by(year, day_of_yr) %>% summarise(
    nrides      = n(),
    dur_med     = round(median(dur, na.rm = TRUE), 1),
    dur_sd      = round(sd(dur, na.rm = TRUE), 2),
    weekend     = first((wday == 1 | wday == 7))
  ) %>%
  left_join(., weather, 
       by = c('year', 'day_of_yr')) %>%
  select(-date, -station, -fl_m, -fl_q, -fl_so, -fl_t,     
         -PRCP, -TMAX, -datetime)







# export =============================================================================================
save(
  days1720,
  sum_station_sf,
  bks1720,
  start_end,
  station_key,
  sum_station,
  sum_station_b_dep, sum_station_b_dep,
  file = file.path(processed, "data/stats17-20.Rdata")
)

