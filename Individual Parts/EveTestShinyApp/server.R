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

#Data initialization

# park_poly <- read.socrata("https://data.cityofnewyork.us/dataset/Social-Distancing-Park-Areas/4iha-m5jk")
# 
# park_poly <- sf::st_as_sf( park_poly, wkt = "multipolygon")
# 
# violations <-  read.socrata("https://data.cityofnewyork.us/dataset/Social-Distancing-Parks-Crowds-Data/gyrw-gvqc") %>%
#   group_by(park_area_id, encounter_timestamp) %>% 
#   summarise(patrons = sum(patroncount))
# 
# parks_with_p <- merge(park_poly,violations,by="park_area_id", all.x=TRUE)
# 
# bins <- c(0, 10, 25, 50, 100, 200, 400, 800, Inf)
# pal <- colorBin("YlOrRd", domain = parks_with_p$patrons, bins = bins)


#shiny vibes
function(input, output, session) {
  #make it move
  filteredData <- reactive(all_parks_with_p %>%
      filter(park_borough %in% input$Borough) %>% 
      filter(encounter_datetime < Sys.Date() | is.na(encounter_datetime))# %>% 
      # filter(strptime(parks_with_p$encounter_timestamp, "%Y-%m-%d %H:%M:%-S") >= strptime(input$range[1],  "%Y-%m-%d %H:%M:%-S")) %>%
      # filter(strptime(parks_with_p$encounter_timestamp, "%Y-%m-%d %H:%M:%-S") <= strptime(input$range[2], "%Y-%m-%d %H:%M:%-S"))
  )
  
  
  # Create the map
  output$mymap <- renderLeaflet({
    leaflet(filteredData()) %>%
      addProviderTiles(providers$CartoDB.Positron) %>%
      addPolygons(label = ~park_area_desc,
                  fillColor = ~pal(patrons),
                  weight = .5,
                  opacity = 5,
                  color = "white",
                  dashArray = "3",
                  fillOpacity = 0.7,
                  layerId = ~park_area_desc) %>%
      addLegend("bottomright", pal = pal, values = ~patrons,
                title = "Number of Patrons Violating Social Distancing ",
                opacity = 1
      )
  })
  
  output$time_reports <- renderPlot(
    filteredData()  %>%
      ggplot(aes(y=patrons, x=encounter_datetime)) +
      geom_col()+
      scale_x_date(date_labels = "%Y %b %d") +
      ggtitle("All") +
      xlab("Date of Observation") + ylab("Number of Patrons Observed"))
  
  observeEvent(input$mymap_shape_click, {
    event <- input$mymap_shape_click
    output$time_reports <- renderPlot(
      all_parks_with_p %>% filter(encounter_datetime < Sys.Date()) %>%
        filter(park_area_desc == event$id) %>%
        ggplot(aes(y=patrons, x=encounter_datetime)) +
        geom_col()+
        scale_x_date(date_labels = "%Y %b %d") +
        ggtitle(event$id) +
        xlab("Date of Observation") + ylab("Number of Patrons Observed")
      )

  })
  
  
}
