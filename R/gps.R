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

                            #-------------#
                            # load data  # ----
                            #-------------#
      imp <- 0
      k   <- 1 
      f   <- 0
      
      if (imp == 1) {

      bks <- readRDS(file.path(MotherData, "motherdata.Rda"))
              # load full dataset

      }

        
                            #-------------#
                            # clean+clpse # ----
                            #-------------#
  if (k == 1) {
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
      # }
      #


      # just export to CSV then edit and reimport
      #write.csv(gpskey, file.path(MotherData, "gpskey-out.csv"))

      # import
      key <- read.csv(file.path(MotherData, "gpskey-in.csv")) %>%
        rename(stn = startstation, lat = start_lat, lng = start_lng)










  } # close switch
  
                            #-------------#
                            # add features # ----
                            #-------------#

      if (f == 1) {
      #ie state, county, near metro, etc

      # import shp files : gadm_sf_import_shp
        # note that this just imports the .shp files and makes a gadm_sf object

        # states
        usa1 <- gadm_sf_loadCountries(dir = file.path(gadm, "gadm36_USA_shp"),
                           "gadm36_USA_1",
                           level = 1,
                           keepall = TRUE)

        usa2 <- gadm_sf_import_shp(dir = file.path(gadm, "gadm36_USA_shp"),
                                    level = 2,
                                    keepall = TRUE)
        # county/city
        usa2 <- gadm_sf_import_shp(dir = file.path(gadm, "gadm36_USA_shp"),
                                   "gadm36_USA_2",
                                   level = 2,
                                   keepall = TRUE)


                # backup, import rds files
                usa1rds <- readRDS(file.path(gadm, "gadm36_USA_shp/gadm36_USA_2_sf.Rds"))
          # %%%% check out

      # import the shp files using raster w shpfile we downloaded from gadm
                #  usa2 <- raster::getData( "GADM",
                #                         file.path(gadm, "gadm36_USA_shp/gadm36_USA_2."),
                #                         download = FALSE,
                #                         country = 'USA',
                #                         level = 2)
                #
                # list.files(path = file.path(gadm, "gadm36_USA_shp"))
                # this doesn't work. wants me to download from internet.

      # associate the gps coordinates with a gadm index number: over?



             # filter missing gps coords
              keys <- filter(key, lng != "NA") #KEYShort


               long <- keys$lng
               lat  <- keys$lat
               coords <- data.frame(long, lat)
               names <- data.frame(keys$stn)

               usa <- SpatialPointsDataFrame(coords = coords, data = names )

               str(usa1rds)


              # make an overlay %%%

              # overlay <- over(x = usa,# spatialpointsdataframe
              #                 y = usa1rds) # spatialpolygons
              #


      # match that number to a location name varlist, input lat-long : listNames







      } # close switch

                            #-------------#
                            # map to dtas # ----
                            #-------------#

    
