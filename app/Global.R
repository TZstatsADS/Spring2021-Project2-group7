
#packages.used=as.list(
#  c(
#    "shiny",
#    "leaflet",
#    "RSocrata",
#    "tidyverse",
#    "haven",
#    "devtools",
#    "RColorBrewer",
#    "reader")
#)
#check.pkg = function(x){
#  if(!require(x, character.only=T)) install.packages(x, 
#                                                     character.only=T,
#                                                     dependence=T)
#}
#lapply(packages.used, check.pkg)

if (!require("shiny")) {
  install.packages("shiny",dependence=T, repos = 'http://cran.rstudio.com/')
  library(shiny)
}
if (!require("leaflet")) {
  install.packages("leaflet",dependence=T, repos = 'http://cran.rstudio.com/')
  library(leaflet)
}
if (!require("RSocrata")) {
  install.packages("RSocrata",dependence=T, repos = 'http://cran.rstudio.com/')
  library(RSocrata)
}
if (!require("tidyverse")) {
  install.packages("tidyverse",dependence=T, repos = 'http://cran.rstudio.com/')
  library(tidyverse)
}
if (!require("haven")) {
  install.packages("haven",dependence=T, repos = 'http://cran.rstudio.com/')
  library(haven)
}
if (!require("devtools")) {
  install.packages("devtools",dependence=T, repos = 'http://cran.rstudio.com/')
  library(devtools)
}
if (!require("RColorBrewer")) {
  install.packages("RColorBrewer",dependence=T, repos = 'http://cran.rstudio.com/')
  library(RColorBrewer)
}
if (!require("reader")) {
  install.packages("reader",dependence=T, repos = 'http://cran.rstudio.com/')
  library(reader)
}


#resturant Data 
ny_restaurant_map <- read.socrata("https://data.cityofnewyork.us/Transportation/Open-Restaurant-Applications/pitm-atqc")
covid_res <- read_csv("https://raw.githubusercontent.com/nychealth/coronavirus-data/master/latest/last7days-by-modzcta.csv") %>%
  select(modzcta, people_positive) 

#Get dataset to use map

ny_restaurant_map2 <- ny_restaurant_map %>% 
  drop_na_(vars = c("latitude", "longitude")) %>% 
  mutate(seating_interest_sidewalk =  recode(seating_interest_sidewalk,
                                             "both" = "both sidewalk and roadway",
                                             "openstreets" = "no seating")) %>%
  mutate(total_dining_area = replace_na(sidewalk_dimensions_area, 0) + 
           replace_na(roadway_dimensions_area, 0) ) %>%
  pivot_longer(cols = ends_with("area"), names_to = "category",
               values_to = "area") %>%
  drop_na("area") 

ny_restaurant_map2 <- left_join(ny_restaurant_map2, covid_res, c('zip' = 'modzcta'))
ny_restaurant_map2$people_positive[is.na(ny_restaurant_map2$people_positive)] <- "Unknown"

#Get dataset for the database

ny_restaurant_table <- ny_restaurant_map %>% 
  mutate(seating_interest_sidewalk =  recode(seating_interest_sidewalk,
                                             "both" = "both sidewalk and roadway",
                                             "openstreets" = "no seating")) %>%
  mutate(total_dining_area = replace_na(sidewalk_dimensions_area, 0) + 
           replace_na(roadway_dimensions_area, 0))  %>% 
  select(restaurant_name, business_address, borough, 
         qualify_alcohol, seating_interest_sidewalk, healthcompliance_terms,
         sidewalk_dimensions_area, roadway_dimensions_area, total_dining_area) %>%
  rename(Name = restaurant_name, Address = business_address, Borough = borough,
         "Type of Seating" = seating_interest_sidewalk, Alcohol = qualify_alcohol,
         "Health Compliance" = healthcompliance_terms, "Sidewalk Dining Area" = sidewalk_dimensions_area,
         "Roadway Dining Area" = roadway_dimensions_area, "Total Dining Area" = total_dining_area)

#Define bins for colors on map

bins <- c(0, 200, 400, 600, 1000, 2000, 4000, 8000, 30000)
pal <- colorBin(c("red", "orange", "yellow", "green", "blue", 
                  "purple", "violet", "brown", "black"),
                domain = NULL, bins = bins)


#park data + Cleaning
park_poly <- read.socrata("https://data.cityofnewyork.us/dataset/Social-Distancing-Park-Areas/4iha-m5jk")

park_poly <- sf::st_as_sf( park_poly, wkt = "multipolygon")

violations <-  read.socrata("https://data.cityofnewyork.us/dataset/Social-Distancing-Parks-Crowds-Data/gyrw-gvqc") %>%
  group_by(park_area_id, encounter_timestamp) %>% 
  summarise(patrons = sum(patroncount))

ambassabors <- read.socrata("https://data.cityofnewyork.us/City-Government/Social-Distancing-Citywide-Ambassador-Data/akzx-fghb") %>%
  group_by(park_area_id, encounter_datetime) %>% 
  summarise(patrons = as.integer(sum(sd_patronscomplied) + sd(sd_patronsnocomply))) %>% 
  drop_na(patrons)

all_violations <- merge(ambassabors,violations,by.x = c("patrons", "park_area_id", "encounter_datetime"), by.y = c("patrons", "park_area_id","encounter_timestamp"), all=TRUE)

all_parks_with_p <- merge(park_poly,all_violations,by="park_area_id", all.x=TRUE)

all_parks_with_p$encounter_datetime <- anytime::anydate(all_parks_with_p$encounter_datetime)


#Get bins for parks

binspark <- c(0, 10, 25, 50, 100, 200, 400, 800, Inf)
palpark <- colorBin("YlOrRd", domain = all_parks_with_p$patrons, bins = binspark)



#OpenStreet Data
open_street <- read.socrata("https://data.cityofnewyork.us/Health/Open-Streets-Locations/uiay-nctu")

open_street <- sf::st_as_sf(open_street, wkt = "the_geom")

#Covid Overview

data1 <- read_csv("data/Modified_Zip_Code_Tabulation_Areas__MODZCTA_.csv") %>%
  select(MODZCTA, the_geom)

data2 <- read_csv("https://raw.githubusercontent.com/nychealth/coronavirus-data/master/latest/last7days-by-modzcta.csv") %>%
  select(modzcta, percentpositivity_7day, people_positive)

data3 <- read_csv("https://raw.githubusercontent.com/nychealth/coronavirus-data/master/totals/data-by-modzcta.csv") %>%
  select(MODIFIED_ZCTA, COVID_CASE_COUNT, PERCENT_POSITIVE)

data4 <- read_csv("https://raw.githubusercontent.com/nychealth/coronavirus-data/master/totals/antibody-by-modzcta.csv") %>%
  select(modzcta_first, PERCENT_POSITIVE, NUM_PEOP_POS)

#data1 <- subset(data1, 10000<MODZCTA & MODZCTA<11698)
covid <- left_join(data1, data2, c('MODZCTA' = 'modzcta'))
covid <- left_join(covid, data3, c('MODZCTA' = 'MODIFIED_ZCTA'))
covid <- left_join(covid, data4, c('MODZCTA' = 'modzcta_first')) %>%
  drop_na_("people_positive")  %>%
  sf::st_as_sf(wkt = "the_geom")


# Define bins, colors, and labels for Covid Data
bins_7 <- c(0, 10, 20, 50, 100, 150, 200, 250, 300, Inf)
bins_t <- c(0, 1000, 2000, 3000, 4000, 5000, 6000, 7000, 8000, Inf)
bins_a <- c(0, 2000, 4000, 6000, 8000, 10000, 12000, 14000, 16000, 18000, Inf)
pal_7 <- colorBin("YlOrRd", domain = covid$people_positive, bins = bins_7)
pal_t <- colorBin("YlOrRd", domain = covid$COVID_CASE_COUNT, bins = bins_t)
pal_a <- colorBin("YlOrRd", domain = covid$NUM_PEOP_POS, bins = bins_a)
label_7 <- sprintf(
  "Zip: <strong>%s</strong><br/>%g people tested positive",
  covid$MODZCTA, covid$people_positive
) %>% lapply(htmltools::HTML)
label_t <- sprintf(
  "Zip: <strong>%s</strong><br/>%g people tested positive",
  covid$MODZCTA, covid$COVID_CASE_COUNT
) %>% lapply(htmltools::HTML)
label_a <- sprintf(
  "Zip: <strong>%s</strong><br/>%g people tested positive",
  covid$MODZCTA, covid$NUM_PEOP_POS
) %>% lapply(htmltools::HTML)
