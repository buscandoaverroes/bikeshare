# md-vis.R
# creates a handful of png files for the opening md

library(tidyverse)
library(sf)
library(miceadds)
library(scales)


# set paths 
processed   <- "/Volumes/Al-Hakem-II/Datasets/bks/bks"
vis         <- "/Volumes/Al-Hakem-II/Scripts/bikeshare/visuals"
days1720    <- readRDS(file.path(processed, "data/stats17-20/days.Rda"))
bks1720     <- readRDS(file.path(processed, "data/stats17-20/bks1720-weather.Rda"))
sum_station <- readRDS(file.path(processed, "data/stats17-20/sum-station.Rda"))
sum_station_yr <-readRDS(file.path(processed, "data/stats17-20/sum-station-yr.Rda"))
start_end <- readRDS(file.path(processed, "data/stats17-20/start-end.Rda"))


load(file.path(processed, "data/stats17-20/misc.Rdata")) 
rm(sum_station_a_arrv, sum_station_a_dep, sum_station_b_arrv)

# create summary
sum_station_sf_fr <- filter(sum_station_sf, departures >= 50, arrivals >= 50)

theme_set(theme_minimal())
alpha = 0.2


# rides by week of year 
f1 <- bks1720 %>%
  group_by(year, week_of_yr) %>% summarise(n = n()) %>%
  ggplot(., aes(week_of_yr, n, color = as.factor(year))) +
  geom_point() + geom_line() + 
  scale_y_continuous(n.breaks = 4, labels = scales::comma, limits = c(0,120000)) +
  labs(title = "Weekly System Rides", y = "N Rides", x = "Week of Year", colour = "Year") 


# weekday vs weekend 
f2 <- sum_station %>%
  group_by(day_of_yr, year) %>%
  summarise(dur_med=mean(dur_med, na.rm=T), weekend=first(weekend)) %>% 
  ggplot(aes(day_of_yr, dur_med, color = weekend)) +
  geom_point() + facet_wrap(~year) + 
  scale_y_time(limits = c(0,4000)) +
  labs(x="Day of Year", y="Median Ride Duration", color = "Weekend", 
       title = "Median Ride Duration by Weekday and Weekend") 


# To-metro percent and member usage 
f3 <- sum_station_yr %>%
  filter(departures >= 100) %>% # include only stations at least 100 departures
  ggplot(., aes(member_pct, metro_end_pct)) +
  geom_point(alpha = 0.4) +
  scale_y_continuous(labels = scales::percent) + 
  labs(y = "Percent of station rides to Subway", 
       x = "Percent of station users who are members",
       title = "Bikeshare-To-Subway Patterns by Rider Membership") +
  facet_grid(rows=vars(year))


# daily variation and median-duration across week
f4 <- sum_station %>%
  filter(year==2020, week_of_yr >= 5 & week_of_yr <= 20) %>%
  ggplot(., aes(dur_med)) +
  geom_histogram() +
  scale_x_time(limits = c(0,3000), labels = NULL) +
  labs(title = "2020: Weekly Change in Daily Station Median Ride Duration",
       x = "Daily Median Ride Duration by Station",
       y = "Count (Station-Days)") +
  facet_wrap(~week_of_yr)


# save 
ggsave(file.path(vis, "/png/rides_by_week.png"), plot = f1, units = "px", dpi = 200, scale = 1)
ggsave(file.path(vis, "/png/dur_weekend.png"), plot = f2, units = "px", dpi = 200, scale = 1)
ggsave(file.path(vis, "/png/station_member_pct.png"), plot = f3, units = "px", dpi = 200, scale = 1)
ggsave(file.path(vis, "/png/weekly_station_dur.png"), plot = f4, units = "px", dpi = 200, scale = 1)
