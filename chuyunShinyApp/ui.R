

#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/


library(shiny)
library(leaflet)
library(haven)
library(devtools)
library(RColorBrewer)
library(RSocrata)
library(shinyTime)

open_street <- read.socrata("https://data.cityofnewyork.us/Health/Open-Streets-Locations/uiay-nctu")


shinyUI(fillPage( tags$head( tags$style( HTML(".shiny-notification {
             position:fixed;
             top: 10vh;
             left: 10vw;
             }
             "))),
  
  leafletOutput("map"),
  #Create master panel with different widgets for specification
  absolutePanel(id = "controls", class = "panel panel-default", 
                fixed = TRUE, draggable = TRUE,
                top = 80, left = 600, 
                right = "auto", bottom = "auto", 
                width = 300, height = "auto",
                
                
                
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
                                 
                                 selectInput("Time", "What day of the week would you like to vist a Street?",
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
                                 
                        
                )
                
                
                
  ))

)
