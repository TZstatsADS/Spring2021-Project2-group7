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

ny_open_street_map <- read.socrata("https://data.cityofnewyork.us/Health/Open-Streets-Locations/uiay-nctu")

  

server <- function(input, output) {
  
  #Get dataset to use map
  
  ny_open_street_map <- ny_open_street_map %>% 
    drop_na_(start_time)%>%
    filter(ny_open_street_map_borough %in% input$Borough)
     
  
  bins <- c(0, 200, 400, 600, 1000, 2000, 4000, 8000, 12000, 30000, Inf)
  pal <- colorBin(c("red", "orange", "yellow", "green", "blue", 
                    "purple", "violet", "brown", "gray", "black"),
                  domain = NULL, bins = bins)
  
  #Allow dataset to be manipulated by the shiny app ui
  shiny_open_street <- reactive(ny_open_street_map[
    which(ny_open_street_map$location_p %in% input$Location &
            ny_open_street_map$borough %in% input$Borough &
            ny_open_street_map$on_street %in% input$OnStreet),])
  
  #output the map in the server
  output$map <- renderLeaflet({
    ny_map <- leaflet(options = leafletOptions(minZoom = 5, maxZoom = 18)) %>%
      addTiles() %>%
      addLegend(title = "Open Streets Area (in sq. ft.)", position = "topleft",
                colors = c("red",
                           "orange", "yellow", 
                           "green", "blue", 
                           "purple", "violet", 
                           "brown", "gray", "black"), 
                labels = c("0 to 200", "201 to 400",
                           "401 to 600", "601 to 1000",
                           "1001 to 2000", "2001 to 4000",
                           "4001 to 8000", "8001 to 12000",
                           "12001 to 30000","30001 to Inf"))
  })
}

# Run the application 
#shinyApp(ui = ui, server = server)