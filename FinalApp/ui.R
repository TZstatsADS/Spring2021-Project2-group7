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

# Define UI for application that draws a histogram
shinyUI(
    navbarPage(theme = shinytheme("journal"), "Get Outside NYC",
               
               tags$head(
                 # Include our custom CSS
                 includeCSS("style.css"),
               ),
               navbarMenu("About", 
                        tabPanel("Outdoor Activites",
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
                                        p("@peter"),
                                    
                                    h3("Open Streets"),
                                        p("@chuyun"),
                                 
                                    h3("Parks"), 
                                         p("Parks can be a great place for a variety of activities, to name a few:" ),
                                         
                                         p(strong("Get some exercise."), "Going for a walk or run is a super low-risk activity and is a great way to stay active rather than going to gyms or other indoor fitness activities. Many parks also have amenities like basketball courts, playgrounds, and baseball fields if your craving a particular activity"),
                                         
                                         p(strong("Have a Picnic Grab."), "some food from home or take out from you favorite restaurant, and eat on the grass or snow. This is a super low-risk activity and an opportunity to stay social." ),
                                         
                                         p(strong("Meet up with friends outside your bubble."), "Parks provide a lot a space, which makes it ideal for a socially distanced chat. ")
                                 
                                ),
                        tabPanel("Data and Sources")
                            
                        ),
               
               navbarMenu("Resturants",
                          tabPanel("Map", 
                                   fluidPage(
                                       
                                       # Application title
                                       titlePanel("Map of NYC Resturants"),
                                       
                                       mainPanel(leafletOutput("foodmap", width="100%", height="100%")),
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
                                   )),
                          tabPanel("Database")),
               tabPanel("Open Streets"),
               tabPanel("Parks", 
                        fillPage(
                            #leaflet not generation for some reason
                            leafletOutput("parkmap", width="100%", height="100%"),
                            absolutePanel(fixed = TRUE, class = "panel panel-default", draggable = TRUE, top = 50, left = "auto", 
                                          right = 10, bottom = "auto", width = 330, height = "auto",
                                          span(tags$i(h4("Select Parks by Borough"))),
                                          checkboxGroupInput("borough", "Which boroughs are you interested in?",
                                                             choices = c("Manhattan", "Brooklyn", "Bronx",
                                                                         "Queens", "Staten Island"),
                                                             selected = c("Manhattan", "Brooklyn", "Bronx",
                                                                          "Queens", "Staten Island")), 
                                          span(tags$i(h4("Click on a Park to See the Amount Of Social Distacing Patrons Over Time"))),
                                          plotOutput("time_reports", height=200)
                            )
                        )), 
                        
               tabPanel("COVID-19 Overview", 
                        fluidPage(
                            titlePanel("Map of NYC COVID-19 Data"),
                            
                            
                            mainPanel(
                                tabsetPanel(
                                    tabPanel("7-Days Positive", leafletOutput("recent_map")), 
                                    tabPanel("Total Positive", leafletOutput("total_map")), 
                                    tabPanel("Antibody", leafletOutput("antibody_map"))
                                )
                            )   
                        
                        )
               )
               
               
        )
    )
