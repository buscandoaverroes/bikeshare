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

# store number of rows 
n_rides <- nrow(bks)

# make names object 
names_bks <- 
   as_tibble(names(bks)) %>%
   gather()

# make string of variable names 
vars_bks1 <- names(bks)             # raw varnames 


vars_bks2 <- c(                     # variables variable generation
   
   "id_ride", 
   "start_number", "end_number",  
   "leave", "dur", 
   "year", "month", "wday", "hour",
   "electric", "member"   
)

vars_bks3 <- c(                     # variables after merge with project id
   "id_ride", 
   "leave", "dur", 
   "year", "month", "wday", "hour",
   "electric", "member", 
   "id_start", "id_end"
)




# export a subset with only id_ride and bike number so we can get ride of bike number ---------- 
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



    
                           #---------------------#
                           #   New Variables      ====================================
                           #---------------------#


# create duration, year, month, day, etc
bks <-
   bks %>%
   mutate( # generate components of duration
      leave  = ymd_hms(start_date, tz = "US/Eastern"),
      arrive = ymd_hms(end_date, tz = "US/Eastern")
   ) %>%
   select(-start_date, -end_date) %>% # remove start and end cols
   mutate( # create duration in rounded minutes\
      dur   = if_else(is.na(duration),
                      true = as.integer(round(leave %--% arrive)),
                      false = as.integer(round(duration))), 
      year  = as.integer(year(leave)),
      month = month(leave, label = FALSE), # leave as numeric
      wday  = as.integer(wday(leave, label = FALSE, week_start=getOption('lubridate.week.start',7))), # numeric, start sunday
      hour  = as.integer(hour(leave))
   ) %>%   
   select(-duration, -start_lat, -start_lng, -end_lat, -end_lng) # remove unneeded vars


# Change factor levels to member/guest binary
bks <-
   bks %>%
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
   select(vars_bks2) # remove string member variable


                              
                              #---------------------#
                              # Join with Station_Key   ====================================
                              #---------------------#
# the goal is to a) identify each ride's origin and destination station by the project id for stations
# (idproj) and also b) to reduce the size of the dataset by eliminating the name columns of the origin
# and destination stations (as these can be remapped with the project id and key). We have to merge 
# four times since there are two different station numbering schemas and both start and end stations



# load station key
station_key <- readRDS(file.path(processed, "keys/station_key.Rda")) %>%
   st_drop_geometry() # drop geometry, don't need, only merging by id number.


# joins --------------------------------------------------------------

bks <-
   bks %>%
   # join 1: OLD.start: start_number <<< number_old
   left_join(., station_key,
             by = c("start_number" = "number_old"),
             na_matches = "never") %>%
   select(vars_bks2, id_proj) %>%  
   rename(id_start = id_proj) %>%
   # join 2: OLD.end: end_number <<< number_old
   left_join(., station_key,
          by = c("end_number" = "number_old"),
          na_matches = "never") %>%
   select(vars_bks2, id_start, id_proj) %>%
   rename(id_end = id_proj) %>%
   select(vars_bks3)


# check that the number of rows didn't change.
assertthat::assert_that(
   n_rides == nrow(bks) # where n_rides is the original number of rows
)

# export as csv 
fwrite(bks, 
       file = file.path(processed, "data/bks-full.csv"),
       na = "", # make missings ""
       compress = "none" # do not compress
)

# save as Rda
saveRDS(bks,
        file = file.path(processed, "data/bks-full.Rda"), compress = FALSE)
