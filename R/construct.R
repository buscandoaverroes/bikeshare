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

vars_bks2 <- c(                     # variables after merge with project id
   "duration", "member",       "start_date",  
   "end_date",     "type",        
   "id_ride",      "id_start",      "id_end" , 
   "start_lat",    "start_lng",    "end_lat",      "end_lng"    
)


vars_bks3 <- c(                     # variables variable generation
   "id_ride",      "id_start",      "id_end" , 
   "start_lat",    "start_lng",    "end_lat",      "end_lng",
   "leave", "dur", "electric", "member"
)

 

# create ride id

set.seed(47)

bks <- bks %>%
   mutate(r = runif(nrow(.)) ) %>% # make random variable
   arrange(r) %>%
   mutate(id_ride = row_number()) %>%
   select(-r)


# create a subset with only id_ride and bike number so we can get ride of bike nummber 
bks %>%
   select(id_ride, bike) %>%
   fwrite(
       file = file.path(processed, "data/bks-bikenos.csv"),
       na = "", # make missings ""
       compress = "none" # do not compress
      )

# drop bike number col 
bks <- bks %>%
   select(-bike)


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
   select(vars_bks1, id_ride, idproj)  %>%
   rename(id_start_old = idproj) %>%
   # join 2: OLD.end: end_number <<< number_old
   left_join(., station_key,
          by = c("end_number" = "number_old"),
          na_matches = "never") %>%
   select(vars_bks1, id_ride, idproj, id_start_old) %>%
   rename(id_end_old = idproj) %>%
   # join 3: NEW.start: start_number <<< number_new
   left_join(., station_key,
          by = c("start_number" = "number_new"),
          na_matches = "never") %>%
   select(vars_bks1, id_ride, idproj, id_start_old, id_end_old) %>%
   rename(id_start_new = idproj) %>%
   # join 4: NEW.end: end_number <<< number_new
   left_join(., station_key,
          by = c("end_number" = "number_new"),
          na_matches = "never") %>%
   select(vars_bks1, id_ride, idproj, id_start_old, id_end_old, id_start_new) %>%
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







                             #---------------------#
                             #   New Variables      ====================================
                             #---------------------#


# create duration 
test <- 
   test %>%
   mutate( # generate components of duration
      leave  = ymd_hms(start_date, tz = "US/Eastern"),
      arrive = ymd_hms(end_date, tz = "US/Eastern")
   ) %>%
   select(-start_date, -end_date) %>% # remove start and end cols
   mutate( # create duration in rounded minutes
      dur = as.integer(round((leave %--% arrive) / minutes(1)))
   ) 

# 
# 
#    test %>%
#    mutate(
#       leave  = ymd_hms(start_date, tz = "US/Eastern"),
#       arrive = ymd_hms(end_date, tz = "US/Eastern"),
#       interval= leave %--% arrive,
#       dur    = interval / dminutes(1),
#       dur2   = interval / minutes(1),
#       dur_int= interval %/% dminutes(1),
#       dur_round= round(interval / minutes(1)),
#       seconds= interval %/% dseconds(1)
#      # period = as.period(interval)
#    )
#    


# Change factor levels to member/guest binary----
test <-
   test %>%
   rename(member_str = member) %>%
   mutate(
      electric = case_when(
         type == "electric_bike" ~ TRUE,
         type == "docked_bike"   ~ FALSE,
         is.na(type) == TRUE     ~ FALSE
         ),
      member = case_when(
         member_str == "member"  ~ TRUE,
         member_str == "Member"  ~ TRUE,
         member_str == "guest"   ~ FALSE,
         member_str == "Guest"   ~ FALSE,
         member_str == "Casual"  ~ FALSE,
         member_str == "casual"  ~ FALSE
      )
   ) %>% 
   select(vars_bks3) # remove string member variable


object.size(test$duration)
object.size(test$dur)
object.size(test$leave)
object.size(test$electric)
object.size(test$bike)
object.size(test$start_lat)
