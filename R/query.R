# -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- #
# Name: query.R
# Description: queries the main database to save working datasets
# -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- #


# toggles --------------------------------------------------------------
# set 1 to run
q1 = 0 # Years 2018-2020
q2 = 0 # Year 2020 
q3 = 1 # years 2017-2020
q4 = 1 # years 2010-2014
q5 = 1 # years 2015-2017



# load main dataset ----------------------------------------------------
bks <- readRDS(file.path(processed, "data/bks-full.Rda"))



# queries ==============================================================
# query 1: most recent 3 years

if (q1 == 1) {
  bks_3yr <- filter(bks, year >= 2018)
  saveRDS(bks_3yr, 
          file.path(processed, "data/years/bks_2018-20.Rda"))
}


# query 2: most recent 1 year 
if (q2 == 1) {
  bks_1yr <- filter(bks, year == 2020)
  saveRDS(bks_1yr, 
          file.path(processed, "data/years/bks_2020.Rda"))
}


# query 3: most recent 4 years 
if (q3 == 1) {
  bks_4yr <- filter(bks, year >= 2017)
  saveRDS(bks_4yr, 
          file.path(processed, "data/years/bks_2017-20.Rda"))
}


# query 4: years 2010-2014
if (q4 == 1) {
  bks_1014 <- filter(bks, (year >= 2010 & year <= 2014))
  saveRDS(bks_1014, 
          file.path(processed, "data/years/bks_2010-14.Rda"))
}


# query 5: years 2015-2016
if (q5 == 1) {
  bks_1516 <- filter(bks, (year >= 2015 & year <= 2016))
  saveRDS(bks_1516, 
          file.path(processed, "data/years/bks_2015-16.Rda"))
}