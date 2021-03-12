#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

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

options(shiny.reactlog = TRUE) # permits to launch reactlog
mapviewOptions(fgb = F) # set to false for greater performance?


ui <- navbarPage("Bikeshare", # UI ===================================================
  # tabPanel("Days", # page 1 -----------------------------------------------------
  #   fluidPage( theme = bs_theme(version = 4, bootswatch = "flatly"),
  #          titlePanel("Title", windowTitle = 'browser title'),
  #          tags$h3("Subtitle"),
  #          tags$body("a paragraph of explanation (but not too long!) goes here."),
  # 
  # 
  #          tags$h3("Graph Title"),
  #          wellPanel(
  #           fluidRow(
  #          column(3,
  #                 verticalLayout(
  #                  tags$h4("Bikeshare Data"),
  #                  pickerInput('y1',
  #                              choices = c("Total Daily Rides"      =  "nrides",
  #                                          "Median Ride Duration" =  "dur_med",
  #                                          "Duration Inequity"    =  "dur_ineq"),
  #                              selected = "nrides",  multiple = FALSE, width = '200px',
  #                              options = pickerOptions(mobile = T)))),
  #           column(3,
  #                  verticalLayout(
  #                  tags$h5("Options"), # spacing
  #                  prettySwitch('y1.weather', "Show Temperature",
  #                               value = FALSE, slim = T, fill = T, inline = T),
  #                  prettySwitch('y1.precip', "Show Precipitation",
  #                               value = FALSE, slim = T, fill = T, inline = T ))),
  #             column(3,
  #               verticalLayout(
  #                  tags$br(),tags$br(),
  #                  prettySwitch('y1.tempfill', "Use Temperature as color",
  #                               value = FALSE, slim = T, fill = T, inline = T),
  #                  prettySwitch('y1.fahr', "Use ℉",
  #                               value = FALSE, slim = T, fill = T, inline = T))),
  #          column(3, tags$br(), tags$br(),
  #                          actionButton('go.y1', "Update", width = "100px")))),
  # 
  # 
  #   withSpinner(plotlyOutput('days'), type = 8, hide.ui = FALSE), tags$br(),
  #   tags$h5("Terms and Notes"),
  #   tags$source("source"),
  #   tags$footer("footer"),
  #   tags$h6("header 6")
  # 
  # 
  #   )), # end first page, panel, page
  tabPanel("Network", # page 2 -----------------------------------------------------
     fluidPage( theme = bs_theme(version = 4, bootswatch = "flatly"),
          titlePanel("Title", windowTitle = 'browser title'), 
          tags$h3("Subtitle"),
          tags$body("a paragraph of explanation (but not too long!) goes here."),
          
          tags$h3("Graph Title"), 
          wellPanel(
            fluidRow(   
              column(3, 
                       tags$h4("Year"),
                       sliderInput('y2.year', "Network Year",
                                   min = 2010, max = max(days$year), value = 2018, # max(rides$year)
                                   step = 1, animate = FALSE, ticks = F, sep = "")),
              column(3,  
                       tags$h5("Options"), # spacing
                       prettySwitch('y2.hourTF', "Show By-Hour",
                                    value = FALSE, slim = T, fill = T, inline = T),
                       sliderInput('y2.hour', "Hour Selector",
                                   min = 0, max = 24, value = 8,
                                   animate = FALSE, ticks = F, sep = "")),
              column(3, tags$br(), tags$br(), 
                     actionButton('go.y2', "Update", width = "100px"))
              )), # end fluid row, wellpanel
            #verbatimTextOutput('print'),
            withSpinner(leafletOutput('network', height = 700), type = 8, hide.ui = FALSE)

      )) # end tab panel, page
    ) # end UI

# SERVER =============================================================================
server <- function(input, output) { 
  
  
source("global.R") # loads files, settings
  
# days::data wrangling--------------------------------------------------------------------------
## values + prepwork ----
# rolling average, 30 days
roll_av_30 <- timetk::slidify(.f = ~ mean(., na.rm=T), .period = 30, .align = 'center', .partial = TRUE)
roll_av_3 <- timetk::slidify(.f = ~ mean(., na.rm=T), .period = 3, .align = 'center', .partial = TRUE)

# midpoints
mid <- reactive({if (input$y1.fahr) {60} else {15}})

min <- reactive({if (input$y1.fahr) {0} else {-12}})

max <- reactive({if (input$y1.fahr) {110} else {42}})

ticks <- reactive({if (input$y1.fahr) {c(20,40,60,80,100)} else {c(0,10,20,30,40)}})

y1.alpha <- reactive({if (input$y1.precip) {0.9} else {0.4}})

#name
name <- eventReactive(input$go.y1, {
    case_when(
        input$y1 == "nrides"     ~ "Daily Rides",
        input$y1 == "dur_med"    ~ "Median Duration (min)",
        input$y1 == "dur_ineq"   ~ "Duration Inequity Index"
    )
}, ignoreNULL=FALSE, ignoreInit = FALSE, label = "name")

## data -----------------------------------------------------------
d1 <- reactive({
    if (input$y1.fahr) {
        days %>% dplyr::ungroup() %>%
            rename(maxtemp = tempmax) %>%
            mutate(maxtemp = round(((9/5)*maxtemp)+32),2)
    } else {
        days %>% dplyr::ungroup() %>%
        rename(maxtemp = tempmax)
    }
})

data1main <- eventReactive( input$go.y1, { 
    
    withProgress(message = 'Assembling bikeshare data',
                 d1() %>% 
                     select(date, input$y1, maxtemp) %>%
                     mutate(
                         rolling_av_30 = case_when( # round only duration_ineq to the hundreths
                             input$y1 == "dur_ineq" ~  round(roll_av_30(.data[[input$y1]]), 2),
                             input$y1 != "dur_ineq" ~  round(roll_av_30(.data[[input$y1]]), 1))))
    
}, ignoreNULL=FALSE, ignoreInit = FALSE, label = "data1main")


data1w <- reactive({ 
    withProgress(message = "Assembling weather data",
      d1() %>% 
          select(date, maxtemp) %>%
          mutate(rolling_av_30_temp =  round(roll_av_30(.data[["maxtemp"]]))))
})

data1p <- reactive({
    d1() %>% 
    select(date, precip)
})


# days::graph -----------------------------------------------------------------------------------
ay <- reactive({
    list(
        zeroline = F, showgrid = F,
        tickfont=list(color=brewer.pal(5,'Purples')[5]), overlaying='y',
        side='right', 
        title=list(text=paste('Observed Daily High',
                              if (input$y1.fahr){'℉'} else{'℃'}),  
                   font=list(color=brewer.pal(5,'Purples')[5])),
        visible=input$y1.weather)
}) 
by <- reactive({
    list(zeroline = F, showgrid = F,
         tickfont=list(color=brewer.pal(5,'Greys')[4]), overlaying='y', side='right', title=list(
             text='Observed Precipitation (mm)', standoff=35), visible=input$y1.precip)
})

## the actual graph object----------------------------------------------------------------
p1 <- eventReactive(input$go.y1, {
    withProgress(message = "Building the graph", # start here.
                 
     plot_ly() %>%
         # temp data
         add_trace(data = data1w(), type='scatter', mode = 'markers', name = "Daily Temp.",
                   x = ~date, y = ~maxtemp, 
                   marker = list(color = brewer.pal(5,'Purples')[3],
                                 opacity = 0.8,
                                 size = 5), 
                   opacity = 0.8,
                   visible = input$y1.weather,
                   legendgroup = "temp",
                   hovertemplate = paste0("<b>%{y:,1f}°</b><br>",
                                          "%{x}",
                                          "<extra></extra>"),
                   yaxis = "y2", alpha = 1 ) %>% #directs to layout.yaxis2
         # rolling av temp
         add_trace(data = data1w(), type='scatter', mode = 'lines', name = "30-day Av",
                   x = ~date, y = ~rolling_av_30_temp, 
                   line = list(color = brewer.pal(5,'Purples')[5]), 
                   opacity = 0.9,
                   visible = input$y1.weather,
                   legendgroup = "temp",
                   hovertemplate = paste0("<b>30-Day Average</b><br>",
                                          "<b>%{y:,1f}°</b><br>",
                                          "%{x}",
                                          "<extra></extra>"),
                   yaxis = "y2", alpha = 1 ) %>%
         # precip
         add_trace(data = data1p(), type = 'bar', x = ~date, y = ~precip,
                   marker = list(color = brewer.pal(5,'Greys')[3], opacity = 0.6),
                   name="Precipitation",
                   legendgroup = "precip",
                   marker=list(line=list(width=1.5)), visible = input$y1.precip,
                   hovertemplate = paste0("<b>%{y:1f} mm</b><br>",
                                          "%{x}",
                                          "<extra></extra>"),
                   yaxis = "y3", alpha = 1 ) %>%
         # main data 
         add_trace(data = data1main(),
                   type = 'scatter', mode = 'markers', name = name(),
                   x = ~date, y = ~isolate(.data[[input$y1]]),
                   marker = list(
                       color = if (input$y1.tempfill) {~maxtemp} else {brewer.pal(5,'Blues')[3]}, 
                       opacity = y1.alpha(),
                       size = 5,
                       showscale = input$y1.tempfill,
                       cmin = min(),
                       cmid = mid(),
                       cmax = max(),
                       colorscale = "RdBu",
                       colorbar = list(
                           title = list(text="Observed <br>Daily High", font=list(size=14)),
                           x = 1.17, y=0.6, len = 1, thickness=25,
                           tickvals=ticks(), tickmode = 'array',
                           ticksuffix=paste(if (input$y1.fahr){'℉'} else{'℃'})
                       )),
                   legendgroup = "bks",
                   hovertemplate = if_else( input$y1.tempfill,
                                            false = paste0("<b>%{y:,2f}</b><br>",
                                                           "%{x}",
                                                           "<extra></extra>"),
                                            true = paste0("<b>%{y:,2f}</b><br>",
                                                          "%{marker.color:1f}",if (input$y1.fahr){'℉'} else{'℃'},
                                                          "<br>%{x}",
                                                          "<extra></extra>"))
         ) %>%
         # rolling av: main data
         add_trace(data = data1main(),
                   type = 'scatter', mode = 'lines', name = paste0("30-day Av"),
                   x = ~date, y = ~rolling_av_30, 
                   line = list(color = brewer.pal(5,'Blues')[4]), 
                   legendgroup = "bks",
                   hovertemplate = paste0("<b>30-Day Average</b><br>",
                                          "<b>%{y:,1f}</b><br>",
                                          "%{x}",
                                          "<extra></extra>")) %>%
         layout( 
             title = list(text=paste("<b>",name(),"</b>"), font=list(size=20)),
             yaxis2= ay(),
             yaxis3= by(),
             yaxis = list(
                 showgrid = F,
                 title = list(text=paste(name()), font=list(size=16))), 
             xaxis = list(
                 title = list(text="<b>Date Range Selector</b>", font=list(size=16)),
                 rangeslider = list(autorange=TRUE, thickness = 0.15),
                 rangeselector = list(
                     x = 0.02, y = 1.1,
                     buttons = list(
                         list(count=3, label="3 yr", step='year', stepmode='backward'),
                         list(count=1, label="1 yr", step='year', stepmode='backward'),
                         list(count=3, label='3 mo', step='month',stepmode='backward'),
                         list(step = 'all')))),
             font = list(family="arial"),
             legend = list(orientation='h', y=1.30, x=0.95, xanchor = "auto"),
             margin = list(l=80, r=100),
             dragmode = 'pan'
         ) %>% # end layout
         config(modeBarButtonsToRemove = c('lasso2d', 'select2d', 'toggleSpikelines',
                                           'autoScale2d', 'zoomIn2d', 'zoomOut2d'))
     
    ) # end withprogress
    
}, ignoreNULL=FALSE, ignoreInit = FALSE, label = 'p1-plotly')
    

## render the graph ---------------------------------------------------------------------------
output$days <- renderPlotly({p1()})
    
    




# network::data wrangling --------------------------------------------------------------------

# load main days dataset
# (pretend it's loaded, it's actually in the local env already...)

## create origin-destination datatset ------------------------------------------------
od <- eventReactive(input$go.y2, {
  withProgress( message = "Gathering the Origin-Destination Data",
  rides %>% # could save a lot of time if there were another file that already had only 3 necessary vars
  ungroup() %>% 
  filter(year == input$y2.year) %>%  # for performance could we preproduce these 10 maps at least?
  group_by(id_start, id_end) %>%
  summarize(nrides = n()) %>%
  rename(id_proj1 = id_start,
         id_proj2 = id_end) %>%
    filter(id_proj1 != id_proj2)
  ) #end withprogress
  
}, ignoreNULL=FALSE, ignoreInit = FALSE, label = 'od-network') 
 
## create "geometry" dataset -------------------------------------------------------
z <- select(key, id_proj, geometry) %>%
  ungroup()

# create desire lines
desire_lines <- eventReactive(input$go.y2, {
  withProgress(message = "Creating Desire Lines",
  od2line(flow = od(), zones = z) %>% filter(nrides >= 100)) #end withProgress
}, ignoreNULL=FALSE, ignoreInit = FALSE, label = 'desire-lines') 


## filter the station-year data -------------------------------------------------

station_yr <- eventReactive(input$go.y2, {
  withProgress(message = "Gathering Station Departure Data",
  stations %>%
    filter(year == input$y2.year) %>%
    st_as_sf()) # end with Progress
}, ignoreNULL=FALSE, ignoreInit = FALSE, label = 'station_year')


## create the mapview graph -----------------------------------------------------
map.network <- reactive({
  withProgress(message = "Building the Graph",
  mapview(desire_lines(), zcol = 'nrides', alpha = 0.3, col.regions = network.pal,
          at = c(100,200,300,500,1000,10000), lwd = 0.7, popup = FALSE, layer.name = "Origin-Dest. Trips") +
    mapview(station_yr(), zcol = "departures", cex = 3, alpha = 0.3, label = "name_bks_st", lwd = 0.5,
            color = "black", col.regions= mapviewColors(station_yr(), station_yr()$departures,
                                                        colors = hcl.colors(7, palette = "Sunset", alpha = NULL, rev = T)),  # dot fill color
            popup=FALSE, layer.name = "Station<br>Departures") # the popuptable argument throws error
 # mapview(breweries, zcol="founded", col.regions = hcl.colors(2, palette = "Cividis"), popup=F) 
  ) # end withProgress
})
# error: Error in value[[3L]]: Couldn't normalize path in `addResourcePath`, with arguments: `prefix` = 'PopupTable-0.0.1'; `directoryPath` = ''

## render mapview --------------------------------------------------------------------
output$network <- renderLeaflet({map.network()@map})






} # end server - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 

# Run the application 
shinyApp(ui = ui, server = server)
