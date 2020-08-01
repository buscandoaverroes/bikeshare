# -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- #
# Name: over.R
# Description: overlays station points to admin characteristics
#
# -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- #

library(sf)
library(rgeos)
library(tidyverse)
library(RANN)


# import the key from csv
key <- read.csv(file.path(MotherData, "gpskey-in.csv")) %>%
  rename(stn = startstation, lat = start_lat, lng = start_lng)


                                
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
        


             # extract gps coords from bikes and metro in osm maps ----


# get maps from osm 
dc.map<- get_map(getbb("Washington, DC"),
                 maptype = "watercolor",
                 source = "osm")

arl.map<- get_map(getbb("Washington, DC"),
                  maptype = "watercolor",
                  source = "osm")



# extract bikeshare info 

q <- getbb("Washington, DC") %>% # query...and add features
  opq() %>%
  add_osm_feature("amenity", "bicycle_rental")

bkrnt <- osmdata_sf(q) # save as sf object

                  # this is just map sh*tt

# ggmap(arl.map) + 
#   geom_sf(data = bkrnt$osm_points,
#           inherit.aes = FALSE,
#           size = 2,
#           alpha = 0.5, 
#           shape = 20
#   ) +
#   labs(x = "", y = "")
# 


# extract metro stations info 
q.m <- getbb("Washington, DC") %>% # query and add metro features
  opq() %>%
  add_osm_feature("railway", "station")

metrostn <- osmdata_sf(q.m) # save as sf object
 
# ggmap(dc.map) + 
#   geom_sf(data = metrostn$osm_points,
#           inherit.aes = FALSE,
#           size = 2,
#           alpha = 0.5, 
#           shape = 20
#   ) +
#   labs(x = "", y = "")




# Join OSM and GADM bikeshare data to one key. Joins by closest gps point 

osmkey <- sf::st_join(bkrnt$osm_points,
                      stngps,
                      join = st_nearest_feature 
                    )

# Then join OSM+GADM key to metro info  ----
metbkkey <- sf::st_join(osmkey, # bike points
              metrostn$osm_points, # station points 
              join = st_is_within_distance,
              dist = 200)  # st_nearest_feature, old

# select subset of varibles
bks.key <- select(metbkkey,
         osm_id.x, name.x, amenity.x, # the osm bikeshare info
         stn, inx, name.y, state,   # the GADM info
         osm_id.y, name, public_transport, railway, station) %>% # metro info
  rename(
    osm_id.b = osm_id.x,
    osm_bk_name = name.x,
    amenity.b = amenity.x,
    cbs_station_name = stn, 
    gadm_cat = inx, 
    gadm_loc = name.y,
    gadm_state = state,
    osm_id.m = osm_id.y, 
    osm_met_name = name,
  ) 

# Find distance to associated metro station ----
  
# do st_distance but pairwise.


mat1 <- st_distance(metrostn$osm_points, # station points 
                    osmkey$geometry, # bike points
                    by_element = FALSE, # apply across all ids (not pairwise)
                    st_is_longlat = TRUE,
                    tolerance = 200) # tolerance = 500 ? 
    # problem here is that the column/row names aren't the stationids

distmat1 <- as.data.frame(mat1) # make mat into a dataframe 
metroid <- metrostn$osm_points$osm_id     # retrieve ids of metro stations
bikeid  <- osmkey$osm_id
colnames(distmat1) <- bikeid  # add column names as the osm ids of metro  (assume right order?)
distmat1 %>%
  mutate(metroid = metroid)  # add var bikeshare station-ids

dist <- select(distmat1, # put metrostation first
               metroid, everything()) 






# Generate a logical vector if the station is within 250 meters of a subway station. 

# dist.mat <- st_distance(osmkey$geometry, #gps points of stations
#                     metrostn$osm_points, # metro stations
#                     by_element = FALSE, # apply across all ids (not pairwise)
#                     ) #tolerance = 1000
# num.200 <- apply(dist.mat, 1, function(x) { # summarize if point is < 200m
#   sum(x < 200) - 1 # exclude the point itself
# })
# 
#   # calculate nearest distance 
# nn.dist <- apply(dist.mat, 1, function(x){
#   return(sort(x, partial = 2)[2])
# })
#   # return the index
# nn.index <- apply(dist.mat, 1, function(x) { order(x, decreasing = FALSE)[2]}) 
# 
#   # construct the new dataframe
# n.osmkey <- osmkey
# colnames(n.osmkey)[1] <- "neighbor"
# colnames(n.osmkey)[2:ncol(n.osmkey)] <- 
#   paste0("n.", colnames(n.osmkey)[2:ncol(n.osmkey)])
# oskmey2 <- data.frame(osmkey, 
#                       n.osmkey[nn.index, ],
#                       n.distance = nn.dist,
#                       radius200 = num.200
#                       )
#### this doesn't work because I have sf objects, try doing this enntirely in sf world. 


# make coordinate matricies 
    #metro.coords <- do.call(rbind, st_geometry(metrostn$osm_points))
    # key.coords <- do.call(rbind, st_geometry(osmkey)) 
    # # do nearest-neighbor match 
    # closestmetro <- nn2(data = metro.coords[,2:1], # chose first two columns in reverse order 
    #                     query= key.coords, # the points queried against data
    #                     k = 1,
    #                     searchtype = "radius",
    #                     radius = 200  ## what is this unit???                   
    # )
    # closestmetro <- sapply(closestmetro, cbind) %>% as.tibble()
    # 
    # 
    # 
    # # create logical vector indicating if there's a nearest neighbor 
    # osmkey <- mutate(osmkey,
    #                  nearmetro = ifelse(closestmetro$nn.idx == 0, # logical statement
    #                                     TRUE, # return value if statement is true
    #                                     FALSE)) # return value if statement is false
    
    
    




# other methods...

  # using Matthias' example: problem is that I'm not sure it's producing the result I want
    # this actually just finds the n number of nearest neighbors. 

    # match stngps (hand-made dictionary) to osm object 
          # gDistance() 

    # # make coordinate matricies 
    #   osm.coords <- do.call(rbind, st_geometry(bkrnt$osm_points))
    #   key.coords <- do.call(rbind, st_geometry(stngps))
    #   
    # # do nearest-neighbor match 
    #   closest <- nn2(data = osm.coords[,2:1], # chose first two columns in reverse order 
    #                  query= key.coords, # the points queried against data
    #                  k = 1,
    #                  searchtype = "radius",
    #                  radius = 0.1                       
    #                  )
    #   closest <- sapply(closest, cbind) %>% as.tibble()
    # 
    # # create logical vector indicating if there's a nearest neighbor
    #   stngps$prox <- ifelse(closest$nn.idx == 0, # logical statement
    #                         TRUE, # return value if statement is true
    #                         FALSE) # return value if statement is false
    #   
      
      
      
 
  

      
      
 
      