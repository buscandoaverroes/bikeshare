# -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- #
# Name: leaf.R
# Description: explores leaflet
#
# -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- #

       library(leaflet)
       #library(urbnmapr)
       
# convert geometry to points 
  cabi.geo.key <- cabi.geo.key %>%
    mutate(
      lon = st_coordinates(geometry)[,1],
      lat = st_coordinates(geometry)[,2]
    )
       
                                
                            #-------------#
                            # plot set 1  # ----
                            #-------------#
                            
                            
      m <- leaflet(cabi.geo.key) %>%
        addTiles() %>%
        addCircleMarkers(lng = cabi.geo.key$lon, lat = cabi.geo.key$lat, label = ~as.character(cabi.station.name),
                         radius = 4,
                         stroke = FALSE, fillOpacity = 0.75) #popup is when you click
      m
      