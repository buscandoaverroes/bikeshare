# -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- #
# Name: daily-rides.R
# Description: creatse daily rides summary objects 
#
# -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- #



                    
                    #---------------------#
                    # load data             ----
                    #---------------------#


load(file.path(full, "years.Rdata"))

                    
                    
                    
                    
                    
                  
                    
                    #---------------------#
                    # create daily rides   ----
                    #---------------------#
                    
# 2010 ---- 
                    
dr2010 <- bks2010 %>% # where dr == daily rides  
  mutate(
    yday      = yday(`Start date`),
    dayoweek  = lubridate::wday(`Start date`, label = TRUE),
    dayoweekn = lubridate::wday(`Start date`, label = FALSE)
  ) %>%
  group_by(yday) %>%
  summarise(
    daily.rides = n(),
    med.dur     = lubridate::duration(median(Duration)),
    dayoweek    = first(dayoweek),
    dayoweekn   = median(dayoweekn)
  )



# 2011 ---- 

dr2011 <- bks2011 %>% # where dr == daily rides  
  mutate(
    yday      = yday(`Start date`),
    dayoweek  = lubridate::wday(`Start date`, label = TRUE),
    dayoweekn = lubridate::wday(`Start date`, label = FALSE)
  ) %>%
  group_by(yday) %>%
  summarise(
    daily.rides = n(),
    med.dur     = lubridate::duration(median(Duration)),
    dayoweek    = first(dayoweek),
    dayoweekn   = median(dayoweekn)
  ) 




# 2012 ---- 
dr2012 <- bks2012 %>% # where dr == daily rides  
  mutate(
    yday      = yday(`Start date`),
    dayoweek  = lubridate::wday(`Start date`, label = TRUE),
    dayoweekn = lubridate::wday(`Start date`, label = FALSE)
  ) %>%
  group_by(yday) %>%
  summarise(
    daily.rides = n(),
    med.dur     = lubridate::duration(median(Duration)),
    dayoweek    = first(dayoweek),
    dayoweekn   = median(dayoweekn)
  ) 

# 2013 ---- 
dr2013 <- bks2013 %>% # where dr == daily rides  
  mutate(
    yday      = yday(`Start date`),
    dayoweek  = lubridate::wday(`Start date`, label = TRUE),
    dayoweekn = lubridate::wday(`Start date`, label = FALSE)
  ) %>%
  group_by(yday) %>%
  summarise(
    daily.rides = n(),
    med.dur     = lubridate::duration(median(Duration)),
    dayoweek    = first(dayoweek),
    dayoweekn   = median(dayoweekn)
  ) 



# 2014 ---- 
dr2014 <- bks2014 %>% # where dr == daily rides  
  mutate(
    yday      = yday(`Start date`),
    dayoweek  = lubridate::wday(`Start date`, label = TRUE),
    dayoweekn = lubridate::wday(`Start date`, label = FALSE)
  ) %>%
  group_by(yday) %>%
  summarise(
    daily.rides = n(),
    med.dur     = lubridate::duration(median(Duration)),
    dayoweek    = first(dayoweek),
    dayoweekn   = median(dayoweekn)
  ) 



# 2015 ---- 
dr2015 <- bks2015 %>% # where dr == daily rides  
  mutate(
    yday      = yday(`Start date`),
    dayoweek  = lubridate::wday(`Start date`, label = TRUE),
    dayoweekn = lubridate::wday(`Start date`, label = FALSE)
  ) %>%
  group_by(yday) %>%
  summarise(
    daily.rides = n(),
    med.dur     = lubridate::duration(median(Duration)),
    dayoweek    = first(dayoweek),
    dayoweekn   = median(dayoweekn)
  ) 


# 2016 ---- 
dr2016 <- bks2016 %>% # where dr == daily rides  
  mutate(
    yday      = yday(`Start date`),
    dayoweek  = lubridate::wday(`Start date`, label = TRUE),
    dayoweekn = lubridate::wday(`Start date`, label = FALSE)
  ) %>%
  group_by(yday) %>%
  summarise(
    daily.rides = n(),
    med.dur     = lubridate::duration(median(Duration)),
    dayoweek    = first(dayoweek),
    dayoweekn   = median(dayoweekn)
  )   


# 2017 ---- 
dr2017 <- bks2017 %>% # where dr == daily rides  
  mutate(
    yday      = yday(`Start date`),
    dayoweek  = lubridate::wday(`Start date`, label = TRUE),
    dayoweekn = lubridate::wday(`Start date`, label = FALSE)
  ) %>%
  group_by(yday) %>%
  summarise(
    daily.rides = n(),
    med.dur     = lubridate::duration(median(Duration)),
    dayoweek    = first(dayoweek),
    dayoweekn   = median(dayoweekn)
  )



# 2018 ---- 
dr2018 <- bks2018 %>% # where dr == daily rides  
  mutate(
    yday      = yday(`Start date`),
    dayoweek  = lubridate::wday(`Start date`, label = TRUE),
    dayoweekn = lubridate::wday(`Start date`, label = FALSE)
  ) %>%
  group_by(yday) %>%
  summarise(
    daily.rides = n(),
    med.dur     = lubridate::duration(median(Duration)),
    dayoweek    = first(dayoweek),
    dayoweekn   = median(dayoweekn)
  ) 



# 2019 ---- 
dr2019 <- bks2019 %>% # where dr == daily rides  
  mutate(
    yday      = yday(`Start date`),
    dayoweek  = lubridate::wday(`Start date`, label = TRUE),
    dayoweekn = lubridate::wday(`Start date`, label = FALSE)
  ) %>%
  group_by(yday) %>%
  summarise(
    daily.rides = n(),
    med.dur     = lubridate::duration(median(Duration)),
    dayoweek    = first(dayoweek),
    dayoweekn   = median(dayoweekn)
  ) 


# 2020.1 ---- 
dr2020.1 <- bks2020.1 %>% # where dr == daily rides  
  mutate(
    yday      = yday(`Start date`),
    dayoweek  = lubridate::wday(`Start date`, label = TRUE),
    dayoweekn = lubridate::wday(`Start date`, label = FALSE)
  ) %>%
  group_by(yday) %>%
  summarise(
    daily.rides = n(),
    med.dur     = lubridate::duration(median(Duration)),
    dayoweek    = first(dayoweek),
    dayoweekn   = median(dayoweekn)
  ) 



# 2020.2 ---- 
dr2020.2 <- bks2020.2 %>% # where dr == daily rides  
  mutate(
    yday      = yday(`Start date`),
    dayoweek  = lubridate::wday(`Start date`, label = TRUE),
    dayoweekn = lubridate::wday(`Start date`, label = FALSE)
  ) %>%
  group_by(yday) %>%
  summarise(
    daily.rides = n(),
    med.dur     = lubridate::duration(median(lubridate::as.duration(Duration))),
    dayoweek    = first(dayoweek),
    dayoweekn   = median(dayoweekn)
  )   


save(
  dr2010, dr2011, dr2012, dr2013, dr2014, dr2015, dr2016,
  dr2017, dr2018, dr2019, dr2020.1, dr2020.2,
  file = file.path(full, "daily-rides.Rdata")
)
