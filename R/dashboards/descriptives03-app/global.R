# global.R
# defines objects available to both UI and SERVER

# data ------------------------------------------------------------------

# color palettes ------------------------------------------------------------------------------------------
# note that obviously not all color palette work can be done here since some things like breaks and ranges 
# will depend on reactive elements to be calculated in the sever, but things like name of pallete can be

#mapview global options 
mapviewOptions(
  vector.palette = hcl.colors(7, palette = "Sunset", alpha = NULL, rev = T) # null means no opacity data
)

network.pal = hcl.colors(5, palette = "Cividis") # continuous desire lines/network graph, n doesn't matter


# why won't relative file paths work, even after changing working directory?
days  <- readRDS("data/days.Rda")
rides <- readRDS("data/daily-rides-light.Rda")
key   <- readRDS("data/station_key.Rda")
stations   <- readRDS("data/sum-station-yr.Rda")



## desire lines -----
# Goal is to have darker colors at the top of the numerical spectrum as they show better in less sparse places

