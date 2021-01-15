# -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- #
# Name: query.R
# Description: queries the main database to create working datasets
# -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- #


# load main dataset ----------------------------------------------------
bks <- readRDS(file.path(processed, "data/bks-full.Rda"))




# query 1: most recent 3 years
bks_3yr <- filter(bks, year >= 2018)


# query 2: most recent 1 year 
bks_3yr <- filter(bks, year == 2020)


# export 
saveRDS(bks_3yr, 
        file.path(processed, "data/years/bks_2018-20.Rda"))

saveRDS(bks_1yr, 
        file.path(processed, "data/years/bks_2020.Rda"))