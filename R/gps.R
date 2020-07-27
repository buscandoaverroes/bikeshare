# -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- #
# Name: gps.R
# Description: creates a station name-id-gps dictionary
#
# -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- #



  library(sp)
  library(stringi)
  library(stringdist)
  library(GADMTools)
  library(rgeos)
  library(raster)
  library(rgdal)

                            #-------------#
                            # load data  # ----
                            #-------------#
      imp <- 1
      k   <- 1 
      f   <- 0
      
      bks <- readRDS(file.path(MotherData, "motherdata.Rda"))
              # load full dataset


        
                            #-------------#
                            # clean+clpse # ----
                            #-------------#
 
  # 1. obtain a full list of station name/id numbers

    # ensure only 1 unique value of station name string for each station id
    ck <- bks %>%
      group_by(startstationnumber) %>%
      summarise( count = n_distinct(startstation)) #%>%
    # problem here is that there are some ids with multiple unique string values, must
    # merge because the ids change from 5 digits to 3 when the have gps coordinates
    # therefore, must do string match

    #create a dictionary of all unique stationnames
    oldnames <- bks %>%
            group_by(startstation) %>%
            summarise() %>%
            filter(oldnames, startstation != "")    # remove blank entries





  # 2.  make a dictionary of all string names with gps coordinate _ - -

    # load the raw datasets
    a2020 <- data.table::fread(file.path(raw, "2020/202004-capitalbikeshare-tripdata.csv"),
                               header = TRUE,
                               na.strings = ".",  # tell characters to be read as missing
                               stringsAsFactors = TRUE,
                               showProgress = TRUE,
                               data.table = FALSE
                              ) # return data frame, not table
    m2020 <- data.table::fread(file.path(raw, "2020/202005-capitalbikeshare-tripdata.csv"),
                               header = TRUE,
                               na.strings = ".",  # tell characters to be read as missing
                               stringsAsFactors = TRUE,
                               showProgress = TRUE,
                               data.table = FALSE,
                               drop = "is_equity") # return data frame, not table

    j2020 <- data.table::fread(file.path(raw, "2020/202006-capitalbikeshare-tripdata.csv"),
                               header = TRUE,
                               na.strings = ".",  # tell characters to be read as missing
                               stringsAsFactors = TRUE,
                               showProgress = TRUE,
                               data.table = FALSE
                              ) # return data frame, not table
    # rbind them
    new2020 <- rbind(a2020, m2020, j2020)

    # create list of distinct names and coordinates
     newnames <- new2020 %>%
      group_by(start_station_name, start_lat, start_lng) %>%
      summarise()

    # then sort on name, lng
     newnames %>% arrange(desc(start_station_name),
                          desc(start_lng))

    # remove the first item in the duplicate list of names

     # identify duplicate strings
     newnames$dup <- stri_duplicated(newnames$start_station_name)

     # remove those with duplicate entries
     newnames <-  filter(newnames, dup == "FALSE")
     newnames <-  select(newnames, start_station_name, start_lat, start_lng)






  # 3.  merge the two together = gpskey

      # keys: oldnames : startstation
        #     newnames : startstation

      gpskey <- full_join(oldnames, newnames,
                          by = c("startstation" = "start_station_name"))

        # sort
      gpskey %>%
        arrange(gpskey, startstation )






  # 4. replace gps coordinates for stations that are actually the same w/ sim strings

      # gpskey$match <- vector("double", nrow(gpskey))
      #
      # for (i in seq_along(gpskey$startstation)) {
      #   gpskey$match[i] <- amatch(gpskey$startstation,
      #                             table = gpskey$startstation,
      #                             nomatch = 0,
      #                             maxDist = 10)
      # 
      #


      # just export to CSV then edit and reimport
      #write.csv(gpskey, file.path(MotherData, "gpskey-out.csv"))

      # import
      key <- read.csv(file.path(MotherData, "gpskey-in.csv")) %>%
        rename(stn = startstation, lat = start_lat, lng = start_lng)











                            #-------------#
                            # add features # ----
                            #-------------#

     

        # load shapefile
       # us <- st_read(file.path(gadm, 
       #                         "gadm36_USA_shp"))
        
        us <- st_read(file.path(gadm, 
                                "gadm36_USA_shp"),
                      layer = "gadm36_USA_2")
        
        va <- filter(.data = us,
                      us$NAME_1 == "Virginia")
        
        dc <- filter(.data = us,
                     us$NAME_1 == "District of Columbia")
        
        md <- filter(.data = us,
                     us$NAME_1 == "Maryland")
        
        
        
        alx <- filter(.data = va,
                      NAME_2 == "Alexandria")
        
        arl <- filter(.data = va,
                      NAME_2 == "Arlington")
        
        fx  <- filter(.data = va,
                      NAME_2 == "Fairfax")
        
        mty <- filter(.data = md,
                      NAME_2 == "Montgomery")
        
        pg  <- filter(.data = md,
                     NAME_2 == "Prince George's")
        
        dmv <- bind_rows(alx, arl, fx, mty, pg, dc)
        
       # store points as sf object 
        pts     <- st_as_sf(latlong,  ## tell r the object that contains the points
                            coords = c("lng", "lat"), # tell the point vars
                            crs = 4326) # tell the crs 
       # harmonize points 
        dmv <- st_transform(dmv, crs = st_crs(pts))
        
      # overlay
        pts2 <- mutate(pts, 
                       inx  = as.integer(st_intersects(pts, dmv)),
                       name = if_else(is.na(inx), "", dmv$NAME_2[inx]),
                       state= if_else(is.na(inx), "", dmv$NAME_1[inx])
        )