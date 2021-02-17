#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
library(leaflet)
library(haven)
library(devtools)
library(RColorBrewer)
library(RSocrata)


ny_restaurant_map <- read.socrata("https://data.cityofnewyork.us/Transportation/Open-Restaurant-Applications/pitm-atqc")
# Define UI for application that maps out resturants 
ui <- fluidPage(

    # Application title
    titlePanel("Map of NYC Resturants"),

    mainPanel(leafletOutput("map")),
    #Create master panel with different widgets for specification
    absolutePanel(id = "controls", class = "panel panel-default", 
                  fixed = TRUE, draggable = TRUE,
                  top = 80, left = 600, 
                  right = "auto", bottom = "auto", 
                  width = 300, height = "auto",
                  
                  #Widget that chooses which area of dining to look at
                  
                  span(tags$i(h4("Select Dining Capacity by Type of Seating"))),
                  selectInput("Category", 
                              "Which type of seating are you interested in?",
                              choices = c("Sidewalk" = "sidewalk_dimensions_area",
                                          "Roadway" = "roadway_dimensions_area",
                                          "Total" = "total_dining_area"),
                              ),
                              
                  #Widget that filters restaurants by borough (can select multiple)
                  span(tags$i(h4("Select Restaurants by Borough"))),
                  checkboxGroupInput("Borough", "Which boroughs are you interested in?",
                                     choices = c("Manhattan", "Brooklyn", "Bronx",
                                                 "Queens", "Staten Island"),
                                     selected = c("Manhattan", "Brooklyn", "Bronx",
                                                  "Queens", "Staten Island")),
                  
                  #Widget that filters restaurants by alcohol availibility
                  span(tags$i(h4("Select Restaurants by Alcohol License Status"))),
                  checkboxGroupInput("Alcohol", "Can alcohol be served here?",
                              choices = c("yes", "no"),
                              selected = c("yes", "no")
                  )
    )
)


# Define server logic required to draw a map of resturants
server <- function(input, output) {
    
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
    output$map <- renderLeaflet({
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
}

# Run the application 
shinyApp(ui = ui, server = server)
