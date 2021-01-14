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


# drop bike number col 
bks <- bks %>%
   select(-bike)


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
   "electric", "member"   
)

vars_bks3 <- c(                     # variables after merge with project id
   "id_ride", 
   "leave", "dur",         
   "electric", "member", 
   "id_start", "id_end"
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


# 
# # make subsample for easy processing
# # note: here I don't set the seed because I actually want a difference each time.
# sample <- bks %>%
#    mutate(r = runif(nrow(.)) ) %>% # make random variable
#    arrange(r) %>%
#    filter(row_number() <= 1000) %>% # keep only first 1000 rows
#    select(-r) %>% # eliminate random variable
#    mutate(id_ride = row_number()) # generate rideid
#    
#    
#    saveRDS(sample, file.path(processed, "sample.Rda")) # save as RDA
#   sample <- readRDS(file.path(processed, "sample.Rda"))






                           
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
   mutate( # create duration in rounded minutes
      dur   = as.integer(round((leave %--% arrive) / minutes(1)))
      year  = as.integer(year(leave)),
      month = month(leave, label = FALSE), # leave as numeric
      wday  = as.integer(wday(leave, label = FALSE)), # leave as numeric
      hour  = as.integer(hour(leave))
   )


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
   rename(id_proj = idproj)


# joins --------------------------------------------------------------
# join 1: OLD.start: start_number <<< number_old
bks <-
   bks %>%
   left_join(., station_key,
             by = c("start_number" = "number_old"),
             na_matches = "never") %>%
   select(vars_bks2, id_proj)  %>%
   rename(id_start_old = id_proj) %>%
   # join 2: OLD.end: end_number <<< number_old
   left_join(., station_key,
          by = c("end_number" = "number_old"),
          na_matches = "never") %>%
   select(vars_bks2, id_proj, id_start_old) %>%
   rename(id_end_old = id_proj) %>%
   # join 3: NEW.start: start_number <<< number_new
   left_join(., station_key,
          by = c("start_number" = "number_new"),
          na_matches = "never") %>%
   select(vars_bks2, id_proj, id_start_old, id_end_old) %>%
   rename(id_start_new = id_proj) %>%
   # join 4: NEW.end: end_number <<< number_new
   left_join(., station_key,
          by = c("end_number" = "number_new"),
          na_matches = "never") %>%
   select(vars_bks2, id_proj, id_start_old, id_end_old, id_start_new) %>%
   rename(id_end_new = id_proj) %>%    # assert that there's only 1 id for between id %%?
   mutate(
      id_start = coalesce(id_start_old, id_start_new),
      id_end   = coalesce(id_end_old, id_end_new)
   ) %>% 
   rowwise() %>% # work rowwise
   mutate( # create a var that sums nonmissing values for start and end number
      n_id_start = sum(!is.na(id_start_new)) + sum(!is.na(id_start_old)),
      n_id_end = sum(!is.na(id_end_new)) + sum(!is.na(id_end_old))
   ) %>%
   select(vars_bks3)

# check that there is only 1 unique value per pair of old-new start and old-new end values


# export as csv 
fwrite(bks, 
       file = file.path(processed, "data/bks-full.csv"),
       na = "", # make missings ""
       compress = "none" # do not compress
)

# save as Rda
saveRDS(bks,
        file = file.path(processed, "data/bks-full.Rda"), compress = FALSE)




# test query
bks %>% 
   filter(as.integer(hour(leave)) == 8)

object.size(test$duration)
object.size(test$dur)
object.size(test$leave)
object.size(test$electric)
object.size(test$bike)
object.size(test$start_lat)


# fyi:
# > object.size(bks)
# [1] 6,707,810,384 bytes
# > object.size(bks$start_date)
# [1] 2,245,481,096 bytes
# > object.size(bks$id_ride)
#  [1] 111,056,416 bytes
# > object.size(bks$start_lat)      # not bad, but times 4
#  [1] 222,112,776 bytes
# > object.size(bks$start_number)
#  [1] 111,056,416 bytes
