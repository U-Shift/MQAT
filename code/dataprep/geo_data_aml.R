# aim: provide some geographic databases

# freguesias geo
FREGUESIASgeo = readRDS(url("https://github.com/U-Shift/biclar/releases/download/0.0.1/FREGUESIASgeo.Rds"))
st_write(FREGUESIASgeo, "geo/FREGUESIASgeo.gpkg")

# municipios geo
MUNICIPIOSgeo = readRDS(url("https://github.com/U-Shift/biclar/releases/download/0.0.1/MUNICIPIOSgeo.Rds"))
MUNICIPIOSgeo$Concelho[MUNICIPIOSgeo$Concelho == "Setubal"] = "Setúbal"
st_write(MUNICIPIOSgeo, "geo/MUNICIPIOSgeo.gpkg", delete_dsn = TRUE)

# centroids
MUNICIPIOScentroid = st_centroid(MUNICIPIOSgeo) |> st_transform(3857)
mapview::mapview(MUNICIPIOScentroid)
st_write(MUNICIPIOScentroid, "geo/MUNICIPIOScentroid.gpkg", delete_dsn = TRUE)

# population weighted centroids
# homework!
# tips: use bgri and population or households or buildings
# what are the differences between the results and the geometric centroid?



# Join Trips with geometric attributes
library(tidyverse)
library(sf)
TRIPSgeo_mun = TRIPSmode_mun |>
  group_by(Origin_mun) |> 
  summarise_if(is.numeric, sum) |> 
  rename(Concelho = Origin_mun) |>
  left_join(MUNICIPIOSgeo) |> 
  st_as_sf()

mapview::mapview(TRIPSgeo_mun, zcol = "Bike")

st_write(TRIPSgeo_mun, "geo/TRIPSgeo_mun.gpkg", delete_dsn = TRUE)


TRIPSgeo_freg = TRIPSmode_freg |>
  group_by(Origin_dicofre16) |> 
  summarise_if(is.numeric, sum) |> 
  rename(Dicofre = Origin_dicofre16) |>
  left_join(FREGUESIASgeo) |> 
  st_as_sf()

mapview::mapview(TRIPSgeo_freg, zcol = "Bike")

st_write(TRIPSgeo_freg, "geo/TRIPSgeo_freg.gpkg")
