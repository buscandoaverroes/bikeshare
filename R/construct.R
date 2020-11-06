# -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- #
# Name: construct.R
# Description: Takes raw rdata files and does some magic.
#
# -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- #

library(lubridate)


                            #---------------------#
                            #    load data        ----
                            #---------------------#
  load(file = file.path(full, "rawdata.Rdata"))


                            
                            #---------------------#
                            #   Data harmonization ----
                            #---------------------#
 # rename variables                            
  bks2020.2 <- r2020.2 %>%
    rename(., `Start date` = started_at,
           `End date` = ended_at, 
          `Start station` = start_station_name, 
          `Start station number` = start_station_id, 
          `End station number` = end_station_id,
          `End station` = end_station_name,
          `Member type` = member_casual,
          `Bike type`  = rideable_type) %>%
        select(-is_equity) # remove is_equity var
  
  
  # check factor levels of membership type, bike type
 bks2020.2 <- 
    mutate(bks2020.2,
      `Member type` = fct_recode(`Member type`,
                                 "Member" = "member",
                                 "Guest" = "casual"),
        `Bike type` = fct_recode(`Bike type`,
                                 "Electric" = "electric_bike",
                                 "Classic"  = "docked_bike")
      
    )
 

  
 
 
                             #---------------------#
                             #   New Variables   ----
                             #---------------------#

 # create list of data frames 
 df.list1 <- list(r2010, r2011, r2012, r2013, r2014, r2015, r2016, r2017, r2018,
                  r2019, r2020.1, bks2020.2)
 
 # create duration for bks2020.2
 bks2020.2$Duration <-lubridate::as.duration(bks2020.2$`End date` - bks2020.2$`Start date`)

 
 # Change factor levels to member/guest binary----
 bks2010 <- r2010 %>%
   rename("member" = `Member type`) %>%
   mutate(
         member = fct_recode(member,
              "Guest" = "Casual",
              "Guest" = "Unknown",
              "Member"= "Member"))
  
 bks2011 <- r2011 %>%
   rename("member" = `Member type`) %>%
   mutate(
     member = fct_recode(member,
                         "Guest" = "Casual",
                         "Guest" = "Unknown",
                         "Member"= "Member"))
 
 bks2012 <- r2012 %>%
   rename("member" = `Member type`) %>%
   mutate(
     member = fct_recode(member,
                         "Guest" = "Casual",
                         "Guest" = "Unknown",
                         "Member"= "Member"))
 
 bks2013 <- r2013 %>%
   rename("member" = `Member type`) %>%
   mutate(
     member = fct_recode(member,
                         "Guest" = "Casual",
                         "Guest" = "Unknown",
                         "Member"= "Member"))
 
 bks2014 <- r2014 %>%
   rename("member" = `Member type`) %>%
   mutate(
     member = fct_recode(member,
                         "Guest" = "Casual",
                         "Guest" = "Unknown",
                         "Member"= "Member"))
 
 bks2015 <- r2015 %>%
   rename("member" = `Member type`) %>%
   mutate(
     member = fct_recode(member,
                         "Guest" = "Casual",
                         "Member"= "Member"))
 
 bks2016 <- r2016 %>%
   rename("member" = `Member type`) %>%
   mutate(
     member = fct_recode(member,
                         "Guest" = "Casual",
                         "Member"= "Member"))
 
 bks2017 <- r2017 %>%
   rename("member" = `Member type`) %>%
   mutate(
     member = fct_recode(member,
                         "Guest" = "Casual",
                         "Member"= "Member"))
 
 bks2018 <- r2018 %>%
   rename("member" = `Member type`) %>%
   mutate(
     member = fct_recode(member,
                         "Guest" = "Casual",
                         "Member"= "Member"))
 
 bks2019 <- r2019 %>%
   rename("member" = `Member type`) %>%
   mutate(
     member = fct_recode(member,
                         "Guest" = "Casual",
                         "Member"= "Member"))
 
 bks2020.1 <- r2020.1 %>%
   rename("member" = `Member type`) %>%
   mutate(
     member = fct_recode(member,
                         "Guest" = "Casual",
                         "Member"= "Member"))
 
 
# remove original dataframes 
 remove(r2010, r2011, r2012, r2013, r2014, r2015, r2016, r2017, r2018,
        r2019, r2020.1, r2020.2)
 
 
# append dataframes 

 
# save 
save(bks2010, bks2011, bks2012, bks2013, bks2014, bks2015, bks2016, bks2017, 
      bks2018, bks2019, bks2020.1,bks2020.2,
      file = file.path(full, "years.Rdata"))
 