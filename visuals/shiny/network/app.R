library(tidyverse)
library(sf)
library(leaflet)
library(leafem)
library(leafpop)
library(leafsync)
library(plotly)
library(shiny)
library(shinyWidgets)
library(lubridate)
library(timetk)
library(RColorBrewer)
library(shinycssloaders)
library(bslib)
library(mapview)
library(stplanr)
library(leafgl)
library(colourvalues)

options(shiny.reactlog = TRUE) # permits to launch reactlog
mapviewOptions(fgb = F) # set to false for greater performance?

ui <- navbarPage("Bikeshare", # UI ===================================================
 
  tabPanel("Network", # network graph ----
     fluidPage( theme = bs_theme(version = 4, bootswatch = "flatly"),
          titlePanel("Title", windowTitle = 'browser title'), 
          tags$h3("Subtitle"),
          tags$body("a paragraph of explanation (but not too long!) goes here."),
          
          tags$h3("Graph Title"), 
          wellPanel(
            fluidRow(   
              column(3,
                     pickerInput('y2.linefill', "Gradient Color", 
                                 choices = c("Rides" = "nrides", "Member Percent"="member_pct"),
                                 selected = "member_pct", multiple = FALSE, width = '150px', 
                                 options = pickerOptions(mobile=T)
                                 ),
                      sliderInput('y2.year', "Network Year",
                                   min = 2010, max = 2020, value = 2018, # max(rides$year)
                                   step = 1, animate = FALSE, ticks = F, sep = ""),
                     sliderInput('y2.hour', "Hour Selector",
                                 min = 0, max = 23, value = 8,
                                 animate = FALSE, ticks = F, sep = "")),
              column(3,
              sliderInput('y2.mindesire', "Minimum Line/Trip Value",
                          min = 50, max = 1000, value = 100, step = 10,
                          animate = FALSE, ticks = F, sep = ""),
              sliderInput('y2.pointsize', "Station Marker Size",
                          min = 1, max = 12, value = 3, step = 1,
                          animate = FALSE, ticks = F, sep = "")),
              column(3,  
                       tags$h5("Options"), # spacing
                       prettySwitch('y2.hourTF', "Show By-Hour",
                                    value = FALSE, slim = T, fill = T, inline = T),
                     prettySwitch('y2.freescale', "Autoscale",
                                  value = TRUE, slim = T, fill = T, inline = T)),
              column(3, tags$br(), tags$br(), 
                     actionButton('go.y2', "Update", width = "100px"))
              )), # end fluid row, wellpanel
            #verbatimTextOutput('print'),
            leafletOutput('network', height = 700),
          verbatimTextOutput('see')

      )) # end tab panel, page
    ) # end UI

# SERVER =============================================================================
server <- function(input, output) { 
  
  
source("global.R") # loads files, settings



# network::data wrangling --------------------------------------------------------------------

# load main days dataset
# (pretend it's loaded, it's actually in the local env already...)

## create origin-destination datatset ------------------------------------------------
od <- eventReactive(input$go.y2, {
  withProgress( message = "Gathering the Origin-Destination Data",
  
    if (input$y2.hourTF) { # if going by year-hour
      rides %>% 
        ungroup() %>%
      filter(year == input$y2.year, hour == input$y2.hour) %>%  # for performance could we preproduce these 10 maps at least?
        group_by(id_start, id_end) %>%
        summarize(nrides = n(), 
                  member_pct = 100*round(mean(member),3)) %>%
        rename(id_proj1 = id_start,
               id_proj2 = id_end) %>%
        filter(id_proj1 != id_proj2)
      
    } else { # if only going by year,
      rides %>% # could save a lot of time if there were another file that already had only 3 necessary vars
        ungroup() %>%
      filter(year == input$y2.year) %>%  # for performance could we preproduce these 10 maps at least?
        group_by(id_start, id_end) %>%
        summarize(nrides = n(),
                  member_pct = 100*round(mean(member),3)) %>%
        rename(id_proj1 = id_start,
               id_proj2 = id_end) %>%
        filter(id_proj1 != id_proj2)
    }) #end withprogress
  
}, ignoreNULL=FALSE, ignoreInit = FALSE, label = 'od-network') 
 
## create "geometry" datasets -------------------------------------------------------
z <- select(key, id_proj, name_bks, geometry) %>%
  ungroup()

z_nullgeo <- st_drop_geometry(z)

desire_min <- reactive({input$y2.mindesire}) # if by hour, min is 50, if by year, 100 if (input$y2.hourTF) {50} else {100}

# create desire lines
desire_lines <- eventReactive(input$go.y2, {
  withProgress(message = "Creating Desire Lines",
  od2line(flow = od(), zones = z) %>% filter(nrides >= desire_min()) %>%
    left_join(z_nullgeo, by=c('id_proj1' = 'id_proj')) %>% # geocode1 = origin
    rename(Origin = name_bks) %>%
    left_join(z_nullgeo, by=c('id_proj2' = 'id_proj')) %>% # geocode2 = destination
    rename(Destination = name_bks)
  
  ) #end withProgress
}, ignoreNULL=FALSE, ignoreInit = FALSE, label = 'desire-lines') 


## filter the station-year data -------------------------------------------------

station_yr <- eventReactive(input$go.y2, {
  withProgress(message = "Gathering Station Departure Data",
    if (input$y2.hourTF) { 
      stations %>%
        filter(year == input$y2.year, hour == input$y2.hour) %>%
        rename(departures = hourly_dep) %>%
        st_as_sf()
    } else {
      stations %>%
        filter(year == input$y2.year) %>%
        rename(departures = hourly_dep) %>%
        st_as_sf()
    }) # end with Progress
}, ignoreNULL=FALSE, ignoreInit = FALSE, label = 'station_year')


## create the leaflet graph -----------------------------------------------------

# settings dependent on by hour or year
net.al <- reactive({ if (input$y2.hourTF) {0.7} else {0.3} }) 
net.at <- eventReactive(input$go.y2, { if (input$y2.freescale) {NULL} else { 
  if (input$y2.hourTF) {c(50,100,200,300,500,10000)} else {c(100,200,300,500,1000,10000)}}
    }, ignoreNULL=FALSE, ignoreInit = FALSE, label = 'custom-at')
net.lwd<- reactive({ if (input$y2.hourTF) {3} else {1} })
markersize <- eventReactive(input$go.y2, {input$y2.pointsize}, ignoreNULL=FALSE, ignoreInit = FALSE, label = 'markersize')
net.fill <- eventReactive(input$go.y2, {input$y2.linefill}, ignoreNULL=FALSE, ignoreInit = FALSE, label = 'linefill')


# leaflet colors 
col.lines <- reactive({color_values(desire_lines()$nrides, "viridis", summary = TRUE)})  # summary arg doesn't matter?
col.pts   <- reactive({color_values(station_yr()$departures, "heat_hcl", summary = FALSE)}) 
pal.quant  <- reactive({colorQuantile("plasma", desire_lines()$nrides, reverse = FALSE)})
pal.bin   <- reactive({colorBin("viridis", desire_lines()$nrides, bins = c(0, 300, 1000, 20000),
                                reverse = FALSE)})

# leaflet gl graph ---------
map.gl <- reactive({
  leaflet() %>%
    addTiles() %>%
    addGlPolylines(data  = desire_lines(),
                   color = ~pal.bin()(desire_lines()$nrides),
                   weight= 0.3, 
                   opacity = 0.7
                   ) %>%
    #addGlPoints(data = station_yr(), fillColor = col.pts(), fillOpacity = 0.6)
    addLegend(position = "topleft",
              na.label = NULL,
              title = "<font size=2>Title",
              pal = pal.bin(),
              values = desire_lines()$nrides,
              opacity = 0.4)
})

#output$see <- renderPrint({str(desire_lines())})


## render mapview --------------------------------------------------------------------
output$network <- renderLeaflet({map.gl()})






} # end server - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 

# Run the application 
shinyApp(ui = ui, server = server)
