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
                              {if(input$Day == "Monday") filter(., strptime(monday_start, "%I:%M%p") <= strptime(input$Time, "%I:%M%p") & 
                                  strptime(monday_end, "%I:%M%p") > strptime(input$Time, "%I:%M%p")) else . } %>%
                              {if(input$Day == "Tuesday") filter(., strptime(tuesday_start, "%I:%M%p") <= strptime(input$Time, "%I:%M%p") & 
                                                                   strptime(tueday_end, "%I:%M%p") > strptime(input$Time, "%I:%M%p")) else . } %>%
                              {if(input$Day == "Wednesday") filter(., strptime(wednesday_start, "%I:%M%p") <= strptime(input$Time, "%I:%M%p") & 
                                                                    strptime(wednesday_end, "%I:%M%p") > strptime(input$Time, "%I:%M%p")) else . } %>%
                              {if(input$Day == "Thursday") filter(., strptime(thursday_start, "%I:%M%p") <= strptime(input$Time, "%I:%M%p") & 
                                                                    strptime(thursday_end, "%I:%M%p") > strptime(input$Time, "%I:%M%p")) else . } %>%
                              {if(input$Day == "Friday") filter(., strptime(friday_start, "%I:%M%p") <= strptime(input$Time, "%I:%M%p") & 
                                                                  strptime(friday_end, "%I:%M%p") > strptime(input$Time, "%I:%M%p")) else . } %>%  
                              {if(input$Day == "Saturday") filter(., strptime(saturday_start, "%I:%M%p") <= strptime(input$Time, "%I:%M%p") & 
                                                                    strptime(saturday_end, "%I:%M%p") > strptime(input$Time, "%I:%M%p")) else . } %>% 
                              {if(input$Day == "Sunday") filter(., strptime(sunday_start, "%I:%M%p") <= strptime(input$Time, "%I:%M%p") & 
                                                                  strptime(sunday_end, "%I:%M%p") > strptime(input$Time, "%I:%M%p")) else . }%>%
                              {if(nrow(.)==0)  showNotification("no streets exist that meet such criteria, try picking another time", type = "error", duration = 15) else . }
                              )
  

  
  #output the map in the server
  output$map <-  renderLeaflet({
      leaflet(data = shiny_open_street()) %>%
        addProviderTiles(providers$CartoDB.Positron) %>%
        addPolygons(label = ~on_street)

  })
}


