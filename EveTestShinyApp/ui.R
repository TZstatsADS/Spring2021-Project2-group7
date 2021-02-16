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


fluidPage(
  leafletOutput("mymap"),
  absolutePanel(top = 10, right = 10,
                sliderInput("range", "Date of Social Distancing Violation", 
                            min(violations$encounter_timestamp), max(violations$encounter_timestamp),
                            value = range(violations$encounter_timestamp)
                ),
                span(tags$i(h4("Select Parks by Borough"))),
                checkboxGroupInput("Borough", "Which boroughs are you interested in?",
                                   choices = c("Manhattan", "Brooklyn", "Bronx",
                                               "Queens", "Staten Island"),
                                   selected = c("Manhattan", "Brooklyn", "Bronx",
                                                "Queens", "Staten Island"))
   )
)