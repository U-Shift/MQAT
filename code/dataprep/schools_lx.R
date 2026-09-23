# aim: prepare schools dataset for accessibility analyses
library(sf)
library(tidyverse)

# For Lisbon -------------------------------------------------------
SCHOOLS <- st_read("original/escolas/b_escs-infos_pop.shp")
names(SCHOOLS)

SHOOLS_basic <- SCHOOLS |>
  filter(tipo == "Pública") |>
  filter(N_basico > 0) |>
  select(INF_NOME, N_basico) |>
  rename(Alunos = N_basico) |>
  mutate(Nivel = "Basico")
SHOOLS_secund <- SCHOOLS |>
  filter(tipo == "Pública") |>
  filter(N_sec > 0) |>
  select(INF_NOME, N_sec) |>
  rename(Alunos = N_sec) |>
  mutate(Nivel = "Secundario")

SCHOOLS_basicsec <- rbind(SHOOLS_basic, SHOOLS_secund)

# export
# st_write(SHOOLS_basic, "geo/SHOOLS_basic.gpkg", delete_dsn = TRUE)
# st_write(SHOOLS_secund, "geo/SHOOLS_secund.gpkg", delete_dsn = TRUE)
st_write(SCHOOLS_basicsec, "geo/SCHOOLS_basicsec.gpkg", delete_dsn = TRUE)


# For Lisbon Metropolitan Area -------------------------------------------------------
# If missing rJava dependency when running read_xlsx, run the commands below:
# $ sudo apt update & sudo apt install default-jdk
# $ sudo R CMD javareconf
# $ find /usr/lib/jvm -name "libjvm.so" # Replace output in the next command
# > dyn.load('/usr/lib/jvm/java-21-openjdk-amd64/lib/server/libjvm.so', local = FALSE)

# 1. Get number of students for each school
students_n_file <- tempfile(fileext = ".xlsx")
download.file(url = "https://www.dgeec.medu.pt/api/ficheiros/6a3e81a11a35c6289d788ae6", destfile = students_n_file, mode = "wb")
students_n <- readxl::read_xlsx(students_n_file)
names(students_n) <- gsub(" ", "_", names(students_n)) # Replace spaces in col names by "_" to make easier to use variables

# View(students_n)
names(students_n)
table(students_n$ANO_LETIVO)
table(students_n$NATUREZA)
table(students_n$TIPOLOGIA)

length(unique(students_n$CÓDIGO_DGEEC_ESCOLA)) # 7648

# Group by total students
# Each "agrupamento" (CÓDIGO_DGEEC_AGRUPAMENTO) has multiple schools
# Each school (ENTIDADE, CÓDIGO_DGEEC_ESCOLA) has multiple rows, one per NÍVEL_DE__ENSINO, ANO_DE_ESCOLARIDADE, SEXO (Homens, Mulheres)
# Students number is given by NÚMERO_DE_ALUNOS_MATRICULADOS

schools_students_n <- students_n |>
  filter(
    NATUREZA == "Público", # Get only public schools
    NÍVEL_DE__ENSINO == "Ensino secundário",
    DISTRITO %in% c("Lisboa", "Setúbal")
  ) |>
  group_by(
    # Location
    MUNICÍPIO,
    # School identifier
    CÓDIGO_DGEEC_AGRUPAMENTO, CÓDIGO_DGEEC_ESCOLA, ESCOLA, TIPOLOGIA,
    # Grade
    # NÍVEL_DE__ENSINO, ANO_DE_ESCOLARIDADE
  ) |>
  summarise(
    N_ESTUDANTES = sum(NÚMERO_DE_ALUNOS_MATRICULADOS)
  )
# View(schools_students_n)

# 2. Get school locations
# No matching ID, match using NOME, CONCELHO (= ESCOLA, MUNICÍPIO)
schools_locations <- read.csv("original/escolas_gesedu/RedeEscolar.csv") |>
  filter(DISTRITO %in% c("Lisboa", "Setúbal"))
# View(schools_locations)

nrow(schools_students_n) # 164
nrow(schools_locations) # 2342
schools_locations_students <- schools_locations |>
  left_join(schools_students_n, by = c("NOME" = "ESCOLA", "CONCELHO" = "MUNICÍPIO")) |>
  filter(!is.na(N_ESTUDANTES)) |>
  select(DISTRITO, CONCELHO, NOME, TIPOLOGIA, N_ESTUDANTES, x, y) |>
  sf::st_as_sf(coords = c("x", "y"), crs = 3763)

nrow(schools_locations_students) # 147
147 / 162 # 90.74%

# Filter by those inside AML
AML_geo <- sf::st_read("geo/MUNICIPIOSgeo.gpkg") |> st_union() |> st_transform(st_crs(schools_locations_students))
schools_aml <- schools_locations_students |> 
  sf::st_filter(AML_geo)

mapview::mapview(schools_aml, zcol = "N_ESTUDANTES")
nrow(schools_aml) #134

st_write(schools_aml, "geo/SCHOOLS_AML_sec.gpkg", delete_dsn = TRUE)
