# aim: prepare GTFS data

library(tidyverse)
library(tidytransit)

Carris = read_gtfs("original/GTFScarris2020.zip") #also tried with 2018, 2022
Carris_stops = gtfs_as_sf(Carris)
Carris_stops = Carris_stops$stops

Carris_stops_freq = get_stop_frequency(Carris, start_time = "06:00:00", end_time = "23:00:00", by_route = TRUE)
# not providing a good result!
