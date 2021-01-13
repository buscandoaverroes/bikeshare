# -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- #
# Name: construct.R
# Description: Takes raw rdata files and does some magic.
#
# -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- #

library(lubridate)


                            #---------------------#
                            #    load data        =============================
                            #---------------------#

# load csv 
bks <- data.table::fread(
   file.path(raw, "bks-import.csv"),
   header = TRUE,
   na.strings = "" 
)


# make names object 
names_bks <- 
   as_tibble(names(bks)) %>%
   gather()

# make string of variable names 
vars_bks1 <- names(bks)
 

# make subsample for easy processing
# note: here I don't set the seed because I actually want a difference each time.
sample <- bks %>%
   mutate(r = runif(nrow(.)) ) %>% # make random variable
   arrange(r) %>%
   filter(row_number() <= 1000) %>% # keep only first 1000 rows
   select(-r) %>% # eliminate random variable
   mutate(idride = row_number()) # generate rideid
   
   
saveRDS(sample, file.path(processed, "sample.Rda")) # save as RDA



                              
                              #---------------------#
                              # Join with Station_Key   ====================================
                              #---------------------#
# the goal is to a) identify each ride's origin and destination station by the project id for stations
# (idproj) and also b) to reduce the size of the dataset by eliminating the name columns of the origin
# and destination stations (as these can be remapped with the project id and key). We have to merge 
# four times since there are two different station numbering schemas and both start and end stations



# load station key
station_key <- readRDS(file.path(processed, "keys/station_key.Rda"))


# OLD numbering schema joins --------------------------------------------------------------
# join 1: OLD.start: start_number <<< number_old

test <-
   sample %>%
   left_join(., station_key,
             by = c("start_number" = "number_old"),
             na_matches = "never") %>%
   select(vars_bks1, idride, idproj) 

test %>% get_dupes(idride) %>% view() # idproj nos 26 and 33 have different names but same oldstation no. compbine?

# 4 duplicates


# join 2: OLD.end: end_number <<< number_old


# join 1: NEW.start: start_number <<< number_new


# join 1: NEW.end: end_number <<< number_new





                             #---------------------#
                             #   New Variables      ====================================
                             #---------------------#


# create duration for bks2020.2
sample$dur <-lubridate::as.duration(bks2020.2$`End date` - bks2020.2$`Start date`)


# Change factor levels to member/guest binary----




# check factor levels of membership type, bike type
bks2020.2 <- 
 mutate(bks2020.2,
        `Member type` = fct_recode(`Member type`,
                                   "Member" = "member",
                                   "Guest" = "casual"),
        `Bike type` = fct_recode(`Bike type`,
                                 "Electric" = "electric_bike",
                                 "Classic"  = "docked_bike")
        
 )


