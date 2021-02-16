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


navbarPage("Parks", id="nav",
           
           tabPanel("Interactive map",
                    div(class="outer",
                        
                        # If not using custom CSS, set height of leafletOutput to a number instead of percent
                        leafletOutput("map", width="100%", height="100%"),
                        
                        # Shiny versions prior to 0.11 should use class = "modal" instead.
                        absolutePanel(id = "controls", class = "panel panel-default", fixed = TRUE,
                                      draggable = TRUE, top = 60, left = "auto", right = 20, bottom = "auto",
                                      width = 330, height = "auto",
                                      
                                      h2("Park explorer"),
                                      
                                      selectInput("color", "Color", vars),
                                      
                                      plotOutput("violations", height = 200),
                      
                        )
                    )
           )
)