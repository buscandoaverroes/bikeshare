# -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- #
# Name: main-bks.R
# Description: primary script for bikeshare r analysis
#
# -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- #





                              # ---- Opening  ----

                              #-------------#
                              # packages    #
                              #-------------#
                              
      if (!is.element("pacman", installed.packages())) {
        install.packages("pacman", dep= T)
      }
                           
      pacman::p_load(
        tidyverse,
         readstata13,
         data.table,
         leaflet,
         sp,
         sf,
         tmap,
         osmdata,
         ggmap,
         gdata,
         lubridate,
         data.table,
         janitor
        )
 




                              #-------------#
                              # Set User    #
                              #-------------#

                              #     1         buscandoaverroes
                              #     2         6k


  user <- 1





  if (user == 1) {
    # scripts
    repo  <- "/Volumes/Al-Hakem-II/Scripts/bikeshare"

    # data
    data    <- "/Volumes/Al-Hakem-II/Datasets/bks"

  }



# same no matter the user.
  scripts           <- file.path(repo,"R")

  gadm              <- "/Volumes/Al-Hakem-II/other+files/gadm"
  raw               <- file.path(data, "raw")
  processed         <- file.path(data, "bks")
  MotherData        <- file.path(data, "MotherData")
    kpop            <- file.path(MotherData, "kpop")
    full            <- file.path(MotherData, "years")


    
# values   
  crs               <- 4326 # main crs for project  
  bike_metro_dist   <- 250 # distance in meters; determines if bike station is "near" a metro station.
    


                                    #-------------#
                                    # run scripts #
                                    #-------------#
# main scripts
  s1 <- 0   # import          variable harmonization, append. no data wrangling
            #                   makes: bks-import.csv
  s2 <- 0   # stations      creates old/new station number dictionary and adds station features
            #                   makes: station_key.Rda, station-geo-objects.Rdata
  s3 <- 0   # construct:      takes bks.Rda and makes other files, runs station-number.R
            #                   makes: bks-full.Rda, bks-full.csv
  s4 <- 0   # query:          filters/queries main database and exports files.
            #                   makes: bks_2020.Rda, bks1720.Rda
  s5 <- 0   # stats          takes years 17-20 from query, processes, adds station info, stats.
            #                   makes: stats17-20.Rdata ~20 min
  s6 <- 0   # 
  
# utilities: can be run independently after main.R
  u1 <- 0   # weather.R       queries weather data from NOAA to create by-day weather dictionary
            #                   makes: data/weather/weather-daily.Rda

  
# rmarkdown
  m1 <- 0   # sandbox.Rmd     exploration markdown of basic plots and regs, using Rdata from sandbox.R    
  

            
# main scripts --------------------------------------------------------------------------------------            
  # import
  if (s1 == 1) {
    source(file.path(scripts, "import.R"))
  }
  # create dictionary of station numbers 
  if (s2 == 1) {
    source(file.path(scripts, "stations.R"))
  }
  # construct
  if (s3 == 1) {
    source(file.path(scripts, "construct.R"))
  }
  # query
  if (s4 == 1) {
    source(file.path(scripts, "query.R"))
  }       
  # sandbox.R
  if (s5 == 1) {
    source(file.path(scripts, "stats17-20.R"))
  }         
            

# utilities --------------------------------------------------------------------------------------            
            
# sandbox.R
if (u1 == 1) {
  source(file.path(scripts, "weather.R"))
}                     
            
            
            
# markdown --------------------------------------------------------------------------------------            
            
# sandbox.R
if (m1 == 1) {
  source(file.path(scripts, "sandbox.Rmd"))
}                     
            
            
            
            
# credits: =======================================================================================
# OpenStreetMaps, GADM, Dominic Royé, https://dominicroye.github.io/en/2018/accessing-openstreetmap-data-with-r/
      # Matthias: https://www.gis-blog.com/nearest-neighbour-search-for-spatial-points-in-r/
       # bzki: https://stackoverflow.com/questions/21977720/r-finding-closest-neighboring-point-and-number-of-neighbors-within-a-given-rad
      # https://stackoverflow.com/questions/6778908/transpose-a-data-frame      
           # https://stackoverflow.com/questions/12925063/numbering-rows-within-groups-in-a-data-frame
   # https://stackoverflow.com/questions/22337394/dplyr-mutate-with-conditional-values
  # https://stackoverflow.com/questions/15344092/creating-a-new-variables-with-missing-values
 # https://stackoverflow.com/questions/35697940/append-suffix-to-colnames
            # https://stackoverflow.com/questions/22959635/remove-duplicated-rows-using-dplyr
  # https://stackoverflow.com/questions/54734771/sf-write-lat-long-from-geometry-into-separate-column-and-keep-id-column
  # https://stackoverflow.com/questions/32766325/fastest-way-of-determining-most-frequent-factor-in-a-grouped-data-frame-in-dplyr
# https://stackoverflow.com/questions/14800161/select-the-top-n-values-by-group
#             
# ideas: map to a/g mobility data (use package covid19mobility?)