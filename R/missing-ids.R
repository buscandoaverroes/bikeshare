# missing ride explore

# raw 2020 extract 
test2020 <- readRDS(file.path(processed, "data/years/bks_2020.Rda"))

# how many missing id_starts are there in extract?
sum(is.na(test2020$id_start)) # 40763

# missings in overall data
sum(is.na(bks$id_start)) # 85415
df1 <- filter(bks, is.na(id_start))


# how many of these are non-electric 
df2 <- filter(df1, electric == FALSE)
nrow(df2) # 0

# store these ride_id numbers 
na_rides_all <- df1$id_ride
na_rides_nonelec <-df2$id_ride

# load raw_bks and find these rides, 
rm(bks)

bks_raw <- data.table::fread(
    file.path(raw, "bks-import.csv"),
    header = TRUE,
    na.strings = "" 
  )

# query rides with missing station id 

rides_orig <- bks_raw[bks_raw$id_ride %in% na_rides_nonelec]

## what station did they come from?
unique(rides_orig$start_name) # "22nd & H St NW"          "22nd & H  NW (disabled)"
unique(rides_orig$start_number) # 0

# conclusion: I can't eliminate the number 0 in the station_key....

