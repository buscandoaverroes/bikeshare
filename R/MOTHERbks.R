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
                              # doParallel

  # install.packages(dplyr)

  library(dplyr)
  library(stargazer)
  library(tidyverse)
  library(readstata13)
  # library(reshape2)
  library(data.table)
  library(foreach)
  library(leaflet)
  # library(doParallel)
  # library(parallel)
  # library(parallel)
   library(MASS)







                              #-------------#
                              # Set User    #
                              #-------------#

                              #     1         buscandoaverroes
                              #     2         6k


  user <- 2





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
            s2 <- 1   # construct:      takes bks.Rda and makes other files
            s3 <- 1   # gps             constructs all gps things
            s3 <- 0   # plot              tbd
            s4 <- 0   # leaf

  # import
  if (s1 == 1) {
    source(file.path(analysis, "import.R"))
  }

  # construct
  if (s2 == 1) {
    source(file.path(analysis, "construct.R"))
  }

  # gps
  if (s3 == 1) {
    source(file.path(analysis, "gps.R"))
  }

  # plot
  if (s4 == 1) {
    source(file.path(analysis, "plot.R"))
  }

  # leaf
  if (s4 == 1) {
    source(file.path(analysis, "leaf.R"))
  }


 # so try to re-import main csv, bks$member should be only 0 1.
 # some empty "" strings in some vars (stationnames )

  # add "other" dummy var -- maybe this incldues the low-cost fare
  # gen 30 min or less var dummy

# credits: OpenStreetMaps, GADM
