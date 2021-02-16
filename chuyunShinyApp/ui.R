

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

open_street <- read.socrata("https://data.cityofnewyork.us/Health/Open-Streets-Locations/uiay-nctu")


ui <- fluidPage(
  
  # Application title
  titlePanel("Map of NYC Open Streets"),
  
  mainPanel(leafletOutput("map")),
  #Create master panel with different widgets for specification
  absolutePanel(id = "controls", class = "panel panel-default", 
                fixed = TRUE, draggable = TRUE,
                top = 80, left = 600, 
                right = "auto", bottom = "auto", 
                width = 300, height = "auto",
                
                
                
                #Widget that filters open streets by borough (can select multiple)
                span(tags$i(h4("Select Open Streets by Borough"))),
                checkboxGroupInput("Borough", "Which boroughs are you interested in?",
                                   choices = c("Manhattan", "Brooklyn", "Bronx",
                                               "Queens", "Staten Island"),
                                   selected = c("Manhattan", "Brooklyn", "Bronx",
                                                "Queens", "Staten Island")),
                
                #Widget that filters openstreets by day of week
                span(tags$i(h4("Select Open Streets by Day of Week"))),
                checkboxGroupInput("Day of Week", "What days of the week is this open street becoming public",
                                   choices = c("M,T,W,R,F","TWRFSU", "F,S","S,U","FSU","RFSU","ALL"),
                                   selected = c("M,T,W,R,F","TWRFSU", "F,S","S,U","FSU","RFSU","ALL")
                )
  )
)

