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
              dist = 200)  # only match first within 300 m, otherwise NA. old: st_nearest_feature 

# select subset of varibles
bks.key <- select(metbkkey,
         osm_id.x, name.x, amenity.x, # the osm bikeshare info
         stn, inx, name.y, state,   # the GADM info
         osm_id.y, name) %>% # metro info
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
  
bks.key$metro200m <- !is.na(bks.key$osm_id.m)

# control duplicates of odm.id bike ----

# remove duplicates whose osmid is the same (200 meters)
bks.key$duposm_id.b <- stri_duplicated(bks.key$osm_id.b)
duposm <- bks.key$osm_id.b[bks.key$duposm_id.b==TRUE] # name the dup values

bks.key <- filter(bks.key, duposm_id.b==FALSE)

# remove duplcates whose capital bikeshare station name is the same; osm id dif.
bks.key$dupcbs <- stri_duplicated(bks.key$cbs_station_name) 
dupcbs <- bks.key$cbs_station_name[bks.key$dupcbs==TRUE]

bks.key <- filter(bks.key, dupcbs==FALSE) %>%
  select(-(duposm_id.b:dupcbs))


   # remove uneeded objects ## issue is that the search function I think is putting all stations within 300m  
remove(alx, arl, dc, fc, fx, key, metbkkey, mty, pg, q, q.m, us, va, md, duposm, dupcbs)







                      # ---------------------------------------------------------#
                      # try to add stationnumbers to dictionaries to merge by number   ----
                      # ---------------------------------------------------------#

# create old/new from bks
    # this should have dup strings with first row as "new" number and second "old" number
namenumb <- bks %>%
  group_by(startstation, startstationnumber) %>%
  summarise() %>%
  filter(startstation != "")   # remove blank entries

# generate group id 
namenumb$group <- group_indices(namenumb)

# generate id within groups 
nn <- namenumb %>%
  group_by(group) %>%
  mutate(id = row_number() ## why will this not generate!
  )

# pivot to wider 
nn.w <- spread(nn,
              key = id, 
              value = startstationnumber) %>%
  rename(old = "1" , # change names
         new = "2",
         misc = "3")

# move values to correct places 
    
  # move low new values to old 
  for (i in seq_along(nn.w$old)) {
    nn.w$old[i] <- ifelse((nn.w$new[i] < 30000) 
                          & (!is.na(nn.w$new[i])) , # new value should be < 30000
                          nn.w$new[i], # if true, replace old with new
                          nn.w$old[i]) # if false, replace with self, true for row 120
  }
  
  # move high values in old to new and replace high olds with NA
  for (i in seq_along(nn.w$new)) {
    nn.w$new[i] <- ifelse((nn.w$old[i] > 30000) 
                          & (!is.na(nn.w$old[i])) , # new value should be < 30000
                          nn.w$old[i], # 
                          nn.w$new[i]) # 
  }

  # do for column 3 
  for (i in seq_along(nn.w$new)) {
    nn.w$new[i] <- ifelse((nn.w$misc[i[]] > 30000) & 
                            (!is.na(nn.w$misc[i])), # new value should be < 30000
                          nn.w$misc[i], #
                          nn.w$new[i]) # 
  }
  
  # (for those with no 'old' value) replace old with missing
  for (i in seq_along(nn.w$old)) {
    nn.w$old[i] <- ifelse((nn.w$old[i] > 30000) & (!is.na(nn.w$old[i])) , # new value should be < 30000
                          NA, #  replace with missing, indicating not in old cat system
                          nn.w$old[i]) # otherwise replace with valid, old number 
  }
    

  # replace pre2020 value with "new" values lower than 30000 
    for (i in seq_along(nn.w)) {
      nn.w$old[i] <- ifelse(nn.w$new[i] < 30000 , # test condition
                                nn.w$new[i], # if true
                                nn.w$post2020[i])
    }

  # remove misc var, drop unecessary objects
  stnidkey <- data.frame(nn.w) %>%
    select(startstation, old, new) %>%
    rename( name = startstation, 
            oldid = old,
            newid = new)
  
  remove(nn, nn.w, namenumb)
  
  

# merge stnidkey to bks.key 
  bks.key2 <- inner_join(bks.key,
                       stnidkey,
                       by = c("cbs_station_name" = "name" )
                       )

         
                    # ---------------------------------------------------------#
                    # merge bks with bks.key, generate more vars   ----
                    # ---------------------------------------------------------#
# create minidatasets 
  m.bks <- bks[1:10000,]

# bks: join by startstation
 
        # match to start   
          # bks.key: key = cbs_station_name
          bks2 <- inner_join(m.bks, bks.key, # keep all obs in bks
                      by = c("startstation" = "cbs_station_name")
                     )
            # add suffix to indicate start
            colnames(bks2)[34:48] <- paste0("s", sep = '.', colnames(bks2)[34:48])
        
        # match to endstation   
          # bks.key: key = cbs_station_name
          bks3 <- inner_join(bks2, bks.key, # keep all obs in bks
                             by = c("endstation" = "cbs_station_name")
          )
          # add suffix to indicate start
          colnames(bks3)[49:63] <- paste0("e", sep = '.', colnames(bks3)[49:63])
            ## %% up to here this works, try on full dataset


  
  
  
    
  # key station number 
  bks2 <- inner_join(bks, bks.key, # keep all obs in bks
                     by = c("startstationnumber" = "newid"),
                     suffix
  ) 
        # something fishy with strings here, see if you can go into keycreate.R and 
        # port over some of the station ids. 
  # 'names' attribute [29736751] must be the same length as the vector [28874997]

####################### join full dataset 
  # match to start   
  # bks.key: key = cbs_station_name
  bks2 <- inner_join(bks, bks.key, # keep all obs in bks
                     by = c("startstation" = "cbs_station_name")
  )
  # add suffix to indicate start
  colnames(bks2)[34:48] <- paste0("s", sep = '.', colnames(bks2)[34:48])
 # %% run up to here. 
  # match to endstation   
  # bks.key: key = cbs_station_name
  bks3 <- inner_join(bks2, bks.key, # keep all obs in bks
                     by = c("endstation" = "cbs_station_name")
  )
  # add suffix to indicate start
  colnames(bks3)[49:63] <- paste0("e", sep = '.', colnames(bks3)[49:63])


  
  # why does bks lose observations as we merge?  