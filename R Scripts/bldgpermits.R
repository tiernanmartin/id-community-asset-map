##########################################################
### NOT COMPLETE!!! Script for processing bldg permits ###                                    ########
##########################################################


#########################################################
### A) Install and load required packages #########
#########################################################

if (!require("gplots")) {
  install.packages("gplots", dependencies = TRUE)
  library(gplots)
}

if (!require("dplyr")) {
  install.packages("gplots", dependencies = TRUE)
  library(dplyr)
}

if (!require("ggmap")) {
  install.packages("ggmap", dependencies = TRUE)
  library(ggmap)
}

if (!require("stringr")) {
  install.packages("stringr", dependencies = TRUE)
  library(stringr)
}


###############################################################
### B) Read in data and transform it into database format ##
###############################################################

# Data used to create this shapefile attribute table is
# hosted at https://github.com/tiernanmartin/id-community-asset-map/tree/master/data

setwd("/Users/tiernanmartin/Documents/GitHub/id-community-asset-map//data") # Set the working directory

bldgpermits.df <- read.csv("Building_Permits___2014-08-27.csv")


################################################################################
### C) Processes the data frames, adding columns and trimming by lat. & long.###
################################################################################

latupper <- 47.601171   # Sets variables for the (approximate) latitude and longitude boundary 
latlower <- 47.593863
longwest <- -122.328946
longeast <- -122.310483

bldgpermits.df <- 
  bldgpermits.df %>%
   filter(Latitude <= latupper &
          Latitude >= latlower &
          Longitude >= longwest &
          Longitude <= longeast &
          Status != "CANCELLED") %>%
   select(Address,
          Permit.Type,
          Action.Type,
          Application.Date,
          Value,
          Category,
          Longitude,
          Latitude) %>%
   arrange(desc(Value))