# -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- #
# Name: station-number.R
# Description: creates a dictionary of station numbers between old and new numbers 
# Note: this is run within the station-number script so no packages/data should be needed.
# -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- #

# load csv 
bks <- data.table::fread(
  file.path(raw, "bks-import.csv"),
  header = TRUE,
  na.strings = "" 
)

# make names object 
names_bks <- 
  as_tibble(names(bks)) %>%
  gather()


                  # ---------------------------------------------------------#
                  #    ----
                  # ---------------------------------------------------------#

# create old/new from bks
# this should have dup strings with first row as "new" number and second "old" number
namenumb <- bks %>%
  group_by(start_name, start_number) %>%
  summarise() %>%
  filter(start_name != "")   # remove blank entries

# generate group id 
namenumb$group <- group_indices(namenumb)

# generate id within groups 
nn <- namenumb %>%
  group_by(group) %>%
  mutate(id = row_number() ## why will this not generate! apparently it will
  )

# pivot to wider 
nn.w <- spread(nn,
               key = id, 
               value = start_number) %>%
  rename(old = "1" , # change names
         new = "2",
         misc = "3")

# move values to correct places 

# move low new values to old 
for (i in seq_along(nn.w$old)) {
  nn.w$old[i] <- ifelse((nn.w$new[i] < 30000) 
                        & (!is.na(nn.w$new[i])) , # new value should be < 30000
                        nn.w$new[i], # if true, replace old with new
                        nn.w$old[i]) # if false, replace with self, true for row 120
}

# move high values in old to new
for (i in seq_along(nn.w$new)) {
  nn.w$new[i] <- ifelse((nn.w$old[i] > 30000) 
                        & (!is.na(nn.w$old[i])) , # new value should be < 30000
                        nn.w$old[i], # 
                        nn.w$new[i]) # 
}

# do for column 3 
for (i in seq_along(nn.w$new)) {
  nn.w$new[i] <- ifelse((nn.w$misc[i[]] > 30000) & 
                          (!is.na(nn.w$misc[i])), # new value should be < 30000
                        nn.w$misc[i], #
                        nn.w$new[i]) # 
}

# (for those with no 'old' value) replace old with missing
for (i in seq_along(nn.w$old)) {
  nn.w$old[i] <- ifelse((nn.w$old[i] > 30000) & (!is.na(nn.w$old[i])) , # new value should be < 30000
                        NA, #  replace with missing, indicating not in old cat system
                        nn.w$old[i]) # otherwise replace with valid, old number 
}

# remove misc var, drop unecessary objects
stnidkey <- data.frame(nn.w) %>%
  select(start_name, old, new) %>%
  rename( name = start_name, 
          oldid = new, # the short numbers are actually the newid!
          newid = old)


# export as Rda
  saveRDS(stnidkey,
          file = file.path(processed, "station_key.Rda")) 

remove(nn, nn.w, namenumb)

