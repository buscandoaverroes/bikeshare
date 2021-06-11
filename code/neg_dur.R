# neg duration

neg <- filter(bks1720, dur <0 )

ggplot(neg, aes(dur)) + geom_histogram() # most are like -1, except some are like negative a million

# merge back to original ride id
bks <- data.table::fread(
  file.path(raw, "bks-import.csv"),
  header = TRUE,
  na.strings = "" 
)

neg2 <- left_join(neg, bks, by = "id_ride")
# looks like the start and end dates in the original are "incorrect" in that the start date is after the end date...

ggplot(neg2, aes(month)) + geom_histogram() # happens more towards end of year
ggplot(neg2, aes(electric)) + geom_bar() # mostly non-electric

