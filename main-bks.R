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
         sf,
         gdata,
         lubridate,
         data.table,
         janitor,
         assertthat
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
  scripts           <- file.path(repo,"code")
    shiny           <- file.path(repo, "visuals/shiny")
  
  raw               <- file.path(data, "raw")
  processed         <- file.path(data, "bks")
    keys            <- file.path(processed, "keys")
    plato           <- file.path(processed, 'data/plato')



    
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
            
# Stats Processing                  
  s5 <- 0   # stats10-14        takes years 10-14 from query, processes, adds station info, stats.
            #                   makes: stats10-14.Rdata ~20 min
  s6 <- 0   # stats15-16       takes years 15-16 from query, processes, adds station info, stats.
            #                   makes: stats15-16.Rdata ~20 min
  s7 <- 0   #stats17-20        takes years 17-20 from query, processes, adds station info, stats.
            #                    makes: stats17-20.Rdata ~20 min
  
# recollection 
  r1 <- 0   # recollect       takes the 'parallel processed' stats files and reassembles them into:
            #                   days, station-sum, rides .Rda files under the /plato directory
  
  
# utilities
  u1 <- 0   # weather.R       queries weather data from NOAA to create by-day weather dictionary
            #                   makes: data/weather/weather-daily.Rda
  u2 <- 0   # names.R         creates a tibble of all key variable names and text/labels for graphs,
  
  
# rmarkdown
  m1 <- 0   # descriptives01.Rmd     exploration markdown of basic plots     
  m2 <- 0   # regressions01.Rmd       basic regressions
  
  

            
# main scripts --------------------------------------------------------------------------------------            
 
  if (s1 == 1) {source(file.path(scripts, "import.R"))}  
  if (s2 == 1) {source(file.path(scripts, "stations.R"))}
  if (s3 == 1) {source(file.path(scripts, "construct.R"))} 
  if (s4 == 1) {source(file.path(scripts, "query.R"))} 
  if (s5 == 1) {source(file.path(scripts, "stats10-14.R"))}  
  if (s6 == 1) {source(file.path(scripts, "stats15-16.R"))}  
  if (s7 == 1) {source(file.path(scripts, "stats17-20.R"))}  
  
  if (r1 == 1) {source(file.path(scripts, "recollect.R"))}  
            

# utilities --------------------------------------------------------------------------------------            
            
if (u1 == 1) {source(file.path(scripts, "weather.R"))}                     
if (u2 == 1) {source(file.path(scripts, "names.R"))}              
            
            
# markdown --------------------------------------------------------------------------------------            
            
if (m1 == 1) {source(file.path(scripts, "analysis/Descriptives01.rmd"))}                     
if (m2 == 1) {source(file.path(scripts, "analysis/regeressions01.rmd"))}                  
            
            
            
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