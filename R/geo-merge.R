# -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- #
# Name: geo-merge.R
# Description: merges geographic data from cabi.geo.key to main dataset
#
# -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- #

 # Note that in this section we will split the main dataset in two based on when the stationid 
 # changes (april 2020). The processing will be the same with the same variables etc. 

# current issue: can't merge because bks eats up all the memory, 
# try next: restart session and run only this? something about garbage? gc?


library(assertthat)
                      #---------------------------------#
                      # load+keep only necessary objects# ----
                      #---------------------------------#
                  # we have to keep only necessary objects for merging because 
                  # otherwise it slows down/will fail.
                  # objects we want: (from bks-full-data): bks
                  #                  (from geo-data): cabi.geo.key  
  
  # remove all existing objects except for essential ones.
  keep("repo", "data", "scripts", "gadm", "raw", "MotherData", "kpop", "full",
       "s1", "s2", "s3", "s4", "s5", "s6", "user", "baselist",
       sure = TRUE)
  
  # load rdata files with objects that we want
  load(file.path(full, "years.Rdata"))
  load(file.path(kpop, "geo-data.Rdata")) 

  
  
                    
                    #---------------------------------#
                    #  Merge geo dictionary to each yr# ----
                    #---------------------------------#
# Note that we will have to merge twice, once for the start station and once for the end station. Also, 
#   we will only merge the project id to save space. This way we can merge to other geographic info 
#   using the project id when needed
  
 # old numbering scheme (station.id.old)   
  bks2010 <- 
    left_join( bks2010, cabi.geo.key,
              by = c("Start station number" = "cabi.station.id.old",
                     "Start station"        = "cabi.station.name"),
              na_matches = "never") %>%
    select(-osm.station.id, -osm.station.name, -cabi.station.id.new, # only keep proj.station.id
           -gadm.loc, -gadm.cat, -gadm.state, -osm.metro.id,
           -osm.metro.name, -metro200m, -dups.cabi.station.id,
           -geometry) %>%
    rename( start.pid = proj.station.id) %>% # rename to start station, repeat for end station
  left_join(cabi.geo.key,
            by = c("End station number" = "cabi.station.id.old",
                   "End station"        = "cabi.station.name"),
            na_matches = "never") %>%
    select(-osm.station.id, -osm.station.name, -cabi.station.id.new, # only keep proj.station.id
           -gadm.loc, -gadm.cat, -gadm.state, -osm.metro.id,
           -osm.metro.name, -metro200m, -dups.cabi.station.id,
           -geometry) %>%
    rename( end.pid = proj.station.id) # rename to end station
  
  
  bks2011 <- 
    left_join( bks2011, cabi.geo.key,
               by = c("Start station number" = "cabi.station.id.old",
                      "Start station"        = "cabi.station.name"),
               na_matches = "never") %>%
    select(-osm.station.id, -osm.station.name, -cabi.station.id.new, # only keep proj.station.id
           -gadm.loc, -gadm.cat, -gadm.state, -osm.metro.id,
           -osm.metro.name, -metro200m, -dups.cabi.station.id,
           -geometry) %>%
    rename( start.pid = proj.station.id) %>% # rename to start station, repeat for end station
    left_join(cabi.geo.key,
              by = c("End station number" = "cabi.station.id.old",
                     "End station"        = "cabi.station.name"),
              na_matches = "never") %>%
    select(-osm.station.id, -osm.station.name, -cabi.station.id.new, # only keep proj.station.id
           -gadm.loc, -gadm.cat, -gadm.state, -osm.metro.id,
           -osm.metro.name, -metro200m, -dups.cabi.station.id,
           -geometry) %>%
    rename( end.pid = proj.station.id) # rename to end station
  

  
  bks2012 <- 
    left_join( bks2012, cabi.geo.key,
               by = c("Start station number" = "cabi.station.id.old",
                      "Start station"        = "cabi.station.name"),
               na_matches = "never") %>%
    select(-osm.station.id, -osm.station.name, -cabi.station.id.new, # only keep proj.station.id
           -gadm.loc, -gadm.cat, -gadm.state, -osm.metro.id,
           -osm.metro.name, -metro200m, -dups.cabi.station.id,
           -geometry) %>%
    rename( start.pid = proj.station.id) %>% # rename to start station, repeat for end station
    left_join(cabi.geo.key,
              by = c("End station number" = "cabi.station.id.old",
                     "End station"        = "cabi.station.name"),
              na_matches = "never") %>%
    select(-osm.station.id, -osm.station.name, -cabi.station.id.new, # only keep proj.station.id
           -gadm.loc, -gadm.cat, -gadm.state, -osm.metro.id,
           -osm.metro.name, -metro200m, -dups.cabi.station.id,
           -geometry) %>%
    rename( end.pid = proj.station.id) # rename to end station
  
  

  bks2013 <- 
    left_join( bks2013, cabi.geo.key,
               by = c("Start station number" = "cabi.station.id.old",
                      "Start station"        = "cabi.station.name"),
               na_matches = "never") %>%
    select(-osm.station.id, -osm.station.name, -cabi.station.id.new, # only keep proj.station.id
           -gadm.loc, -gadm.cat, -gadm.state, -osm.metro.id,
           -osm.metro.name, -metro200m, -dups.cabi.station.id,
           -geometry) %>%
    rename( start.pid = proj.station.id) %>% # rename to start station, repeat for end station
    left_join(cabi.geo.key,
              by = c("End station number" = "cabi.station.id.old",
                     "End station"        = "cabi.station.name"),
              na_matches = "never") %>%
    select(-osm.station.id, -osm.station.name, -cabi.station.id.new, # only keep proj.station.id
           -gadm.loc, -gadm.cat, -gadm.state, -osm.metro.id,
           -osm.metro.name, -metro200m, -dups.cabi.station.id,
           -geometry) %>%
    rename( end.pid = proj.station.id) # rename to end station
  
  
  
  bks2014 <- 
    left_join( bks2014, cabi.geo.key,
               by = c("Start station number" = "cabi.station.id.old",
                      "Start station"        = "cabi.station.name"),
               na_matches = "never") %>%
    select(-osm.station.id, -osm.station.name, -cabi.station.id.new, # only keep proj.station.id
           -gadm.loc, -gadm.cat, -gadm.state, -osm.metro.id,
           -osm.metro.name, -metro200m, -dups.cabi.station.id,
           -geometry) %>%
    rename( start.pid = proj.station.id) %>% # rename to start station, repeat for end station
    left_join(cabi.geo.key,
              by = c("End station number" = "cabi.station.id.old",
                     "End station"        = "cabi.station.name"),
              na_matches = "never") %>%
    select(-osm.station.id, -osm.station.name, -cabi.station.id.new, # only keep proj.station.id
           -gadm.loc, -gadm.cat, -gadm.state, -osm.metro.id,
           -osm.metro.name, -metro200m, -dups.cabi.station.id,
           -geometry) %>%
    rename( end.pid = proj.station.id) # rename to end station
  
  
  
  
  bks2015 <- 
    left_join( bks2015, cabi.geo.key,
               by = c("Start station number" = "cabi.station.id.old",
                      "Start station"        = "cabi.station.name"),
               na_matches = "never") %>%
    select(-osm.station.id, -osm.station.name, -cabi.station.id.new, # only keep proj.station.id
           -gadm.loc, -gadm.cat, -gadm.state, -osm.metro.id,
           -osm.metro.name, -metro200m, -dups.cabi.station.id,
           -geometry) %>%
    rename( start.pid = proj.station.id) %>% # rename to start station, repeat for end station
    left_join(cabi.geo.key,
              by = c("End station number" = "cabi.station.id.old",
                     "End station"        = "cabi.station.name"),
              na_matches = "never") %>%
    select(-osm.station.id, -osm.station.name, -cabi.station.id.new, # only keep proj.station.id
           -gadm.loc, -gadm.cat, -gadm.state, -osm.metro.id,
           -osm.metro.name, -metro200m, -dups.cabi.station.id,
           -geometry) %>%
    rename( end.pid = proj.station.id) # rename to end station
  
  
  bks2016 <- 
    left_join( bks2016, cabi.geo.key,
               by = c("Start station number" = "cabi.station.id.old",
                      "Start station"        = "cabi.station.name"),
               na_matches = "never") %>%
    select(-osm.station.id, -osm.station.name, -cabi.station.id.new, # only keep proj.station.id
           -gadm.loc, -gadm.cat, -gadm.state, -osm.metro.id,
           -osm.metro.name, -metro200m, -dups.cabi.station.id,
           -geometry) %>%
    rename( start.pid = proj.station.id) %>% # rename to start station, repeat for end station
    left_join(cabi.geo.key,
              by = c("End station number" = "cabi.station.id.old",
                     "End station"        = "cabi.station.name"),
              na_matches = "never") %>%
    select(-osm.station.id, -osm.station.name, -cabi.station.id.new, # only keep proj.station.id
           -gadm.loc, -gadm.cat, -gadm.state, -osm.metro.id,
           -osm.metro.name, -metro200m, -dups.cabi.station.id,
           -geometry) %>%
    rename( end.pid = proj.station.id) # rename to end station
  
  
  bks2017 <- 
    left_join( bks2017, cabi.geo.key,
               by = c("Start station number" = "cabi.station.id.old",
                      "Start station"        = "cabi.station.name"),
               na_matches = "never") %>%
    select(-osm.station.id, -osm.station.name, -cabi.station.id.new, # only keep proj.station.id
           -gadm.loc, -gadm.cat, -gadm.state, -osm.metro.id,
           -osm.metro.name, -metro200m, -dups.cabi.station.id,
           -geometry) %>%
    rename( start.pid = proj.station.id) %>% # rename to start station, repeat for end station
    left_join(cabi.geo.key,
              by = c("End station number" = "cabi.station.id.old",
                     "End station"        = "cabi.station.name"),
              na_matches = "never") %>%
    select(-osm.station.id, -osm.station.name, -cabi.station.id.new, # only keep proj.station.id
           -gadm.loc, -gadm.cat, -gadm.state, -osm.metro.id,
           -osm.metro.name, -metro200m, -dups.cabi.station.id,
           -geometry) %>%
    rename( end.pid = proj.station.id) # rename to end station
  
  
  
  
  bks2018 <- 
    left_join( bks2018, cabi.geo.key,
               by = c("Start station number" = "cabi.station.id.old",
                      "Start station"        = "cabi.station.name"),
               na_matches = "never") %>%
    select(-osm.station.id, -osm.station.name, -cabi.station.id.new, # only keep proj.station.id
           -gadm.loc, -gadm.cat, -gadm.state, -osm.metro.id,
           -osm.metro.name, -metro200m, -dups.cabi.station.id,
           -geometry) %>%
    rename( start.pid = proj.station.id) %>% # rename to start station, repeat for end station
    left_join(cabi.geo.key,
              by = c("End station number" = "cabi.station.id.old",
                     "End station"        = "cabi.station.name"),
              na_matches = "never") %>%
    select(-osm.station.id, -osm.station.name, -cabi.station.id.new, # only keep proj.station.id
           -gadm.loc, -gadm.cat, -gadm.state, -osm.metro.id,
           -osm.metro.name, -metro200m, -dups.cabi.station.id,
           -geometry) %>%
    rename( end.pid = proj.station.id) # rename to end station
  
 
  bks2019 <- 
    left_join( bks2019, cabi.geo.key,
               by = c("Start station number" = "cabi.station.id.old",
                      "Start station"        = "cabi.station.name"),
               na_matches = "never") %>%
    select(-osm.station.id, -osm.station.name, -cabi.station.id.new, # only keep proj.station.id
           -gadm.loc, -gadm.cat, -gadm.state, -osm.metro.id,
           -osm.metro.name, -metro200m, -dups.cabi.station.id,
           -geometry) %>%
    rename( start.pid = proj.station.id) %>% # rename to start station, repeat for end station
    left_join(cabi.geo.key,
              by = c("End station number" = "cabi.station.id.old",
                     "End station"        = "cabi.station.name"),
              na_matches = "never") %>%
    select(-osm.station.id, -osm.station.name, -cabi.station.id.new, # only keep proj.station.id
           -gadm.loc, -gadm.cat, -gadm.state, -osm.metro.id,
           -osm.metro.name, -metro200m, -dups.cabi.station.id,
           -geometry) %>%
    rename( end.pid = proj.station.id) # rename to end station
  
  
  bks2020.1 <- 
    left_join( bks2020.1, cabi.geo.key,
               by = c("Start station number" = "cabi.station.id.old",
                      "Start station"        = "cabi.station.name"),
               na_matches = "never") %>%
    select(-osm.station.id, -osm.station.name, -cabi.station.id.new, # only keep proj.station.id
           -gadm.loc, -gadm.cat, -gadm.state, -osm.metro.id,
           -osm.metro.name, -metro200m, -dups.cabi.station.id,
           -geometry) %>%
    rename( start.pid = proj.station.id) %>% # rename to start station, repeat for end station
    left_join(cabi.geo.key,
              by = c("End station number" = "cabi.station.id.old",
                     "End station"        = "cabi.station.name"),
              na_matches = "never") %>%
    select(-osm.station.id, -osm.station.name, -cabi.station.id.new, # only keep proj.station.id
           -gadm.loc, -gadm.cat, -gadm.state, -osm.metro.id,
           -osm.metro.name, -metro200m, -dups.cabi.station.id,
           -geometry) %>%
    rename( end.pid = proj.station.id) # rename to end station
  
 
  
  # new numbering scheme (station.id.new)
  bks2020.2 <-
    left_join( bks2020.2, cabi.geo.key,
               by = c("Start station number" = "cabi.station.id.new",
                      "Start station"        = "cabi.station.name"),
               na_matches = "never") %>% 
    select(-osm.station.id, -osm.station.name, -cabi.station.id.old, # only keep proj.station.id
           -gadm.loc, -gadm.cat, -gadm.state, -osm.metro.id,
           -osm.metro.name, -metro200m, -dups.cabi.station.id,
           -geometry) %>%
    rename(start.pid = proj.station.id) %>% # rename to start station, repeat for end station
    left_join(cabi.geo.key,
              by = c("End station number" = "cabi.station.id.new",
                     "End station"        = "cabi.station.name"),
              na_matches = "never") %>%
    select(-osm.station.id, -osm.station.name, -cabi.station.id.old, # only keep proj.station.id
           -gadm.loc, -gadm.cat, -gadm.state, -osm.metro.id,
           -osm.metro.name, -metro200m, -dups.cabi.station.id,
           -geometry) %>%
    rename( end.pid = proj.station.id) # rename to end station
  
  
  # remove items, save dataset 
  save(bks2010, bks2011, bks2012, bks2013, bks2014, bks2015, bks2016, bks2017, 
       bks2018, bks2019, bks2020.1,bks2020.2,
       file = file.path(full, "years.Rdata"))