# prepare data for ACST class

library(tidyverse)
library(sf)
library(openxlsx)

TRIPSmun <- IMOBaml_TUDOJUNTO
colnames(TRIPSmun)
table(TRIPSmun$Tipo_veiculo_2)

#reduzir para os seguintes modos: car, transit, motorcycle, bike, walk, other
TRIPSmun$modo = "Other"
TRIPSmun$modo[TRIPSmun$Tipo_veiculo_2=="Cycling"]<-"Bike"
TRIPSmun$modo[TRIPSmun$Tipo_veiculo_2=="Walking"]<-"Walk"
TRIPSmun$modo[TRIPSmun$Tipo_veiculo_2=="passenger car - as driver"]<-"Car"
TRIPSmun$modo[TRIPSmun$Tipo_veiculo_2=="passenger car - as passenger"]<-"Car"
TRIPSmun$modo[TRIPSmun$Tipo_veiculo_2=="Táxi (como passageiro)"]<-"Car"
TRIPSmun$modo[TRIPSmun$Tipo_veiculo_2=="motorcycle and moped"]<-"Motorcycle"
TRIPSmun$modo[TRIPSmun$Tipo_veiculo_2=="bus and coach - TE"]<-"Transit"
TRIPSmun$modo[TRIPSmun$Tipo_veiculo_2=="bus and coach - TP"]<-"Transit"
TRIPSmun$modo[TRIPSmun$Tipo_veiculo_2=="Regular train"]<-"Transit"
TRIPSmun$modo[TRIPSmun$Tipo_veiculo_2=="Urban rail"]<-"Transit"
TRIPSmun$modo[TRIPSmun$Tipo_veiculo_2=="Waterways"]<-"Transit"
table(TRIPSmun$modo)

#remover viagens para fora da AML
DICOFRE_aml = readRDS("/media/rosa/Dados/GIS/MQAT/original/DICOFRE_aml.Rds")
table(TRIPSmun$DTCC_or)
DICOFRE_aml = DICOFRE_aml |>
  mutate(DTCC = as.character(DTCC)) 

library(readxl)
RelacaoFreguesiasINE20112016 <- read_excel("/media/rosa/Dados/GIS/CAOP/2020/RelacaoFreguesiasINE20112016.xlsx")
library(zoo)
RelacaoFreguesiasINE20112016$Dicofre = na.locf(RelacaoFreguesiasINE20112016$DICOFRE16) #preencher campos vazios com o último valor não NA
RelacaoFreguesiasINE20112016 = RelacaoFreguesiasINE20112016 |> select(Dicofre, DICOFRE11) |> distinct()

BGRI = st_read("/media/rosa/Dados/GIS/IMOB/GIS/INE2011_AML_DICOFREBGRI.shp") |> st_drop_geometry() |> as.data.frame()


#remover viagens para fora da AML
TRIPSmun = TRIPSmun |> 
  filter(DTCC_or %in% DICOFRE_aml$DTCC) |>
  filter(DTCC_de %in% DICOFRE_aml$DTCC) |> 
  filter(!is.na(DTCC_or11), !is.na(DTCC_de11))

sum(TRIPSmun$PESOFIN) #5266475 humm


# create dicofre variable (dt + cc + fr) and bgri (++Sec + SS)
TRIPSmun = TRIPSmun |>
  mutate(Origin_bgri11 = paste0(DTCC_or11, FR_or11, Sec_or11, SS_or11),
         Destination_bgri11 = paste0(DTCC_de11, FR_de11, Sec_de11, SS_de11))

# use bgri after 2016 - there are some freguesias that were split!
TRIPSmun = TRIPSmun |> left_join(BGRI |> select(BGRI11, Dicofre),
                                   by=c("Origin_bgri11" = "BGRI11")) |> rename(Origin_dicofre16 = Dicofre)
TRIPSmun = TRIPSmun |> left_join(BGRI |> select(BGRI11, Dicofre),
                                   by=c("Destination_bgri11" = "BGRI11")) |> rename(Destination_dicofre16 = Dicofre)

# create municipal variable (dt + cc 2016)
TRIPSmun = TRIPSmun |>
  mutate(Origin_mun16 = substr(Origin_dicofre16, 1, 4),
         Destination_mun16 = substr(Destination_dicofre16, 1, 4))

sum(TRIPSmun$PESOFIN) #5299848 ok

# join with sd individuos

TRIPSmun = TRIPSmun |> ungroup() |> 
  left_join(INDIVIDUOS |> select(Id_aloj_1, N_Individuo, Sexo_Dsg, Idade_Cod_Dsg, Parentesco_Dsg, 
                                 Nivel_Instr_Cod_Dsg, Cond_Trab_Cod_Dsg, Mob_Reduz1_Dsg, Carta_C1,
                                 Carta_C2, Carta_C3, Carta_C4, Conduz_Dsg, Exist_Passe_Dsg, Ltrab_Tipo_Dsg,
                                 Estaci_Trab1, Estaci_Escol1),
            by = c("Id_aloj_1", "N_Individuo"))

TRIPSmun = TRIPSmun |> ungroup() |> 
  left_join(ALOJAMENTOrendimentos |> select(Id_aloj_1, Rendimento_Dsg))

TRIPSmun = TRIPSmun |> ungroup() |> 
  left_join(ALOJAMENTOveiculosN |> rename(N_Automoveis = `V0100 1`,
                                          N_VMercadorias = `V0100 2`,
                                          N_Motociclos = `V0100 3`,
                                          N_VOutros = `V0100 4`,
                                          N_Bicicletas = `V0100 5`,
                                          NaoDispoeVeiculos = `V0100 N`
))

TRIPSmun = TRIPSmun |> ungroup() |> 
  left_join(ALOJAMENTOdespesa |> select(Id_aloj_1, Desp_Comb_Esc_Dsg, Desp_Tp_Esc_Dsg, Desp_Esta_Esc_Dsg, Desp_Port_Esc_Dsg))

# remover e ordenar colunas que não interessam
names(TRIPSmun)
TRIPSmun_allvars = TRIPSmun |> select(Id_aloj_1, Id_aloj_2, PESOFIN, N_Individuo, N_Desloc, 
                                      D0500_Dsg, Dia_da_semana, Hora_partida, Hora_chegada, Duracao, Distancia,
                                      Origin_mun16, Origin_dicofre16, Destination_mun16, Destination_dicofre16, 
                                      modo, ET1_Titulo_transp, ET_1_passageiros, Sexo_Dsg, Idade_Cod_Dsg, Parentesco_Dsg, 
                                      Nivel_Instr_Cod_Dsg, Rendimento_Dsg, Cond_Trab_Cod_Dsg, Mob_Reduz1_Dsg, Carta_C1,
                                      Carta_C2, Carta_C3, Carta_C4, Conduz_Dsg, Exist_Passe_Dsg, Ltrab_Tipo_Dsg,
                                      Estaci_Trab1, Estaci_Escol1, N_Automoveis, N_VMercadorias, 
                                      N_Motociclos, N_VOutros, N_Bicicletas, NaoDispoeVeiculos, 
                                      Desp_Comb_Esc_Dsg, Desp_Tp_Esc_Dsg, Desp_Esta_Esc_Dsg, 
                                      Desp_Port_Esc_Dsg)

names(TRIPSmun_allvars)
TRIPSmun_allvars = data.frame(TRIPSmun_allvars)

library(openxlsx)
IMOB_classes = createWorkbook()
addWorksheet(IMOB_classes, "Data", tabColour = "orange")
addWorksheet(IMOB_classes, "Opinions", tabColour = "purple")
writeDataTable(IMOB_classes, sheet = "Data", x = TRIPSmun_allvars)
writeDataTable(IMOB_classes, sheet = "Opinions", x = ALOJAMENTOopinioes)
saveWorkbook(IMOB_classes, "/media/rosa/Dados/GIS/MQAT/original/TRIPSmun_allvars.xlsx", overwrite = TRUE)

# openxlsx::write.xlsx(TRIPSmun_allvars, "/media/rosa/Dados/GIS/MQAT/original/TRIPSmun_allvars.xlsx", sheetName = "Data", asTable = TRUE, overwrite = TRUE)
# openxlsx::write.xlsx(ALOJAMENTOopinioes, "/media/rosa/Dados/GIS/MQAT/original/TRIPSmun_allvars.xlsx", sheetName = "Opinioes", asTable = TRUE)

# write.xlsx(TRIPSmun_allvars, "/media/rosa/Dados/GIS/MQAT/original/TRIPSmun_allvars.xlsx",
#                  sheetName = "IMOB",
#                  row.names = FALSE)

piggyback::pb_upload("/media/rosa/Dados/GIS/MQAT/original/TRIPSmun_allvars.xlsx",
                      repo = "U-Shift/MQAT")

saveRDS(TRIPSmun_allvars, "/media/rosa/Dados/GIS/MQAT/original/TRIPSmun_allvars.Rds")




# separate in municipalities of residence ---------------------------------

DTCCname = DICOFRE_aml |> select(DTCC, CONCELHO_DSG) |> 
  distinct() |> 
  rename(DTCC_aloj = DTCC) |> 
  mutate(DTCC_aloj = as.integer(DTCC_aloj))

TRIPSmun_allvars_aloj = TRIPSmun_allvars |> 
  left_join(ALOJAMENTO |> select(Id_aloj_1, DTCC_aloj, Zona_aloj)) |> 
  left_join(DTCCname)

for (i in DTCCname$DTCC_aloj) {
  TRIPSmun_allvars_aloj_i =  TRIPSmun_allvars_aloj |> filter(DTCC_aloj == i)
  familias_i = TRIPSmun_allvars_aloj_i$Id_aloj_1 |> unique()
  ALOJAMENTOopinioes_i = ALOJAMENTOopinioes |> filter(Id_aloj_1 %in% familias_i)
  nome = DTCCname$CONCELHO_DSG[DTCCname$DTCC_aloj == i]
  
  IMOB_classes_i = createWorkbook()
  addWorksheet(IMOB_classes_i, "Data", tabColour = "orange")
  addWorksheet(IMOB_classes_i, "Opinions", tabColour = "purple")
  writeDataTable(IMOB_classes_i, sheet = "Data", x = TRIPSmun_allvars_aloj_i)
  writeDataTable(IMOB_classes_i, sheet = "Opinions", x = ALOJAMENTOopinioes_i)
  saveWorkbook(IMOB_classes_i, paste0("/media/rosa/Dados/GIS/MQAT/original/TRIPSmun_", nome,".xlsx"), overwrite = TRUE)
  
  piggyback::pb_upload(paste0("/media/rosa/Dados/GIS/MQAT/original/TRIPSmun_", nome,".xlsx"),
                       repo = "U-Shift/MQAT")
}


# separate Lisbon in 3 areas ---------------------------------
## Freguesias - não existem na base de ALOJAMENTO
# Lisbon_north = c("110608", "110610", "110639", "110654", "110611", "110618", "110664")
# Lisbon_center = c("110658", "110601", "110602", "110660", "110659", "110661", "110666", "110656", "110667", "110657") # passar 57 para norte?
# Lisbon_west = c("110663", "110607", "110655", "110621", "110633", "110662")

## Zonas
Lisbon_north = c(2)
Lisbon_south = c(1, 5)
Lisbon_west = c(3,4)

Lisbon_3p = c("Lisbon_north", "Lisbon_south", "Lisbon_west") #center

for (j in Lisbon_3p) {
  TRIPSmun_allvars_aloj_j =  TRIPSmun_allvars_aloj|> filter(DTCC_aloj == 1106, Zona_aloj %in% get(j))
  familias_j = TRIPSmun_allvars_aloj_j$Id_aloj_1 |> unique()
  ALOJAMENTOopinioes_j = ALOJAMENTOopinioes |> filter(Id_aloj_1 %in% familias_j)
  nome = j
  
  IMOB_classes_j = createWorkbook()
  addWorksheet(IMOB_classes_j, "Data", tabColour = "orange")
  addWorksheet(IMOB_classes_j, "Opinions", tabColour = "purple")
  writeDataTable(IMOB_classes_j, sheet = "Data", x = TRIPSmun_allvars_aloj_j)
  writeDataTable(IMOB_classes_j, sheet = "Opinions", x = ALOJAMENTOopinioes_j)
  saveWorkbook(IMOB_classes_j, paste0("/media/rosa/Dados/GIS/MQAT/original/TRIPSmun_", nome,".xlsx"), overwrite = TRUE)

  print(length(unique(TRIPSmun_allvars_aloj_j$Id_aloj_1)))
}


# Aloj Lisbon_north = 1152
# Aloj Lisbon_south = 1907
# Aloj Lisbon_west = 1914

# separate Lisbon in 5 zones ---------------------------------
## Zonas
Lisbon_zones = c(1:5) #center

for (k in Lisbon_zones) {
  TRIPSmun_allvars_aloj_k = TRIPSmun_allvars_aloj|> filter(DTCC_aloj == 1106, Zona_aloj == k)
  familias_k = TRIPSmun_allvars_aloj_k$Id_aloj_1 |> unique()
  ALOJAMENTOopinioes_k = ALOJAMENTOopinioes |> filter(Id_aloj_1 %in% familias_k)
  nome = paste0("Lisbon_zona", k)
  
  IMOB_classes_k = createWorkbook()
  addWorksheet(IMOB_classes_k, "Data", tabColour = "orange")
  addWorksheet(IMOB_classes_k, "Opinions", tabColour = "purple")
  writeDataTable(IMOB_classes_k, sheet = "Data", x = TRIPSmun_allvars_aloj_k)
  writeDataTable(IMOB_classes_k, sheet = "Opinions", x = ALOJAMENTOopinioes_k)
  saveWorkbook(IMOB_classes_k, paste0("/media/rosa/Dados/GIS/MQAT/original/TRIPSmun_", nome,".xlsx"), overwrite = TRUE)
  
  print(length(unique(TRIPSmun_allvars_aloj_k$Id_aloj_1)))
}
