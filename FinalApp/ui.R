#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
library(shinythemes)
library(leaflet)

# Define UI for application that draws a histogram
shinyUI(
  
    navbarPage(theme = shinytheme("journal"),
               position = "static-top",
               
               "Get Outside NYC",
               
               navbarMenu("About",  
                        tabPanel(style = "overflow-y:scroll; max-height:90vh",
                                 "Outdoor Activites",
                            
                                 tags$head(
                                   # Include our custom CSS
                                   includeCSS("style.css")
                                 ),
                                 
                            img(src="/cover.png", width="80%"),
                                     
                            div(class = "introtxt", 
                            
                                  h1("Safe Outdoor Activites during COVID-19"),
                                        p("COVID-19 has added massive limitations to new yorkers' social lives. The museums, bars, clubs, festivals, concerts and other crowded spaces that used to occupy weeknights and weekends are now closed or only open in limited capacities. Yet, at the same time social lives and activities are more important than ever. Whether its zoom fatigue, depression and anxiety from isolation, or a need to exercise, our health is intrinsically tied to what activities we do—making it critical to find COVID-safe ways to fill our free time."),

                                        p("So what to do with all that free time?  Believe it or not there are still things to do that are safe and accessible. One of the biggest categories of these activities is outdoor activity, which pose a lower risk of spread of the COVID-19 virus than indoor activities do."),

                                        strong("With this app you can explore the availability of three options for outdoor activities in New York and compare that with COVID-19 data, to make educated and safe choices for socializing during COVID-19. Check out different tabs to explore each option in an interactive map  or database, or keep reading to better understand why outdoor activities are so important and what types of activities you can do."),
                                    
                                    h2("Why should I choose outdoor activities?"),
                                         p("The COVID-19 virus spreads through droplets that are released into the air from our bodies when we talk, laugh,  cough, breath, etc. These droplets, and the virus spread the fastest when people are in close contact (within about 6 feet) of each other. In enclosed spaces people tend to be closer together, and there tends to be poor ventilation, which means that the COVID-19 virus can get trapped in the air and spread quickly." ),
                                         
                                         p("However, When you're outside, fresh air is constantly moving, dispersing droplets that might contain COVID-19, making you less likely become infected. Especially if you wear a mask, and  maintain distance from others while outside, it's much more difficult to become infected. Other than avoiding infection, being outside also offers other benefits, like making you feel less tense, stressed, angry or depressed (and sunlight can give your body vitamin D!)." ),
                                 
                                    
                                    h2("What outdoor options do I have in NYC?"),
                                         p("There are three reliable types places you can go and gather in outside in New York City"),
                                    
                                    h3("Outdoor Dining"),
                                        p("Lack of proper ventilation and clean air can make indoor dining especially risky in the age of COVID-19. Outdoor dining is a much safer alternative that allows people to enjoy a dine-in experience similar to pre-pandemic times."),
                                        
                                        p(strong("Planning Ahead."), "Be sure to check if the restaurant you want to eat at has outdoor dining and has availible tables"),
                                        
                                        p(strong("Common Courtesy."), "When inside the restaurant making your order, be sure to wear a mask."),
                                
                                    h3("Open Streets"),
                                        p("@chuyun"),
                                 
                                    h3("Parks"), 
                                         p("Parks can be a great place for a variety of activities, to name a few:" ),
                                         
                                         p(strong("Get some exercise."), "Going for a walk or run is a super low-risk activity and is a great way to stay active rather than going to gyms or other indoor fitness activities. Many parks also have amenities like basketball courts, playgrounds, and baseball fields if your craving a particular activity"),
                                         
                                         p(strong("Have a Picnic Grab."), "some food from home or take out from you favorite restaurant, and eat on the grass or snow. This is a super low-risk activity and an opportunity to stay social." ),
                                         
                                         p(strong("Meet up with friends outside your bubble."), "Parks provide a lot a space, which makes it ideal for a socially distanced chat. ")
                                 
                                )
                            ),
                        tabPanel(style = "overflow-y:scroll; max-height:90vh",
                                 "Data and Sources", 
                                          tags$head(
                                            # Include our custom CSS
                                            includeCSS("style.css")
                                          ),
                            
                             div(class = "introtxt", 
                                 
                                 h1("Data Sources"),
                                 h3("Data Last Updated:"),
                                 h4(Sys.Date()), 
                                 
                                 h2("Restaurants"),
                                 
                                 p("This was created with the Open Restaurant Applications dataset from NYC Open Data, It is a dataset of applications from food service establishments seeking authorization to re-open under Phase Two of the State’s New York Forward Plan, and place outdoor seating in front of their business on the sidewalk and/or roadway."), 
                                 tags$a(href="https://data.cityofnewyork.us/Transportation/Open-Restaurant-Applications/pitm-atqc", "View Dataset Here"), 
                        
                                 h2("Open Streets"), 
                                  
                                 p("This was created with the Open Streets Locations data set available through NYC Open Data. It provides the hours and locations of streets that have been closed to cars so the public can use the roadbed."),
                                 tags$a(href="https://data.cityofnewyork.us/Health/Open-Streets-Locations/uiay-nctu", "View Dataset Here"), 
                                 
                                 h2("Parks"),
                         
                                 p("This uses three data sets from NYC Open Data, all of which were created as a part of NYC Parks Covid-19 Social Distancing and Enforcement Data Collection. The first, park areas, list NYC parks and their respective polygons. The second, list encounters that park Maintenance and Operations Staff have had with patrons violating social distancing. The third list encounters NYC park ambassadors have had with patrons violating social distancing."),
                                 tags$a(href="https://data.cityofnewyork.us/dataset/Social-Distancing-Park-Areas/4iha-m5jk", "View the Park Areas Dataset Here", tags$br()),
                                 tags$a(href="https://data.cityofnewyork.us/dataset/Social-Distancing-Parks-Crowds-Data/gyrw-gvqc", "View the Maintenance and Operations Staff Encounter Dataset Here", tags$br()),
                                 tags$a(href="https://data.cityofnewyork.us/City-Government/Social-Distancing-Citywide-Ambassador-Data/akzx-fghb", "View the Park Ambassador Encounter Dataset Here", tags$br()),
                                 
                                 h2("COVID-19 Overview"),
                                 
                                 p("This was created with the COVID-19: Data available through NYC Department of Health. It constantly tracks the COVID-19 related data through all boroughs of New York City. This app focuses on the total number of confirmed cases, number of antibody, as well as the number of positive tests during the past seven days"),
                                 tags$a(href = "https://www1.nyc.gov/site/doh/covid/covid-19-data.page", "View Dataset Here"),
                                 
                                 h1("Tutorials Used"),
                                 
                                 h2("Shiny App Tutorials"),
                                 
                                 p("General tutorial for creating shiny apps."),
                                 tags$a(href = "https://chengliangtang.shinyapps.io/shiny_tutorial_2017fall/", "View the General Shiny App Tutorial Here"),
                                 
                                 
                                 p("This tutorial was used to make the directory for the restaurants."),
                                 tags$a(href= "https://shiny.rstudio.com/reference/shiny/latest/tableOutput.html", "View the Table Output Tutorial Here"),
                          
                                 
                                 h2("Leaflet Tutorial"),
                                 p("This tutorial was used to make the maps in leaflet."),
                                 tags$a(href = "https://rstudio.github.io/leaflet/map_widget.html", "View the Leaflet Map Tutorial Here"),
                                 
                                 h2("Background Information"),
                                 
                                 p("This article was used when considering motivation for the restaurant app."),
                                 tags$a(href = "https://www.eater.com/21518621/indoor-dining-restaurants-safety-risks-covid-19-chefs-waiters-servers", "View the Article Here")
                           )
                        )
               ),
               navbarMenu("Resturants",
                          tabPanel("Map",
                                   
                                   tags$head(
                                     # Include our custom CSS
                                     includeCSS("style.css")
                                   ),
                                   
                                   fillPage(
                                       
                                       # Application title
                                       tags$style(type = "text/css", "#foodmap {height: calc(100vh - 100px) !important;}"),
                                       leafletOutput("foodmap"),
                                       #Create master panel with different widgets for specification
                                       absolutePanel(fixed = TRUE, class = "panel panel-default", draggable = TRUE, top = 90, left = "auto", 
                                                     right = 20, bottom = "auto", width = 330, height = "auto",
                                                     
                                                     #Widget that chooses which area of dining to look at
                                                     span(tags$i(h3("Find a Resturant"))),
                                                     span(tags$i(h4("Select Dining Capacity by Type of Seating"))),
                                                     selectInput("Category", 
                                                                 "Which type of seating are you interested in?",
                                                                 choices = c("Sidewalk" = "sidewalk_dimensions_area",
                                                                             "Roadway" = "roadway_dimensions_area",
                                                                             "Total" = "total_dining_area"),
                                                     ),
                                                     
                                                     #Widget that filters restaurants by borough (can select multiple)
                                                     span(tags$i(h4("Select Restaurants by Borough"))),
                                                     helpText("Tip! You much have at least one borough selected"),
                                                     checkboxGroupInput("Borough", "Which boroughs are you interested in?",
                                                                        choices = c("Manhattan", "Brooklyn", "Bronx",
                                                                                    "Queens", "Staten Island"),
                                                                        selected = c("Manhattan", "Brooklyn", "Bronx",
                                                                                     "Queens", "Staten Island")),
                                                     
                                                     #Widget that filters restaurants by alcohol availability
                                                     span(tags$i(h4("Select Restaurants by Alcohol License Status"))),
                                                     checkboxGroupInput("Alcohol", "Can alcohol be served here?",
                                                                        choices = c("yes", "no"),
                                                                        selected = c("yes", "no")
                                                     ), 
                                                     
                                                     helpText("Tip! Drag this panel around to better see the map")
                                       )
                                   )),
                          tabPanel(style = "overflow-y:scroll; max-height:90vh", "Database", fluidPage(titlePanel("NYC Resturants Database (area in sq. ft.)"),
                                                         mainPanel(
                                                           column(1, dataTableOutput("restaurant_table"))))
                         )),
               
               tabPanel("Open Streets", 
                        fillPage( tags$head( tags$style( HTML(".shiny-notification {
                                position:fixed;
                                top: 10vh;
                                left: 10vw;
                                  }"))),
                                  
                                  tags$style(type = "text/css", "#map {height: calc(100vh - 100px) !important;}"),
                                  leafletOutput("map"),
                                  #Create master panel with different widgets for specification
                                  absolutePanel(fixed = TRUE, class = "panel panel-default", draggable = TRUE, top = 90, left = "auto", 
                                                right = 20, bottom = "auto", width = 330, height = "auto",
                                                
                                                
                                                
                                                #Widget that filters open streets by borough (can select multiple)
                                                span(tags$i(h3("Find an Openstreet"))),
                                                span(tags$i(h4("Filter Open Streets by Borough"))),
                                                helpText("Tip! You much have at least one borough selected"),
                                                checkboxGroupInput("boroughst", "Which boroughs are you interested in?",
                                                                   choices = c("Manhattan", "Brooklyn", "Bronx",
                                                                               "Queens", "Staten Island"),
                                                                   selected = c("Manhattan", "Brooklyn", "Bronx",
                                                                                "Queens", "Staten Island")),
                                                
                                                #Widget that filters openstreets by day of week
                                                
                                                selectInput("datetime", "Do you want to fliter by date and time?",
                                                            choices = c("No", "Yes")),
                                                
                                                conditionalPanel("input.datetime == 'Yes'", 
                                                                 
                                                                 selectInput("Day", "What day of the week would you like to vist a Street?",
                                                                             choices = c("Select", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday")
                                                                 ),
                                                                
                                                                 helpText("Tip! Try diffrent times to see diffrent streed avaiblites"),
                                                                 
                                                                 selectInput("Time", "What time would you like to vist a Street?",
                                                                             choices = c("12:00AM",
                                                                                         "1:00AM",
                                                                                         "2:00AM",
                                                                                         "3:00AM",
                                                                                         "4:00AM",
                                                                                         "5:00AM",
                                                                                         "6:00AM",
                                                                                         "7:00AM",
                                                                                         "8:00AM",
                                                                                         "9:00AM",
                                                                                         "10:00AM",
                                                                                         "11:00AM",
                                                                                         "12:00PM",
                                                                                         "1:00PM",
                                                                                         "2:00PM",
                                                                                         "3:00PM",
                                                                                         "4:00PM",
                                                                                         "5:00PM",
                                                                                         "6:00PM",
                                                                                         "7:00PM",
                                                                                         "8:00PM",
                                                                                         "9:00PM",
                                                                                         "10:00PM",
                                                                                         "11:00PM")
                                                                 )
                                                                 
                                                                 
                                                ),
                                                helpText("Tip! Drag this panel around to better see the map")
                                                
                                                
                                                
                                  ))
                        
                        
                        
                        ),
               tabPanel("Parks", 
                        fillPage(
                            tags$style(type = "text/css", "#parkmap {height: calc(100vh - 100px) !important;}"),
                            leafletOutput("parkmap"),
                            
                            absolutePanel(fixed = TRUE, class = "panel panel-default", draggable = TRUE, top = 90, left = "auto", 
                                          right = 20, bottom = "auto", width = 330, height = "auto",
                                          span(tags$i(h3("Find a Park"))),
                                          span(tags$i(h4("Select Parks by Borough"))),
                                          helpText("Tip! at least one borough must be selected"),
                                          checkboxGroupInput("borough", "Which boroughs are you interested in?",
                                                             choices = c("Manhattan", "Brooklyn", "Bronx",
                                                                         "Queens", "Staten Island"),
                                                             selected = c("Manhattan", "Brooklyn", "Bronx",
                                                                          "Queens", "Staten Island")), 
                                          span(tags$i(h4("Click on a Park to See the Number of Patrons violating Social Distancing Over Time"))),
                                          plotOutput("time_reports", height=200),
                                          helpText("Tip! Drag this panel around to better see the map")
                            )
                        )), 
                        
               tabPanel("COVID-19 Overview", 
                                
                                p("Make an educated Descion on where you go in New York. Hover over a zipcode to see COVID-19 data for that area, Explore the diffrent tabs for diffrent statistics."),  

                                tabsetPanel(
                                  
                                    tabPanel("7-Days Positive", 
                                             tags$style(type = "text/css", "#recent_map {height: calc(100vh - 100px) !important;}"),
                                             leafletOutput("recent_map")),
                                    
                                    tabPanel("Total Positive", 
                                             tags$style(type = "text/css", "#total_map {height: calc(100vh - 100px) !important;}"),
                                             leafletOutput("total_map")), 
                                    
                                    tabPanel("Antibody", 
                                             tags$style(type = "text/css", "#antibody_map {height: calc(100vh - 100px) !important;}"),
                                             leafletOutput("antibody_map"))
                                )

               )
               
               
        )
)
