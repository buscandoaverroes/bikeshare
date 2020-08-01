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
        




            # ---------------------------------------------------------#
             # extract gps coords from bikes and metro in osm maps ----
            # ---------------------------------------------------------#


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

# ggmap(dc.map) +
#   geom_sf(data = bks.key$geometry,
#           inherit.aes = FALSE,
#           size = 2,
#           alpha = 0.4,
#           shape = 20,
#           color =
#   ) +
#   labs(x = "", y = "")



# extract metro stations info 
q.m <- getbb("Washington, DC") %>% # query and add metro features
  opq() %>%
  add_osm_feature("railway", "station")

metrostn <- osmdata_sf(q.m) # save as sf object


                  # ---------------------------------------------------------#
                  # combine all features to form a dictionary ----
                  # ---------------------------------------------------------#


# Join OSM and GADM bikeshare data to one key. Joins by closest gps point 

osmkey <- sf::st_join(bkrnt$osm_points,
                      stngps,
                      join = st_nearest_feature 
                    )

# Then join OSM+GADM key to metro info  ----
metbkkey <- sf::st_join(osmkey, # bike points
              metrostn$osm_points, # station points 
              join = st_is_within_distance,
              dist = 300)  # only match first within 200 m, otherwise NA. old: st_nearest_feature

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
  ) %>%
  mutate(metro300m = !is.na(bks.key$osm_id.m))

# map, showing bikeshares near metro in different color 
 
  # try using leaflet 



   # remove uneeded objects 
remove(alx, arl, dc, fc, fx, key, metbkkey, mty, pg, q, q.m, us, va, md)






                    
                    # ---------------------------------------------------------#
                    # merge bks with bks.key, generate more vars   ----
                    # ---------------------------------------------------------#

# join main dataset to gps key 
    # bks: join by startstation
    # bks.key: key = cbs_station_name
  bks %>% 
    full_join(bks.key, 
              by = c("startstation" = "cbs_station_name"),
              keep = FALSE)
        # something fishy with strings here, see if you can go into keycreate.R and 
        # port over some of the station ids. 


