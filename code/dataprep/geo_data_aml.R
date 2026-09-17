# This script provide some geographic databases

library(sf)
library(dplyr)
library(mapview)

# Municipality geometries ------------------------------------------------------------

## 1. Fetch latest CAOP from DGT ----------------------------------------------------
# (Source: https://www.dgterritorio.gov.pt/atividades/cartografia/cartografia-tematica/caop)

# > Download zip
link_DGT_CAOP <- "https://geo2.dgterritorio.gov.pt/caop/CAOP_Continente_2025-gpkg.zip"
CAOP_zip <- tempfile(fileext = ".zip")
download.file(link_DGT_CAOP, destfile = CAOP_zip, mode = "wb")
zip::zip_list(CAOP_zip) # Validate the contents of the zip file

# > Unzip gpkg
CAOP_gpkg <- tempdir()
unzip(CAOP_zip, exdir = CAOP_gpkg)
list.files(CAOP_gpkg)

# > Read gpkg
CAOP <- sf::st_read(file.path(CAOP_gpkg, "Continente_CAOP2025.gpkg"))
# mapview(CAOP)
st_crs(CAOP) # 3763

# > Filter by NUT II Lisboa
nrow(CAOP) # 3392
CAOP_GLPS <- CAOP |>
  filter(nuts2 %in% c("Grande Lisboa", "Península de Setúbal")) |>
  select(-id, -nuts1, -nuts3, -tipo_area_administrativa, -distrito_ilha, -perimetro_km) |>
  st_transform(crs = 4326)
nrow(CAOP_GLPS) # 189
names(CAOP_GLPS)
# mapview(CAOP_GLPS)

## 2. Fetch latest COS from DGT ----------------------------------------------------
# (Source: https://www.dgterritorio.gov.pt/dados-abertos)

# > Download zip
link_DGT_COS <- "https://geo2.dgterritorio.gov.pt/cos/S2/COS2023/COS2023v1-S2-gpkg.zip"
COS_zip <- tempfile(fileext = ".zip")
download.file(link_DGT_COS, destfile = COS_zip, mode = "wb")
zip::zip_list(COS_zip)

# > Unzip gpkg
COS_gpkg <- tempdir()
unzip(COS_zip, exdir = COS_gpkg)
list.files(COS_gpkg)
COS <- sf::st_read(file.path(COS_gpkg, "COS2023v1-S2.gpkg")) |> st_transform(crs = 4326)
# mapview(COS)
names(COS)


## 3. Adjust geometries to remove water areas (from COS) ----------------------------------------------------

# > Get COS inside CAOP_GLPS
nrow(COS) # 783760
COS_GLPS <- COS |>
  st_intersection(CAOP_GLPS |> st_union()) |>
  st_make_valid() |>
  mutate(n_row = row_number())
nrow(COS_GLPS) # 31104
# mapview(COS_GLPS)
table(COS_GLPS$COS23_n4_L)

# > Remove water from COS
WATER_LABELS <- c("Desembocaduras fluviais", "Zonas entremarés", "Sapais", "Pauis e turfeiras")
# FARMING_LABELS <- c("Arrozais", "Culturas temporárias de sequeiro e regadio", "Pastagens melhoradas")
# mapview(COS_GLPS |> filter(COS23_n4_L %in% WATER_LABELS), layer.name = "Water", col.regions = "#00ccff") +
# mapview(COS_GLPS |> filter(COS23_n4_L %in% FARMING_LABELS), layer.name="Farming", col.regions="#00ff00") +
# mapview(COS_GLPS |> filter(COS23_n4_L == "Rede rodoviária"), layer.name="Roads", col.regions="#808080") +
# mapview(COS_GLPS |> filter(!COS23_n4_L %in% c(WATER_LABELS)), layer.name = "Land", col.regions = "#996633")
COS_GLPS_LAND <- COS_GLPS |>
  filter(!(COS23_n4_L %in% WATER_LABELS))
nrow(COS_GLPS_LAND) # 30975
# mapview(COS_GLPS_LAND)

# > Remove bboxs from COS_GLPS_LAND
bbox <- list(
  c(38.698032, -9.179598, 38.682482, -9.174718), # Ponte 25 de Abril
  c(38.736986, -9.008036, 38.783230, -9.081920), # Ponte Vasco da Gama South
  c(38.786945, -9.090903, 38.782942, -9.075899) # Ponte Vasco da Gama North
)
for (i in seq_along(bbox)) { # i = 1
  bbox_i <- st_as_sfc(
    st_bbox(c(xmin = bbox[[i]][2], xmax = bbox[[i]][4], ymin = bbox[[i]][3], ymax = bbox[[i]][1]),
      crs = st_crs(4326)
    )
  )
  # mapview(bbox_i)
  COS_GLPS_LAND <- COS_GLPS_LAND |>
    st_difference(bbox_i)
}
# mapview(COS_GLPS_LAND, layer.name = "COS Land", col.regions = "#996633")


# > Cut CAOP using COS land geometry
sf_use_s2(FALSE)
COS_GLPS_LAND_UNION <- COS_GLPS_LAND |>
  st_union()
sf_use_s2(TRUE)
# mapview(COS_GLPS_LAND_UNION, layer.name = "COS Land Union", col.regions = "#996633") +
# mapview(COS_GLPS, layer.name = "COS", col.regions = "#00cc99") +
# mapview(COS_GLPS_LAND, layer.name = "COS Land", col.regions = "#ffcc66") +
# mapview(CAOP_GLPS, layer.name = "CAOP GLPS", col.regions = "#015160")


# > Cut CAOP_GLPS with COS_GLPS_LAND
CAOP_GLPS_LAND <- CAOP_GLPS |>
  st_intersection(COS_GLPS_LAND_UNION) |>
  st_make_valid()
nrow(CAOP_GLPS_LAND) # 188
# mapview(CAOP_GLPS_LAND)

## 6. Geometry for municipalities ----------------------------------------------------
MUNICIPIOSgeo <- CAOP_GLPS_LAND |>
  mutate(
    dtmn = substr(as.character(dtmnfr), 1, 4),
    name = municipio
  ) |>
  group_by(dtmn, name) |>
  summarise(geometry = st_union(geom))
nrow(MUNICIPIOSgeo) # 18
# mapview(MUNICIPIOSgeo, zcol="name")
# mapview(MUNICIPIOSgeo, zcol="nid")

sf::st_write(MUNICIPIOSgeo, "geo/MUNICIPIOSgeo.gpkg", delete_dsn = TRUE)
# MUNICIPIOSgeo = sf::st_read("geo/MUNICIPIOSgeo.gpkg")

## 7. Municipality centroids ------------------------------------------------------------
MUNICIPIOScentroid <- st_centroid(MUNICIPIOSgeo) |> st_transform(3857)
# mapview::mapview(MUNICIPIOScentroid)
st_write(MUNICIPIOScentroid, "geo/MUNICIPIOScentroid.gpkg", delete_dsn = TRUE)
# MUNICIPIOScentroid = sf::st_read("geo/MUNICIPIOScentroid.gpkg")

# piggyback::pb_upload(file = "geo/MUNICIPIOSgeo.gpkg", repo = "U-Shift/MQAT")
# piggyback::pb_upload(file = "geo/FREGUESIASgeo.gpkg", repo = "U-Shift/MQAT")

# Freguesias geometries ------------------------------------------------
## 1. Load freguesias from biclar, to keep using DICOFRE (for compatibility with IMOB) ----------------------------------------------------
FREGUESIASgeo = readRDS(url("https://github.com/U-Shift/biclar/releases/download/0.0.1/FREGUESIASgeo.Rds"))

## 2. Adjust geometries to remove water areas ----------------------------------------------------
FREGUESIASgeo = FREGUESIASgeo |>
  st_intersection(COS_GLPS_LAND_UNION) |>
  st_make_valid()

st_write(FREGUESIASgeo, "geo/FREGUESIASgeo.gpkg", delete_dsn = TRUE)
# FREGUESIASgeo = sf::st_read("geo/FREGUESIASgeo.gpkg")

# Polygons with trips info ------------------------------------------------

TRIPSmode_mun <- readRDS("data/TRIPSmode_mun.Rds")
sum(TRIPSmode_mun$Total) # 5299853

## 1. For municipalities, direct association (by name) ----------------------------------------------------
TRIPSgeo_mun <- TRIPSmode_mun |>
  group_by(Origin_mun) |>
  summarise_if(is.numeric, sum) |>
  rename(name = Origin_mun) |>
  left_join(MUNICIPIOSgeo) |>
  st_as_sf()

# mapview::mapview(TRIPSgeo_mun, zcol = "Bike")
# assertthat::are_equal(sum(TRIPSgeo_mun$Total), sum(TRIPSmode_mun$Total))
st_write(TRIPSgeo_mun, "geo/TRIPSgeo_mun.gpkg", delete_dsn = TRUE)
# TRIPSgeo_mun = sf::st_read("geo/TRIPSgeo_mun.gpkg")

## 1. For parishes, convert DICOFRE to DTMNFR ----------------------------------------------------
TRIPSmode_freg <- readRDS("data/TRIPSmode_freg.Rds")
TRIPSgeo_freg = TRIPSmode_freg |>
  group_by(Origin_dicofre16) |> 
  summarise_if(is.numeric, sum) |> 
  rename(Dicofre = Origin_dicofre16) |>
  left_join(FREGUESIASgeo) |> 
  st_as_sf()


# mapview::mapview(TRIPSgeo_freg, zcol = "Bike")
# assertthat::are_equal(sum(TRIPSgeo_freg$Total), sum(TRIPSmode_mun$Total))
st_write(TRIPSgeo_freg, "geo/TRIPSgeo_freg.gpkg", delete_dsn = TRUE)
# TRIPSgeo_freg = sf::st_read("geo/TRIPSgeo_freg.gpkg")

# Desire lines ------------------------------------------------------------

## Desire lines
# rescue the ones from biclar
# TRIPSmode_freguesias_desirelines = readRDS(url("https://github.com/U-Shift/biclar/releases/download/0.0.1/TRIPSmode_freguesias.Rds"))
# mapview::mapview(TRIPSmode_freguesias_desirelines, lwd =0.1)

## Create news with municipalities only
library(stplanr)
CENTROIDS <- st_read("original/CENTROIDS_pop21.gpkg")
DICOFRE_aml_names = readRDS("data/Dicofre_names.Rds")
CENTROIDS <- CENTROIDS |>
  st_transform(3857) |>
  select(DTMN21) |>
  rename(DTCC = DTMN21) |>
  left_join(DICOFRE_aml_names |> select(DTCC, Concelho))

TRIPSdl_mun <- od2line(
  flow = TRIPSmode_mun,
  zones = CENTROIDS,
  zone_code = "Concelho"
)

mapview::mapview(TRIPSdl_mun)

st_write(TRIPSdl_mun, "geo/TRIPSdl_mun.gpkg")
