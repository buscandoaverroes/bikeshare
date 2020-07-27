# practice. that's what we're talking about. 

library(sp)

  # load geometries 
usa <- st_read("/Volumes/Al-Hakem-II/other+files/gadm/gadm36_USA_gpkg/gadm36_USA.gpkg",
        layer = "gadm36_USA_2" )
arl <- filter(gpusa, gpusa$NAME_1 == "Virginia") %>%
  filter(NAME_2 == "Arlington")

arlply <- as_Spatial(arl, IDs = arl$NAME_2 ) ## this?



  # make points 
latlong <- data.frame(lng = c(-77.0633, -77.068121, -77.1234) ,
                      lat = c(38.8637, 38.86215, 38.1234)
                      )
pts     <- st_as_sf(latlong,  # tell r the object that contains the points
                    coords = c("lng", "lat"), # tell the point vars
                    crs = 4326) # tell the crs 

  # harmonise crs 
  st_crs(arlply) # default set as 4326
  usa <- st_transform(usa, crs = st_crs(pts))
  arl <- st_transform(arl, crs = st_crs(pts))
  #arlply <- st_transform(arlply, # object
  #             crs = 2283) # new crs
  

  # do sf_intersect , thx to https://gis.stackexchange.com/questions/282750/identify-polygon-containing-point-with-r-sf-package
  
pts2 <- mutate(pts,
  inx  = as.integer(st_intersects(pts, arl)),
  name = if_else(is.na(inx), "", arl$NAME_2[inx]),
  state= if_else(is.na(inx), "", arl$NAME_1[inx])
  )
#% this runs but no names are mapped...
  # trying over 
ovr <- st_within(pts, # points
                 arl) # map

    # now try by making inputs spatail points/polygons data frame 
      # but chane crs first (to 2283)
      st_crs(2283)$proj4string
    pointsdf <- st_transform(pointsdf, crs = st_crs(pts))
    pointsdf2 <- spTransform(pointsdf, CRS("+init=epsg:2283")) # st_crs(2283)$proj4string
    
  ovr2 <- ovr(pointsdf,
              dmvply)

