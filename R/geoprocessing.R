# -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- #
# Name: geoprocessing.R
# Description: overlays station points to admin characteristics
#
# -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- #

library(sf)
library(rgeos)
library(tidyverse)
library(RANN)
library(stringi)


                                #---------------------#
                                # import cabi key     # ----
                                #---------------------#
# import 
key <- read.csv(file.path(MotherData, "gpskey-in.csv")) %>%
  rename(stn = startstation, lat = start_lat, lng = start_lng, cabi.id = X)

    # we don't want to check for duplicate values here because if it's a value we want to 
    # preserve it for when we match to data.

                                
                                #---------------------#
                                # map gps to location # ----
                                #---------------------#



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
  

# create district, maryland and virigina geographic map
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
        




            # --------------------------------------------------------------#
            # extract gps coords from bikes and metro stations in osm maps  #----
            # --------------------------------------------------------------#


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



# extract metro stations info 
q.m <- getbb("Washington, DC") %>% # query and add metro features
  opq() %>%
  add_osm_feature("railway", "station")

metrostn <- osmdata_sf(q.m) # save as sf object


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



                  # ----------------------------------------------------------#
                  # combine all features to form a dictionary                 #----
                  # ----------------------------------------------------------#

# Join OSM and GADM bikeshare data to one key. Joins by closest gps point 

osmkey <- sf::st_join(stngps,  # imported gps coordinates of bikeshare stations from cabi
                      bkrnt$osm_points, # bikeshare station info from osm
                      join = st_nearest_feature, # merge by nearest proximity
                      left = TRUE # return the left join
                    )

# Then join all bikeshare station info above to metro info  ----
metbkkey <- sf::st_join(osmkey, # bike points
              metrostn$osm_points, # station points 
              join = st_is_within_distance,
              left = TRUE,  # keep all obs from station key
              dist = 200)  # only match first within 300 m, otherwise NA. old: st_nearest_feature 
  
  # select subset of varibles
  bks.key <- select(metbkkey,
           osm_id.x, name.x,  # the osm bikeshare info
           cabi.id, stn, inx, name.y, state,   # the GADM info
           osm_id.y, name) %>% # metro info
    rename(
      osm.station.id = osm_id.x, # rename bike id
      osm.station.name = name.x,   # osm bike name 
      #amenity.b = amenity.x,
      cabi.station.id   = cabi.id,
      cabi.station.name = stn,    
      gadm.cat = inx, 
      gadm.loc = name.y,
      gadm.state = state,
      osm.metro.id = osm_id.y, 
      osm.metro.name = name,
    ) 
  # generate
  bks.key$metro200m <- !is.na(bks.key$osm.metro.id)

# control duplicates  ----
  # note that this happens when you have two metro stations within the givn threshold, ie, 
  # a bikeshare station is located close to two metro stations (ie farragut north and farragut west, etc)
  # so eliminating the duplciates will keep essentially one of the stations at random, we don't know which, 
  # but it doesn't really matter because all we care about is the yes/no if the bikeshare station is 
  # near ANY metro station.
  
  # remove duplicates whose cabi.station.id is the same (200 meters)
  bks.key$dups.cabi.station.id <- stri_duplicated(bks.key$cabi.station.id)
  dups <- bks.key$cabi.station.id[bks.key$dups.cabi.station.id==TRUE] # name the dup values
  
  bks.key <- filter(bks.key, dups.cabi.station.id==FALSE)
  


   # remove uneeded objects ## issue is that the search function I think is putting all stations within 300m  
    remove(alx, arl, dc, fc, fx, key, metbkkey, mty, pg, q, q.m, us, va, md, dups)


                    
                    # ---------------------------------------------------------#
                    # merge main station key to station number key generated before   ----
                    # ---------------------------------------------------------#
                # The stationnumber key links old station naming schemes to new schemes
                # in cabi data. varname is cabi.station.id
                # Note that oldid and newid in stnidkey are different than cabi.station.id in bks.key 
                # as the later is generated by me and has no real meaning. We will add 
                # cabi.station.id.old to cabi.station.id.new to the dataset 
 

# merge stnidkey to bks.key 
cabi.geo.key <- left_join(bks.key,
                       stnidkey,
                       by = c("cabi.station.name" = "name" )) %>%
      rename(cabi.station.id.old = oldid,
             cabi.station.id.new = newid,
             proj.station.id     = cabi.station.id) %>%
      select(osm.station.id, osm.station.name, cabi.station.id.new, cabi.station.id.old, everything())

 
  
    
    
    
# Save/export as Rdata   
  save(cabi.geo.key, osmkey, dmv, stngps,
       file = file.path(kpop, "geo-data.Rdata"))  
