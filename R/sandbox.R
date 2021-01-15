# sandbox.R
# exploring what to do after query.R

library(scales)


# load 2020 + stations ----------------------------------------------------------------------------------
bks2020 <- readRDS(file.path(processed, "data/years/bks_2020.Rda"))
bks1820 <- readRDS(file.path(processed, "data/years/bks_2018-20.Rda"))

station_key <- readRDS(file.path(processed, "keys/station_key.Rda")) %>%
  rename(id_proj = idproj) %>%
  select(name_bks, id_proj, lat, lng, metro, name_metro) %>% # keep only necessary variables
  st_drop_geometry() # remove sf object



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
  bks2020 %>%
  filter(!is.na(id_start)) %>%
  group_by(id_start, id_end, year) %>%
  summarize(
    n_trip_to_end = n() # by destination number of trips
  ) %>%
  ungroup() %>% group_by(id_start, year) %>% # ungroup, regroup only by start id and year
  summarise(
    departures = sum(n_trip_to_end), # if you add all the by-destination number of trips = total number of station departures
    n_dest   = n_distinct(id_end), # number of distinct end stations
    sd       = round(sd(n_trip_to_end, na.rm = TRUE), 2) # this is our temporary measure of 'parity' in destination distribution
    # here what we want is the exact same formula as sd() but using max instead of sample mean
  )



# graphing break!

sum_station_end %>%
  filter(departures >= 100) %>% # include only stations at least 100 departures
  ggplot(., aes(n_dest,sd, size=departures)) +
  geom_point(alpha = 0.5) + 
  ylim(0,300) 
 # scale_x_log10() +
  facet_grid(rows=vars(year)) 





# graphs =========================================================================
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
