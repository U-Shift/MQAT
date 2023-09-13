# aim: create OD trips dataset for AML, by dicofre and mode

library(dplyr)
library(sf)

TRIPSmode_freguesias = readRDS(url("https://github.com/U-Shift/biclar/releases/download/0.0.1/TRIPSmode_freguesias.Rds"))
TRIPSmode_freguesias_desirelines = TRIPSmode_freguesias
TRIPSmode_freguesias = TRIPSmode_freguesias %>% st_drop_geometry() %>% as.data.frame()

TRIPSmode_freguesias = TRIPSmode_freguesias %>% 
  mutate(Car = Car + CarP) %>% 
  select(-c(CarP, Active))

saveRDS(TRIPSmode_freguesias, "original/TRIPSmode_freguesias.Rds")


TRIPSmode_municipio = readRDS(url("https://github.com/U-Shift/biclar/releases/download/0.0.1/TRIPSmode_municipal.Rds"))
TRIPSmode_municipio = readRDS("original/TRIPSmode_municipal.Rds")
TRIPSmode_municipal = TRIPSmode_municipio
dput(names(TRIPSmode_municipal))
names(TRIPSmode_municipal) = c("Origin", "Destination", "mode", "trips")
saveRDS(TRIPSmode_municipal, "data/TRIPSmode_municipal.Rds")

IMOBrespondents = readRDS((url("https://github.com/U-Shift/biclar/releases/download/0.0.1/IMOBrespondents.Rds")))

FREGUESIASgeo = readRDS(url("https://github.com/U-Shift/biclar/releases/download/0.0.1/FREGUESIASgeo.Rds"))




# table(VIAGENSOD$Tipo_veiculo_2)
# Aviation           bus and coach - TE           bus and coach - TP 
# 107                         1143                         8242 
# Cycling         motorcycle and moped                        Other 
# 601                         1354                          590 
# passenger car - as driver passenger car - as passenger                Regular train 
# 57296                        14586                         4296 
# Táxi (como passageiro)                      unknown                   Urban rail 
# 416                         3961                         4034 
# van/lorry/tractor/camper                      Walking                    Waterways 
# 519                        23231                          368 


#summarize trips AML

TRIPSfreg <- readRDS("D:/GIS/IMOB/R/TRIPSod_original.Rds")
colnames(TRIPSfreg)
table(TRIPSfreg$Tipo_veiculo_2)

#remover viagens para fora da AML
DTCC_AMLisboa <- read_excel("D:/GIS/IMOB/DICOFRE_DTCC_AMLisboa.xlsx")
DTCC_AMLisboa$DTCC = as.character(DTCC_AMLisboa$DTCC)
table(TRIPSfreg$DTCC_or)
TRIPSfreg = TRIPSfreg[TRIPSfreg$DTCC_or %in% DTCC_AMLisboa$DTCC, ]
TRIPSfreg = TRIPSfreg[TRIPSfreg$DTCC_de %in% DTCC_AMLisboa$DTCC, ]
sum(TRIPSfreg$PESOFIN) #5.334.335


#dar nomes aos códigos
TRIPSfreg = left_join(TRIPSfreg, DTCC_AMLisboa, by=c("DTCC_or"="DTCC"))
TRIPSfreg = left_join(TRIPSfreg, DTCC_AMLisboa, by=c("DTCC_de"="DTCC"))
names(TRIPSfreg)[19] = "Origem"
names(TRIPSfreg)[20] = "Destino"

#reduzir para os seguintes modos: car, transit, motorcycle, bike, walk, other
TRIPSfreg$modo = "Other"
TRIPSfreg$modo[TRIPSfreg$Tipo_veiculo_2=="Cycling"]<-"Bike"
TRIPSfreg$modo[TRIPSfreg$Tipo_veiculo_2=="Walking"]<-"Walk"
TRIPSfreg$modo[TRIPSfreg$Tipo_veiculo_2=="passenger car - as driver"]<-"Car"
TRIPSfreg$modo[TRIPSfreg$Tipo_veiculo_2=="passenger car - as passenger"]<-"Car"
TRIPSfreg$modo[TRIPSfreg$Tipo_veiculo_2=="Táxi (como passageiro)"]<-"Car"
TRIPSfreg$modo[TRIPSfreg$Tipo_veiculo_2=="motorcycle and moped"]<-"Motorcycle"
TRIPSfreg$modo[TRIPSfreg$Tipo_veiculo_2=="bus and coach - TE"]<-"Transit"
TRIPSfreg$modo[TRIPSfreg$Tipo_veiculo_2=="bus and coach - TP"]<-"Transit"
TRIPSfreg$modo[TRIPSfreg$Tipo_veiculo_2=="Regular train"]<-"Transit"
TRIPSfreg$modo[TRIPSfreg$Tipo_veiculo_2=="Urban rail"]<-"Transit"
TRIPSfreg$modo[TRIPSfreg$Tipo_veiculo_2=="Waterways"]<-"Transit"
table(TRIPSfreg$modo)

#make long format
TRIPSfreg$Origin = paste0(TRIPSfreg$DTCC_or11,TRIPSfreg$FR_or11)
TRIPSfreg$Destination = paste0(TRIPSfreg$DTCC_de11,TRIPSfreg$FR_de11)
TRIPSmode = TRIPSfreg %>% group_by(Origin,Destination, modo) %>% summarise(trips=sum(PESOFIN)) %>% ungroup()
saveRDS(TRIPSmode, "data/TRIPSmode_freg.Rds")

#make wide format
TRIPSmodefreg = TRIPSmode %>% pivot_wider(id_cols = c(1,2), names_from = modo, values_from = trips)
TRIPSmodefreg[is.na(TRIPSmodefreg)] = 0
TRIPSmodefreg = TRIPSmodefreg[,c(1,2,4,7,8,3,5,6)]


TRIPSmodefreg$Total = rowSums(TRIPSmodefreg[,c(3:8)])
sum(TRIPSmodefreg$Total) #5.334.335 ok
saveRDS(TRIPSmodefreg, "data/TRIPSmodefreg.Rds")