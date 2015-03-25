### Load project's packages, install them if necessary

if (!require("gplots")) {
  install.packages("gplots", dependencies = TRUE)
  library(gplots)
}

if (!require("dplyr")) {
  install.packages("gplots", dependencies = TRUE)
  library(dplyr)
}


### Load the data

URM.df <- read.csv("ID_URM bldg inventory-5.csv")

URM.df <- data.frame(URM.df, stringsAsFactors = FALSE)

### Add variable with 3-digit address

URM.df <-
  URM.df %>%
  mutate(STNUM_short = substr((as.character(ST_NUM)),1,3), 
         ADDRESS_edit = paste(STNUM_short,ST_NAME, sep = ' ')) 

### Check the format of the columns (as required by Smarty Streets)

address_example <- read.csv("example-lists/standard-address-input.csv")

### Create new .csv to paste into Smarty Streets

names(URM.df)

smarty.df <-
  URM.df %>%
  select(Address = ADDRESS_edit, City = CITY, State = STATE) #Select the rows and rename them to match Smarty's reqs


### Load Smarty file

write.csv(smarty.df, file="smarty.csv")


### This will add the data frame to the clipboard

clip <- pipe("pbcopy", "w") 
write.table(smarty.df, file=clip, col.names = TRUE)
close(clip) # ... that didn't work... I had to open the .csv in excel and copy + paste into the browser

rm(clip)

smarty_zips.df <- read.csv("smarty_full.csv")
names(smarty_zips.df)

### Trim down the table and write a new one

names(URM.df)

smarty_trim.df <- 
  smarty_zips.df %>%
  select(ADDRESS_edit = Address, Zipcode = X.zipcode., Latitude = X.latitude., Longitude = X.longitude.)

URM_join <- left_join(URM.df, smarty_trim.df) # joins using the 'ADDRESS_edit' variable

names(URM_join)

write.csv(URM_join, file = "URM_join.csv")


