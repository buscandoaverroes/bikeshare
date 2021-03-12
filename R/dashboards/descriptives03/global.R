# global.R
# defines objects available to both UI and SERVER

# data ------------------------------------------------------------------
days  <- readRDS("days.Rda")
rides <- readRDS("daily-rides.Rda")
key   <- readRDS("station_key.Rda")



# color palettes ------------------------------------------------------------------------------------------
# note that obviously not all color palette work can be done here since some things like breaks and ranges 
# will depend on reactive elements to be calculated in the sever, but things like name of pallete can be

desire.pal = hcl.colors(5, palette = "Berlin")



## desire lines -----
# Goal is to have darker colors at the top of the numerical spectrum as they show better in less sparse places

