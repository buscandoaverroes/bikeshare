# -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- #
# Name: over.R
# Description: overlays station points to admin characteristics
#
# -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- #

library(sf)
library(rgeos)
library(tidyverse)


# import the key from csv
key <- read.csv(file.path(MotherData, "gpskey-in.csv")) %>%
  rename(stn = startstation, lat = start_lat, lng = start_lng)

## here, could also map to osm_id by taking teh shortest distance between two gps points 



                                
                                #-------------#
                                # map gps to location # ----
                                #-------------#



# load GADM shapefiles, trim down 


us <- st_read(file.path(gadm, 
                        "gadm36_USA_shp"),
              layer = "gadm36_USA_2")
# states
va <- filter(.data = us,
             us$NAME_1 == "Virginia")
dc <- filter(.data = us,
             us$NAME_1 == "District of Columbia")
md <- filter(.data = us,
             us$NAME_1 == "Maryland")

# places 
alx <- filter(.data = va,
              NAME_2 == "Alexandria")
arl <- filter(.data = va,
              NAME_2 == "Arlington")
fc  <- filter(.data = va, 
              NAME_2 == "Falls Church")
fx  <- filter(.data = va,
              NAME_2 == "Fairfax")
mty <- filter(.data = md,
              NAME_2 == "Montgomery")
pg  <- filter(.data = md,
              NAME_2 == "Prince George's")
  

# create district, maryland and virigina geographic mac
dmv <- bind_rows(alx, arl, fc, fx, mty, pg, dc)


# store key as sf object 
stngps <- st_as_sf(key,  ## tell r the object that contains the points
                    coords = c("lng", "lat"), # tell the point vars
                    crs = 4326) # tell the crs 
# harmonize points 
dmv <- st_transform(dmv, crs = st_crs(stngps))

# map points to geolocation 
stngps <- mutate(stngps, 
               inx  = as.integer(st_intersects(stngps, dmv)),
               name = if_else(is.na(inx), "", dmv$NAME_2[inx]),
               state= if_else(is.na(inx), "", dmv$NAME_1[inx])
)
        


# distance matrix 
stngps.s <- head(stngps)
mat <- st_distance(stngps.s, stngps.s)

                                  #-------------#
                                  # add other features # ----
                                  #-------------#
# get maps from osm 
dc.map<- get_map(getbb("Washington, DC"),
                 maptype = "watercolor",
                 source = "osm")

arl.map<- get_map(getbb("Washington, DC"),
                  maptype = "watercolor",
                  source = "osm")



# testing -- with bikeshare stops
q <- getbb("Washington, DC") %>%
  opq() %>%
  add_osm_feature("amenity", "bicycle_rental")
bkrnt <- osmdata_sf(q)

ggmap(arl.map) + 
  geom_sf(data = bkrnt$osm_points,
          inherit.aes = FALSE,
          size = 2,
          alpha = 0.5, 
          shape = 20
  ) +
  labs(x = "", y = "")

# metro stations 
q.m <- getbb("Washington, DC") %>%
  opq() %>%
  add_osm_feature("railway", "station")
metrostn <- osmdata_sf(q.m)

ggmap(dc.map) + 
  geom_sf(data = metrostn$osm_points,
          inherit.aes = FALSE,
          size = 2,
          alpha = 0.5, 
          shape = 20
  ) +
  labs(x = "", y = "")





available_tags("public transport")

# Join OSM and bikeshare gps data to one key.


  # using Matthias' example: problem is that I'm not sure it's producing the result I want
    # this actually just finds the n number of nearest neighbors. 

    # match stngps (hand-made dictionary) to osm object 
          # gDistance() 

    # make coordinate matricies 
      osm.coords <- do.call(rbind, st_geometry(bkrnt$osm_points))
      key.coords <- do.call(rbind, st_geometry(stngps))
      
    # do nearest-neighbor match 
      closest <- nn2(data = osm.coords[,2:1], # chose first two columns in reverse order 
                     query= key.coords, # the points queried against data
                     k = 1,
                     searchtype = "radius",
                     radius = 0.1                       
                     )
      closest <- sapply(closest, cbind) %>% as.tibble()
    
    # create logical vector indicating if there's a nearest neighbor
      stngps$prox <- ifelse(closest$nn.idx == 0, # logical statement
                            TRUE, # return value if statement is true
                            FALSE) # return value if statement is false
      
      
      
      
  # using st_distance() # this works, but produces a matrix of distances... 
      mat1 <- st_distance(bkrnt$osm_points,
                        stngps,
                        by_element = FALSE, # apply across all ids (not pairwise)
                        tolerance = 1000)
      
    
  # using sf_join, replace join arguement with st_nearest_feature 
      osmkey <- sf::st_join(bkrnt$osm_points,
                          stngps,
                          join = st_nearest_feature 
                      )

      
      
      
# Generate a logical vector if the station is within 250 meters of a subway station. 
      
    # using Matthias...
      # make coordinate matricies 
      metro.coords <- do.call(rbind, st_geometry(metrostn$osm_points))
      key.coords <- do.call(rbind, st_geometry(osmkey)) 
      # do nearest-neighbor match 
      closestmetro <- nn2(data = metro.coords[,2:1], # chose first two columns in reverse order 
                     query= key.coords, # the points queried against data
                     k = 1,
                     searchtype = "radius",
                     radius = 200  ## what is this unit???                   
      )
      closestmetro <- sapply(closestmetro, cbind) %>% as.tibble()
      
      

      
      # create logical vector indicating if there's a nearest neighbor 
      osmkey <- mutate(osmkey,
                       nearmetro = ifelse(closestmetro$nn.idx == 0, # logical statement
                            TRUE, # return value if statement is true
                            FALSE)) # return value if statement is false
      
      
      
      