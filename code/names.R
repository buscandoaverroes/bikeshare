# names.R
# takes the raw variable names and creates a tibble of various names for graphs, html etc 

# import list of variable names -------------------------------------------------------------------

# create function to import, extract names and remove object
names.extract <- function(x) {
  data <- readRDS(file.path("/Volumes/Al-Hakem-II/Datasets/bks/bks/data/plato", paste0((x), ".Rda")))
  names<- names(data)
  rm(data)
  
  names
}


# Run for each object 
n.days         <- names.extract("days")
n.dailyrides   <- names.extract("daily-rides")
n.sumstation   <- names.extract('sum-station')
n.sumstationyr <- names.extract('sum-station-yr')


# Combine names, make tibble
names <- c(n.days, n.dailyrides, n.sumstation, n.sumstationyr) %>%
  unique(.) %>%
  as_tibble()

# export as csv, then re-import 
write_csv(names,
          file.path(keys, "names.csv"))


# import
