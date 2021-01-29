# sandbox.R
# exploring what to do after query.R

library(scales)
library(mapview)
library(leaflet)
library(leafpop)
library(ineq)
library(leafsync)
library(plotly)



# graphs =========================================================================
# note, the only graphs I'll put here are ones that cannot be embedded in rmarkdown

# leafletmaps  ---------------------------------------------------------------------------------------------------

# make station_key into sf
key <- readRDS(file.path(processed, "keys/station_key.Rda")) %>%
  select(name_bks, id_proj, lat, lng, metro, name_metro)  # keep only necessary variables


# 4 pane map

st_crs(station_map) <- 4326

mapviewOptions(fgb = FALSE, basemaps = "CartoDB.Positron")
at_scale <- c(0, 500, 2000,5000,10000,20000,50000,100000)


# years
mv2018 <- mapview(station_map[station_map$year==2018,], 
                  zcol = c("departures"),
                  at = at_scale,
                  alpha.regions = 0.5,
                  layer.name = "2018",
                  popup = popupTable(
                    station_map[station_map$year==2018,],
                    zcol = c("name_bks", 
                             "name_metro", 
                             "departures",
                             "n_dest",
                             "sd",
                             "departures_pct_top05"))) 
mv2019 <- mapview(station_map[station_map$year==2019,], 
                  zcol = c("departures"),
                  at = at_scale,
                  alpha.regions = 0.5,
                  layer.name = "2019",
                  popup = popupTable(
                    station_map[station_map$year==2019,],
                    zcol = c("name_bks", 
                             "name_metro", 
                             "departures",
                             "n_dest",
                             "sd",
                             "departures_pct_top05"))) 
mv2020 <- mapview(station_map[station_map$year==2020,], 
                  zcol = c("departures"),
                  at = at_scale,
                  alpha.regions = 0.5,
                  layer.name = "2020",
                  popup = popupTable(
                    station_map[station_map$year==2020,],
                    zcol = c("name_bks", 
                             "name_metro", 
                             "departures",
                             "n_dest",
                             "sd",
                             "departures_pct_top05"))) 

mv2017 <- mapview(station_map[station_map$year==2017,], 
                  zcol = c("departures"),
                  at = at_scale,
                  alpha.regions = 0.5,
                  layer.name = "2017",
                  popup = popupTable(
                    station_map[station_map$year==2017,], 
                    zcol = c("name_bks", 
                             "name_metro", 
                             "departures",
                             "n_dest",
                             "sd",
                             "departures_pct_top05"))) 

sync(mv2017, mv2018, mv2019, mv2020)


# airplane map --------------------------------------------------------------------------

# map projection 
geo <- list(
  scope = 'north america',
  fitbounds = 'locations',
  projection = list(type = 'azimuthal equal area'),
  showland = TRUE,
  showrivers = TRUE,
  showsubunits = TRUE,
  landcolor = toRGB('gray95'),
  countrycolor = toRGB('gray80')
)

# figure
stations19 <- filter(sum_station_sf, year == 2019)
stations20 <- filter(sum_station_sf, year == 2020)
start_end_2020 <- filter(start_end, (n_depart >= 300), year == 2020)
start_end_2019 <- filter(start_end, (n_depart >= 300), year == 2019)

fig20 <- plot_geo(locationmode = 'USA-states', color = I('red')) %>%
  add_markers(
  data = stations20,
  x = ~lng, y = ~lat, text = ~name_bks_st,
  size = ~departures
) %>%
  add_segments(
    data = group_by(start_end_2020, id_start, id_end),
    x = ~lng_st, xend = ~lng_end,
    y = ~lat_st, yend = ~lat_end, text = ~n_depart,
    alpha = 0.2
  ) %>%
  layout(
    title = "title",
    geo = geo, showlegend = TRUE, height = 800
  )

fig19 <- plot_geo(locationmode = 'USA-states', color = I('red')) %>%
  add_markers(
    data = stations19,
    x = ~lng, y = ~lat, text = ~name_bks_st,
    size = ~departures
  ) %>%
  add_segments(
    data = group_by(start_end_2019, id_start, id_end),
    x = ~lng_st, xend = ~lng_end,
    y = ~lat_st, yend = ~lat_end, text = ~n_depart,
    alpha = 0.2 
  ) %>%
  layout(
    title = "title",
    geo = geo, showlegend = TRUE, height = 800
  )

fig20
fig19


