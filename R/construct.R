# -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- #
# Name: construct.R
# Description: creates various dataset from mother dataset
#
# -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- #


	                              #-------------#
	                              # import Rda  # ----
	                              #-------------#
      bks <- readRDS(file.path(MotherData, "motherdata.Rda"))

      # create byyear: collapse by year ----

      byyear <- bks %>%
       group_by(yearstart) %>%
       summarise( count = n(),
                  nstation = n_distinct(startstationnumber),
                  mbr_ratio = mean(member, na.rm = TRUE),
                  av_dur = mean(duration, na.rm = TRUE),
                  av_min = mean(min, na.rm = TRUE),
                  av_hour = mean(hour, na.rm = TRUE),
                  med_dur = median(duration, na.rm = TRUE),
                  med_min = median(min, na.rm = TRUE),
                  med_hour = median(hour, na.rm = TRUE)
      )




      # create bymo: collapse by month averaged across all years ----

      bymo <- bks %>%
        group_by(monthstart) %>%
        summarise( count = n(),
                   nstation = n_distinct(startstationnumber),
                   mbr_ratio = mean(member, na.rm = TRUE),
                   av_dur = mean(duration, na.rm = TRUE),
                   av_min = mean(min, na.rm = TRUE),
                   av_hour = mean(hour, na.rm = TRUE),
                   med_dur = median(duration, na.rm = TRUE),
                   med_min = median(min, na.rm = TRUE),
                   med_hour = median(hour, na.rm = TRUE)
        )




      # create byyearmo: collapse by year-month ----

      byyearmo <- bks %>%
        group_by(monthstart, yearstart) %>%
        summarise( count = n(),
                   nstation = n_distinct(startstationnumber),
                   mbr_ratio = mean(member, na.rm = TRUE),
                   av_dur = mean(duration, na.rm = TRUE),
                   av_min = mean(min, na.rm = TRUE),
                   av_hour = mean(hour, na.rm = TRUE),
                   med_dur = median(duration, na.rm = TRUE),
                   med_min = median(min, na.rm = TRUE),
                   med_hour = median(hour, na.rm = TRUE)
        )




      # create bydow: collapse by day of the week (1, 2, 3, ) ----

      bydow <- bks %>%
        group_by(dowstart) %>%
        summarise( count = n(),
                   nstation = n_distinct(startstationnumber),
                   mbr_ratio = mean(member, na.rm = TRUE),
                   av_dur = mean(duration, na.rm = TRUE),
                   av_min = mean(min, na.rm = TRUE),
                   av_hour = mean(hour, na.rm = TRUE),
                   med_dur = median(duration, na.rm = TRUE),
                   med_min = median(min, na.rm = TRUE),
                   med_hour = median(hour, na.rm = TRUE),
                   nwoyyear = n_distinct(weekstart, yearstart),
        )

      bydow <- mutate(bydow,
                      dailyrides = count / nwoyyear )


      # create bymodow: collapse by day of the week and month ----

      bymodow <- bks %>%
        group_by(dowstart, monthstart) %>%
        summarise( count = n(),
                   nstation = n_distinct(startstationnumber),
                   mbr_ratio = mean(member, na.rm = TRUE),
                   av_dur = mean(duration, na.rm = TRUE),
                   av_min = mean(min, na.rm = TRUE),
                   av_hour = mean(hour, na.rm = TRUE),
                   med_dur = median(duration, na.rm = TRUE),
                   med_min = median(min, na.rm = TRUE),
                   med_hour = median(hour, na.rm = TRUE)
        )




      # create bydoy: collapse by day of year  ----

      bydoy <- bks %>%
        group_by(doystart) %>%
        summarise( count = n(),
                   nstation = n_distinct(startstationnumber),
                   mbr_ratio = mean(member, na.rm = TRUE),
                   av_dur = mean(duration, na.rm = TRUE),
                   av_min = mean(min, na.rm = TRUE),
                   av_hour = mean(hour, na.rm = TRUE),
                   med_dur = median(duration, na.rm = TRUE),
                   med_min = median(min, na.rm = TRUE),
                   med_hour = median(hour, na.rm = TRUE),
                   nyear = n_distinct(yearstart, na.rm = TRUE))

      bydoy<- mutate(bydoy,
             dailyrides = count / nyear)





      # create bywoy: collapse by week of year ----

      bywoy <- bks %>%
        group_by(weekstart) %>%
        summarise( count = n(),
                   nstation = n_distinct(startstationnumber),
                   mbr_ratio = mean(member, na.rm = TRUE),
                   av_dur = mean(duration, na.rm = TRUE),
                   av_min = mean(min, na.rm = TRUE),
                   av_hour = mean(hour, na.rm = TRUE),
                   med_dur = median(duration, na.rm = TRUE),
                   med_min = median(min, na.rm = TRUE),
                   med_hour = median(hour, na.rm = TRUE),
                   nyear = n_distinct(yearstart, na.rm = TRUE)
        )

    bywoy <-  mutate(bywoy,
             weeklyrides = count / nyear,
             dailyrides  = (count / (nyear * 7)) )

      byhour <- bks %>%
        group_by(hourstart) %>%
        summarise( count = n(),
                   nstation = n_distinct(startstationnumber),
                   mbr_ratio = mean(member, na.rm = TRUE),
                   av_dur = mean(duration, na.rm = TRUE),
                   av_min = mean(min, na.rm = TRUE),
                   av_hour = mean(hour, na.rm = TRUE),
                   med_dur = median(duration, na.rm = TRUE),
                   med_min = median(min, na.rm = TRUE),
                   med_hour = median(hour, na.rm = TRUE)
        )

      byhouryr <- bks %>%
        group_by(yearstart, hourstart) %>%
        summarise( count = n(),
                   nstation = n_distinct(startstationnumber),
                   mbr_ratio = mean(member, na.rm = TRUE),
                   av_dur = mean(duration, na.rm = TRUE),
                   av_min = mean(min, na.rm = TRUE),
                   av_hour = mean(hour, na.rm = TRUE),
                   med_dur = median(duration, na.rm = TRUE),
                   med_min = median(min, na.rm = TRUE),
                   med_hour = median(hour, na.rm = TRUE)
        )
        byhouryr$year <- factor(byhouryr$yearstart, ordered = TRUE)




      # create dlyrd: one row is average for each day since opening ----
      dlyrd <- bks %>%
        group_by(yearstart, doystart) %>%
        summarise( count = n(),
                   nstation = n_distinct(startstationnumber),
                   mbr_ratio = mean(member, na.rm = TRUE),
                   av_dur = mean(duration, na.rm = TRUE),
                   av_min = mean(min, na.rm = TRUE),
                   av_hour = mean(hour, na.rm = TRUE),
                   med_dur = median(duration, na.rm = TRUE),
                   med_min = median(min, na.rm = TRUE),
                   med_hour = median(hour, na.rm = TRUE)
        )

      dlyrd_mbr <- bks %>%
        group_by(yearstart, doystart, member) %>%
        summarise( count = n(),
                   nstation = n_distinct(startstationnumber),
                   mbr_ratio = mean(member, na.rm = TRUE),
                   av_dur = mean(duration, na.rm = TRUE),
                   av_min = mean(min, na.rm = TRUE),
                   av_hour = mean(hour, na.rm = TRUE),
                   med_dur = median(duration, na.rm = TRUE),
                   med_min = median(min, na.rm = TRUE),
                   med_hour = median(hour, na.rm = TRUE)
        )


      # sort on year and day of year
      dlyrd <- arrange(dlyrd, yearstart, doystart)
      dlyrd_mbr <- arrange(dlyrd, yearstart, doystart)
      # create a numer == to _n for day of operation, rearrange
      dlyrd <- arrange(dlyrd, yearstart, doystart)
      dlyrd_mbr <- arrange(dlyrd, yearstart, doystart)

      dlyrd$dayid <- seq_len(nrow(dlyrd))
      dlyrd_mbr$dayid <- seq_len(nrow(dlyrd_mbr)) # every row here should skip

      dlyrd <- arrange(dlyrd, dayid, yearstart, doystart)
      dlyrd_mbr <- arrange(dlyrd, dayid, yearstart, doystart)

      dlyrd$year <- factor(dlyrd$yearstart, ordered = TRUE)
      dlyrd_mbr$year <- factor(dlyrd$yearstart, ordered = TRUE)

      # create by station, average beginning rides per year
      stnyr <- bks %>%
        group_by(yearstart, startstationnumber) %>%
        summarise( count = n(),
                   nstation = n_distinct(startstationnumber),
                   mbr_ratio = mean(member, na.rm = TRUE),
                   av_dur = mean(duration, na.rm = TRUE),
                   av_min = mean(min, na.rm = TRUE),
                   av_hour = mean(hour, na.rm = TRUE),
                   med_dur = median(duration, na.rm = TRUE),
                   med_min = median(min, na.rm = TRUE),
                   med_hour = median(hour, na.rm = TRUE)
        )


      gps <- read.dta13(file.path(MotherData, "april2020gps.dta"),
                        convert.factors = TRUE,
                        nonint.factors = TRUE,
                        select.cols = c("ride_id",
                                        "started_at",
                                        "ended_at",
                                        "start_station_name",
                                        "startstationnumber",
                                        "start_lat",
                                        "start_lng"))

      
      
      
      
                                    
                                    #---------------------#
                                    # run station-number.R # ----
                                    #---------------------#
      # this script creates a dictionary of station numbers because, at some point in 2020,
      # the station number scheme changes
      # output= object called "stnidkey"
      
      source(file.path(scripts, "station-number.R"))
                                    
                                    
                                    
      
      
  
                                    #---------------------#
                                    # export all as Rdata # ----
                                    #---------------------#
      
      
  save(bydow, bydoy, byhour, byhour, bymo, bymodow, bywoy, byyear, 
       byyearmo, dlyrd, dlyrd_mbr, gps, stnyr, stnidkey, # objects
       file = file.path(kpop, "bike-snippets.Rdata"))
                                        
      

                                    #-------------------------#
                                    # export each file as Rda # ----
                                    #-------------------------#



      saveRDS(bydow,
              file.path(kpop, "bydow.Rda"))
      saveRDS(bydoy,
              file.path(kpop, "bydoy.Rda"))
      saveRDS(byhour,
              file.path(kpop, "byhour.Rda"))
      saveRDS(byhouryr,
              file.path(kpop, "byhouryr.Rda"))
      saveRDS(bymo,
              file.path(kpop, "bymo.Rda"))
      saveRDS(bymodow,
              file.path(kpop, "bymodow.Rda"))
      saveRDS(bywoy,
              file.path(kpop, "bywoy.Rda"))
      saveRDS(byyear,
              file.path(kpop, "byyear.Rda"))
      saveRDS(byyearmo,
              file.path(kpop, "byyearmo.Rda"))
      saveRDS(dlyrd,
              file.path(kpop, "dlyrd.Rda"))
      saveRDS(dlyrd_mbr,
              file.path(kpop, "dlyrd_mbr.Rda"))
      saveRDS(gps,
              file.path(kpop, "gps-import.Rda"))
      saveRDS(stnyr,
              file.path(kpop, "stnyr.Rda"))
