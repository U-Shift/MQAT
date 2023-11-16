# prepare data for ACST class

library(tidyverse)
library(sf)

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
