# Bikeshare

A work-in-progress project to analyze Capital Bikeshare data. My research angle looks at any potential changes in aggregate usage patterns due to COVID-19. This is an independent research project; my views and conclusions here are my own.

## Data
Please note that while the code here is available publicly, all system data should be downloaded directly from the capital bikeshare [website](https://www.capitalbikeshare.com/system-data), as per their [license agreement](https://www.capitalbikeshare.com/data-license-agreement). The full usage data is quite large (~4gb), so please make the appropriate adjustments or time allotments when running the code.

The code is designed to pull the raw .csv files from folders named by year. 

## Current Status and Research Questions
__note: main project currently on pause due to development of [cycleR](https://github.com/buscandoaverroes/cycleR), which should hopefully make this project better :)__ 

_Technical_
1. Should the project architecture+code be tweaked to fit the `stplanr` [package and workflow](https://github.com/ropensci/stplanr)?
2. How to treat docked vs dockless bikes?

_Research_
1. What indicators are most useful for tracking aggregate trends before and across different stages of the pandemic?
2. Can the GINI coefficient be implemented to reveal anything, and if so what does it actually mean?
3. Can we really think about trends in a pre-, during-, return-to-normal trajectory or is this "restoration" narrative less appropriate than a "change" narrative?

## Attribution

Data come from OpenStreetMap and from CapitalBikeShare (as described above). Upon the request of OSM, here's the attribution:  "© OpenStreetMap contributors". The data derived from OpenStreetMap should be maintained under the [Open Database License](www.opendatacommons.org/licenses/odbl); I intend to do so. 
