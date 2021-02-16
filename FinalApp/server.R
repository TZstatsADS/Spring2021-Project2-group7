#
# This is the server logic of a Shiny web application. You can run the
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)

# Define server logic required to draw a histogram
shinyServer(function(input, output) {

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

})
