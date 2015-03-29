#######################################################
### CREATING THE ASSET MAP BUILDING ATTRIBUTE TABLE ###                                    ########
#######################################################


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

aptbldg_geocoded.df <- read.csv(file = "AptBldg_geocoded.csv", header = TRUE, sep = ",") # Bring in the geocoded .csv's as data frames
commbldg_geocoded.df <- read.csv(file = "CommBldg_geocoded.csv", header = TRUE, sep = ",") 
resbldg_geocoded.df <- read.csv(file = "ss_resbldg_geocoded.csv", header = TRUE, sep = ",")

aptbldg_trimmed.df <- read.csv(file = "aptbldg_trimmed.csv", header = TRUE, sep = ",") #Bring in the trimmed .csv's to be processed
commbldg_trimmed.df <- read.csv(file = "commbldg_trimmed.csv", header = TRUE, sep = ",")
resbldg_trimmed.df <- read.csv(file = "resbldg_trimmed.csv", header = TRUE, sep = ",")


################################################################################
### C) Processes the data frames, adding columns and trimming by lat. & long.###
################################################################################

latupper <- 47.601171   # Sets variables for the (approximate) latitude and longitude boundary 
latlower <- 47.593863
longwest <- -122.328946
longeast <- -122.310483

aptbldg_processed.df <-      # Create a new dataframe with Lat., Long., and any other desired columns
  aptbldg_trimmed.df %>%
   mutate(Address = aptbldg_geocoded.df$address,  # Add geocoded Address, Long., Lat.
         Longitude = aptbldg_geocoded.df$lon,
         Latitude = aptbldg_geocoded.df$lat,
         Type = "Multi-Family Residential") %>%
   select(Major,                                  # Select desired columns
         Minor,
         Type,
         Address,
         Longitude,
         Latitude,
         Description = ComplexDescr,
         Stories = NbrStories,
         NbrBldgs,
         Units = NbrUnits,
         AvgUnitSize,
         Quality = BldgQuality,
         Condition,
         Year = YrBuilt) %>%
   filter(Latitude <= latupper &                  # Filter by Long., Lat.
             Latitude >= latlower &
             Longitude >= longwest &
             Longitude <= longeast) %>%
   arrange(desc(Latitude))                        # Arrange by Lat. (descending)


commbldg_processed.df <-
    commbldg_trimmed.df %>%
    mutate(Address = commbldg_geocoded.df$address,
           Longitude = commbldg_geocoded.df$lon,
           Latitude = commbldg_geocoded.df$lat,
           Type = "Commercial") %>%
    select(Major,
           Minor,
           Type,
           Address,
           Longitude,
           Latitude,
           Description = BldgDescr,
           Stories = NbrStories,
           NbrBldgs,
           Quality = BldgQuality,
           Year = YrBuilt) %>%
   filter(Latitude <= latupper &          
           Latitude >= latlower &
           Longitude >= longwest &
           Longitude <= longeast) %>%
   arrange(desc(Latitude))


resbldg_processed.df <-
  resbldg_trimmed.df %>%
  mutate(ss_Address = paste(resbldg_geocoded.df$X.delivery_line_1.,resbldg_geocoded.df$X.city_name.,resbldg_geocoded.df$X.state_abbreviation.,resbldg_geocoded.df$ZIP, sep = " "),
         Longitude = resbldg_geocoded.df$X.longitude.,
         Latitude = resbldg_geocoded.df$X.latitude.,
         AvgUnitSize = SqFtTotLiving/NbrLivingUnits,
         Type = "Single-Family Residential") %>%
  select(Major,
         Minor,
         Type,
         Address = ss_Address,
         Longitude,
         Latitude,
         Stories,
         Units = NbrLivingUnits,
         AvgUnitSize,
         Condition,
         Year = YrBuilt) %>%
  filter(Latitude <= latupper &
           Latitude >= latlower &
           Longitude >= longwest &
           Longitude <= longeast) %>%
  arrange(desc(AvgUnitSize)) %>%
  distinct(Longitude, Latitude)    # This removes any duplicates (e.g. if a building has two units, only the larger of the two is retained)

