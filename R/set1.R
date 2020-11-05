# -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- #
# Name: set1.R
# Description: makes datasets needed for first set
#
# -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- #


library(leaflet)


# settings 
save = 1

# load data 
load(file.path(kpop, "geo-data.Rdata"))
load(file.path(full, "years.Rdata"))


# create no start/end rides at each station 
nstarts <- bks2020.2 %>%
  #filter(`Member type` == "Guest") %>%
  group_by(`Start station number`) %>%
  summarise(
    nstarts = n(),
  ) 
nend  <- bks2020.2 %>%
  #filter(`Member type` == "Guest") %>%
  group_by(`End station number`) %>%
  summarise(
    nend = n()
  )

# remove old station numbers
spring20 <- cabi.geo.key %>%
  mutate(
    lon = st_coordinates(geometry)[,1],
    lat = st_coordinates(geometry)[,2]
  ) %>%
  filter(is.na(cabi.station.id.new) == FALSE) 

 # join start/end 
 spring20 <- left_join(spring20,
            nstarts,
            by = c("cabi.station.id.new" = "Start station number")) %>%
            left_join(nend,
                      by = c("cabi.station.id.new" = "End station number")) %>%
   mutate(
     net = nend - nstarts,
     tot_interaction = nstarts + nend
   )

 
 if (save == 1) {
  save(spring20,
       file = file.path(full, "spring20.Rda"))
 }
 
 #-------------#
 # plot set 1  # ----
 #-------------#
 
# n starts by color  ####
 
 
 # create continuous palette function 
 pala <- colorNumeric(
   palette = c("white", "green"),
   domain = spring20$nstarts
 )
 
 a <- leaflet(spring20) %>%
   addTiles() %>%
   addCircleMarkers(
                    label = ~as.character(nstarts),
                    radius = 9,
                    stroke = FALSE,
                    fillOpacity = 0.75,
                    color = ~pala(nstarts)
   )
                     #popup is when you click
 a  
 
 
 # n finishes by color ####
 
 # create continuous palette function 
 palb <- colorNumeric(
   palette = c("white", "tomato"),
   domain = spring20$nend
 )
 
 b <- leaflet(spring20) %>%
   addTiles() %>%
   addCircleMarkers(
     label = ~as.character(nend),
     radius = 9,
     stroke = FALSE,
     fillOpacity = 0.75,
     color = ~palb(nend)
   )
 #popup is when you click
 b  
 
 
 
 
 # n total interactions by color ####
 
 # create continuous palette function 
 palc <- colorNumeric(
   palette = c("white", "magenta"),
   domain = spring20$tot_interaction
 )
 
 qpalc <- colorQuantile(
   palette = c("white", "magenta"),
   domain = spring20$tot_interaction,
   n = 8
 )
 
 c <- leaflet(spring20) %>%
   addTiles() %>%
   addCircleMarkers(
     label = ~as.character(spring20$tot_interaction),
     labelOptions = labelOptions(textsize = "14px",
                                 sticky = FALSE,
                                 textOnly = FALSE),
     radius = 9,
     stroke = FALSE,
     fillOpacity = 0.75,
     color = ~palc(tot_interaction)
   )
 #popup is when you click
 c
 
 