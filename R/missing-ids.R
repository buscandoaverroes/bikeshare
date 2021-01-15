# missing ride explore

# raw 2020 extract 
test2020 <- readRDS(file.path(processed, "data/years/bks_2020.Rda"))

# how many missing id_starts are there in extract?
sum(is.na(test2020$id_start)) # 40763

# how many of these are non-electric 
df1 <-
filter(test2020, is.na(id_start) & electric == FALSE)

nrow(df1) # 695

# ok so about 700 have no station id. not bad, but why??

# store these ride_id numbers 
na_rides <- df1$id_ride


# load raw_bks and find these rides, 
