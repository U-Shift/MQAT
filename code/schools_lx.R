# aim: prepare schools dataset for accessibility analyses

library(sf)
library(tidyverse)

SCHOOLS = st_read("original/escolas/b_escs-infos_pop.shp")
names(SCHOOLS)

SHOOLS_basic = SCHOOLS %>% filter(tipo == "Pública") %>% filter(N_basico > 0) %>% select(INF_NOME, N_basico)
SHOOLS_secund = SCHOOLS %>% filter(tipo == "Pública") %>% filter(N_sec > 0) %>% select(INF_NOME, N_sec)

# export
st_write(SHOOLS_basic, "geo/SHOOLS_basic.gpkg", delete_dsn = TRUE)
st_write(SHOOLS_secund, "geo/SHOOLS_secund.gpkg", delete_dsn = TRUE)
