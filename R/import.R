# -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- #
# Name: import.R
# Description: compresses the .dta file into R, hopefully faster.
#
# -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- #


raw_names1 <- c("duration", "bike", "member",
                "start_date", "start_name", "start_number",
                "end_date", "end_name", "end_number")

raw_names2 <- c("member", "type",
                "start_lat", "start_lng", "end_lat", "end_lng",
                "start_date", "start_name", "start_number",
                "end_date", "end_name", "end_number")



# rename old names
raw_rename1 <- c(
  "duration" = "Duration",
  "bike" = "Bike number",
  "member" = "Member type",
  "start_date" = "Start date",
  "start_name" = "Start station",
  "start_number" = "Start station number",
  "end_date" = "End date",
  "end_name" = "End station",
  "end_number" = "End station number"
)

# rename new schema's names 
raw_rename2 <- c(
  "type" = "rideable_type",
  "member" = "member_casual",
  "start_date" = "started_at",
  "start_name" = "start_station_name",
  "start_number" = "start_station_id",
  "end_date" = "ended_at",
  "end_name" = "end_station_name",
  "end_number" = "end_station_id"
)


# create functions for importing ======================================
# note, x will always be a number

# by years 
import_year <- function(x) {
  data.table::fread(
    file.path(raw, x, paste0(x, "-capitalbikeshare-tripdata.csv")),
    na.strings = ""
  ) %>%
    rename(all_of(raw_rename1)) %>%
    select(raw_names1, everything())
}



# by quarter:
  # note: this will import all 4 quarters and append
import_quarter <- function(x) {
  
# Q1
  q1 <- 
    data.table::fread(
    file.path(raw, x, paste0(x, "Q1-capitalbikeshare-tripdata.csv")),
    na.strings = ""
  ) %>%
    rename(all_of(raw_rename1)) %>%
    select(raw_names1, everything())

# Q2
  q2 <- 
    data.table::fread(
      file.path(raw, x, paste0(x, "Q2-capitalbikeshare-tripdata.csv")),
      na.strings = ""
    )  %>%
    rename(all_of(raw_rename1)) %>%
    select(raw_names1, everything())

# Q3
  q3 <- 
    data.table::fread(
      file.path(raw, x, paste0(x, "Q3-capitalbikeshare-tripdata.csv")),
      na.strings = ""
    ) %>%
    rename(all_of(raw_rename1)) %>%
    select(raw_names1, everything())
  
# Q4
  q4 <- 
    data.table::fread(
      file.path(raw, x, paste0(x, "Q4-capitalbikeshare-tripdata.csv")),
      na.strings = ""
    ) %>%
    rename(all_of(raw_rename1)) %>%
    select(raw_names1, everything())
  
# append and return year object
year <- bind_rows(q1, q2, q3, q4)
  
year 
  
}



# by month
  # note: will also return a year object with all months
import_month <- function(x) {

  
  # janurary: file name for 2018 is different
  if (x == 2018) {
    m1 <- 
      data.table::fread(
        file.path(raw, x, paste0(x, "01_capitalbikeshare_tripdata.csv")),
        na.strings = ""
      ) %>%
      rename(all_of(raw_rename1)) %>%
      select(raw_names1, everything())
  }
  else {
    m1 <- 
      data.table::fread(
        file.path(raw, x, paste0(x, "01-capitalbikeshare-tripdata.csv")),
        na.strings = ""
      ) %>%
      rename(all_of(raw_rename1))  %>%
      select(raw_names1, everything())
  }

  
  # feb 
  m2 <- 
    data.table::fread(
      file.path(raw, x, paste0(x, "02-capitalbikeshare-tripdata.csv")),
      na.strings = ""
    ) %>%
    rename(all_of(raw_rename1)) %>%
    select(raw_names1, everything())
  
  # march 
  m3 <- 
    data.table::fread(
      file.path(raw, x, paste0(x, "03-capitalbikeshare-tripdata.csv")),
      na.strings = ""
    ) %>%
    rename(all_of(raw_rename1)) %>%
    select(raw_names1, everything())
  
  # april 
  m4 <- 
    data.table::fread(
      file.path(raw, x, paste0(x, "04-capitalbikeshare-tripdata.csv")),
      na.strings = ""
    )  %>%
    rename(all_of(raw_rename1))  %>%
    select(raw_names1, everything())
  
  # may 
  m5 <- 
    data.table::fread(
      file.path(raw, x, paste0(x, "05-capitalbikeshare-tripdata.csv")),
      na.strings = ""
    )  %>%
    rename(all_of(raw_rename1))  %>%
    select(raw_names1, everything())
  
  # june 
  m6 <- 
    data.table::fread(
      file.path(raw, x, paste0(x, "06-capitalbikeshare-tripdata.csv")),
      na.strings = ""
    )  %>%
    rename(all_of(raw_rename1))  %>%
    select(raw_names1, everything())
  
  # july 
  m7 <- 
    data.table::fread(
      file.path(raw, x, paste0(x, "07-capitalbikeshare-tripdata.csv")),
      na.strings = ""
    )  %>%
    rename(all_of(raw_rename1))  %>%
    select(raw_names1, everything())
  
  # august 
  m8 <- 
    data.table::fread(
      file.path(raw, x, paste0(x, "08-capitalbikeshare-tripdata.csv")),
      na.strings = ""
    )  %>%
    rename(all_of(raw_rename1))  %>%
    select(raw_names1, everything())
  
  # september 
  m9 <- 
    data.table::fread(
      file.path(raw, x, paste0(x, "09-capitalbikeshare-tripdata.csv")),
      na.strings = ""
    ) %>%
    rename(all_of(raw_rename1))  %>%
    select(raw_names1, everything())
  
  # october 
  m10 <- 
    data.table::fread(
      file.path(raw, x, paste0(x, "10-capitalbikeshare-tripdata.csv")),
      na.strings = ""
    )  %>%
    rename(all_of(raw_rename1))  %>%
    select(raw_names1, everything())
  
  # november 
  m11 <- 
    data.table::fread(
      file.path(raw, x, paste0(x, "11-capitalbikeshare-tripdata.csv")),
      na.strings = ""
    )  %>%
    rename(all_of(raw_rename1))  %>%
    select(raw_names1, everything())
  
  # december 
  m12 <- 
    data.table::fread(
      file.path(raw, x, paste0(x, "12-capitalbikeshare-tripdata.csv")),
      na.strings = ""
    ) %>%
    rename(all_of(raw_rename1))  %>%
    select(raw_names1, everything()) 
  
  
  # append + return
  year <- bind_rows(m1, m2, m3, m4,
                    m5, m6, m7, m8,
                    m9, m10,m11,m12)
  
  
  year 
  
}





# import files using functions ===================================
# all of the years 2010 through 2019 have datasets that fit into the 
# patterns expected in the above functions, so we can use these functions
# to import the data
r2010 <- import_year(2010)
r2011 <- import_year(2011)

r2012 <- import_quarter(2012)
r2013 <- import_quarter(2013)
r2014 <- import_quarter(2014)
r2015 <- import_quarter(2015)
r2016 <- import_quarter(2016)
r2017 <- import_quarter(2017)

r2018 <- import_month(2018)
r2019 <- import_month(2019)



# import 2020 manually =================================================
# note: the data structure changes a lot from the 3rd to 4th month of 2020.
# therefore, I think it makes sense to import 2020 manually.

# months 1-3:
m1 <- 
  data.table::fread(
   input = file.path(raw, "2020/202001-capitalbikeshare-tripdata.csv"),
   na.strings = "",
   header = TRUE
  )  %>%
  rename(all_of(raw_rename1))  %>%
  select(raw_names1, everything())

m2 <- 
  data.table::fread(
    file.path(raw,"2020/202002-capitalbikeshare-tripdata.csv"),
    na.strings = "",
    header = TRUE
  )  %>%
  rename(all_of(raw_rename1))  %>%
  select(raw_names1, everything())

m3 <- 
  data.table::fread(
    file.path(raw, "2020/202003-capitalbikeshare-tripdata.csv"),
    na.strings = "",
    header = TRUE
  )  %>%
  rename(all_of(raw_rename1))  %>%
  select(raw_names1, everything())

# append months 1-3
r2020 <- bind_rows(m1, m2, m3)

# remove month objeccts
rm(m1,m2,m3)


# months 4-12
m4 <- 
  data.table::fread(
    file.path(raw, "2020/202004-capitalbikeshare-tripdata.csv"),
    na.strings = "",
    header = TRUE
  ) %>%
  rename(all_of(raw_rename2))  %>%
  select(raw_names2, everything())

m5 <- 
  data.table::fread(
    file.path(raw, "2020/202005-capitalbikeshare-tripdata.csv"),
    na.strings = "",
    header = TRUE
  ) %>%
  rename(all_of(raw_rename2))  %>%
  select(raw_names2, everything())

m6 <- 
  data.table::fread(
    file.path(raw, "2020/202006-capitalbikeshare-tripdata.csv"),
    na.strings = "",
    header = TRUE
  ) %>%
  rename(all_of(raw_rename2))  %>%
  select(raw_names2, everything())

m7 <-
  data.table::fread(
    file.path(raw, "2020/202007-capitalbikeshare-tripdata.csv"),
    na.strings = "",
    header = TRUE
  ) %>%
  rename(all_of(raw_rename2))  %>%
  select(raw_names2, everything())

m8 <-
  data.table::fread(
    file.path(raw, "2020/202008-capitalbikeshare-tripdata.csv"),
    na.strings = "",
    header = TRUE
  ) %>%
  rename(all_of(raw_rename2))  %>%
  select(raw_names2, everything())

m9 <- 
  data.table::fread(
    file.path(raw, "2020/202009-capitalbikeshare-tripdata.csv"),
    na.strings = "",
    header = TRUE
  ) %>%
  rename(all_of(raw_rename2))  %>%
  select(raw_names2, everything())

m10 <- 
  data.table::fread(
    file.path(raw, "2020/202010-capitalbikeshare-tripdata.csv"),
    na.strings = "",
    header = TRUE
  ) %>%
  rename(all_of(raw_rename2))  %>%
  select(raw_names2, everything())

m11 <- 
  data.table::fread(
    file.path(raw, "2020/202011-capitalbikeshare-tripdata.csv"),
    na.strings = "",
    header = TRUE
  ) %>%
  rename(all_of(raw_rename2))  %>%
  select(raw_names2, everything())

m12 <- 
  data.table::fread(
    file.path(raw, "2020/202012-capitalbikeshare-tripdata.csv"),
    na.strings = "",
    header = TRUE
  ) %>%
  rename(all_of(raw_rename2))  %>%
  select(raw_names2, everything())

# append months 4-12 to main 2020 dataset
r2020 <-
  r2020 %>%
  bind_rows(m4,m5,m6,m7,m8,m9,m10,m11,m12) 

# remove month objects
rm(m4,m5,m6,m7,m8,m9,m10,m11,m12)





# append, id_ride, export ==============================================================================


# manage duplicates, export another version --------------------------------------------------------------

# Eliminate duplicates for number_old
# starting on 01 June, 2018 (inclusive), station number 31607 appears to be moved from
# 14th/D to 13th/E  with the name change made accordingly. the station id number was not
# changed even though the name was not. In this scenario, I will create a "new" station id
# number, starting with 999, congruent to the numbering schema at the time it was made. This way
# will be able to distinguish the station from its two points in time: before it was moved, and after
# it was moved locations. The actual number I will replace the id with is 99901

# append -----------------------------------------------------------------------------------------------------
append <-
  bind_rows(
    r2010, r2011, r2012, r2013, r2014, r2015,
    r2016, r2017, r2018, r2019, r2020
  ) %>%
  select(-ride_id) %>%  # remove unwanted columns
  mutate(               # change start stations
    start_number2 = case_when(
      start_name == "13th & E St SE" & start_number == 31607 ~ as.integer(99901),
      TRUE                                                   ~ start_number,
    ),                  # change end stations
    end_number2 = case_when(
      end_name == "13th & E St SE" & end_number == 31607 ~ as.integer(99901),
      TRUE                                                   ~ end_number,
    )
  ) %>%
  select(-start_number, -end_number) %>% # drop original number columns
  rename(start_number = start_number2, # rename variables to match key variable names
         end_number   = end_number2)




# generate ride id ----------------------------------------------------------------------------------------

set.seed(47)

append <- 
  append %>%
  mutate(r = runif(nrow(.)) ) %>% # make random variable
  arrange(r) %>%
  mutate(id_ride = row_number()) %>%
  select(-r)



# export  -----------------------------------------------------------------------------------------------
fwrite(append, 
       file = file.path(raw, "bks-import.csv"),
       na = "", # make missings ""
       compress = "none" # do not compress
)


rm(append,
   r2010, r2011, r2012, r2013, r2014, r2015,
   r2016, r2017, r2018, r2019, r2020)


