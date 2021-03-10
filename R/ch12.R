# ch12.R
# a sandbox file to learn ch12 from geocomputation with R from Robin Lovelace et al,

# Create Desire lines with OD data ---------------

library(dplyr)
library(sf)
library(stplanr)
library(tmap)
library(mapview)
library(ggplot2)

# import
rides <- readRDS("/Volumes/Al-Hakem-II/Datasets/bks/bks/data/plato/daily-rides.Rda") 
key   <- readRDS("/Volumes/Al-Hakem-II/Datasets/bks/bks/keys/station_key.Rda") 
View(head(rides))

# separate od and spatial data
# stations, remove empty geometry for now.
z <- select(key, id_proj, geometry) %>%
  ungroup() %>%
  rename(geocode = id_proj) %>%
  filter(st_is_empty(geometry)==FALSE)

#od data in long form
od <- filter(rides, year == 2017) %>%
  ungroup() %>%
  group_by(id_start, id_end) %>%
  summarise(nrides = n()) %>%
  rename(geocode1 = id_start,
         geocode2 = id_end)

od_inter <- filter(od, geocode1 != geocode2) 

od_inter <- filter(od_inter, geocode1 %in% z$geocode) %>%
  filter(geocode2 %in% z$geocode) 
  
# create origin-destination stations (od)
desire_lines <- od2line(flow = od_inter, zones = z)

# graph 
# What's the distribution of ods?
ggplot(desire_lines, aes(nrides)) + geom_histogram(binwidth = 5) + lims(x=c(0,100))
lwd <- filter(desire_lines, nrides >= 50) # filtered dataset

m <- mapview(lwd, zcol='nrides', at=c(0, 200, 300, 500, 1000), alpha = 0.2, lwd=0.3) 
# go with mapview, play with colorscale, etc, could work well in shiny if done by-hour, year
m

tm <- tm_shape(lwd) + tm_lines(
  col = "nrides",
  palette = "plasma", breaks = c(100, 200, 300, 500, 1000),
  lwd = 0.1,
  scale = 9,
  title.lwd = "Number of Rides in 2017",
  alpha = 0.5,
  title = "Number of Rides in 2017"
) + 
  tm_scale_bar() +
  tm_layout(
    legend.bg.alpha = 0.5,
    legend.bg.color = 'white'
  )
tm
