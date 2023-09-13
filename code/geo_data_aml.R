# aim: provide some geographic databases

# freguesias geo
FREGUESIASgeo = readRDS(url("https://github.com/U-Shift/biclar/releases/download/0.0.1/FREGUESIASgeo.Rds"))
st_write(FREGUESIASgeo, "geo/FREGUESIASgeo.gpkg")

# municipios geo
MUNICIPIOSgeo = readRDS(url("https://github.com/U-Shift/biclar/releases/download/0.0.1/MUNICIPIOSgeo.Rds"))
st_write(MUNICIPIOSgeo, "geo/MUNICIPIOSgeo.gpkg")

# centroids
MUNICIPIOScentroid = st_centroid(MUNICIPIOSgeo) %>% st_transform(3857)
mapview::mapview(MUNICIPIOScentroid)
st_write(MUNICIPIOScentroid, "geo/MUNICIPIOScentroid.gpkg")

# population weighted centroids
# homework!
# tips: use bgri and population or households or buildings
# what are the differences between the results and the geometric centroid?
