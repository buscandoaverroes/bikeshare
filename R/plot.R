# -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- #
# Name: plot.R
# Description: creates some plots
#
# -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- #
  

                                    
                                    #-------------#
                                    # plot set 1  # ----
                                    #-------------#
byhour <- readRDS(file.path(kpop, "byhour.Rda"))
byhouryr <- readRDS(file.path(kpop, "byhouryr.Rda"))
dlyrd <-  readRDS(file.path(kpop, "dlyrd.Rda"))


ggplot(data = byhour) + 
  geom_point(mapping = aes(x = hourstart, y = count, color = mbr_ratio))
                                    
    
 # specify shape                                                                 
ggplot(data = byhour) + 
  geom_point(mapping = aes(x = hourstart, y = count), shape = 19)

# same but smooth
ggplot(data = byhour) + 
  geom_smooth(mapping = aes(x = hourstart, y = count))


# facet wrap: dailyrd 

ggplot(data = dlyrd) + 
  geom_smooth(mapping = aes(x = doystart, y = count)) + 
  facet_wrap(~ yearstart)

#  stack year by dif color
ggplot(data = dlyrd) + 
  geom_smooth(mapping = aes(x = doystart, y = count, color = year  ))

    #  stack year by dif color: y = member ratio
    ggplot(data = dlyrd) + 
      geom_smooth(mapping = aes(x = doystart, y = mbr_ratio, color = year  ))
    
    #  stack year by dif color: y = median minutes
    ggplot(data = dlyrd) + 
      geom_smooth(mapping = aes(x = doystart, y = med_min, color = year  ))
    
   
    
    #  stack year by dif color: y = median minutes, split by member
    # ggplot(data = dlyrd) + 
    #   geom_smooth(mapping = aes(x = doystart, y = med_min, color = year  )) + 
    #   facet_wrap(~ m)
    
    
    
# by hour, split by year 
    
    # y= med minutes
    ggplot(data = byhouryr) + 
      geom_smooth(mapping = aes(x = hourstart, y = med_min, color = year  )) 
     
    # y= nrides
    ggplot(data = byhouryr) + 
      geom_smooth(mapping = aes(x = hourstart, y = count, color = year  )) 
    
    # y= member ratio
    ggplot(data = byhouryr) + 
      geom_smooth(mapping = aes(x = hourstart, y = mbr_ratio, color = year  )) 
    
    # y= count, in year grid
    ggplot(data = byhouryr) + 
      geom_smooth(mapping = aes(x = hourstart, y = count, color = year  )) +
      facet_wrap(~ year)

    # y= mbr ratio, in year grid
    ggplot(data = byhouryr) + 
      geom_smooth(mapping = aes(x = hourstart, y = mbr_ratio, color = year  )) +
      facet_wrap(~ year)
    
    # y= mbr ratio, in year grid
    ggplot(data = byhouryr) + 
      geom_smooth(mapping = aes(x = hourstart, y = mbr_ratio, color = year  )) +
      facet_wrap(~ year)
    
    # y= med duration, in year grid
    ggplot(data = byhouryr) + 
      geom_smooth(mapping = aes(x = hourstart, y = med_min, color = year  )) +
      facet_wrap(~ year)
    