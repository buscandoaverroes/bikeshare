# missing-geo.R

library(mapview)

# import station objects + key 
load(file = file.path(processed, "data/station-geo-objects.Rdata"))
key <- readRDS(file = file.path(processed, "keys/station_key.Rda"))

# quick look at missing geom
nmiss <- sum(st_is_empty(key$geometry))
nmiss 

# filter out missing geoms, look at name 
missings <- filter(key, (st_is_empty(geometry)==TRUE))
View(missings)

missings <- st_drop_geometry(missings) # can't overwrite if geometry already present...

# code to manually replace missings
# replace lat/long
missings$lat[missings$id_proj==18] <- 38.86294
missings$lng[missings$id_proj==18] <- -77.05276
  
missings$lat[missings$id_proj==33] <- key$lat[key$id_proj==34] # same name, assume lat/long same
missings$lng[missings$id_proj==33] <- key$lng[key$id_proj==34]

missings$lat[missings$id_proj==117] <- key$lat[key$id_proj==118] # same name, assume lat/long same
missings$lng[missings$id_proj==117] <- key$lng[key$id_proj==118]

missings$lat[missings$id_proj==140] <- 38.88362
missings$lng[missings$id_proj==140] <- -76.95782
  
missings$lat[missings$id_proj==433] <- key$lat[key$id_proj==432] # office, big assumption but assume same for now
missings$lng[missings$id_proj==433] <- key$lng[key$id_proj==432]

missings$lat[missings$id_proj==547] <- 38.92357
missings$lng[missings$id_proj==547] <- -77.23132
  
missings$lat[missings$id_proj==561] <- 39.09425
missings$lng[missings$id_proj==561] <- -77.13278

missings2 <- st_as_sf(missings, coords = c('lng', 'lat'), na.fail = TRUE, remove = FALSE)
View(missings2)
