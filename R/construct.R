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
vars_bks1 <- names(bks)             # raw varnames 
vars_bks2 <- c(
   "duration",     "bike",         "member",       "start_date",  
   "end_date",     "type",        
   "idride",      "id_start",      "id_end" , 
   "start_lat",    "start_lng",    "end_lat",      "end_lng"    
       
)
 

# make subsample for easy processing
# note: here I don't set the seed because I actually want a difference each time.
sample <- bks %>%
   mutate(r = runif(nrow(.)) ) %>% # make random variable
   arrange(r) %>%
   filter(row_number() <= 1000) %>% # keep only first 1000 rows
   select(-r) %>% # eliminate random variable
   mutate(id_ride = row_number()) # generate rideid
   
   
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
   select(vars_bks1, idride, idproj)  %>%
   rename(id_start_old = idproj) %>%
   # join 2: OLD.end: end_number <<< number_old
   left_join(., station_key,
          by = c("end_number" = "number_old"),
          na_matches = "never") %>%
   select(vars_bks1, idride, idproj, id_start_old) %>%
   rename(id_end_old = idproj) %>%
   # join 3: NEW.start: start_number <<< number_new
   left_join(., station_key,
          by = c("start_number" = "number_new"),
          na_matches = "never") %>%
   select(vars_bks1, idride, idproj, id_start_old, id_end_old) %>%
   rename(id_start_new = idproj) %>%
   # join 4: NEW.end: end_number <<< number_new
   left_join(., station_key,
          by = c("end_number" = "number_new"),
          na_matches = "never") %>%
   select(vars_bks1, idride, idproj, id_start_old, id_end_old, id_start_new) %>%
   rename(id_end_new = idproj) %>%    # assert that there's only 1 id for between id %%?
   mutate(
      id_start = coalesce(id_start_old, id_start_new),
      id_end   = coalesce(id_end_old, id_end_new)
   ) %>% 
   rowwise() %>% # work rowwise
   mutate( # create a var that sums nonmissing values for start and end number
      n_id_start = sum(!is.na(id_start_new)) + sum(!is.na(id_start_old)),
      n_id_end = sum(!is.na(id_end_new)) + sum(!is.na(id_end_old))
   ) %>%
   select(vars_bks2)

# check that there is only 1 unique value per pair of old-new start and old-new end values


#test %>% get_dupes(idride) %>% view() # idproj nos 26 and 33 have different names but same oldstation no. compbine?
# 4 duplicates



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


