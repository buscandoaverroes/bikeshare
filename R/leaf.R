# -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- #
# Name: leaf.R
# Description: explores leaflet
#
# -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- #

       library(leaflet)
       library(urbnmapr)
       
                            
                            #-------------#
                            # plot set 1  # ----
                            #-------------#
                            
                            
      m <- leaflet(key) %>%
        addTiles() %>%
        addCircleMarkers(~lng, ~lat, label = ~as.character(stn),
                         radius = 4,
                         stroke = FALSE, fillOpacity = 0.75) #popup is when you click
      m
      
      
      # urbn mapr 
      counties <- get_urbn_map("counties", sf = TRUE)
      counties %>%
        ggplot(aes()) + 
        geom(sf)