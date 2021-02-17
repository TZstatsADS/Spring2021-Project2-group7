#
# This is the server logic of a Shiny web application. You can run the
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

packages.used=as.list(
  c(
  "shiny",
  "leaflet",
  "RSocrata",
  "tidyverse",
  "haven",
  "devtools",
  "RColorBrewer")
)
check.pkg = function(x){
  if(!require(x, character.only=T)) install.packages(x, 
                                                     character.only=T,
                                                     dependence=T)
}
lapply(packages.used, check.pkg)

#resturant Data 
ny_restaurant_map <- read.socrata("https://data.cityofnewyork.us/Transportation/Open-Restaurant-Applications/pitm-atqc")
covid_res <- read_csv("data/last7days-by-modzcta.csv") %>%
  select(modzcta, people_positive) 
# Define UI for application that maps out resturants 


#park data + Cleaning
park_poly <- read.socrata("https://data.cityofnewyork.us/dataset/Social-Distancing-Park-Areas/4iha-m5jk")

park_poly <- sf::st_as_sf( park_poly, wkt = "multipolygon")

violations <-  read.socrata("https://data.cityofnewyork.us/dataset/Social-Distancing-Parks-Crowds-Data/gyrw-gvqc") %>%
    group_by(park_area_id, encounter_timestamp) %>% 
    summarise(patrons = sum(patroncount))

ambassabors <- read.socrata("https://data.cityofnewyork.us/City-Government/Social-Distancing-Citywide-Ambassador-Data/akzx-fghb") %>%
    group_by(park_area_id, encounter_datetime) %>% 
    summarise(patrons = as.integer(sum(sd_patronscomplied) + sd(sd_patronsnocomply))) %>% 
    drop_na(patrons)

all_violations <- merge(ambassabors,violations,by.x = c("patrons", "park_area_id", "encounter_datetime"), by.y = c("patrons", "park_area_id","encounter_timestamp"), all=TRUE)

all_parks_with_p <- merge(park_poly,all_violations,by="park_area_id", all.x=TRUE)

all_parks_with_p$encounter_datetime <- anytime::anydate(all_parks_with_p$encounter_datetime)



# Define server logic required to draw a histogram
shinyServer(function(input, output) {
    
    #Restaurants ---------------------------------------------------------------------------------------------
    #Get dataset to use map
    
    ny_restaurant_map2 <- ny_restaurant_map %>% 
      drop_na_(vars = c("latitude", "longitude")) %>% 
      mutate(seating_interest_sidewalk =  recode(seating_interest_sidewalk,
                                                 "both" = "both sidewalk and roadway",
                                                 "openstreets" = "no seating")) %>%
      mutate(total_dining_area = replace_na(sidewalk_dimensions_area, 0) + 
               replace_na(roadway_dimensions_area, 0) ) %>%
      pivot_longer(cols = ends_with("area"), names_to = "category",
                   values_to = "area") %>%
      drop_na_("area") 
    
    ny_restaurant_map2 <- left_join(ny_restaurant_map2, covid_res, c('zip' = 'modzcta'))
    ny_restaurant_map2$people_positive[is.na(ny_restaurant_map2$people_positive)] <- "Unknown"
    
    
    ny_restaurant_table <- ny_restaurant_map %>% 
      mutate(seating_interest_sidewalk =  recode(seating_interest_sidewalk,
                                                 "both" = "both sidewalk and roadway",
                                                 "openstreets" = "no seating")) %>%
      mutate(total_dining_area = replace_na(sidewalk_dimensions_area, 0) + 
               replace_na(roadway_dimensions_area, 0))  %>% 
      select(restaurant_name, business_address, borough, 
             qualify_alcohol, seating_interest_sidewalk, healthcompliance_terms,
             sidewalk_dimensions_area, roadway_dimensions_area, total_dining_area) %>%
      rename(Name = restaurant_name, Address = business_address, Borough = borough,
             "Type of Seating" = seating_interest_sidewalk, Alcohol = qualify_alcohol,
             "Health Compliance" = healthcompliance_terms, "Sidewalk Dining Area" = sidewalk_dimensions_area,
             "Roadway Dining Area" = roadway_dimensions_area, "Total Dining Area" = total_dining_area)

    
    bins <- c(0, 200, 400, 600, 1000, 2000, 4000, 8000, 20000, 60000)
    pal <- colorBin(c("red", "orange", "yellow", "green", "blue", 
                      "purple", "violet", "brown", "gray", "black"),
                    domain = NULL, bins = bins)
    
    #Allow dataset to be manipulated by the shiny app ui
    shiny_restaurants <- reactive(ny_restaurant_map2[
        which(ny_restaurant_map2$category %in% input$Category &
                  ny_restaurant_map2$borough %in% input$Borough &
                  ny_restaurant_map2$qualify_alcohol %in% input$Alcohol),])
    
    
    #output the map in the server
    output$foodmap <- renderLeaflet({
        leaflet() %>%
            addProviderTiles(providers$CartoDB.Positron)%>%
            addCircles(lng = shiny_restaurants()$longitude,
                       lat = shiny_restaurants()$latitude, 
                       label = sprintf(
                   "<strong>%s</strong><br/>%g recent positive cases in zip code<br/>%s<br/>%g sq.ft. of dining<br/>%s %g",
                   shiny_restaurants()$restaurant_name,  shiny_restaurants()$people_positive, shiny_restaurants()$seating_interest_sidewalk,
                   shiny_restaurants()$area, shiny_restaurants()$business_address,  shiny_restaurants()$zip) %>% 
                   lapply(htmltools::HTML),
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
  
    output$restaurant_table <- renderDataTable(ny_restaurant_table)
    
    
    #parks --------------------------------------------------------------------------------------------------------------
    filteredData <- reactive(all_parks_with_p %>%
                                 filter(park_borough %in% input$borough) %>% 
                                 filter(encounter_datetime < Sys.Date() | is.na(encounter_datetime)))
    
    binspark <- c(0, 10, 25, 50, 100, 200, 400, 800, Inf)
    palpark <- colorBin("YlOrRd", domain = all_parks_with_p$patrons, bins = binspark)
    
    # Create the map
    output$parkmap <- renderLeaflet({
        leaflet(filteredData()) %>%
            addProviderTiles(providers$CartoDB.Positron) %>%
            addPolygons(label = ~park_area_desc,
                        fillColor = ~palpark(patrons),
                        weight = .5,
                        opacity = 5,
                        color = "white",
                        dashArray = "3",
                        fillOpacity = 0.7,
                        layerId = ~park_area_desc) %>%
            addLegend("bottomright", pal = palpark, values = ~patrons,
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
    select(MODIFIED_ZCTA, COVID_CASE_COUNT, PERCENT_POSITIVE)
  data4 <- read_csv("data/antibody-by-modzcta.csv") %>%
    select(modzcta_first, PERCENT_POSITIVE, NUM_PEOP_POS)
  #data1 <- subset(data1, 10000<MODZCTA & MODZCTA<11698)
  covid <- left_join(data1, data2, c('MODZCTA' = 'modzcta'))
  covid <- left_join(covid, data3, c('MODZCTA' = 'MODIFIED_ZCTA'))
  covid <- left_join(covid, data4, c('MODZCTA' = 'modzcta_first')) %>%
    drop_na_("people_positive")  %>%
    sf::st_as_sf(wkt = "the_geom")
    
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
            addProviderTiles(providers$CartoDB.Positron)%>%
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
            addProviderTiles(providers$CartoDB.Positron)%>%
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
            addProviderTiles(providers$CartoDB.Positron)%>%
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
