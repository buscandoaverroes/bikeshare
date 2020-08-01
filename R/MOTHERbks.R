# -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- #
# Name: MOTHERbks.R
# Description: primary script for bikeshare r analysis
#
# -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- #





                              # ---- Opening  ----

                              #-------------#
                              # packages    #
                              #-------------#

# #   package names
#   pacman::p_load(stargazer,
#                  tidyverse,
#                  readstata13,
#                  reshape2,
#                  data.table,
#                  readstata13,
#                  foreach,
#                  parallel,
#                  MASS,
#                  readr
#                  )
#
      # library(stargazer)
      # library(tidyverse)
      # library(readstata13)
      # library(reshape2)
      # library(data.table)
      # library(foreach)
      # library(leaflet)
      # library(doParallel)
      # library(parallel)
      # library(parallel)
      # library(MASS)
                              
  # install.packages(dplyr)
                              
  # library(pacman)  
  # library(tidyverse)
  # library(readstata13)
  # library(leaflet)
  # library(sp)
  # library(tmap)
  # library(data.table)
  #     
                              
                              
 # ----                             
      pacman::p_load(tidyverse,
               readstata13,
               data.table,
               leaflet,
               sp,
               sf,
               tmap,
               osmdata,
               ggmap)
 






                              #-------------#
                              # Set User    #
                              #-------------#

                              #     1         buscandoaverroes
                              #     2         6k


  user <- 1





                              #-------------#
                              # tiny / main #
                              #-------------#

  # size == 1 is tiny
  # size == 2 is master
  # size == 3 is csv

  size <- 3





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
    full            <- file.path(MotherData, "full")
    tiny            <- file.path(full, "tinymaster.dta")
    master          <- file.path(full, "master.dta")
    csv             <- file.path(full, "master.csv")






                                    #-------------#
                                    # run scripts #
                                    #-------------#

            s1 <- 0   # import          imports from stata
            s2 <- 0   # construct:      takes bks.Rda and makes other files
            s3 <- 0   # gps             constructs all gps things
            s3 <- 0   # plot              tbd
            s4 <- 0   # leaf

  # import
  if (s1 == 1) {
    source(file.path(scripts, "import.R"))
  }

  # construct
  if (s2 == 1) {
    source(file.path(scripts, "construct.R"))
  }

  # gps
  if (s3 == 1) {
    source(file.path(scripts, "gps.R"))
  }

  # plot
  if (s4 == 1) {
    source(file.path(scripts, "plot.R"))
  }

  # leaf
  if (s4 == 1) {
    source(file.path(scripts, "leaf.R"))
  }


 # so try to re-import main csv, bks$member should be only 0 1.
 # some empty "" strings in some vars (stationnames )

  # add "other" dummy var -- maybe this incldues the low-cost fare
  # gen 30 min or less var dummy

# credits: OpenStreetMaps, GADM, Dominic Royé, https://dominicroye.github.io/en/2018/accessing-openstreetmap-data-with-r/
      # Matthias: https://www.gis-blog.com/nearest-neighbour-search-for-spatial-points-in-r/
       # bzki: https://stackoverflow.com/questions/21977720/r-finding-closest-neighboring-point-and-number-of-neighbors-within-a-given-rad
      # https://stackoverflow.com/questions/6778908/transpose-a-data-frame      
# ideas: map to a/g mobility data (use package covid19mobility?)