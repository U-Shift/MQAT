
# create simple webmap ----------------------------------------------------

library(tidyverse)
library(sf)
library(mapview)

# read geopackage layer

MUNICIPIOStrips = st_read("geo/TRIPSgeo_mun.gpkg")


# map
plot(MUNICIPIOStrips[["geom"]])

mapview(MUNICIPIOStrips) # simple

mapview(MUNICIPIOStrips, zcol = "Concelho") # categorized

mapview(MUNICIPIOStrips, zcol = "Car_perc") # graduated
mapview(MUNICIPIOStrips, zcol = "Car_perc", alpha.regions = 0.4) # graduated and transparency

# Open in browser
# Export, Save as Web Page



# Add more layers ---------------------------------------------------------

Desirelines = st_read("geo/LINHASod_TI.gpkg")
Desirelines = Desirelines |> filter(TIndividual > 5000)

mapview(Desirelines, zcol = "TIndividual")
mapview(Desirelines, zcol = "TIndividual", lwd = 5)

# all together now
mapview(MUNICIPIOStrips, col.regions = "grey40", alpha.regions = 0.4) +
  mapview(Desirelines, zcol = "TIndividual", lwd = 5)

# More mapview controls at: https://r-spatial.github.io/mapview/articles/mapview_02-advanced.html

# Have a look at TripsAML.html , another package is used: tmap



# Export gis data ---------------------------------------------------------

st_write(Desirelines, "geo/Desirelines.gpkg") #you can choose any extension: .shp .geojson .gpkg 
# if the layer already exists in the folder, add ", delete_dns = TRUE" to overwrite
?st_write