#######################################################
### GETTING LAT. AND LONG. FOR BUILDING-LEVEL DATA  ###                                    ########
#######################################################


#############################################
### A) Install and load required packages ###
#############################################

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

list.files(path = ".") #Check out the names of the files

commbldg.df <- read.csv(file = "EXTR_CommBldg.csv", header = TRUE, sep = ",") # Bring in the .csv's as data frames
resbldg.df <- read.csv(file = "EXTR_ResBldg.csv", header = TRUE, sep = ",")
aptbldg.df <- read.csv(file = "EXTR_AptComplex.csv", header = TRUE, sep = ",")
bldgpermits.df <- read.csv(file = "Building_Permits___2014-08-27.csv", header = TRUE, sep = ",")

##################################################################
### C) Trim dataframes to only 98104, 98134, and 98144 records ###
##################################################################

aptbldg_trimmed.df <- aptbldg.df[grepl("98104$|98134$|98144$", aptbldg.df$Address), ] #Uses regex to filter by zip code because the zip code is embedded in the full address
write.csv(aptbldg_trimmed.df, "aptbldg_trimmed.csv")

commbldg_trimmed.df <- filter(commbldg.df, ZipCode == "98104" |
                        ZipCode == "98134" |
                        ZipCode == "98144")
write.csv(commbldg_trimmed.df, "commbldg_trimmed.csv")

resbldg_trimmed.df <- filter(resbldg.df, ZipCode == "98104" |
                        ZipCode == "98134" |
                        ZipCode == "98144")
write.csv(resbldg_trimmed.df, "resbldg_trimmed.csv")



################################
### D) Geocode the addresses ###
################################

aptbldg_trimmed.df$Address <- as.character(aptbldg_trimmed.df$Address) # Change Address column from factor to character

aptbldg_geocoded.df <- geocode(aptbldg_trimmed.df$Address, output = "latlona") # Geocode the addresses (uses Google Maps API)

write.csv(aptbldg_geocoded.df, file = "AptBldg_geocoded.csv") # Saves the geocoded output as a .csv


commbldg_trimmed.df$Address <- as.character (commbldg_trimmed.df$Address)

commbldg_geocoded.df <- geocode(commbldg.df$Address, output = "latlona")

write.csv(commbldg_geocoded.df, file = "CommBldg_geocoded.csv")


resbldg_trimmed.df$Address <- as.character(resbldg_trimmed.df$Address) # Change Address column from factor to character

ss_address_example <- read.csv("/Users/tiernanmartin/Documents/GitHub//id-community-asset-map//smarty-streets-example-lists//standard-address-input.csv") #This example shows the required table headers for using the Smarty Streets API

i <- resbldg_trimmed.df$Address

d <- regexpr(".+(?=\\d{5})",i,perl=T) # Regular expression that calls all the characters before the zipcode
d
e <- regmatches(i,d)
e
f <- gsub("\\s+"," ",e) # Changes all whitespace to a single space: " "
f
g <- str_trim(f) # Trims spaces at the beginning or end of the line
g
resbldg_trimmed.df$ss_Address <- g


ss_resbldg.df <-               # Creates a .df that matches the Smarty Streets format
  resbldg_trimmed.df %>%
  mutate(Address = ss_Address,
         City = "Seattle",
         State = "WA",
         ZIP = ZipCode) %>%
  select(Address,
         City,
         State,
         ZIP)

write.csv(ss_resbldg.df,"ss_resbldg.csv")

# Now the data is manual pasted from the .csv file (opened in MS Excel) into the processing box here: https://smartystreets.com/account#list-processor


