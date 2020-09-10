# -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- #
# Name: MOTHERbks.R
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
                           
      pacman::p_load(tidyverse,
               readstata13,
               data.table,
               leaflet,
               sp,
               sf,
               tmap,
               osmdata,
               ggmap,
               gdata)
 






                              #-------------#
                              # Set User    #
                              #-------------#

                              #     1         buscandoaverroes
                              #     2         6k


  user <- 1






                              #-------------#
                              # File paths  #
                              #-------------#




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
  MotherData        <- file.path(data, "MotherData")
    kpop            <- file.path(MotherData, "kpop")
    full            <- file.path(MotherData, "years")


    
                                    #------------------#
                                    # store essentials #
                                    #------------------#
    
                          # here we store all the important objects in a list 
                          # that we can call to prevent delting when clearning objects
    
  baselist <- c("repo", "data", "scripts", "gadm", "raw", "MotherData", "kpop", "full", "tiny", "master", 
                "csv", "s1", "s2", "s3", "s4", "s5", "s6", "s7", "s8")
    
    
    


                                    #-------------#
                                    # run scripts #
                                    #-------------#

            s1 <- 0   # import-csv          raw files from csv, appends into year, stores as R files
            s2 <- 0   # construct:      takes bks.Rda and makes other files, runs station-number.R
            s3 <- 0   # geoprocessing   constructs all gps things
            s4 <- 0   # geomerge           Merges geoprocessed data to main bks dataset. 
            s5 <- 0   # plot            tbd
            s6 <- 0   # leaf            makes map with leaf 

  # import
  if (s1 == 1) {
    source(file.path(scripts, "import-csv.R"))
  }

  # construct
  if (s2 == 1) {
    source(file.path(scripts, "construct.R"))
  }

  # gps
  if (s3 == 1) {
    source(file.path(scripts, "geoprocessing.R"))
  }

  # plot
  if (s4 == 1) {
    source(file.path(scripts, "geo-merge.R"))
  }

  # leaf
  if (s5 == 1) {
    source(file.path(scripts, "plot.R"))
  }
  # leaf
  if (s6 == 1) {
    source(file.path(scripts, "leaf.R"))
  }
            
            
# things to do ----
            
# Ride-Level:            
  # add "other" dummy var -- maybe this incldues the low-cost fare
  # gen 30 min or less var dummy
  # merge bks.key to bks using station names, string.
    # indicator if ride was to metro, from metro.

            
# Station-Level
  # (this is really station-[time] var level): generate cumulative flow, ie net input
  

# general
  # (long term) migrate cleaning from Stata to R....
            
            
            
            
# credits: OpenStreetMaps, GADM, Dominic Royé, https://dominicroye.github.io/en/2018/accessing-openstreetmap-data-with-r/
      # Matthias: https://www.gis-blog.com/nearest-neighbour-search-for-spatial-points-in-r/
       # bzki: https://stackoverflow.com/questions/21977720/r-finding-closest-neighboring-point-and-number-of-neighbors-within-a-given-rad
      # https://stackoverflow.com/questions/6778908/transpose-a-data-frame      
           # https://stackoverflow.com/questions/12925063/numbering-rows-within-groups-in-a-data-frame
   # https://stackoverflow.com/questions/22337394/dplyr-mutate-with-conditional-values
  # https://stackoverflow.com/questions/15344092/creating-a-new-variables-with-missing-values
 # https://stackoverflow.com/questions/35697940/append-suffix-to-colnames
            # https://stackoverflow.com/questions/22959635/remove-duplicated-rows-using-dplyr
  # https://stackoverflow.com/questions/54734771/sf-write-lat-long-from-geometry-into-separate-column-and-keep-id-column
            
# ideas: map to a/g mobility data (use package covid19mobility?)