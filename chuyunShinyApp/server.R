#
# This is the server logic of a Shiny web application. You can run the
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

# Set Up
packages.used=as.list(
  c(
    "tidyverse",
    "haven",
    "devtools",
    "RColorBrewer",
    "data.table",
    "ggplot2",
    "dplyr", 
    "RSocrata", 
    "sf", 
    "rgdal",
    "leaflet")
)

check.pkg = function(x){
  if(!require(x, character.only=T)) install.packages(x, 
                                                     character.only=T,
                                                     dependence=T)
}


lapply(packages.used, check.pkg)

open_street <- read.socrata("https://data.cityofnewyork.us/Health/Open-Streets-Locations/uiay-nctu")

open_street <- sf::st_as_sf(open_street, wkt = "the_geom")
  

server <- function(input, output) {
  
  #Allow dataset to be manipulated by the shiny app ui
  shiny_open_street <- reactive(open_street %>%
                              filter(borough %in% input$boroughst) %>%
                              {if(input$Day == "Monday") drop_na(., monday_start)  else . } %>%
                              {if(input$Day == "Tuesday") drop_na(., tuesday_start) else . } %>%
                              {if(input$Day == "Wednesday") drop_na(., wednesday_start) else . } %>%
                              {if(input$Day == "Thursday") drop_na(., thursday_start) else . } %>%
                              {if(input$Day == "Friday") drop_na(., friday_start) else . } %>%  
                              {if(input$Day == "Saturday") drop_na(., saturday_start) else . } %>% 
                              {if(input$Day == "Sunday") drop_na(., sunday_start) else . } 
                              )
  
   
  
  #output the map in the server
  output$map <- renderLeaflet({
    leaflet(data = shiny_open_street()) %>%
      addProviderTiles(providers$CartoDB.Positron) %>%
      addPolygons(label = ~on_street)
  })
}

# Run the application 
#shinyApp(ui = ui, server = server)

