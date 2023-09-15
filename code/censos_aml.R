# aim: redux census database

library(tidyverse)
library(sf)

CENSOS21geo = st_read("original/BGRI21_LISBOA.gpkg")
class(CENSOS21geo)

CENSOS21 = st_drop_geometry(CENSOS21geo)
class(CENSOS21)

CENSOS21geo = CENSOS21geo %>% select(OBJECTID, geom) # aka BGRI


names(CENSOS21)


# Censos nível freguesia
CENSOS21_freg = CENSOS21 %>%
  group_by(DTMN21, DTMNFR21) %>% # municipality and freguesia
  summarise_if(is.numeric, sum) %>%
  select(-SHAPE_Length, -OBJECTID)

saveRDS(CENSOS21_freg, "data/CENSOS21_freg.Rds")
