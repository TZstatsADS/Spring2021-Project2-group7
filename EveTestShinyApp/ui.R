#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)


# Choices for drop-downs
vars <- c(
  "number of violations" = "violations",
  "Community Board" = "community",
  "Borough" = "borough"
)


fillPage(
  tags$style(type = "text/css", "html, body {width:100%; height:100%}"),
  leafletOutput("mymap", width = "100%", height = "100%"),
  absolutePanel(fixed = TRUE, class = "panel panel-default", draggable = TRUE, top = 10, left = "auto", 
                right = 10, bottom = "auto", width = 330, height = "auto",
                # sliderInput("range", "Date of Social Distancing Violation", 
                #             min(violations$encounter_timestamp), max(violations$encounter_timestamp),
                #             value = range(violations$encounter_timestamp)
                # ),
                span(tags$i(h4("Select Parks by Borough"))),
                checkboxGroupInput("Borough", "Which boroughs are you interested in?",
                                   choices = c("Manhattan", "Brooklyn", "Bronx",
                                               "Queens", "Staten Island"),
                                   selected = c("Manhattan", "Brooklyn", "Bronx",
                                                "Queens", "Staten Island"))
   )
)