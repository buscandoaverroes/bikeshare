# global.R
# defines objects available to both UI and SERVER

# data ------------------------------------------------------------------

# color palettes ------------------------------------------------------------------------------------------
# note that obviously not all color palette work can be done here since some things like breaks and ranges 
# will depend on reactive elements to be calculated in the sever, but things like name of pallete can be

network.pal = hcl.colors(5, palette = "Cividis") # continuous desire lines/network graph, n doesn't matter


# why won't relative file paths work, even after changing working directory?
days  <- readRDS("/Volumes/Al-Hakem-II/Scripts/bikeshare/R/dashboards/descriptives03-app/data/days.Rda")
rides <- readRDS("/Volumes/Al-Hakem-II/Scripts/bikeshare/R/dashboards/descriptives03-app/data/daily-rides.Rda") 
key   <- readRDS("/Volumes/Al-Hakem-II/Scripts/bikeshare/R/dashboards/descriptives03-app/data/station_key.Rda")



## desire lines -----
# Goal is to have darker colors at the top of the numerical spectrum as they show better in less sparse places

