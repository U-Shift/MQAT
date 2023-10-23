# aim: prepare GTFS data

library(tidyverse)
library(tidytransit)

Carris = read_gtfs("original/GTFScarris2020.zip") #also tried with 2018, 2022
Carris_stops = gtfs_as_sf(Carris)
Carris_stops = Carris_stops$stops

Carris_stops_freq = get_stop_frequency(Carris, start_time = "06:00:00", end_time = "23:00:00", by_route = TRUE)
# not providing a good result!



# Gabriel version ---------------------------------------------------------

library(tidyverse)
library(gtfstools)
library(sf)

Carris = read_gtfs("original/gtfs_CARRIS.zip")

Carris_stops_tabela = Carris$stops |>
  left_join(Carris$stop_times, by = "stop_id") |>
  left_join(Carris$frequencies, by = "trip_id") |>
  left_join(Carris$trips, by = "trip_id") |>
  left_join(Carris$calendar, by = "service_id") |>
  left_join(Carris$routes, by = "route_id")

excluir = c("stop_code", "stop_desc", "zone_id", "stop_url", "location_type", "parent_station", "stop_headsign", "pickup_type",
            "drop_off_type", "shape_dist_traveled", "trip_headsign", "direction_id", "block_id", "route_short_name",
            "route_desc","route_url", "route_color", "route_text_color")
Carris_stops_tabela = Carris_stops_tabela |> select(!all_of(excluir))

names(Carris_stops_tabela)

Carris_stops_redux = Carris_stops_tabela |>
  group_by(stop_id, stop_name, stop_lat, stop_lon) |> 
  summarise(frequency = n()) |> 
  ungroup()

Carris_stops = st_as_sf(Carris_stops_redux, coords = c("stop_lon", "stop_lat"), crs=4326)

st_write(Carris_stops, "geo/Carris_stops.gpkg", delete_dsn = TRUE)
