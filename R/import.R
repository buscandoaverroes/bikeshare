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


r2020 <- bind_rows(m1, m2, m3)
rm(m1,m2,m3)

# months 4+
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

r2020 <-
  r2020 %>%
  bind_rows(m4,m5,m6,m7,m8,m9) 

rm(m4,m5,m6,m7,m8,m9)





# append all years+export ====================================================
bind_rows(
  r2010, r2011, r2012, r2013, r2014, r2015,
  r2016, r2017, r2018, r2019, r2020
) %>%
  select(-is_equity, -ride_id) %>%  # remove unwanted columns
  fwrite(., 
         file = file.path(raw, "bks-import.csv"),
         na = "", # make missings ""
         compress = "none" # do not compress
         )