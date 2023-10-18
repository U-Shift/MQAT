# aim: export GIRA 
# see Contagens/stats/paneldata.R


library(tidyverse)
library(sf)

GIRA2023 = GIRA_anos |>
  select(estacaolocalizacao, latitude, longitude) |> 
  st_as_sf(coords = c("longitude", "latitude"), crs = 4326)

st_write(GIRA2023, "D:/GIS/MQAT/geo/GIRA2023.geojson")
