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
  keep("repo", "data", "scripts", "gadm", "raw", "MotherData", "kpop", "full", "tiny", "master", 
       "csv", "s1", "s2", "s3", "s4", "s5", "s6", "user", "size", "baselist",
       sure = TRUE)
  
  # load rdata files with objects that we want
  bks <- readRDS(file.path(kpop, "bks.Rda"))
  load(file.path(kpop, "geo-data.Rdata")) 
  
  # keep only objects we want
  keep(bks, cabi.geo.key,
       "repo", "data", "scripts", "gadm", "raw", "MotherData", "kpop", "full", "tiny", "master", 
       "csv", "s1", "s2", "s3", "s4", "s5", "s6", "user", "size", "baselist",
       sure = TRUE)
  
  
                        #---------------------------------#
                        #  Restrict Rows + remove geometry# ----
                        #---------------------------------#
                        
                        
  
  # Note 2: we can't actually merge by string because it exhausts the memory, so we'll 
  # restrict the cabi.geo.key to only the appropriate rows so that we don't have duplicate 
  # observations. we can do this by filtering rows where the new/old id exists.
  
  # filter cabi.geo.key rows 
  cabi.geo.key.new <- filter(cabi.geo.key,
                             !is.na(cabi.station.id.new)) %>%
    st_drop_geometry() %>%
    select(c("osm.station.id", "cabi.station.id.new", "proj.station.id"))
    
  
  cabi.geo.key.old <- filter(cabi.geo.key,
                             !is.na(cabi.station.id.old)) %>%
    st_drop_geometry() %>%
    select(c("osm.station.id", "cabi.station.id.old", "proj.station.id"))
  
  
  #---------------------------------#
  #       convert bks to data table        # ----
  #---------------------------------#
  # library(data.table)
  # bks.dt <- data.table(bks)
  # 
                      #---------------------------------#
                      #        Merge to Pre2020         # ----
                      #---------------------------------#
                      
        # we merge by name here because the station name is actually the unique identifier for 
            # the station since there are often misspellings in the raw data: there are sometimes 
            # multiple entires for the same station number because there are multiple spellings 
            # in the raw data, so if we merge by number we get double merges.
        # note  bks is 33 x 27,034,374
  
                      # count number of missings for station number in bks #
  bks.station.miss <- sum(is.na(bks$startstationnumber))
  
    
                      
                      # split bks into two: old and new ids #
  # old
bkspre2020 <- bks %>%
    filter(is.na(startstationnumber) | startstationnumber > 1000 ) # all old ids are greater than 700, include missings
  
  # new
  bkspost2020 <- bks %>%
    filter(startstationnumber < 1000) # all old ids are greater than 700
  
  # check that no rows have been lost 
  oldnrows <- nrow(bkspre2020) #store no rows in old
  newnrows <- nrow(bkspost2020)#store no rows in new
  totnrows <- oldnrows+newnrows
  
  assert_that(oldnrows+newnrows == nrow(bks)) # check to make sure we didn't lose any in the split.

  # remove bks 
  rm(bks)
  
  

### start here.  can't get memeory to not exhaust on the merge, remove geometry from cabi.geo.key
  bkspre2020 %>%
    left_join(., cabi.geo.key.old, # merge to startstation
              by = c("startstationnumber" = "cabi.station.id.old"),
              na_matches = "never", # don't mess with na's
                ) 
  left_join(y = cabi.geo.key.new, # merge to endstation
            by = c("endstationnumber" = "cabi.station.id.new"),
            na_matches = "never", # don't mess with na's
  )

# add a prefix to indicate start
  # note that this assumes that the merged columns 
  # stay the same over time. check. 
colnames(bkspre2020)[34:48] <- paste0("s", sep = '.', colnames(bkspre2020)[34:48])
# add prefix to indicate end.
colnames(bkspre2020)[49:63] <- paste0("e", sep = '.', colnames(bkspre2020)[49:63])

# why does bks gain obs when we merge? becuase of multiple entires for same stationid (dif strings)





                          #---------------------------------#
                          #           Merge to post2020     # ----
                          #---------------------------------#


bkspost2020 <- bks %>%
  filter(startstationnumber < 1000) %>% # all new ids are greater less than 1000
  left_join(., cabi.geo.key, # merge to startstation
            by = c("startstation" = "cabi.station.name"),
            keep = FALSE
  ) %>%
  left_join(., cabi.geo.key, # merge to endstation
            by = c("endstation" = "cabi.station.name"),
            keep = FALSE)

# add a prefix to indicate start
# note that this assumes that the merged columns 
# stay the same over time. check. 
colnames(bkspost2020)[34:48] <- paste0("s", sep = '.', colnames(bkspost2020)[34:48])
# add prefix to indicate end.
colnames(bkspost2020)[49:63] <- paste0("e", sep = '.', colnames(bkspost2020)[49:63])

save(bks, bkspost2020, bkspre2020, cabi.geo.key,
     bydow, bydoy, byhour, byhour, bymo, bymodow, bywoy, byyear, 
     byyearmo, dlyrd, dlyrd_mbr, gps, stnyr, stnidkey, # objects
     file = file.path(kpop, "bks-full-data.Rdata"))
