# -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- #
# Name: station-summary.R
# Description: creates summary objects by station, year
#
# -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- #




load(file.path(full, "years.Rdata"))



#---------------------#
#  Station Summary   ---- 
#---------------------#

# 2010 ----

# daily 

stndaily2010o <- bks2010 %>% # read: station daily, [year]
  mutate(
    yday      = yday(`Start date`),
    month     = month(`Start date`),
    hour      = hour(`Start date`),
  ) %>%
  group_by(start.pid, yday, hour) %>%
  summarise(
    #station.pid = first(start.id),
    npickup    = n(),
    month      = first(month),
    med.dur.ot = lubridate::duration(median(Duration))
    
  )

stndaily2010i <- bks2010 %>% # read: station daily, [year]
  mutate(
    yday      = yday(`Start date`),
    hour      = hour(`Start date`)
  ) %>%
  group_by(end.pid, yday, hour) %>%
  summarise(
    #station.pid = first(start.id),
    ndropoff   = n(),
    med.dur.in = lubridate::duration(median(Duration))
    
  )

stndaily2010 <- full_join(stndaily2010o,
                          stndaily2010i,
                          by = c("start.pid" = "end.pid",
                                 "yday"      = "yday",
                                 "hour"      = "hour"))
rm(stndaily2010i, stndaily2010o)



# monthly 

stnmonthly2010o <- bks2010 %>% # read: station daily, [year]
  mutate(
    month     = month(`Start date`),
  ) %>%
  group_by(start.pid, month) %>%
  summarise(
    npickup    = n(),
    month      = first(month),
    av.daily.ot= round((n()/lubridate::days_in_month(month)), digits = 1),
    med.dur.ot = lubridate::duration(median(Duration), units = "seconds")
  )

stnmonthly2010i <- bks2010 %>% # read: station daily, [year]
  mutate(
    month     = month(`Start date`),
  ) %>%
  group_by(end.pid, month) %>%
  summarise(
    #station.pid = first(start.id),
    ndropoff   = n(),
    month      = first(month),
    med.dur.in = lubridate::duration(median(Duration)), 
    av.daily.in= round((n()/lubridate::days_in_month(month)), digits = 1),
  ) 

stnmonthly2010 <- 
  full_join(stnmonthly2010o,
            stnmonthly2010i,
            by = c("start.pid" = "end.pid",
                   "month"     = "month")) %>%
  rename(pid = start.pid)

rm(stnmonthly2010i, stnmonthly2010o)


# top 3 stations 

## 1st top destination 
top.dest1 <- bks2010 %>% # read: station daily, [year]
  mutate(
    month     = month(`Start date`),
  ) %>%
  group_by(month, start.pid, end.pid) %>%
  summarise(
    #station.pid = first(start.id),
    top.dest1n    = n(),
  ) %>%
  filter(row_number(desc(top.dest1n)) == 1) %>%
  rename(dest1.pid = end.pid) 

# 2nd top destination
top.dest2 <- bks2010 %>% 
  mutate(
    month     = month(`Start date`),
  ) %>%
  group_by(month, start.pid, end.pid) %>%
  summarise(
    #station.pid = first(start.id),
    top.dest2n    = n(),
  ) %>%
  filter(row_number(desc(top.dest2n)) == 2)%>%
  rename(dest2.pid = end.pid) 

# 3rd top destination 
top.dest3 <- bks2010 %>% 
  mutate(
    month     = month(`Start date`),
  ) %>%
  group_by(month, start.pid, end.pid) %>%
  summarise(
    #station.pid = first(start.id),
    top.dest3n    = n(),
  ) %>%
  filter(row_number(desc(top.dest3n)) == 3)%>%
  rename(dest3.pid = end.pid) 

# join top destinations together.
top.dest.2010 <- 
  left_join(top.dest1, top.dest2,
            by = c("start.pid", "month")) %>% 
  left_join(top.dest3, by = c("start.pid", "month")) %>%
  rename(pid = start.pid)


# remove objects. 
rm(top.dest1, top.dest2, top.dest3)




# 1st top arriv 
top.arrv1 <- bks2010 %>% # read: station daily, [year]
  mutate(
    month     = month(`Start date`),
  ) %>%
  group_by(month, end.pid, start.pid) %>%
  summarise(
    #station.pid = first(start.id),
    top.arrv1n    = n(),
  ) %>%
  filter(row_number(desc(top.arrv1n)) == 1) %>%
  rename(arrv1.pid = start.pid) 

# 2nd top arrriv
top.arrv2 <- bks2010 %>% 
  mutate(
    month     = month(`Start date`),
  ) %>%
  group_by(month, end.pid, start.pid) %>%
  summarise(
    #station.pid = first(start.id),
    top.arrv2n    = n(),
  ) %>%
  filter(row_number(desc(top.arrv2n)) == 2)%>%
  rename(arrv2.pid = start.pid) 

# 3rd top arriv 
top.arrv3 <- bks2010 %>% 
  mutate(
    month     = month(`Start date`),
  ) %>%
  group_by(month, end.pid, start.pid) %>%
  summarise(
    #station.pid = first(start.id),
    top.arrv3n    = n(),
  ) %>%
  filter(row_number(desc(top.arrv3n)) == 3)%>%
  rename(arrv3.pid = start.pid) 

# join top arrvinations together.
top.arrv.2010 <-
  left_join(top.arrv1, top.arrv2,
            by = c("end.pid", "month")) %>%
  left_join(top.arrv3, by = c("end.pid", "month")) %>%
  rename(pid = end.pid)

# remove objects. 
rm(top.arrv1, top.arrv2, top.arrv3)


## Join tops together 
top.2010 <- 
  left_join(top.arrv.2010, top.dest.2010,
            by = c("pid", "month"))

## join to main monthly thing, add net flow replace with na if top value <= 5 %%%
stnmonthly2010 <- stnmonthly2010 %>%
  left_join(top.2010, by = c("pid", "month")) %>%
  mutate(net.daily.flow = av.daily.ot - av.daily.in)




# 2011 ---- 

# daily 

stndaily2011o <- bks2011 %>% # read: station daily, [year]
  mutate(
    yday      = yday(`Start date`),
    month     = month(`Start date`),
    hour      = hour(`Start date`),
  ) %>%
  group_by(start.pid, yday, hour) %>%
  summarise(
    #station.pid = first(start.id),
    npickup    = n(),
    month      = first(month),
    med.dur.ot = lubridate::duration(median(Duration))
    
  )

stndaily2011i <- bks2011 %>% # read: station daily, [year]
  mutate(
    yday      = yday(`Start date`),
    hour      = hour(`Start date`)
  ) %>%
  group_by(end.pid, yday, hour) %>%
  summarise(
    #station.pid = first(start.id),
    ndropoff   = n(),
    med.dur.in = lubridate::duration(median(Duration))
    
  )

stndaily2011 <- full_join(stndaily2011o,
                          stndaily2011i,
                          by = c("start.pid" = "end.pid",
                                 "yday"      = "yday",
                                 "hour"      = "hour"))
rm(stndaily2011i, stndaily2011o)



# monthly 

stnmonthly2011o <- bks2011 %>% # read: station daily, [year]
  mutate(
    month     = month(`Start date`),
  ) %>%
  group_by(start.pid, month) %>%
  summarise(
    npickup    = n(),
    month      = first(month),
    av.daily.ot= round((n()/lubridate::days_in_month(month)), digits = 1),
    med.dur.ot = lubridate::duration(median(Duration), units = "seconds")
  )

stnmonthly2011i <- bks2011 %>% # read: station daily, [year]
  mutate(
    month     = month(`Start date`),
  ) %>%
  group_by(end.pid, month) %>%
  summarise(
    #station.pid = first(start.id),
    ndropoff   = n(),
    month      = first(month),
    med.dur.in = lubridate::duration(median(Duration)), 
    av.daily.in= round((n()/lubridate::days_in_month(month)), digits = 1),
  ) 

stnmonthly2011 <- 
  full_join(stnmonthly2011o,
            stnmonthly2011i,
            by = c("start.pid" = "end.pid",
                   "month"     = "month")) %>%
  rename(pid = start.pid)

rm(stnmonthly2011i, stnmonthly2011o)


# top 3 stations 

## 1st top destination 
top.dest1 <- bks2011 %>% # read: station daily, [year]
  mutate(
    month     = month(`Start date`),
  ) %>%
  group_by(month, start.pid, end.pid) %>%
  summarise(
    #station.pid = first(start.id),
    top.dest1n    = n(),
  ) %>%
  filter(row_number(desc(top.dest1n)) == 1) %>%
  rename(dest1.pid = end.pid) 

# 2nd top destination
top.dest2 <- bks2011 %>% 
  mutate(
    month     = month(`Start date`),
  ) %>%
  group_by(month, start.pid, end.pid) %>%
  summarise(
    #station.pid = first(start.id),
    top.dest2n    = n(),
  ) %>%
  filter(row_number(desc(top.dest2n)) == 2)%>%
  rename(dest2.pid = end.pid) 

# 3rd top destination 
top.dest3 <- bks2011 %>% 
  mutate(
    month     = month(`Start date`),
  ) %>%
  group_by(month, start.pid, end.pid) %>%
  summarise(
    #station.pid = first(start.id),
    top.dest3n    = n(),
  ) %>%
  filter(row_number(desc(top.dest3n)) == 3)%>%
  rename(dest3.pid = end.pid) 

# join top destinations together.
top.dest.2011 <- 
  left_join(top.dest1, top.dest2,
            by = c("start.pid", "month")) %>% 
  left_join(top.dest3, by = c("start.pid", "month")) %>%
  rename(pid = start.pid)


# remove objects. 
rm(top.dest1, top.dest2, top.dest3)




# 1st top arriv 
top.arrv1 <- bks2011 %>% # read: station daily, [year]
  mutate(
    month     = month(`Start date`),
  ) %>%
  group_by(month, end.pid, start.pid) %>%
  summarise(
    #station.pid = first(start.id),
    top.arrv1n    = n(),
  ) %>%
  filter(row_number(desc(top.arrv1n)) == 1) %>%
  rename(arrv1.pid = start.pid) 

# 2nd top arrriv
top.arrv2 <- bks2011 %>% 
  mutate(
    month     = month(`Start date`),
  ) %>%
  group_by(month, end.pid, start.pid) %>%
  summarise(
    #station.pid = first(start.id),
    top.arrv2n    = n(),
  ) %>%
  filter(row_number(desc(top.arrv2n)) == 2)%>%
  rename(arrv2.pid = start.pid) 

# 3rd top arriv 
top.arrv3 <- bks2011 %>% 
  mutate(
    month     = month(`Start date`),
  ) %>%
  group_by(month, end.pid, start.pid) %>%
  summarise(
    #station.pid = first(start.id),
    top.arrv3n    = n(),
  ) %>%
  filter(row_number(desc(top.arrv3n)) == 3)%>%
  rename(arrv3.pid = start.pid) 

# join top arrvinations together.
top.arrv.2011 <-
  left_join(top.arrv1, top.arrv2,
            by = c("end.pid", "month")) %>%
  left_join(top.arrv3, by = c("end.pid", "month")) %>%
  rename(pid = end.pid)

# remove objects. 
rm(top.arrv1, top.arrv2, top.arrv3)


## Join tops together 
top.2011 <- 
  left_join(top.arrv.2011, top.dest.2011,
            by = c("pid", "month"))

rm(top.arrv.2011, top.dest.2011)


## join to main monthly thing, add net flow replace with na if top value <= 5 %%%
stnmonthly2011 <- stnmonthly2011 %>%
  left_join(top.2011, by = c("pid", "month")) %>%
  mutate(net.daily.flow = av.daily.ot - av.daily.in)





# 2012 ----

# daily 

stndaily2012o <- bks2012 %>% # read: station daily, [year]
  mutate(
    yday      = yday(`Start date`),
    month     = month(`Start date`),
    hour      = hour(`Start date`),
  ) %>%
  group_by(start.pid, yday, hour) %>%
  summarise(
    #station.pid = first(start.id),
    npickup    = n(),
    month      = first(month),
    med.dur.ot = lubridate::duration(median(Duration))
    
  )

stndaily2012i <- bks2012 %>% # read: station daily, [year]
  mutate(
    yday      = yday(`Start date`),
    hour      = hour(`Start date`)
  ) %>%
  group_by(end.pid, yday, hour) %>%
  summarise(
    #station.pid = first(start.id),
    ndropoff   = n(),
    med.dur.in = lubridate::duration(median(Duration))
    
  )

stndaily2012 <- full_join(stndaily2012o,
                          stndaily2012i,
                          by = c("start.pid" = "end.pid",
                                 "yday"      = "yday",
                                 "hour"      = "hour"))
rm(stndaily2012i, stndaily2012o)



# monthly 

stnmonthly2012o <- bks2012 %>% # read: station daily, [year]
  mutate(
    month     = month(`Start date`),
  ) %>%
  group_by(start.pid, month) %>%
  summarise(
    npickup    = n(),
    month      = first(month),
    av.daily.ot= round((n()/lubridate::days_in_month(month)), digits = 1),
    med.dur.ot = lubridate::duration(median(Duration), units = "seconds")
  )

stnmonthly2012i <- bks2012 %>% # read: station daily, [year]
  mutate(
    month     = month(`Start date`),
  ) %>%
  group_by(end.pid, month) %>%
  summarise(
    #station.pid = first(start.id),
    ndropoff   = n(),
    month      = first(month),
    med.dur.in = lubridate::duration(median(Duration)), 
    av.daily.in= round((n()/lubridate::days_in_month(month)), digits = 1),
  ) 

stnmonthly2012 <- 
  full_join(stnmonthly2012o,
            stnmonthly2012i,
            by = c("start.pid" = "end.pid",
                   "month"     = "month")) %>%
  rename(pid = start.pid)

rm(stnmonthly2012i, stnmonthly2012o)


# top 3 stations 

## 1st top destination 
top.dest1 <- bks2012 %>% # read: station daily, [year]
  mutate(
    month     = month(`Start date`),
  ) %>%
  group_by(month, start.pid, end.pid) %>%
  summarise(
    #station.pid = first(start.id),
    top.dest1n    = n(),
  ) %>%
  filter(row_number(desc(top.dest1n)) == 1) %>%
  rename(dest1.pid = end.pid) 

# 2nd top destination
top.dest2 <- bks2012 %>% 
  mutate(
    month     = month(`Start date`),
  ) %>%
  group_by(month, start.pid, end.pid) %>%
  summarise(
    #station.pid = first(start.id),
    top.dest2n    = n(),
  ) %>%
  filter(row_number(desc(top.dest2n)) == 2)%>%
  rename(dest2.pid = end.pid) 

# 3rd top destination 
top.dest3 <- bks2012 %>% 
  mutate(
    month     = month(`Start date`),
  ) %>%
  group_by(month, start.pid, end.pid) %>%
  summarise(
    #station.pid = first(start.id),
    top.dest3n    = n(),
  ) %>%
  filter(row_number(desc(top.dest3n)) == 3)%>%
  rename(dest3.pid = end.pid) 

# join top destinations together.
top.dest.2012 <- 
  left_join(top.dest1, top.dest2,
            by = c("start.pid", "month")) %>% 
  left_join(top.dest3, by = c("start.pid", "month")) %>%
  rename(pid = start.pid)


# remove objects. 
rm(top.dest1, top.dest2, top.dest3)




# 1st top arriv 
top.arrv1 <- bks2012 %>% # read: station daily, [year]
  mutate(
    month     = month(`Start date`),
  ) %>%
  group_by(month, end.pid, start.pid) %>%
  summarise(
    #station.pid = first(start.id),
    top.arrv1n    = n(),
  ) %>%
  filter(row_number(desc(top.arrv1n)) == 1) %>%
  rename(arrv1.pid = start.pid) 

# 2nd top arrriv
top.arrv2 <- bks2012 %>% 
  mutate(
    month     = month(`Start date`),
  ) %>%
  group_by(month, end.pid, start.pid) %>%
  summarise(
    #station.pid = first(start.id),
    top.arrv2n    = n(),
  ) %>%
  filter(row_number(desc(top.arrv2n)) == 2)%>%
  rename(arrv2.pid = start.pid) 

# 3rd top arriv 
top.arrv3 <- bks2012 %>% 
  mutate(
    month     = month(`Start date`),
  ) %>%
  group_by(month, end.pid, start.pid) %>%
  summarise(
    #station.pid = first(start.id),
    top.arrv3n    = n(),
  ) %>%
  filter(row_number(desc(top.arrv3n)) == 3)%>%
  rename(arrv3.pid = start.pid) 

# join top arrvinations together.
top.arrv.2012 <-
  left_join(top.arrv1, top.arrv2,
            by = c("end.pid", "month")) %>%
  left_join(top.arrv3, by = c("end.pid", "month")) %>%
  rename(pid = end.pid)

# remove objects. 
rm(top.arrv1, top.arrv2, top.arrv3)


## Join tops together 
top.2012 <- 
  left_join(top.arrv.2012, top.dest.2012,
            by = c("pid", "month"))

rm(top.arrv.2012, top.dest.2012)

## join to main monthly thing, add net flow replace with na if top value <= 5 %%%
stnmonthly2012 <- stnmonthly2012 %>%
  left_join(top.2012, by = c("pid", "month")) %>%
  mutate(net.daily.flow = av.daily.ot - av.daily.in)


# 2013 ---- 


# daily 

stndaily2013o <- bks2013 %>% # read: station daily, [year]
  mutate(
    yday      = yday(`Start date`),
    month     = month(`Start date`),
    hour      = hour(`Start date`),
  ) %>%
  group_by(start.pid, yday, hour) %>%
  summarise(
    #station.pid = first(start.id),
    npickup    = n(),
    month      = first(month),
    med.dur.ot = lubridate::duration(median(Duration))
    
  )

stndaily2013i <- bks2013 %>% # read: station daily, [year]
  mutate(
    yday      = yday(`Start date`),
    hour      = hour(`Start date`)
  ) %>%
  group_by(end.pid, yday, hour) %>%
  summarise(
    #station.pid = first(start.id),
    ndropoff   = n(),
    med.dur.in = lubridate::duration(median(Duration))
    
  )

stndaily2013 <- full_join(stndaily2013o,
                          stndaily2013i,
                          by = c("start.pid" = "end.pid",
                                 "yday"      = "yday",
                                 "hour"      = "hour"))
rm(stndaily2013i, stndaily2013o)



# monthly 

stnmonthly2013o <- bks2013 %>% # read: station daily, [year]
  mutate(
    month     = month(`Start date`),
  ) %>%
  group_by(start.pid, month) %>%
  summarise(
    npickup    = n(),
    month      = first(month),
    av.daily.ot= round((n()/lubridate::days_in_month(month)), digits = 1),
    med.dur.ot = lubridate::duration(median(Duration), units = "seconds")
  )

stnmonthly2013i <- bks2013 %>% # read: station daily, [year]
  mutate(
    month     = month(`Start date`),
  ) %>%
  group_by(end.pid, month) %>%
  summarise(
    #station.pid = first(start.id),
    ndropoff   = n(),
    month      = first(month),
    med.dur.in = lubridate::duration(median(Duration)), 
    av.daily.in= round((n()/lubridate::days_in_month(month)), digits = 1),
  ) 

stnmonthly2013 <- 
  full_join(stnmonthly2013o,
            stnmonthly2013i,
            by = c("start.pid" = "end.pid",
                   "month"     = "month")) %>%
  rename(pid = start.pid)

rm(stnmonthly2013i, stnmonthly2013o)


# top 3 stations 

## 1st top destination 
top.dest1 <- bks2013 %>% # read: station daily, [year]
  mutate(
    month     = month(`Start date`),
  ) %>%
  group_by(month, start.pid, end.pid) %>%
  summarise(
    #station.pid = first(start.id),
    top.dest1n    = n(),
  ) %>%
  filter(row_number(desc(top.dest1n)) == 1) %>%
  rename(dest1.pid = end.pid) 

# 2nd top destination
top.dest2 <- bks2013 %>% 
  mutate(
    month     = month(`Start date`),
  ) %>%
  group_by(month, start.pid, end.pid) %>%
  summarise(
    #station.pid = first(start.id),
    top.dest2n    = n(),
  ) %>%
  filter(row_number(desc(top.dest2n)) == 2)%>%
  rename(dest2.pid = end.pid) 

# 3rd top destination 
top.dest3 <- bks2013 %>% 
  mutate(
    month     = month(`Start date`),
  ) %>%
  group_by(month, start.pid, end.pid) %>%
  summarise(
    #station.pid = first(start.id),
    top.dest3n    = n(),
  ) %>%
  filter(row_number(desc(top.dest3n)) == 3)%>%
  rename(dest3.pid = end.pid) 

# join top destinations together.
top.dest.2013 <- 
  left_join(top.dest1, top.dest2,
            by = c("start.pid", "month")) %>% 
  left_join(top.dest3, by = c("start.pid", "month")) %>%
  rename(pid = start.pid)


# remove objects. 
rm(top.dest1, top.dest2, top.dest3)




# 1st top arriv 
top.arrv1 <- bks2013 %>% # read: station daily, [year]
  mutate(
    month     = month(`Start date`),
  ) %>%
  group_by(month, end.pid, start.pid) %>%
  summarise(
    #station.pid = first(start.id),
    top.arrv1n    = n(),
  ) %>%
  filter(row_number(desc(top.arrv1n)) == 1) %>%
  rename(arrv1.pid = start.pid) 

# 2nd top arrriv
top.arrv2 <- bks2013 %>% 
  mutate(
    month     = month(`Start date`),
  ) %>%
  group_by(month, end.pid, start.pid) %>%
  summarise(
    #station.pid = first(start.id),
    top.arrv2n    = n(),
  ) %>%
  filter(row_number(desc(top.arrv2n)) == 2)%>%
  rename(arrv2.pid = start.pid) 

# 3rd top arriv 
top.arrv3 <- bks2013 %>% 
  mutate(
    month     = month(`Start date`),
  ) %>%
  group_by(month, end.pid, start.pid) %>%
  summarise(
    #station.pid = first(start.id),
    top.arrv3n    = n(),
  ) %>%
  filter(row_number(desc(top.arrv3n)) == 3)%>%
  rename(arrv3.pid = start.pid) 

# join top arrvinations together.
top.arrv.2013 <-
  left_join(top.arrv1, top.arrv2,
            by = c("end.pid", "month")) %>%
  left_join(top.arrv3, by = c("end.pid", "month")) %>%
  rename(pid = end.pid)

# remove objects. 
rm(top.arrv1, top.arrv2, top.arrv3)


## Join tops together 
top.2013 <- 
  left_join(top.arrv.2013, top.dest.2013,
            by = c("pid", "month"))

rm(top.arrv.2013, top.dest.2013)


## join to main monthly thing, add net flow replace with na if top value <= 5 %%%
stnmonthly2013 <- stnmonthly2013 %>%
  left_join(top.2013, by = c("pid", "month")) %>%
  mutate(net.daily.flow = av.daily.ot - av.daily.in)


# 
# 2014 ---- 


# daily 

stndaily2014o <- bks2014 %>% # read: station daily, [year]
  mutate(
    yday      = yday(`Start date`),
    month     = month(`Start date`),
    hour      = hour(`Start date`),
  ) %>%
  group_by(start.pid, yday, hour) %>%
  summarise(
    #station.pid = first(start.id),
    npickup    = n(),
    month      = first(month),
    med.dur.ot = lubridate::duration(median(Duration))
    
  )

stndaily2014i <- bks2014 %>% # read: station daily, [year]
  mutate(
    yday      = yday(`Start date`),
    hour      = hour(`Start date`)
  ) %>%
  group_by(end.pid, yday, hour) %>%
  summarise(
    #station.pid = first(start.id),
    ndropoff   = n(),
    med.dur.in = lubridate::duration(median(Duration))
    
  )

stndaily2014 <- full_join(stndaily2014o,
                          stndaily2014i,
                          by = c("start.pid" = "end.pid",
                                 "yday"      = "yday",
                                 "hour"      = "hour"))
rm(stndaily2014i, stndaily2014o)



# monthly 

stnmonthly2014o <- bks2014 %>% # read: station daily, [year]
  mutate(
    month     = month(`Start date`),
  ) %>%
  group_by(start.pid, month) %>%
  summarise(
    npickup    = n(),
    month      = first(month),
    av.daily.ot= round((n()/lubridate::days_in_month(month)), digits = 1),
    med.dur.ot = lubridate::duration(median(Duration), units = "seconds")
  )

stnmonthly2014i <- bks2014 %>% # read: station daily, [year]
  mutate(
    month     = month(`Start date`),
  ) %>%
  group_by(end.pid, month) %>%
  summarise(
    #station.pid = first(start.id),
    ndropoff   = n(),
    month      = first(month),
    med.dur.in = lubridate::duration(median(Duration)), 
    av.daily.in= round((n()/lubridate::days_in_month(month)), digits = 1),
  ) 

stnmonthly2014 <- 
  full_join(stnmonthly2014o,
            stnmonthly2014i,
            by = c("start.pid" = "end.pid",
                   "month"     = "month")) %>%
  rename(pid = start.pid)

rm(stnmonthly2014i, stnmonthly2014o)


# top 3 stations 

## 1st top destination 
top.dest1 <- bks2014 %>% # read: station daily, [year]
  mutate(
    month     = month(`Start date`),
  ) %>%
  group_by(month, start.pid, end.pid) %>%
  summarise(
    #station.pid = first(start.id),
    top.dest1n    = n(),
  ) %>%
  filter(row_number(desc(top.dest1n)) == 1) %>%
  rename(dest1.pid = end.pid) 

# 2nd top destination
top.dest2 <- bks2014 %>% 
  mutate(
    month     = month(`Start date`),
  ) %>%
  group_by(month, start.pid, end.pid) %>%
  summarise(
    #station.pid = first(start.id),
    top.dest2n    = n(),
  ) %>%
  filter(row_number(desc(top.dest2n)) == 2)%>%
  rename(dest2.pid = end.pid) 

# 3rd top destination 
top.dest3 <- bks2014 %>% 
  mutate(
    month     = month(`Start date`),
  ) %>%
  group_by(month, start.pid, end.pid) %>%
  summarise(
    #station.pid = first(start.id),
    top.dest3n    = n(),
  ) %>%
  filter(row_number(desc(top.dest3n)) == 3)%>%
  rename(dest3.pid = end.pid) 

# join top destinations together.
top.dest.2014 <- 
  left_join(top.dest1, top.dest2,
            by = c("start.pid", "month")) %>% 
  left_join(top.dest3, by = c("start.pid", "month")) %>%
  rename(pid = start.pid)


# remove objects. 
rm(top.dest1, top.dest2, top.dest3)




# 1st top arriv 
top.arrv1 <- bks2014 %>% # read: station daily, [year]
  mutate(
    month     = month(`Start date`),
  ) %>%
  group_by(month, end.pid, start.pid) %>%
  summarise(
    #station.pid = first(start.id),
    top.arrv1n    = n(),
  ) %>%
  filter(row_number(desc(top.arrv1n)) == 1) %>%
  rename(arrv1.pid = start.pid) 

# 2nd top arrriv
top.arrv2 <- bks2014 %>% 
  mutate(
    month     = month(`Start date`),
  ) %>%
  group_by(month, end.pid, start.pid) %>%
  summarise(
    #station.pid = first(start.id),
    top.arrv2n    = n(),
  ) %>%
  filter(row_number(desc(top.arrv2n)) == 2)%>%
  rename(arrv2.pid = start.pid) 

# 3rd top arriv 
top.arrv3 <- bks2014 %>% 
  mutate(
    month     = month(`Start date`),
  ) %>%
  group_by(month, end.pid, start.pid) %>%
  summarise(
    #station.pid = first(start.id),
    top.arrv3n    = n(),
  ) %>%
  filter(row_number(desc(top.arrv3n)) == 3)%>%
  rename(arrv3.pid = start.pid) 

# join top arrvinations together.
top.arrv.2014 <-
  left_join(top.arrv1, top.arrv2,
            by = c("end.pid", "month")) %>%
  left_join(top.arrv3, by = c("end.pid", "month")) %>%
  rename(pid = end.pid)

# remove objects. 
rm(top.arrv1, top.arrv2, top.arrv3)


## Join tops together 
top.2014 <- 
  left_join(top.arrv.2014, top.dest.2014,
            by = c("pid", "month"))

rm(top.arrv.2014, top.dest.2014)


## join to main monthly thing, add net flow replace with na if top value <= 5 %%%
stnmonthly2014 <- stnmonthly2014 %>%
  left_join(top.2014, by = c("pid", "month")) %>%
  mutate(net.daily.flow = av.daily.ot - av.daily.in)



# 2015 ---- 

# daily 

stndaily2015o <- bks2015 %>% # read: station daily, [year]
  mutate(
    yday      = yday(`Start date`),
    month     = month(`Start date`),
    hour      = hour(`Start date`),
  ) %>%
  group_by(start.pid, yday, hour) %>%
  summarise(
    #station.pid = first(start.id),
    npickup    = n(),
    month      = first(month),
    med.dur.ot = lubridate::duration(median(Duration))
    
  )

stndaily2015i <- bks2015 %>% # read: station daily, [year]
  mutate(
    yday      = yday(`Start date`),
    hour      = hour(`Start date`)
  ) %>%
  group_by(end.pid, yday, hour) %>%
  summarise(
    #station.pid = first(start.id),
    ndropoff   = n(),
    med.dur.in = lubridate::duration(median(Duration))
    
  )

stndaily2015 <- full_join(stndaily2015o,
                          stndaily2015i,
                          by = c("start.pid" = "end.pid",
                                 "yday"      = "yday",
                                 "hour"      = "hour"))
rm(stndaily2015i, stndaily2015o)



# monthly 

stnmonthly2015o <- bks2015 %>% # read: station daily, [year]
  mutate(
    month     = month(`Start date`),
  ) %>%
  group_by(start.pid, month) %>%
  summarise(
    npickup    = n(),
    month      = first(month),
    av.daily.ot= round((n()/lubridate::days_in_month(month)), digits = 1),
    med.dur.ot = lubridate::duration(median(Duration), units = "seconds")
  )

stnmonthly2015i <- bks2015 %>% # read: station daily, [year]
  mutate(
    month     = month(`Start date`),
  ) %>%
  group_by(end.pid, month) %>%
  summarise(
    #station.pid = first(start.id),
    ndropoff   = n(),
    month      = first(month),
    med.dur.in = lubridate::duration(median(Duration)), 
    av.daily.in= round((n()/lubridate::days_in_month(month)), digits = 1),
  ) 

stnmonthly2015 <- 
  full_join(stnmonthly2015o,
            stnmonthly2015i,
            by = c("start.pid" = "end.pid",
                   "month"     = "month")) %>%
  rename(pid = start.pid)

rm(stnmonthly2015i, stnmonthly2015o)


# top 3 stations 

## 1st top destination 
top.dest1 <- bks2015 %>% # read: station daily, [year]
  mutate(
    month     = month(`Start date`),
  ) %>%
  group_by(month, start.pid, end.pid) %>%
  summarise(
    #station.pid = first(start.id),
    top.dest1n    = n(),
  ) %>%
  filter(row_number(desc(top.dest1n)) == 1) %>%
  rename(dest1.pid = end.pid) 

# 2nd top destination
top.dest2 <- bks2015 %>% 
  mutate(
    month     = month(`Start date`),
  ) %>%
  group_by(month, start.pid, end.pid) %>%
  summarise(
    #station.pid = first(start.id),
    top.dest2n    = n(),
  ) %>%
  filter(row_number(desc(top.dest2n)) == 2)%>%
  rename(dest2.pid = end.pid) 

# 3rd top destination 
top.dest3 <- bks2015 %>% 
  mutate(
    month     = month(`Start date`),
  ) %>%
  group_by(month, start.pid, end.pid) %>%
  summarise(
    #station.pid = first(start.id),
    top.dest3n    = n(),
  ) %>%
  filter(row_number(desc(top.dest3n)) == 3)%>%
  rename(dest3.pid = end.pid) 

# join top destinations together.
top.dest.2015 <- 
  left_join(top.dest1, top.dest2,
            by = c("start.pid", "month")) %>% 
  left_join(top.dest3, by = c("start.pid", "month")) %>%
  rename(pid = start.pid)


# remove objects. 
rm(top.dest1, top.dest2, top.dest3)




# 1st top arriv 
top.arrv1 <- bks2015 %>% # read: station daily, [year]
  mutate(
    month     = month(`Start date`),
  ) %>%
  group_by(month, end.pid, start.pid) %>%
  summarise(
    #station.pid = first(start.id),
    top.arrv1n    = n(),
  ) %>%
  filter(row_number(desc(top.arrv1n)) == 1) %>%
  rename(arrv1.pid = start.pid) 

# 2nd top arrriv
top.arrv2 <- bks2015 %>% 
  mutate(
    month     = month(`Start date`),
  ) %>%
  group_by(month, end.pid, start.pid) %>%
  summarise(
    #station.pid = first(start.id),
    top.arrv2n    = n(),
  ) %>%
  filter(row_number(desc(top.arrv2n)) == 2)%>%
  rename(arrv2.pid = start.pid) 

# 3rd top arriv 
top.arrv3 <- bks2015 %>% 
  mutate(
    month     = month(`Start date`),
  ) %>%
  group_by(month, end.pid, start.pid) %>%
  summarise(
    #station.pid = first(start.id),
    top.arrv3n    = n(),
  ) %>%
  filter(row_number(desc(top.arrv3n)) == 3)%>%
  rename(arrv3.pid = start.pid) 

# join top arrvinations together.
top.arrv.2015 <-
  left_join(top.arrv1, top.arrv2,
            by = c("end.pid", "month")) %>%
  left_join(top.arrv3, by = c("end.pid", "month")) %>%
  rename(pid = end.pid)

# remove objects. 
rm(top.arrv1, top.arrv2, top.arrv3)


## Join tops together 
top.2015 <- 
  left_join(top.arrv.2015, top.dest.2015,
            by = c("pid", "month"))

rm(top.arrv.2015, top.dest.2015)


## join to main monthly thing, add net flow replace with na if top value <= 5 %%%
stnmonthly2015 <- stnmonthly2015 %>%
  left_join(top.2015, by = c("pid", "month")) %>%
  mutate(net.daily.flow = av.daily.ot - av.daily.in)



# 2016 ---- 

# daily 

stndaily2016o <- bks2016 %>% # read: station daily, [year]
  mutate(
    yday      = yday(`Start date`),
    month     = month(`Start date`),
    hour      = hour(`Start date`),
  ) %>%
  group_by(start.pid, yday, hour) %>%
  summarise(
    #station.pid = first(start.id),
    npickup    = n(),
    month      = first(month),
    med.dur.ot = lubridate::duration(median(Duration))
    
  )

stndaily2016i <- bks2016 %>% # read: station daily, [year]
  mutate(
    yday      = yday(`Start date`),
    hour      = hour(`Start date`)
  ) %>%
  group_by(end.pid, yday, hour) %>%
  summarise(
    #station.pid = first(start.id),
    ndropoff   = n(),
    med.dur.in = lubridate::duration(median(Duration))
    
  )

stndaily2016 <- full_join(stndaily2016o,
                          stndaily2016i,
                          by = c("start.pid" = "end.pid",
                                 "yday"      = "yday",
                                 "hour"      = "hour"))
rm(stndaily2016i, stndaily2016o)



# monthly 

stnmonthly2016o <- bks2016 %>% # read: station daily, [year]
  mutate(
    month     = month(`Start date`),
  ) %>%
  group_by(start.pid, month) %>%
  summarise(
    npickup    = n(),
    month      = first(month),
    av.daily.ot= round((n()/lubridate::days_in_month(month)), digits = 1),
    med.dur.ot = lubridate::duration(median(Duration), units = "seconds")
  )

stnmonthly2016i <- bks2016 %>% # read: station daily, [year]
  mutate(
    month     = month(`Start date`),
  ) %>%
  group_by(end.pid, month) %>%
  summarise(
    #station.pid = first(start.id),
    ndropoff   = n(),
    month      = first(month),
    med.dur.in = lubridate::duration(median(Duration)), 
    av.daily.in= round((n()/lubridate::days_in_month(month)), digits = 1),
  ) 

stnmonthly2016 <- 
  full_join(stnmonthly2016o,
            stnmonthly2016i,
            by = c("start.pid" = "end.pid",
                   "month"     = "month")) %>%
  rename(pid = start.pid)

rm(stnmonthly2016i, stnmonthly2016o)


# top 3 stations 

## 1st top destination 
top.dest1 <- bks2016 %>% # read: station daily, [year]
  mutate(
    month     = month(`Start date`),
  ) %>%
  group_by(month, start.pid, end.pid) %>%
  summarise(
    #station.pid = first(start.id),
    top.dest1n    = n(),
  ) %>%
  filter(row_number(desc(top.dest1n)) == 1) %>%
  rename(dest1.pid = end.pid) 

# 2nd top destination
top.dest2 <- bks2016 %>% 
  mutate(
    month     = month(`Start date`),
  ) %>%
  group_by(month, start.pid, end.pid) %>%
  summarise(
    #station.pid = first(start.id),
    top.dest2n    = n(),
  ) %>%
  filter(row_number(desc(top.dest2n)) == 2)%>%
  rename(dest2.pid = end.pid) 

# 3rd top destination 
top.dest3 <- bks2016 %>% 
  mutate(
    month     = month(`Start date`),
  ) %>%
  group_by(month, start.pid, end.pid) %>%
  summarise(
    #station.pid = first(start.id),
    top.dest3n    = n(),
  ) %>%
  filter(row_number(desc(top.dest3n)) == 3)%>%
  rename(dest3.pid = end.pid) 

# join top destinations together.
top.dest.2016 <- 
  left_join(top.dest1, top.dest2,
            by = c("start.pid", "month")) %>% 
  left_join(top.dest3, by = c("start.pid", "month")) %>%
  rename(pid = start.pid)


# remove objects. 
rm(top.dest1, top.dest2, top.dest3)




# 1st top arriv 
top.arrv1 <- bks2016 %>% # read: station daily, [year]
  mutate(
    month     = month(`Start date`),
  ) %>%
  group_by(month, end.pid, start.pid) %>%
  summarise(
    #station.pid = first(start.id),
    top.arrv1n    = n(),
  ) %>%
  filter(row_number(desc(top.arrv1n)) == 1) %>%
  rename(arrv1.pid = start.pid) 

# 2nd top arrriv
top.arrv2 <- bks2016 %>% 
  mutate(
    month     = month(`Start date`),
  ) %>%
  group_by(month, end.pid, start.pid) %>%
  summarise(
    #station.pid = first(start.id),
    top.arrv2n    = n(),
  ) %>%
  filter(row_number(desc(top.arrv2n)) == 2)%>%
  rename(arrv2.pid = start.pid) 

# 3rd top arriv 
top.arrv3 <- bks2016 %>% 
  mutate(
    month     = month(`Start date`),
  ) %>%
  group_by(month, end.pid, start.pid) %>%
  summarise(
    #station.pid = first(start.id),
    top.arrv3n    = n(),
  ) %>%
  filter(row_number(desc(top.arrv3n)) == 3)%>%
  rename(arrv3.pid = start.pid) 

# join top arrvinations together.
top.arrv.2016 <-
  left_join(top.arrv1, top.arrv2,
            by = c("end.pid", "month")) %>%
  left_join(top.arrv3, by = c("end.pid", "month")) %>%
  rename(pid = end.pid)

# remove objects. 
rm(top.arrv1, top.arrv2, top.arrv3)


## Join tops together 
top.2016 <- 
  left_join(top.arrv.2016, top.dest.2016,
            by = c("pid", "month"))

rm(top.arrv.2016, top.dest.2016)


## join to main monthly thing, add net flow replace with na if top value <= 5 %%%
stnmonthly2016 <- stnmonthly2016 %>%
  left_join(top.2016, by = c("pid", "month")) %>%
  mutate(net.daily.flow = av.daily.ot - av.daily.in)



# 2017 ---- 

# daily 

stndaily2017o <- bks2017 %>% # read: station daily, [year]
  mutate(
    yday      = yday(`Start date`),
    month     = month(`Start date`),
    hour      = hour(`Start date`),
  ) %>%
  group_by(start.pid, yday, hour) %>%
  summarise(
    #station.pid = first(start.id),
    npickup    = n(),
    month      = first(month),
    med.dur.ot = lubridate::duration(median(Duration))
    
  )

stndaily2017i <- bks2017 %>% # read: station daily, [year]
  mutate(
    yday      = yday(`Start date`),
    hour      = hour(`Start date`)
  ) %>%
  group_by(end.pid, yday, hour) %>%
  summarise(
    #station.pid = first(start.id),
    ndropoff   = n(),
    med.dur.in = lubridate::duration(median(Duration))
    
  )

stndaily2017 <- full_join(stndaily2017o,
                          stndaily2017i,
                          by = c("start.pid" = "end.pid",
                                 "yday"      = "yday",
                                 "hour"      = "hour"))
rm(stndaily2017i, stndaily2017o)



# monthly 

stnmonthly2017o <- bks2017 %>% # read: station daily, [year]
  mutate(
    month     = month(`Start date`),
  ) %>%
  group_by(start.pid, month) %>%
  summarise(
    npickup    = n(),
    month      = first(month),
    av.daily.ot= round((n()/lubridate::days_in_month(month)), digits = 1),
    med.dur.ot = lubridate::duration(median(Duration), units = "seconds")
  )

stnmonthly2017i <- bks2017 %>% # read: station daily, [year]
  mutate(
    month     = month(`Start date`),
  ) %>%
  group_by(end.pid, month) %>%
  summarise(
    #station.pid = first(start.id),
    ndropoff   = n(),
    month      = first(month),
    med.dur.in = lubridate::duration(median(Duration)), 
    av.daily.in= round((n()/lubridate::days_in_month(month)), digits = 1),
  ) 

stnmonthly2017 <- 
  full_join(stnmonthly2017o,
            stnmonthly2017i,
            by = c("start.pid" = "end.pid",
                   "month"     = "month")) %>%
  rename(pid = start.pid)

rm(stnmonthly2017i, stnmonthly2017o)


# top 3 stations 

## 1st top destination 
top.dest1 <- bks2017 %>% # read: station daily, [year]
  mutate(
    month     = month(`Start date`),
  ) %>%
  group_by(month, start.pid, end.pid) %>%
  summarise(
    #station.pid = first(start.id),
    top.dest1n    = n(),
  ) %>%
  filter(row_number(desc(top.dest1n)) == 1) %>%
  rename(dest1.pid = end.pid) 

# 2nd top destination
top.dest2 <- bks2017 %>% 
  mutate(
    month     = month(`Start date`),
  ) %>%
  group_by(month, start.pid, end.pid) %>%
  summarise(
    #station.pid = first(start.id),
    top.dest2n    = n(),
  ) %>%
  filter(row_number(desc(top.dest2n)) == 2)%>%
  rename(dest2.pid = end.pid) 

# 3rd top destination 
top.dest3 <- bks2017 %>% 
  mutate(
    month     = month(`Start date`),
  ) %>%
  group_by(month, start.pid, end.pid) %>%
  summarise(
    #station.pid = first(start.id),
    top.dest3n    = n(),
  ) %>%
  filter(row_number(desc(top.dest3n)) == 3)%>%
  rename(dest3.pid = end.pid) 

# join top destinations together.
top.dest.2017 <- 
  left_join(top.dest1, top.dest2,
            by = c("start.pid", "month")) %>% 
  left_join(top.dest3, by = c("start.pid", "month")) %>%
  rename(pid = start.pid)


# remove objects. 
rm(top.dest1, top.dest2, top.dest3)




# 1st top arriv 
top.arrv1 <- bks2017 %>% # read: station daily, [year]
  mutate(
    month     = month(`Start date`),
  ) %>%
  group_by(month, end.pid, start.pid) %>%
  summarise(
    #station.pid = first(start.id),
    top.arrv1n    = n(),
  ) %>%
  filter(row_number(desc(top.arrv1n)) == 1) %>%
  rename(arrv1.pid = start.pid) 

# 2nd top arrriv
top.arrv2 <- bks2017 %>% 
  mutate(
    month     = month(`Start date`),
  ) %>%
  group_by(month, end.pid, start.pid) %>%
  summarise(
    #station.pid = first(start.id),
    top.arrv2n    = n(),
  ) %>%
  filter(row_number(desc(top.arrv2n)) == 2)%>%
  rename(arrv2.pid = start.pid) 

# 3rd top arriv 
top.arrv3 <- bks2017 %>% 
  mutate(
    month     = month(`Start date`),
  ) %>%
  group_by(month, end.pid, start.pid) %>%
  summarise(
    #station.pid = first(start.id),
    top.arrv3n    = n(),
  ) %>%
  filter(row_number(desc(top.arrv3n)) == 3)%>%
  rename(arrv3.pid = start.pid) 

# join top arrvinations together.
top.arrv.2017 <-
  left_join(top.arrv1, top.arrv2,
            by = c("end.pid", "month")) %>%
  left_join(top.arrv3, by = c("end.pid", "month")) %>%
  rename(pid = end.pid)

# remove objects. 
rm(top.arrv1, top.arrv2, top.arrv3)


## Join tops together 
top.2017 <- 
  left_join(top.arrv.2017, top.dest.2017,
            by = c("pid", "month"))

rm(top.arrv.2017, top.dest.2017)


## join to main monthly thing, add net flow replace with na if top value <= 5 %%%
stnmonthly2017 <- stnmonthly2017 %>%
  left_join(top.2017, by = c("pid", "month")) %>%
  mutate(net.daily.flow = av.daily.ot - av.daily.in)



# 2018 ---- 

# daily 

stndaily2018o <- bks2018 %>% # read: station daily, [year]
  mutate(
    yday      = yday(`Start date`),
    month     = month(`Start date`),
    hour      = hour(`Start date`),
  ) %>%
  group_by(start.pid, yday, hour) %>%
  summarise(
    #station.pid = first(start.id),
    npickup    = n(),
    month      = first(month),
    med.dur.ot = lubridate::duration(median(Duration))
    
  )

stndaily2018i <- bks2018 %>% # read: station daily, [year]
  mutate(
    yday      = yday(`Start date`),
    hour      = hour(`Start date`)
  ) %>%
  group_by(end.pid, yday, hour) %>%
  summarise(
    #station.pid = first(start.id),
    ndropoff   = n(),
    med.dur.in = lubridate::duration(median(Duration))
    
  )

stndaily2018 <- full_join(stndaily2018o,
                          stndaily2018i,
                          by = c("start.pid" = "end.pid",
                                 "yday"      = "yday",
                                 "hour"      = "hour"))
rm(stndaily2018i, stndaily2018o)



# monthly 

stnmonthly2018o <- bks2018 %>% # read: station daily, [year]
  mutate(
    month     = month(`Start date`),
  ) %>%
  group_by(start.pid, month) %>%
  summarise(
    npickup    = n(),
    month      = first(month),
    av.daily.ot= round((n()/lubridate::days_in_month(month)), digits = 1),
    med.dur.ot = lubridate::duration(median(Duration), units = "seconds")
  )

stnmonthly2018i <- bks2018 %>% # read: station daily, [year]
  mutate(
    month     = month(`Start date`),
  ) %>%
  group_by(end.pid, month) %>%
  summarise(
    #station.pid = first(start.id),
    ndropoff   = n(),
    month      = first(month),
    med.dur.in = lubridate::duration(median(Duration)), 
    av.daily.in= round((n()/lubridate::days_in_month(month)), digits = 1),
  ) 

stnmonthly2018 <- 
  full_join(stnmonthly2018o,
            stnmonthly2018i,
            by = c("start.pid" = "end.pid",
                   "month"     = "month")) %>%
  rename(pid = start.pid)

rm(stnmonthly2018i, stnmonthly2018o)


# top 3 stations 

## 1st top destination 
top.dest1 <- bks2018 %>% # read: station daily, [year]
  mutate(
    month     = month(`Start date`),
  ) %>%
  group_by(month, start.pid, end.pid) %>%
  summarise(
    #station.pid = first(start.id),
    top.dest1n    = n(),
  ) %>%
  filter(row_number(desc(top.dest1n)) == 1) %>%
  rename(dest1.pid = end.pid) 

# 2nd top destination
top.dest2 <- bks2018 %>% 
  mutate(
    month     = month(`Start date`),
  ) %>%
  group_by(month, start.pid, end.pid) %>%
  summarise(
    #station.pid = first(start.id),
    top.dest2n    = n(),
  ) %>%
  filter(row_number(desc(top.dest2n)) == 2)%>%
  rename(dest2.pid = end.pid) 

# 3rd top destination 
top.dest3 <- bks2018 %>% 
  mutate(
    month     = month(`Start date`),
  ) %>%
  group_by(month, start.pid, end.pid) %>%
  summarise(
    #station.pid = first(start.id),
    top.dest3n    = n(),
  ) %>%
  filter(row_number(desc(top.dest3n)) == 3)%>%
  rename(dest3.pid = end.pid) 

# join top destinations together.
top.dest.2018 <- 
  left_join(top.dest1, top.dest2,
            by = c("start.pid", "month")) %>% 
  left_join(top.dest3, by = c("start.pid", "month")) %>%
  rename(pid = start.pid)


# remove objects. 
rm(top.dest1, top.dest2, top.dest3)




# 1st top arriv 
top.arrv1 <- bks2018 %>% # read: station daily, [year]
  mutate(
    month     = month(`Start date`),
  ) %>%
  group_by(month, end.pid, start.pid) %>%
  summarise(
    #station.pid = first(start.id),
    top.arrv1n    = n(),
  ) %>%
  filter(row_number(desc(top.arrv1n)) == 1) %>%
  rename(arrv1.pid = start.pid) 

# 2nd top arrriv
top.arrv2 <- bks2018 %>% 
  mutate(
    month     = month(`Start date`),
  ) %>%
  group_by(month, end.pid, start.pid) %>%
  summarise(
    #station.pid = first(start.id),
    top.arrv2n    = n(),
  ) %>%
  filter(row_number(desc(top.arrv2n)) == 2)%>%
  rename(arrv2.pid = start.pid) 

# 3rd top arriv 
top.arrv3 <- bks2018 %>% 
  mutate(
    month     = month(`Start date`),
  ) %>%
  group_by(month, end.pid, start.pid) %>%
  summarise(
    #station.pid = first(start.id),
    top.arrv3n    = n(),
  ) %>%
  filter(row_number(desc(top.arrv3n)) == 3)%>%
  rename(arrv3.pid = start.pid) 

# join top arrvinations together.
top.arrv.2018 <-
  left_join(top.arrv1, top.arrv2,
            by = c("end.pid", "month")) %>%
  left_join(top.arrv3, by = c("end.pid", "month")) %>%
  rename(pid = end.pid)

# remove objects. 
rm(top.arrv1, top.arrv2, top.arrv3)


## Join tops together 
top.2018 <- 
  left_join(top.arrv.2018, top.dest.2018,
            by = c("pid", "month"))

rm(top.arrv.2018, top.dest.2018)

## join to main monthly thing, add net flow replace with na if top value <= 5 %%%
stnmonthly2018 <- stnmonthly2018 %>%
  left_join(top.2018, by = c("pid", "month")) %>%
  mutate(net.daily.flow = av.daily.ot - av.daily.in)



# 2019 ---- 

# daily 

stndaily2019o <- bks2019 %>% # read: station daily, [year]
  mutate(
    yday      = yday(`Start date`),
    month     = month(`Start date`),
    hour      = hour(`Start date`),
  ) %>%
  group_by(start.pid, yday, hour) %>%
  summarise(
    #station.pid = first(start.id),
    npickup    = n(),
    month      = first(month),
    med.dur.ot = lubridate::duration(median(Duration))
    
  )

stndaily2019i <- bks2019 %>% # read: station daily, [year]
  mutate(
    yday      = yday(`Start date`),
    hour      = hour(`Start date`)
  ) %>%
  group_by(end.pid, yday, hour) %>%
  summarise(
    #station.pid = first(start.id),
    ndropoff   = n(),
    med.dur.in = lubridate::duration(median(Duration))
    
  )

stndaily2019 <- full_join(stndaily2019o,
                          stndaily2019i,
                          by = c("start.pid" = "end.pid",
                                 "yday"      = "yday",
                                 "hour"      = "hour"))
rm(stndaily2019i, stndaily2019o)



# monthly 

stnmonthly2019o <- bks2019 %>% # read: station daily, [year]
  mutate(
    month     = month(`Start date`),
  ) %>%
  group_by(start.pid, month) %>%
  summarise(
    npickup    = n(),
    month      = first(month),
    av.daily.ot= round((n()/lubridate::days_in_month(month)), digits = 1),
    med.dur.ot = lubridate::duration(median(Duration), units = "seconds")
  )

stnmonthly2019i <- bks2019 %>% # read: station daily, [year]
  mutate(
    month     = month(`Start date`),
  ) %>%
  group_by(end.pid, month) %>%
  summarise(
    #station.pid = first(start.id),
    ndropoff   = n(),
    month      = first(month),
    med.dur.in = lubridate::duration(median(Duration)), 
    av.daily.in= round((n()/lubridate::days_in_month(month)), digits = 1),
  ) 

stnmonthly2019 <- 
  full_join(stnmonthly2019o,
            stnmonthly2019i,
            by = c("start.pid" = "end.pid",
                   "month"     = "month")) %>%
  rename(pid = start.pid)

rm(stnmonthly2019i, stnmonthly2019o)


# top 3 stations 

## 1st top destination 
top.dest1 <- bks2019 %>% # read: station daily, [year]
  mutate(
    month     = month(`Start date`),
  ) %>%
  group_by(month, start.pid, end.pid) %>%
  summarise(
    #station.pid = first(start.id),
    top.dest1n    = n(),
  ) %>%
  filter(row_number(desc(top.dest1n)) == 1) %>%
  rename(dest1.pid = end.pid) 

# 2nd top destination
top.dest2 <- bks2019 %>% 
  mutate(
    month     = month(`Start date`),
  ) %>%
  group_by(month, start.pid, end.pid) %>%
  summarise(
    #station.pid = first(start.id),
    top.dest2n    = n(),
  ) %>%
  filter(row_number(desc(top.dest2n)) == 2)%>%
  rename(dest2.pid = end.pid) 

# 3rd top destination 
top.dest3 <- bks2019 %>% 
  mutate(
    month     = month(`Start date`),
  ) %>%
  group_by(month, start.pid, end.pid) %>%
  summarise(
    #station.pid = first(start.id),
    top.dest3n    = n(),
  ) %>%
  filter(row_number(desc(top.dest3n)) == 3)%>%
  rename(dest3.pid = end.pid) 

# join top destinations together.
top.dest.2019 <- 
  left_join(top.dest1, top.dest2,
            by = c("start.pid", "month")) %>% 
  left_join(top.dest3, by = c("start.pid", "month")) %>%
  rename(pid = start.pid)


# remove objects. 
rm(top.dest1, top.dest2, top.dest3)




# 1st top arriv 
top.arrv1 <- bks2019 %>% # read: station daily, [year]
  mutate(
    month     = month(`Start date`),
  ) %>%
  group_by(month, end.pid, start.pid) %>%
  summarise(
    #station.pid = first(start.id),
    top.arrv1n    = n(),
  ) %>%
  filter(row_number(desc(top.arrv1n)) == 1) %>%
  rename(arrv1.pid = start.pid) 

# 2nd top arrriv
top.arrv2 <- bks2019 %>% 
  mutate(
    month     = month(`Start date`),
  ) %>%
  group_by(month, end.pid, start.pid) %>%
  summarise(
    #station.pid = first(start.id),
    top.arrv2n    = n(),
  ) %>%
  filter(row_number(desc(top.arrv2n)) == 2)%>%
  rename(arrv2.pid = start.pid) 

# 3rd top arriv 
top.arrv3 <- bks2019 %>% 
  mutate(
    month     = month(`Start date`),
  ) %>%
  group_by(month, end.pid, start.pid) %>%
  summarise(
    #station.pid = first(start.id),
    top.arrv3n    = n(),
  ) %>%
  filter(row_number(desc(top.arrv3n)) == 3)%>%
  rename(arrv3.pid = start.pid) 

# join top arrvinations together.
top.arrv.2019 <-
  left_join(top.arrv1, top.arrv2,
            by = c("end.pid", "month")) %>%
  left_join(top.arrv3, by = c("end.pid", "month")) %>%
  rename(pid = end.pid)

# remove objects. 
rm(top.arrv1, top.arrv2, top.arrv3)


## Join tops together 
top.2019 <- 
  left_join(top.arrv.2019, top.dest.2019,
            by = c("pid", "month"))

## join to main monthly thing, add net flow replace with na if top value <= 5 %%%
stnmonthly2019 <- stnmonthly2019 %>%
  left_join(top.2019, by = c("pid", "month")) %>%
  mutate(net.daily.flow = av.daily.ot - av.daily.in)

rm(top.arrv.2019, top.dest.2019)


# 2020.1 ---- 

# daily 

stndaily2020.1o <- bks2020.1 %>% # read: station daily, [year]
  mutate(
    yday      = yday(`Start date`),
    month     = month(`Start date`),
    hour      = hour(`Start date`),
  ) %>%
  group_by(start.pid, yday, hour) %>%
  summarise(
    #station.pid = first(start.id),
    npickup    = n(),
    month      = first(month),
    med.dur.ot = lubridate::duration(median(Duration))
    
  )

stndaily2020.1i <- bks2020.1 %>% # read: station daily, [year]
  mutate(
    yday      = yday(`Start date`),
    hour      = hour(`Start date`)
  ) %>%
  group_by(end.pid, yday, hour) %>%
  summarise(
    #station.pid = first(start.id),
    ndropoff   = n(),
    med.dur.in = lubridate::duration(median(Duration))
    
  )

stndaily2020.1 <- full_join(stndaily2020.1o,
                            stndaily2020.1i,
                            by = c("start.pid" = "end.pid",
                                   "yday"      = "yday",
                                   "hour"      = "hour"))
rm(stndaily2020.1i, stndaily2020.1o)



# monthly 

stnmonthly2020.1o <- bks2020.1 %>% # read: station daily, [year]
  mutate(
    month     = month(`Start date`),
  ) %>%
  group_by(start.pid, month) %>%
  summarise(
    npickup    = n(),
    month      = first(month),
    av.daily.ot= round((n()/lubridate::days_in_month(month)), digits = 1),
    med.dur.ot = lubridate::duration(median(Duration), units = "seconds")
  )

stnmonthly2020.1i <- bks2020.1 %>% # read: station daily, [year]
  mutate(
    month     = month(`Start date`),
  ) %>%
  group_by(end.pid, month) %>%
  summarise(
    #station.pid = first(start.id),
    ndropoff   = n(),
    month      = first(month),
    med.dur.in = lubridate::duration(median(Duration)), 
    av.daily.in= round((n()/lubridate::days_in_month(month)), digits = 1),
  ) 

stnmonthly2020.1 <- 
  full_join(stnmonthly2020.1o,
            stnmonthly2020.1i,
            by = c("start.pid" = "end.pid",
                   "month"     = "month")) %>%
  rename(pid = start.pid)

rm(stnmonthly2020.1i, stnmonthly2020.1o)


# top 3 stations 

## 1st top destination 
top.dest1 <- bks2020.1 %>% # read: station daily, [year]
  mutate(
    month     = month(`Start date`),
  ) %>%
  group_by(month, start.pid, end.pid) %>%
  summarise(
    #station.pid = first(start.id),
    top.dest1n    = n(),
  ) %>%
  filter(row_number(desc(top.dest1n)) == 1) %>%
  rename(dest1.pid = end.pid) 

# 2nd top destination
top.dest2 <- bks2020.1 %>% 
  mutate(
    month     = month(`Start date`),
  ) %>%
  group_by(month, start.pid, end.pid) %>%
  summarise(
    #station.pid = first(start.id),
    top.dest2n    = n(),
  ) %>%
  filter(row_number(desc(top.dest2n)) == 2)%>%
  rename(dest2.pid = end.pid) 

# 3rd top destination 
top.dest3 <- bks2020.1 %>% 
  mutate(
    month     = month(`Start date`),
  ) %>%
  group_by(month, start.pid, end.pid) %>%
  summarise(
    #station.pid = first(start.id),
    top.dest3n    = n(),
  ) %>%
  filter(row_number(desc(top.dest3n)) == 3)%>%
  rename(dest3.pid = end.pid) 

# join top destinations together.
top.dest.2020.1 <- 
  left_join(top.dest1, top.dest2,
            by = c("start.pid", "month")) %>% 
  left_join(top.dest3, by = c("start.pid", "month")) %>%
  rename(pid = start.pid)


# remove objects. 
rm(top.dest1, top.dest2, top.dest3)




# 1st top arriv 
top.arrv1 <- bks2020.1 %>% # read: station daily, [year]
  mutate(
    month     = month(`Start date`),
  ) %>%
  group_by(month, end.pid, start.pid) %>%
  summarise(
    #station.pid = first(start.id),
    top.arrv1n    = n(),
  ) %>%
  filter(row_number(desc(top.arrv1n)) == 1) %>%
  rename(arrv1.pid = start.pid) 

# 2nd top arrriv
top.arrv2 <- bks2020.1 %>% 
  mutate(
    month     = month(`Start date`),
  ) %>%
  group_by(month, end.pid, start.pid) %>%
  summarise(
    #station.pid = first(start.id),
    top.arrv2n    = n(),
  ) %>%
  filter(row_number(desc(top.arrv2n)) == 2)%>%
  rename(arrv2.pid = start.pid) 

# 3rd top arriv 
top.arrv3 <- bks2020.1 %>% 
  mutate(
    month     = month(`Start date`),
  ) %>%
  group_by(month, end.pid, start.pid) %>%
  summarise(
    #station.pid = first(start.id),
    top.arrv3n    = n(),
  ) %>%
  filter(row_number(desc(top.arrv3n)) == 3)%>%
  rename(arrv3.pid = start.pid) 

# join top arrvinations together.
top.arrv.2020.1 <-
  left_join(top.arrv1, top.arrv2,
            by = c("end.pid", "month")) %>%
  left_join(top.arrv3, by = c("end.pid", "month")) %>%
  rename(pid = end.pid)

# remove objects. 
rm(top.arrv1, top.arrv2, top.arrv3)


## Join tops together 
top.2020.1 <- 
  left_join(top.arrv.2020.1, top.dest.2020.1,
            by = c("pid", "month"))

rm(top.arrv.2020.1, top.dest.2020.1)


## join to main monthly thing, add net flow replace with na if top value <= 5 %%%
stnmonthly2020.1 <- stnmonthly2020.1 %>%
  left_join(top.2020.1, by = c("pid", "month")) %>%
  mutate(net.daily.flow = av.daily.ot - av.daily.in)



# 2020.2 ---- 

# daily 

stndaily2020.2o <- bks2020.2 %>% # read: station daily, [year]
  mutate(
    yday      = yday(`Start date`),
    month     = month(`Start date`),
    hour      = hour(`Start date`),
  ) %>%
  group_by(start.pid, yday, hour) %>%
  summarise(
    #station.pid = first(start.id),
    npickup    = n(),
    month      = first(month),
    med.dur.ot = lubridate::duration(median(Duration))
    
  )

stndaily2020.2i <- bks2020.2 %>% # read: station daily, [year]
  mutate(
    yday      = yday(`Start date`),
    hour      = hour(`Start date`)
  ) %>%
  group_by(end.pid, yday, hour) %>%
  summarise(
    #station.pid = first(start.id),
    ndropoff   = n(),
    med.dur.in = lubridate::duration(median(Duration))
    
  )

stndaily2020.2 <- full_join(stndaily2020.2o,
                            stndaily2020.2i,
                            by = c("start.pid" = "end.pid",
                                   "yday"      = "yday",
                                   "hour"      = "hour"))
rm(stndaily2020.2i, stndaily2020.2o)



# monthly 

stnmonthly2020.2o <- bks2020.2 %>% # read: station daily, [year]
  mutate(
    month     = month(`Start date`),
  ) %>%
  group_by(start.pid, month) %>%
  summarise(
    npickup    = n(),
    month      = first(month),
    av.daily.ot= round((n()/lubridate::days_in_month(month)), digits = 1),
    med.dur.ot = lubridate::duration(median(Duration), units = "seconds")
  )

stnmonthly2020.2i <- bks2020.2 %>% # read: station daily, [year]
  mutate(
    month     = month(`Start date`),
  ) %>%
  group_by(end.pid, month) %>%
  summarise(
    #station.pid = first(start.id),
    ndropoff   = n(),
    month      = first(month),
    med.dur.in = lubridate::duration(median(Duration)), 
    av.daily.in= round((n()/lubridate::days_in_month(month)), digits = 1),
  ) 

stnmonthly2020.2 <- 
  full_join(stnmonthly2020.2o,
            stnmonthly2020.2i,
            by = c("start.pid" = "end.pid",
                   "month"     = "month")) %>%
  rename(pid = start.pid)

rm(stnmonthly2020.2i, stnmonthly2020.2o)


# top 3 stations 

## 1st top destination 
top.dest1 <- bks2020.2 %>% # read: station daily, [year]
  mutate(
    month     = month(`Start date`),
  ) %>%
  group_by(month, start.pid, end.pid) %>%
  summarise(
    #station.pid = first(start.id),
    top.dest1n    = n(),
  ) %>%
  filter(row_number(desc(top.dest1n)) == 1) %>%
  rename(dest1.pid = end.pid) 

# 2nd top destination
top.dest2 <- bks2020.2 %>% 
  mutate(
    month     = month(`Start date`),
  ) %>%
  group_by(month, start.pid, end.pid) %>%
  summarise(
    #station.pid = first(start.id),
    top.dest2n    = n(),
  ) %>%
  filter(row_number(desc(top.dest2n)) == 2)%>%
  rename(dest2.pid = end.pid) 

# 3rd top destination 
top.dest3 <- bks2020.2 %>% 
  mutate(
    month     = month(`Start date`),
  ) %>%
  group_by(month, start.pid, end.pid) %>%
  summarise(
    #station.pid = first(start.id),
    top.dest3n    = n(),
  ) %>%
  filter(row_number(desc(top.dest3n)) == 3)%>%
  rename(dest3.pid = end.pid) 

# join top destinations together.
top.dest.2020.2 <- 
  left_join(top.dest1, top.dest2,
            by = c("start.pid", "month")) %>% 
  left_join(top.dest3, by = c("start.pid", "month")) %>%
  rename(pid = start.pid)


# remove objects. 
rm(top.dest1, top.dest2, top.dest3)




# 1st top arriv 
top.arrv1 <- bks2020.2 %>% # read: station daily, [year]
  mutate(
    month     = month(`Start date`),
  ) %>%
  group_by(month, end.pid, start.pid) %>%
  summarise(
    #station.pid = first(start.id),
    top.arrv1n    = n(),
  ) %>%
  filter(row_number(desc(top.arrv1n)) == 1) %>%
  rename(arrv1.pid = start.pid) 

# 2nd top arrriv
top.arrv2 <- bks2020.2 %>% 
  mutate(
    month     = month(`Start date`),
  ) %>%
  group_by(month, end.pid, start.pid) %>%
  summarise(
    #station.pid = first(start.id),
    top.arrv2n    = n(),
  ) %>%
  filter(row_number(desc(top.arrv2n)) == 2)%>%
  rename(arrv2.pid = start.pid) 

# 3rd top arriv 
top.arrv3 <- bks2020.2 %>% 
  mutate(
    month     = month(`Start date`),
  ) %>%
  group_by(month, end.pid, start.pid) %>%
  summarise(
    #station.pid = first(start.id),
    top.arrv3n    = n(),
  ) %>%
  filter(row_number(desc(top.arrv3n)) == 3)%>%
  rename(arrv3.pid = start.pid) 

# join top arrvinations together.
top.arrv.2020.2 <-
  left_join(top.arrv1, top.arrv2,
            by = c("end.pid", "month")) %>%
  left_join(top.arrv3, by = c("end.pid", "month")) %>%
  rename(pid = end.pid)

# remove objects. 
rm(top.arrv1, top.arrv2, top.arrv3)


## Join tops together 
top.2020.2 <- 
  left_join(top.arrv.2020.2, top.dest.2020.2,
            by = c("pid", "month"))

rm(top.arrv.2020.2, top.dest.2020.2)


## join to main monthly thing, add net flow replace with na if top value <= 5 %%%
stnmonthly2020.2 <- stnmonthly2020.2 %>%
  left_join(top.2020.2, by = c("pid", "month")) %>%
  mutate(net.daily.flow = av.daily.ot - av.daily.in)



# save ---- 

save(
  stndaily2010, stndaily2011, stndaily2012, stndaily2013, stndaily2014, stndaily2015, 
  stndaily2016, stndaily2017, stndaily2018, stndaily2019, stndaily2020.1, stndaily2020.2,
  file = file.path(full, "station-daily.Rdata"))