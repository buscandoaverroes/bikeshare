# Bikeshare

A work-in-progress project to analyze Capital Bikeshare data. The goal is actually to learn R, relevant packages, and maybe do something useful on the side. My research angle looks at any potential changes in aggregate usage patterns due to COVID-19. This is an independent research project; my views and conclusions here are my own.

Please note that while the code here is available publicly, all system data should be downloaded directly from the capital bikeshare [website](https://www.capitalbikeshare.com/system-data), as per their [license agreement](https://www.capitalbikeshare.com/data-license-agreement). The full usage data is quite large (~4gb), so please make the appropriate adjustments or time allotments when running the code.

The code is designed to pull the raw .csv files from folders named by year. 

## Current Mullings and Research Questions
_Technical_
1. Should the project architecture+code be tweaked to fit the `stplanr` (package and workflow)[https://github.com/ropensci/stplanr]?

## Attribution

Data come from OpenStreetMap and from CapitalBikeShare (as described above). Upon the request of OSM, here's the attribution:  "© OpenStreetMap contributors". The data derived from OpenStreetMap should be maintained under the [Open Database License](www.opendatacommons.org/licenses/odbl); I intend to do so. 
