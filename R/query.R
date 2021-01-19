# -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- #
# Name: query.R
# Description: queries the main database to save working datasets
# -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- #


# toggles --------------------------------------------------------------

q1 = 0 # Years 2018-2020
q2 = 0 # Year 2020 
q3 = 1 # years 2017-2020



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
if (q2 == 2) {
  bks_1yr <- filter(bks, year == 2020)
  saveRDS(bks_1yr, 
          file.path(processed, "data/years/bks_2020.Rda"))
}


# query 3: most recent 4 years 
if (q2 == 2) {
  bks_4yr <- filter(bks, year >= 2017)
  saveRDS(bks_4yr, 
          file.path(processed, "data/years/bks_2017-20.Rda"))
}