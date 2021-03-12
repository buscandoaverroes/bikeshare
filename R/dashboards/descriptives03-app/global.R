# global.R
# defines objects available to both UI and SERVER

# data ------------------------------------------------------------------

# color palettes ------------------------------------------------------------------------------------------
# note that obviously not all color palette work can be done here since some things like breaks and ranges 
# will depend on reactive elements to be calculated in the sever, but things like name of pallete can be

network.pal = hcl.colors(5, palette = "Cividis") # continuous desire lines/network graph, n doesn't matter



## desire lines -----
# Goal is to have darker colors at the top of the numerical spectrum as they show better in less sparse places

