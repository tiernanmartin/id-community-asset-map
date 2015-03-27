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

###############################################################
### B) Read in data and transform it into database format ##
###############################################################

# Data used to create this shapefile attribute table is
# hosted at https://github.com/tiernanmartin/id-community-asset-map/tree/master/data

setwd("/Users/tiernanmartin/Documents/GitHub/id-community-asset-map//data") # Set the working directory

list.files(path = ".") #Check out the names of the files

commbldg.df <- read.csv(file = "EXTR_CommBldg.csv", header = TRUE, sep = ",") # Bring in the .csv's as data frames
resbldg.df <- read.csv(file = "EXTR_ResBldg.csv", header = TRUE, sep = ",")
aptbldg.df <- read.csv(file = "EXTR_AptComplex.csv", header = TRUE, sep = ",")
bldgpermits.df <- read.csv(file = "Building_Permits___2014-08-27.csv", header = TRUE, sep = ",")

##################################################################
### C) Trim dataframes to only 98104, 98134, and 98144 records ###
##################################################################

commbldg.df <- filter(commbldg.df, ZipCode == "98104" |
                        ZipCode == "98134" |
                        ZipCode == "98144")

resbldg.df <- filter(resbldg.df, ZipCode == "98104" |
                        ZipCode == "98134" |
                        ZipCode == "98144")

aptbldg.df <- aptbldg.df[grepl("98104$|98134$|98144$", aptbldg.df$Address), ] #Uses regex to filter by zip code because the zip code is embedded in the full address


###############################################################################
### D) Geocode the addresses then trim dataframes by Latitude and Longitude ###
###############################################################################

latupper <- 47.601171   # Sets variables for the latitude and longitude boundary 
latlower <- 47.593863
longwest <- -122.328946
longeast <- -122.310483

aptbldg.df$Address <- as.character(aptbldg.df$Address) # Change Address column from factor to character

#NOTE:  the following process takes about 10 minutes. Remove the '#' in order to run it.
#aptbldg_geocoded.df <- geocode(aptbldg.df$Address, output = "latlona") #Geocode the addresses (uses Google Maps API)

aptbldg.df <-      # Create a new dataframe with Lat., Long., and any other desired columns
  aptbldg.df %>%
   mutate(Address = aptbldg_geocoded.df$address,  # Add geocoded Address, Long., Lat.
         Longitude = aptbldg_geocoded.df$lon,
         Latitude = aptbldg_geocoded.df$lat) %>%
   select(Major,                                  # Select desired columns
         Minor,
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

commbldg.df$Address <- as.character (commbldg.df$Address)
#commbldg_geocoded.df <- geocode(commbldg.df$Address, output = "latlona")

commbldg.df <-
    commbldg.df %>%
    mutate(Address = commbldg_geocoded.df$address,
           Longitude = commbldg_geocoded.df$lon,
           Latitude = commbldg_geocoded.df$lat) %>%
    select(Major,
           Minor,
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


bldgpermits.df <- filter(bldgpermits.df,               
                         Latitude <= latupper &
                           Latitude >= latlower &
                           Longitude >= longwest &
                           Longitude <= longeast)



