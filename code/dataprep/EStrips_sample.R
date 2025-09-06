# aim: prepare trip dataset for MQAT home assignment

library(tidyverse)
library(sf)

# filter week of 20 to 26 may
TRIPSes_week2 = TRIPSclean |> 
  filter(start_time >= "2019-05-20 00:00:00",
         start_time <= "2019-05-26 23:59:59")

TRIPSes_week = TRIPSrotas |> filter(trip_id %in% TRIPSes_week2$trip_id) |> 
  select(trip_id, start_time, end_time, trip_duration, path) |> 
  left_join(TRIPSes_week2 |> select (trip_id, Origin, Destination)) |> 
  mutate(trip_id = seq(1:nrow(TRIPSes_week)))



rm(TRIPSes_week2)

class(TRIPSes_week)

# write.table(TRIPSes_week, "D:/GIS/MQAT/geo/TRIPS_EScooters.txt", sep = "\t", row.names = F)

# write 3 layers in the same gpkg: routes, origins, destinations
st_write(TRIPSes_week, "D:/GIS/MQAT/geo/TRIPS_EScooters.gpkg", layer = "routes", delete_dsn = TRUE)

st_geometry(TRIPSes_week) = "Origin"
st_write(TRIPSes_week, "D:/GIS/MQAT/geo/TRIPS_EScooters.gpkg", layer = "origins", append = TRUE)

st_geometry(TRIPSes_week) = "Destination"
st_write(TRIPSes_week, "D:/GIS/MQAT/geo/TRIPS_EScooters.gpkg", layer = "destinations", append = TRUE)
