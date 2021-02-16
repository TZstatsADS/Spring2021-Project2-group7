
library(tidyverse)
library(ggmap)
library(dplyr)
library(RSocrata)
library(leaflet)


#Shiny App Server

server <- function(input, output) {

  data1 <- read_csv("data/Modified_Zip_Code_Tabulation_Areas__MODZCTA_.csv") %>%
    select(MODZCTA, the_geom)
  data2 <- read_csv("data/last7days-by-modzcta.csv") %>%
    select(modzcta, percentpositivity_7day, people_positive)
  data3 <- read_csv("data/data-by-modzcta.csv") %>%
    select(MODIFIED_ZCTA, COVID_CASE_COUNT, PERCENT_POSITIVE) %>% 
    rename(MODZCTA = MODIFIED_ZCTA)
  data4 <- read_csv("data/antibody-by-modzcta.csv") %>%
    select(modzcta_first, PERCENT_POSITIVE, NUM_PEOP_POS) %>% 
    rename(MODZCTA = modzcta_first)
  data1 <- subset(data1, 10000<MODZCTA & MODZCTA<11698)
  covid <- cbind(data1, data2, data3, data4) %>% sf::st_as_sf(wkt = "the_geom")
  
  bins_7 <- c(0, 10, 20, 50, 100, 150, 200, 250, 300, Inf)
  bins_t <- c(0, 1000, 2000, 3000, 4000, 5000, 6000, 7000, 8000, Inf)
  bins_a <- c(0, 2000, 4000, 6000, 8000, 10000, 12000, 14000, 16000, 18000, Inf)
  pal_7 <- colorBin("YlOrRd", domain = covid$people_positive, bins = bins_7)
  pal_t <- colorBin("YlOrRd", domain = covid$COVID_CASE_COUNT, bins = bins_t)
  pal_a <- colorBin("YlOrRd", domain = covid$NUM_PEOP_POS, bins = bins_a)
  label_7 <- sprintf(
    "Zip: <strong>%s</strong><br/>%g people tested positive",
    covid$MODZCTA, covid$people_positive
  ) %>% lapply(htmltools::HTML)
  label_t <- sprintf(
    "Zip: <strong>%s</strong><br/>%g people tested positive",
    covid$MODZCTA, covid$COVID_CASE_COUNT
  ) %>% lapply(htmltools::HTML)
  label_a <- sprintf(
    "Zip: <strong>%s</strong><br/>%g people tested positive",
    covid$MODZCTA, covid$NUM_PEOP_POS
  ) %>% lapply(htmltools::HTML)
  
  output$recent_map <- renderLeaflet({
    recent_map <- leaflet(data = covid) %>%
      addTiles() %>%
      addPolygons(fillOpacity = 0.9, weight = 2, opacity = 1, color = 'white', dashArray = '3',
                  fillColor = ~pal_7(people_positive), 
                  highlight = highlightOptions(
                    weight = 5,
                    color = "#666",
                    dashArray = "",
                    fillOpacity = 1,
                    bringToFront = TRUE),
                  label = label_7,
                  labelOptions = labelOptions(
                    style = list("font-weight" = "normal", padding = "3px 8px"),
                    textsize = "15px",
                    direction = "auto")) %>%
      addLegend(pal = pal_7, values = ~people_positive, opacity = 1.0)
  })

  
  output$total_map <- renderLeaflet({
    total_map <- leaflet(data = covid) %>%
      addTiles() %>%
      addPolygons(fillOpacity = 0.9, weight = 2, opacity = 1, color = 'white', dashArray = '3',
                  fillColor = ~pal_t(COVID_CASE_COUNT), 
                  highlight = highlightOptions(
                    weight = 5,
                    color = "#666",
                    dashArray = "",
                    fillOpacity = 1,
                    bringToFront = TRUE),
                  label = label_t,
                  labelOptions = labelOptions(
                    style = list("font-weight" = "normal", padding = "3px 8px"),
                    textsize = "15px",
                    direction = "auto")) %>%
      addLegend(pal = pal_t, values = ~COVID_CASE_COUNT, opacity = 1.0)
  })
  

  output$antibody_map <- renderLeaflet({
    antibody_map <- leaflet(data = covid) %>%
      addTiles() %>%
      addPolygons(fillOpacity = 0.9, weight = 2, opacity = 1, color = 'white', dashArray = '3',
                  fillColor = ~pal_a(NUM_PEOP_POS), 
                  highlight = highlightOptions(
                    weight = 5,
                    color = "#666",
                    dashArray = "",
                    fillOpacity = 1,
                    bringToFront = TRUE),
                  label = label_a,
                  labelOptions = labelOptions(
                    style = list("font-weight" = "normal", padding = "3px 8px"),
                    textsize = "15px",
                    direction = "auto")) %>%
      addLegend(pal = pal_a, values = ~NUM_PEOP_POS, opacity = 1.0)
  })
  
  
}



#Shiny App UI

ui <- fluidPage(
  titlePanel("Map of NYC COVID-19 Data"),
  

    mainPanel(
      tabsetPanel(
        tabPanel("7-Days Positive", leafletOutput("recent_map")), 
        tabPanel("Total Positive", leafletOutput("total_map")), 
        tabPanel("Antibody", leafletOutput("antibody_map"))
      )
    )
  )

#run
shinyApp(ui = ui, server = server)

