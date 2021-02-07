# recollect.R
# generates a new/original dataset by recollecting old data, as Plato might.

# append + export daily rides ===============================================

bks1014 <- readRDS(file.path(processed, "data/stats10-14/bks1014-weather.Rda"))
bks1516 <- readRDS(file.path(processed, "data/stats15-16/bks1516-weather.Rda"))
bks1720 <- readRDS(file.path(processed, "data/stats17-20/bks1720-weather.Rda"))

bks_plato <- bind_rows(
  bks1014, bks1516, bks1720
)

bks <- fread(file.path(raw, "bks-import.csv", na.strings = ""))

assertthat::assert_that(
  nrow(bks) == nrow(bks_plato)
)
