# weather.R
# extracts info from NOAA databases to create by-hour/day dictionary of basic weather info

# key variables: date/time, temp, precipitation

library(rnoaa)
library(lubridate)
library(sf)
library(mapview)

# determine locations ------------------------------------------------------------------------------------
ncdc_locs_cats() # location categories
ncdc_locs(locationcategoryid = c('ST'), sortfield = 'name', limit = 100) # search by category: arlington CITY:US510002
va_loc <- ncdc_stations(locationid = 'CITY:US510002', limit = 100)  # find stations that meet location criteria
uk_loc <- ncdc_stations(locationid = 'CITY:UK000005', limit = 100)
ca_loc<- ncdc_stations(loc = 'CITY:US060033', limit = 100)

# filter and amend data for sorting and plotting
va_filter <- va_loc$data %>%
  mutate(
    min = as_date(mindate),
    max = as_date(maxdate),
    min_yr= year(min),
    max_yr= year(max)
  ) %>%
  filter(min_yr <= 2010, max_yr >=2020) %>%
  st_as_sf(coords=c("longitude", "latitude")) 


# key findings:
# stationid: 
#     GHCND:US1MDMG0042 is good for now (takoma park)
#     
# locationid: 
#     CITY:US510002


# sample california workflow ===============================================================

# 1. find station -------------------------------------------------------------------------------
# find the way to search for a station number of what i want
ncdc_locs_cats() # location categories

# then after I know that I'm looking for states, search for it
ncdc_locs(locationcategoryid = c('ST'), sortfield = 'name', limit = 100) # ca is FIPS:06


# determine a data category, sort by state of ca (grouping of datatypes)
datacats <- ncdc_datacats(locationid = "FIPS:06", limit = 300) # result: air temperature (TEMP)


# could further refine by datatype: filter by location and datacat
datatype <- ncdc_datatypes(locationid = 'FIPS:06', datacategoryid = 'TEMP', limit = 300) # air temp mean (HLY-TEMP-NORMAL)


# look for weather stations in in locationid, datacat, datatype
stations <- ncdc_stations(locationid = 'FIPS:06', datacategoryid = 'TEMP', limit = 300) # big sur: COOP:040790




# 2. find out data that's available at the station --------------------------------------------

# search by datacat
station.cat <- ncdc_datacats(stationid = 'COOP:040790')


# search by datatype (more refined)
station.type <- ncdc_datatypes(stationid = 'COOP:040790') # precipitation HPCP (but there are many precip indicators)


# search by dataset (and any combination of the datacats or types above)
station.sets <- ncdc_datasets(stationid = 'COOP:040790', datatypeid = 'HPCP') # PRECIP_HLY (datasetid)


# 3. Get data with dataset id ----------------------------------------------------------
bigsur.precip <- ncdc(datasetid = 'PRECIP_HLY',
                      stationid = 'COOP:040790',
                      startdate = '2012-01-01',
                      enddate = '2012-05-01',
                      limit = 50)
view(bigsur.precip$data)

