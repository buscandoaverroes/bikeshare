# -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- #
# Name: over.R
# Description: overlays station points to admin characteristics
#
# -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- #




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
        


                                  #-------------#
                                  # add other features # ----
                                  #-------------#

# near metro station? distnace to other stations? 