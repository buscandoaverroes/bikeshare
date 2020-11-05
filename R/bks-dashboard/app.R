#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
library(tidyverse)


library(leaflet)

# load data 
load(file.path(kpop, "geo-data.Rdata"))
load(file.path(full, "spring20.Rda"))




# Define UI for application that draws a histogram
ui <- navbarPage(
    
  # Tab panel 1: map 
  tabsetPanel( type = "pills",
    tabPanel(
      title = "Interactive Map",

    leafletOutput("map", height = "700px", width = "800px"),
    
    
    
    # Sidebar
      absolutePanel(
        id = "mapinput",
        draggable = TRUE,
        fixed = TRUE,
        top = 50,
        bottom = "auto",
        right = "auto",
        left = 50,
        width = 200, 
        height = "auto",
        
        h2("sidebar"),
        ("This is the part where you adjust input"),
        sliderInput(
          "ntiles", 
          "Number of n-tiles",
          value = 4,
          min = 2,
          max = 100),
        selectInput(
          "int_type",
          "Type of Interaction",
          choices = c("Returns"   = "nend",
                      "Checkouts" = "nstart",
                      "Combined"  = "tot_interaction"),
          selected= "Checkouts",
          multiple = FALSE),
          
      )
    ),
    
    tabPanel("Data Explorer",
            p(h2("here will go some plots"))
             
             )

      
    )
)
    
    


# Define server logic required to draw a histogram
server <- function(input, output) {
  


  
  output$map <- renderLeaflet({
    
    # define color scale as quantiles/n-tiles (must be done in app)
    qpalc <- colorBin(
      palette = "BuPu",
      n = 7,
      domain = spring20$tot_interaction,
    )
    
    
    leaflet(spring20) %>%
      addTiles() %>%
      addCircleMarkers(
        data = spring20,
        lng = spring20$lon,
        lat = spring20$lat,
        label = ~as.character(spring20$tot_interaction),
        labelOptions = labelOptions(textsize = "14px",
                                    sticky = FALSE,
                                    textOnly = FALSE),
        radius = 9,
        stroke = FALSE,
        fillOpacity = 0.75,
        color = ~qpalc(spring20$tot_interaction)
      )
  })
    
}

# Run the application 
shinyApp(ui = ui, server = server)
