#
# This is the server logic of a Shiny web application. You can run the
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#



# Define server logic required to draw a histogram
shinyServer(function(input, output) {
    
    #Restaurants ---------------------------------------------------------------------------------------------
    #Get dataset to use map
    
    
    
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
                   "<strong>%s</strong><br/>%s recent positive cases in zip code<br/>%s<br/>%g sq.ft. of dining<br/>%s %g",
                   shiny_restaurants()$restaurant_name,  shiny_restaurants()$people_positive, shiny_restaurants()$seating_interest_sidewalk,
                   shiny_restaurants()$area, shiny_restaurants()$business_address,  shiny_restaurants()$zip) %>% 
                   lapply(htmltools::HTML),
                       color = pal(shiny_restaurants()$area)) %>%
            addLegend(title = "Dining Area (in sq. ft.)", position = "topleft",
                      colors = c("red",
                                 "orange", "yellow", 
                                 "green", "blue", 
                                 "purple", 
                                 "brown", "black"), 
                      labels = c("0 to 199", "200 to 399",
                                 "400 to 599", "600 to 999",
                                 "1000 to 1999", "2000 to 3999",
                                 "4000 to 7999", "8000 and up"))
    })
  
    output$restaurant_table <- renderDataTable(ny_restaurant_table)
    
    #Open Streets --------------------------------------------------------------------------------------------
    #Allow dataset to be manipulated by the shiny app ui
    shiny_open_street <- reactive(open_street %>%
                                    {if(input$Day == "Monday") filter(., strptime(monday_start, "%I:%M%p") <= strptime(input$Time, "%I:%M%p") & 
                                                                        strptime(monday_end, "%I:%M%p") > strptime(input$Time, "%I:%M%p")) else . } %>%
                                    {if(input$Day == "Tuesday") filter(., strptime(tuesday_start, "%I:%M%p") <= strptime(input$Time, "%I:%M%p") & 
                                                                         strptime(tuesday_end, "%I:%M%p") > strptime(input$Time, "%I:%M%p")) else . } %>%
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
                                    {if(nrow(.)==0)  showNotification("no streets exist that meet such criteria, try picking another time", type = "error", duration = 7) else . } %>%
                                    
                                    {if(input$datetime == "No") bind_rows(., open_street)  else . } %>%
                                    
                                    filter(borough %in% input$boroughst) 
    )
    
    
    
    #output the map in the server
    output$map <-  renderLeaflet({
      leaflet(data = shiny_open_street()) %>%
        addProviderTiles(providers$CartoDB.Positron) %>%
        addPolygons(label = ~on_street)
      
    })
    
    
    #parks --------------------------------------------------------------------------------------------------------------
    filteredData <- reactive(all_parks_with_p %>%
                                 filter(park_borough %in% input$borough) %>% 
                                 filter(encounter_datetime < Sys.Date() | is.na(encounter_datetime)))
    
    
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
    
    
    output$total_map <- renderLeaflet({
        total_map <- leaflet(data = covid) %>%
            addProviderTiles(providers$CartoDB.Positron)%>%
            addPolygons(fillOpacity = 0.9, weight = 2, opacity = 1, color = 'white', dashArray = '3',
                        fillColor = ~pal_t(PERCENT_POSITIVE), 
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
            addLegend(pal = pal_t, values = ~PERCENT_POSITIVE, opacity = 1.0)
    })
    
    
    output$antibody_map <- renderLeaflet({
        antibody_map <- leaflet(data = covid) %>%
            addProviderTiles(providers$CartoDB.Positron)%>%
            addPolygons(fillOpacity = 0.9, weight = 2, opacity = 1, color = 'white', dashArray = '3',
                        fillColor = ~pal_a(PERCENT_ANTI), 
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
            addLegend(pal = pal_a, values = ~PERCENT_ANTI, opacity = 1.0)
    })

})
