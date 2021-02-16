#
# This is the server logic of a Shiny web application. You can run the
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)


ny_restaurant_map <- read.socrata("https://data.cityofnewyork.us/Transportation/Open-Restaurant-Applications/pitm-atqc")
# Define UI for application that maps out resturants 


# Define server logic required to draw a histogram
shinyServer(function(input, output) {
    
    #Resturants ---------------------------------------------------------------------------------------------
    #Get dataset to use map
    
    ny_restaurant_map <- ny_restaurant_map %>% 
        drop_na_(vars = c("latitude", "longitude")) %>% 
        mutate(seating_interest_sidewalk =  recode(seating_interest_sidewalk,
                                                   "both" = "both sidewalk and roadway")) %>%
        mutate(total_dining_area = replace_na(sidewalk_dimensions_area, 0) + 
                   replace_na(roadway_dimensions_area, 0) ) %>%
        pivot_longer(cols = ends_with("area"), names_to = "category",
                     values_to = "area") %>%
        drop_na_("area") 
    
    bins <- c(0, 200, 400, 600, 1000, 2000, 4000, 8000, 20000, 60000)
    pal <- colorBin(c("red", "orange", "yellow", "green", "blue", 
                      "purple", "violet", "brown", "gray", "black"),
                    domain = NULL, bins = bins)
    
    #Allow dataset to be manipulated by the shiny app ui
    shiny_restaurants <- reactive(ny_restaurant_map[
        which(ny_restaurant_map$category %in% input$Category &
                  ny_restaurant_map$borough %in% input$Borough &
                  ny_restaurant_map$qualify_alcohol %in% input$Alcohol),])
    
    #output the map in the server
    output$foodmap <- renderLeaflet({
        ny_map <- leaflet(options = leafletOptions(minZoom = 5, maxZoom = 18)) %>%
            setView(-73.98928, lat = 40.75042, zoom = 10) %>%
            addTiles() %>%
            addCircles(lng = shiny_restaurants()$longitude,
                       lat = shiny_restaurants()$latitude, 
                       label = shiny_restaurants()$restaurant_name,
                       color = pal(shiny_restaurants()$area)) %>%
            addLegend(title = "Dining Area (in sq. ft.)", position = "topleft",
                      colors = c("red",
                                 "orange", "yellow", 
                                 "green", "blue", 
                                 "purple", "violet", 
                                 "brown", "gray", "black"), 
                      labels = c("0 to 200", "201 to 400",
                                 "401 to 600", "601 to 1000",
                                 "1001 to 2000", "2001 to 4000",
                                 "4001 to 8000", "8001 to 12000",
                                 "12001 to 30000","30001 to 60000"))
    })
    
    
    #parks --------------------------------------------------------------------------------------------------------------
    filteredData <- reactive(all_parks_with_p %>%
                                 filter(park_borough %in% input$Borough) %>% 
                                 filter(encounter_datetime < Sys.Date() | is.na(encounter_datetime)))
    
    
    # Create the map
    output$parkmap <- renderLeaflet({
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
    
    observeEvent(input$parkmap_shape_click, {
        event <- input$parkmap_shape_click
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
    
    #COVID data --------------------------------------------------------------------------
    
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

})
