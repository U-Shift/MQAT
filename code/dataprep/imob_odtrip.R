# aim: create OD trips dataset for AML, by dicofre and mode (and weekdays?)

library(dplyr)
library(tidyr)
library(sf)

TRIPSmode_freguesias = readRDS(url("https://github.com/U-Shift/biclar/releases/download/0.0.1/TRIPSmode_freguesias.Rds"))
TRIPSmode_freguesias_desirelines = TRIPSmode_freguesias
TRIPSmode_freguesias = TRIPSmode_freguesias |> st_drop_geometry() |> as.data.frame()

TRIPSmode_freguesias = TRIPSmode_freguesias |> 
  mutate(Car = Car + CarP) |> 
  select(-c(CarP, Active))

saveRDS(TRIPSmode_freguesias, "original/TRIPSmode_freguesias.Rds")



## summarize trips AML

# Get dicofre updated to 2016 

DICOFRE_aml = readRDS("original/DICOFRE_aml.Rds")
table(TRIPSfreg$DTCC_or)
DICOFRE_aml = DICOFRE_aml |>
  mutate(DTCC = as.character(DTCC)) 

library(readxl)
RelacaoFreguesiasINE20112016 <- read_excel("D:/GIS/IMOB/GIS/InfExtra_Concelhos_Freguesias_CAOP2019/RelacaoFreguesiasINE20112016.xlsx")
library(zoo)
RelacaoFreguesiasINE20112016$Dicofre = na.locf(RelacaoFreguesiasINE20112016$DICOFRE16) #preencher campos vazios com o último valor não NA
RelacaoFreguesiasINE20112016 = RelacaoFreguesiasINE20112016 |> select(Dicofre, DICOFRE11) |> distinct()

BGRI = st_read("D:/GIS/IMOB/GIS/INE2011_AML_DICOFREBGRI.shp") |> st_drop_geometry() |> as.data.frame()



TRIPSfreg = readRDS("D:/GIS/IMOB/R/TRIPSod_original.Rds")
# colnames(TRIPSfreg)
# [1] "Id_aloj_2"      "N_Individuo"    "N_Desloc"       "DTCC_or11"      "FR_or11"        "Sec_or11"       "SS_or11"        "DTCC_de11"     
# [9] "FR_de11"        "Sec_de11"       "SS_de11"        "DTCC_or"        "Zona_or"        "DTCC_de"        "Zona_de"        "Dia_da_semana" 
# [17] "Tipo_veiculo_2" "PESOFIN"  
# unique(TRIPSfreg$Tipo_veiculo_2)
# [1] "passenger car - as passenger" "Walking"                      "bus and coach - TP"           "Waterways"                   
# [5] "passenger car - as driver"    "unknown"                      "motorcycle and moped"         "Regular train"               
# [9] "Urban rail"                   "van/lorry/tractor/camper"     "Other"                        "Cycling"                     
# [13] "bus and coach - TE"           "Táxi (como passageiro)"       "Aviation"           


#remover viagens para fora da AML
TRIPSfreg = TRIPSfreg |> 
  filter(DTCC_or %in% DICOFRE_aml$DTCC) |>
  filter(DTCC_de %in% DICOFRE_aml$DTCC) |> 
  filter(!is.na(DTCC_or11), !is.na(DTCC_de11))

sum(TRIPSfreg$PESOFIN) #5299848 ok


# create dicofre variable (dt + cc + fr) and bgri (++Sec + SS)
TRIPSfreg = TRIPSfreg |>
  # mutate(Origin_dicofre11 = paste0(DTCC_or11, FR_or11),
  #        Destination_dicofre11 = paste0(DTCC_de11, FR_de11)) |> 
  mutate(Origin_bgri11 = paste0(DTCC_or11, FR_or11, Sec_or11, SS_or11),
         Destination_bgri11 = paste0(DTCC_de11, FR_de11, Sec_de11, SS_de11))

# use bgri after 2016 - there are some freguesias that were split!
TRIPSfreg = TRIPSfreg |> left_join(BGRI |> select(BGRI11, Dicofre),
                                    by=c("Origin_bgri11" = "BGRI11")) |> rename(Origin_dicofre16 = Dicofre)
TRIPSfreg = TRIPSfreg |> left_join(BGRI |> select(BGRI11, Dicofre),
                                    by=c("Destination_bgri11" = "BGRI11")) |> rename(Destination_dicofre16 = Dicofre)


sum(TRIPSfreg$PESOFIN) #5299848 ok


#reduzir para os seguintes modos: car, transit, motorcycle, bike, walk, other
TRIPSfreg = TRIPSfreg |> 
  mutate(mode = case_match(Tipo_veiculo_2,
                           "Cycling" ~ "Bike",
                           "Walking" ~ "Walk",
                           c("passenger car - as driver", 
                             "passenger car - as passenger", 
                             "Táxi (como passageiro)", 
                             "motorcycle and moped") ~"Car",
                           c("bus and coach - TE", 
                             "bus and coach - TP", 
                             "Regular train",
                             "Urban rail",
                             "Waterways") ~ "PTransit",
                           .default = "Other" # includes vans/trucks/tractor, unknown, aviation
                           ))
table(TRIPSfreg$mode) #join other with PTransit?
# Bike      Car    Other PTransit     Walk 
# 583    70183     1018    17597    22761 

# weekdays and weekends
table(TRIPSfreg$Dia_da_semana)
TRIPSfreg = TRIPSfreg |> 
  mutate(weekday = case_match(Dia_da_semana,
                              c("Sábado", "Domingo") ~ "Weekend",
                              .default = "Workingday"))





#make long format
TRIPSmode_freg_weekday = TRIPSfreg |>
  group_by(Origin_dicofre16, Destination_dicofre16, mode, weekday) |> #with weekday, if necessary
  summarise(trips=sum(PESOFIN)) |>
  ungroup()

TRIPSmode_freg = TRIPSfreg |>
  group_by(Origin_dicofre16, Destination_dicofre16, mode) |>
  summarise(trips=sum(PESOFIN)) |>
  ungroup()


#make wide format
TRIPSmode_freg = TRIPSmode_freg |>
  pivot_wider(id_cols = c(Origin_dicofre16, Destination_dicofre16),
              names_from = mode,
              values_from = trips) |> 
  replace(is.na(.), 0) |> 
  mutate(Total = Car + Bike + Walk + PTransit + Other) |> 
  mutate_if(is.numeric, round) |> 
  select(Origin_dicofre16, Destination_dicofre16, Total, Walk, Bike, Car, PTransit, Other)

sum(TRIPSmode_freg$Total) #5299853 is fine (5 trips difference with round)

saveRDS(TRIPSmode_freg, "data/TRIPSmode_freg.Rds")

#dar nomes aos códigos
POPFreguesias <- readRDS("D:/GIS/MQAT/original/POPFreguesias.Rds")
DICOFRE_aml_names = FREGUESIASgeo |> st_drop_geometry() |> select(Dicofre, Concelho) |>
  left_join(POPFreguesias |> select(Dicofre, Freguesia)) |> 
  left_join(DICOFRE_aml |> select(DTCC, DICOFRE) |> mutate(Dicofre = as.character(DICOFRE))) |> 
  select(DTCC, Dicofre, Concelho, Freguesia)

saveRDS(DICOFRE_aml_names, "data/Dicofre_names.Rds")


## Municipal
# TRIPSmode_municipal = readRDS(url("https://github.com/U-Shift/biclar/releases/download/0.0.1/TRIPSmode_municipal.Rds"))
# TRIPSmode_municipal = readRDS("original/TRIPSmode_municipal.Rds")

TRIPSmode_mun = TRIPSmode_freg |> 
  left_join(DICOFRE_aml_names |> select(Dicofre, Concelho),
            by = c("Origin_dicofre16" = "Dicofre")) |> 
              rename(Origin_mun = Concelho) |> 
  left_join(DICOFRE_aml_names |> select(Dicofre, Concelho), 
            by = c("Destination_dicofre16" = "Dicofre")) |> 
              rename(Destination_mun = Concelho) |> 
  group_by(Origin_mun, Destination_mun) |> 
  summarise_if(is.numeric, sum) |> 
  ungroup()

TRIPSmode_mun[TRIPSmode_mun == "Setubal"] = "Setúbal"
saveRDS(TRIPSmode_mun, "data/TRIPSmode_mun.Rds")


## other

IMOBrespondents = readRDS((url("https://github.com/U-Shift/biclar/releases/download/0.0.1/IMOBrespondents.Rds")))
IMOBmore <- readRDS("original/IMOBaml_TUDOJUNTOmais.Rds")

