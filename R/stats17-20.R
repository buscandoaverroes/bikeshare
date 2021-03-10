# stats17-20.R
# takes the file containting rides from years 2017-2020, processes, adds station info, creates summary
# station info

library(scales)
library(mapview)
library(leaflet)
library(leafpop)
library(ineq)
library(leafsync)


# load years 2017-20 file + stations ----------------------------------------------------------------------------------
bks1720 <- readRDS(file.path(processed, "data/years/bks_2017-20.Rda"))
nrow_bks1720 <- nrow(bks1720)

station_key <- readRDS(file.path(processed, "keys/station_key.Rda")) %>%
  select(name_bks, id_proj, lat, lng, metro, name_metro) %>% # keep only necessary variables
  st_drop_geometry() # remove sf object

weather <- readRDS(file.path(processed, "data/weather/weather-daily.Rda")) %>%
  mutate(week_of_yr = as.integer(week(datetime))) %>%
  select(year, week_of_yr, day_of_yr, tempmax, precip) # reduce variables

# replace negative duration with station-week median duration -----------------------------------------------------------
# I'm doing this because there are about 2,000 rides that have start times that appear in the raw data AFTER the end times,
# which result in negative durations. I don't want to simply drop these rides, because that may disproportionately reduce the
# number of departures, etc. so I will replace negative values with the station-wweek median.

# create a duration0 variable where the lowest possible duraiton is 0, or NA
bks1720$dur0 <- bks1720$dur
bks1720$dur0[bks1720$dur0 < 0] <- NA 

bks1720 <-
  bks1720 %>%
  mutate(week = week(leave),
         date = date(leave)) %>%
  group_by(id_start, week) %>%
  mutate(   # create a median duration for each station-year
    sta_dur_med = as.integer(round(median(dur0, na.rm = TRUE)))
  ) 

bks1720 <-
  bks1720 %>%
  mutate(
    dur = if_else(
      dur < 0,  # if the ride duration is negative...
      true = sta_dur_med, # ...replace the value with the station-week's median duration
      false= dur # otherwise keep the original value
    )
  ) %>%
  select(-dur0, -sta_dur_med) # remove variables

# join 2017-2020 file with stations info, weather -----------------------------------------------------------------------

bks1720 <-
  bks1720 %>%
  left_join(        # join to start station
    ., station_key, 
    by = c("id_start" = "id_proj"),
    na_matches = "never"
  ) %>%
  left_join(        # join to end, change suffix
    station_key, 
    by = c("id_end" = "id_proj"),
    na_matches = "never", 
    suffix = c("_st", "_end")
  )  %>% 
  mutate(
    day_of_yr   = as.integer(yday(leave)),
    weekend     = if_else((wday == 1 | wday == 7), true = TRUE, false = FALSE),
  ) %>%
  left_join(weather,
    by = c("year", "day_of_yr"),
    na_matches = "never"
  ) 


# ensure the number of rows hasn't been altered
assertthat::assert_that( # 12915580
  nrow(bks1720) == nrow_bks1720
)




# station-year-day summaries ===========================================================================

# create summary part a: DEPARTURES ~ - ~ - ~ - ~ - ~ - ~ - ~ - ~ - 
#   group: start station, year, day_of_yr
#   stats: from start station -- duration, departures, etc

sum_station_a_dep <- 
  bks1720 %>%
  mutate(
    metro_end_int = as.integer(metro_end),
    member_int    = as.integer(member)
    ) %>%
  group_by(id_start, date, year, month, wday, day_of_yr) %>%
  summarize(
    name_bks_st= first(na.omit(name_bks_st)),
    metro      = first(na.omit(metro_st)),
    dur_med    = median(dur, na.rm = TRUE),
    dur_sd     = sd(dur, na.rm = TRUE),
    departures = n(),
    n_dest     = n_distinct(id_end),
    metro_end_pct= round(mean(metro_end_int, na.rm = TRUE), 3),
    member_pct = round(mean(member_int, na.rm = TRUE), 3),
    weekend    = first(weekend)
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
    group_by(id_end, year, day_of_yr) %>%    # group by end station, year
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
  group_by(id_start, id_end, year, day_of_yr) %>%
  summarize(
    n_trip_to_end = n() # by destination number of trips
  ) %>%
  ungroup() %>% group_by(id_start, year, day_of_yr) %>% # ungroup, regroup only by start id and year
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
  group_by(id_start, id_end, year, day_of_yr) %>%
  summarize(
    n_trip_to_end = n() # by destination number of trips
  ) %>%
  ungroup() %>% group_by(id_end, year, day_of_yr) %>% # ungroup, regroup only by start id and year
  summarise(
    arrv_ineq = Gini(n_trip_to_end, na.rm = TRUE)
  )





# join four summary files, generate difference variables
sum_station <- 
  sum_station_a_dep %>%
  select(-departures, -n_dest) %>% # already in sum_station_b_dep
  left_join(sum_station_b_dep,
            .,
            by = c("id_start", "year", "day_of_yr")) %>%  # note, we lose 4 obs, why?
  left_join(.,
            sum_station_a_arrv,
            by = c( "id_start" = "id_end", "year", "day_of_yr")) %>% 
  left_join(.,
            sum_station_b_arrv,
            by = c("id_start" = "id_end", "year", "day_of_yr")) %>% 
  rename(id_station = id_start) %>% 
  mutate(   #  compare the equivalent arrival and departure statistic: ARRIVAL - Departure
    net_flow       = arrivals - departures, # positive means more arrivals than departures
    net_med_dur    = dur_med_arrv - dur_med, # pos means median dur is greater coming in than leaving
    dif_member_pct = member_arrv_pct - member_pct, # positive means greater % of incoming rides are members
    dif_metro_pct  = metro_st_pct - metro_end_pct # positive means greater % of incoming ridess are coming from metro
  )   # note, we lose 4 obs, why?


# remove objects 
rm(sum_station_a_arrv, sum_station_a_dep, sum_station_b_arrv, sum_station_b_dep)



# join with weather ------------------------------------------------------------------------
# store number of rows before merge
nrow1 <- nrow(sum_station)

# join with weather
sum_station <-
  sum_station %>%
  left_join(weather, by = c("year", "day_of_yr"), na_matches='never')


# check number of rows 
assertthat::assert_that(
  nrow(sum_station) == nrow1
)

# check for duplicates
assertthat::assert_that(
  nrow(distinct(sum_station, id_station, year, day_of_yr)) == nrow(sum_station)
)


# join with key for gps coords ------------------------------------------------------------------------
sum_station <-
  sum_station %>%
  left_join(., station_key,
          by = c("id_station" = "id_proj")) %>%
  select(-metro.y, -name_metro) %>% rename(metro = metro.x)


# check number of rows 
assertthat::assert_that(
  nrow(sum_station) == nrow1
)

# check for duplicates
assertthat::assert_that(
  nrow(distinct(sum_station, id_station, year, day_of_yr)) == nrow(sum_station)
)



# create lag variables  ----------------------------------------------------------------------
sum_station <-
  sum_station %>%
  group_by(id_station, day_of_yr) %>% 
  mutate(
    lag_departures      = lag(departures, order_by = year),
    lag_arrivals        = lag(arrivals, order_by = year),
    lag_dep_ineq        = lag(dep_ineq, order_by = year),
    lag_arrv_ineq       = lag(arrv_ineq, order_by = year),
    lag_member_pct      = lag(member_pct, order_by = year),
    lag_member_arrv_pct = lag(member_arrv_pct, order_by = year),
    lag_dur_med         = lag(dur_med, order_by = year),
    lag_metro_st_pct    = lag(metro_st_pct, order_by = year)
  )
    


# station-year summaries ======================================================================

# create summary part a: DEPARTURES ~ - ~ - ~ - ~ - ~ - ~ - ~ - ~ - 
#   group: start station, year, day_of_yr
#   stats: from start station -- duration, departures, etc

sum_station_a_dep <- 
  bks1720 %>%
  mutate(
    metro_end_int = as.integer(metro_end),
    member_int    = as.integer(member)
    ) %>%
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
sum_station_yr <- 
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
  ) 



# create lag variables  ----------------------------------------------------------------------
sum_station_yr <-
  sum_station_yr %>%
  group_by(id_station) %>% 
  mutate(
    lag_departures      = lag(departures, order_by = year),
    lag_arrivals        = lag(arrivals, order_by = year),
    lag_dep_ineq        = lag(dep_ineq, order_by = year),
    lag_arrv_ineq       = lag(arrv_ineq, order_by = year),
    lag_member_pct      = lag(member_pct, order_by = year),
    lag_member_arrv_pct = lag(member_arrv_pct, order_by = year),
    lag_dur_med         = lag(dur_med, order_by = year),
    lag_metro_st_pct    = lag(metro_st_pct, order_by = year)
  )





# sf version of sum_station_yr -----------------------------------------------------
sum_station_sf <- 
  sum_station_yr %>%
  left_join(., station_key,
            by = c("id_station" = "id_proj")) %>%
  select(-metro.y) %>% rename(metro = metro.x) %>% # keep only one metro var
  st_as_sf(coords = c("lng", "lat"), na.fail = FALSE, remove = FALSE)

st_crs(sum_station_sf) <- 4326






# count of start-to-end for all combinations --------------------------------------------------

start_end <-   
  bks1720 %>%
  group_by(year, id_start, id_end) %>%
  summarise(n_depart = n(),
            lat_st   = first(lat_st),
            lng_st   = first(lng_st),
            lat_end  = first(lat_end),
            lng_end  = first(lng_end))












# system-day summary with weather ===========================================================================
days1720 <- 
  bks1720 %>% ungroup() %>%
  group_by(date, year, month, wday, day_of_yr) %>%
  summarise(
    nrides      = n(),
    dur_med     = round(median(dur, na.rm = TRUE), 1),
    dur_ineq    = round(Gini(dur, na.rm = TRUE), 2),
    weekend     = if_else((wday == 1 | wday == 7), true = TRUE, false = FALSE),
    week_of_yr  = first(week_of_yr),
    precip      = first(precip), # we can assume that taking the first in each group is ok
    tempmax     = first(tempmax) #  ... since the values are the same for each year-dayofyear group
  ) %>% distinct(date, year, month, wday, day_of_yr, .keep_all = T)





# export =============================================================================================

#individual objects
saveRDS(days1720, file.path(processed, "data/stats17-20/days.Rda"), compress = FALSE)
saveRDS(bks1720, file.path(processed, "data/stats17-20/bks1720-weather.Rda"), compress = FALSE)
saveRDS(sum_station, file.path(processed, "data/stats17-20/sum-station.Rda"), compress = FALSE)
saveRDS(sum_station_yr, file.path(processed, "data/stats17-20/sum-station-yr.Rda"), compress = FALSE)
saveRDS(start_end, file.path(processed, "data/stats17-20/start-end.Rda"), compress = FALSE)

# rest, as Rdata
save(
  sum_station_sf,
  sum_station_a_arrv, sum_station_a_dep, sum_station_b_arrv, sum_station_b_dep,
  file = file.path(processed, "data/stats17-20/misc.Rdata"),
  compress = FALSE
)

