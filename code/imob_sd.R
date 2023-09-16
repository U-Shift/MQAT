# reduzir ao individuo, ponderar por pesofin
IMOBsd_freg = IMOBmore |> 
  left_join(IMOBaml_TUDOJUNTO |> select(Id_aloj_1, PESOFIN) |> distinct()) |> # get weight of household
  filter(!is.na(Id_aloj_2), !is.na(PESOFIN), !is.na(DTCC_de11)) |> 
  filter(D0500_Cod == 96) |>  # keep only the "Regressar a casa" trip purpose to get the destination dicofre
  select(Id_aloj_2, N_Individuo, DTCC_de11, FR_de11, Sec_de11, SS_de11, Cond_Trab_Cod_Dsg,
         Carta_C1, Exist_Passe, Ltrab_Tipo_Dsg, Estaci_Trab1, Estaci_Trab2, Nveiculos, Rendimento_Dsg, PESOFIN) |> 
  distinct(Id_aloj_2, N_Individuo, .keep_all = TRUE)  #remove duplicate "return home" trips
  
#  dicofre 21, using bgri, and remove household vars
IMOBsd_freg = IMOBsd_freg |> 
  mutate(BGRI11 = paste0(DTCC_de11, FR_de11, Sec_de11, SS_de11)) |> 
  left_join(BGRI |> select(BGRI11, Dicofre)) |> 
  select(-c(BGRI11, DTCC_de11, FR_de11, Sec_de11, SS_de11, Id_aloj_2, N_Individuo)) |> 
  filter(!is.na(Dicofre)) #remove households outside AML

sum(IMOBsd_freg$PESOFIN) #1933746 moving residents

# rendimento médio freguesia alojamento
# table(IMOBsd_freg$Rendimento_Dsg)
IMOBsd_freg = IMOBsd_freg |> 
  mutate(IncomeHH =  case_match(Rendimento_Dsg,
                                "Menos de 430 euros" ~ 400,
                                "De 430 até menos de 600 euros" ~ 515,
                                "De 600 até menos de 1000 euros" ~ 800,
                                "De 1000 até menos de 1500 euros" ~ 1250,
                                "De 1500 até menos de 2600 euros" ~ 2050,
                                "De 2600 até menos de 3600 euros" ~ 3100,
                                "De 3600 até menos de 5700 euros" ~ 4650,
                                "De 5700 até menos de 7000 euros" ~ 6350,
                                "7000 ou mais euros" ~ 7500,
                                "Ns/Nr" ~ NA)) |> 
  select(-Rendimento_Dsg)
weighted.mean(IMOBsd_freg$IncomeHH, IMOBsd_freg$PESOFIN, na.rm = TRUE) # 1750 €
  
# ter carta de condução 1 = Yes, 2 = No, 0 = Not aplicable
IMOBsd_freg = IMOBsd_freg |> 
  mutate(DrivingLic = case_match(Carta_C1,
                              0 ~ NA, #nao existe 
                              1 ~ 1,
                              2 ~ 0)) |> 
  select(-Carta_C1)

# ter passe social 1 = Yes, 2 = No
IMOBsd_freg = IMOBsd_freg |> 
  mutate(PTpass = case_match(Exist_Passe,
                                 0 ~ NA,
                                 1 ~ 1,
                                 2 ~ 0)) |> 
  select(-Exist_Passe)

# ocupação: trabalhador fora de casa, estudante, reformado e outros
# unique(IMOBsd_freg$Cond_Trab_Cod_Dsg)
# unique(IMOBsd_freg$Ltrab_Tipo_Dsg)
# não dá para separar estudante de trabalhador. Remover variaveis
IMOBsd_freg = IMOBsd_freg |> select(-Cond_Trab_Cod_Dsg, -Ltrab_Tipo_Dsg)


# ter estacionamento no local de trabalho
IMOBsd_freg = IMOBsd_freg |> 
  mutate(CarParkFree_Work = ifelse(Estaci_Trab1 == 1 | Estaci_Trab2 == 1 , 1, 
       ifelse(Estaci_Trab1 == 0 | Estaci_Trab2 == 0, NA, 0))) |> 
  select(-Estaci_Trab1, -Estaci_Trab2)

# nº veiculos origem alojamento - dont touch
names(IMOBsd_freg)
IMOBsd_freg = IMOBsd_freg |> 
  group_by(Dicofre) |> 
  summarise(nrespondants = n(),
            weigth = sum(PESOFIN),
            IncomeHH = weighted.mean(IncomeHH, PESOFIN, na.rm = TRUE),
            Nvehicles = weighted.mean(Nveiculos, PESOFIN, na.rm = TRUE),
            DrivingLic = weighted.mean(DrivingLic, PESOFIN, na.rm = TRUE), # will this return a % (between 0 and 1)?
            CarParkFree_Work = weighted.mean(CarParkFree_Work, PESOFIN, na.rm = TRUE),
            PTpass = weighted.mean(PTpass, PESOFIN, na.rm = TRUE)) |> 
  mutate(weigth = round(weigth, 2)) |> 
  mutate(IncomeHH = round(IncomeHH, 2)) |> 
  mutate(Nvehicles = round(Nvehicles, 2)) |> 
  mutate(DrivingLic = round(100 * DrivingLic, 2)) |> 
  mutate(CarParkFree_Work = round(100 * CarParkFree_Work, 2)) |> 
  mutate(PTpass = round(100 * PTpass, 2))

summary(IMOBsd_freg$IncomeHH)
summary(IMOBsd_freg$Nvehicles)
summary(IMOBsd_freg$DrivingLic)
summary(IMOBsd_freg$CarParkFree_Work)
summary(IMOBsd_freg$PTpass)
sum(IMOBsd_freg$weigth) # 1.933 k moving residents

# % genero em e total, pelos censos (ver censos_aml.R)
CENSOS21_freg_gender = CENSOS21_freg |> 
  ungroup() |> 
  select(DTMNFR21, N_INDIVIDUOS, N_INDIVIDUOS_H) |> 
  mutate(Male_perc = round(100*N_INDIVIDUOS_H/N_INDIVIDUOS, 2))

IMOBsd_freg = IMOBsd_freg |> 
  left_join(CENSOS21_freg_gender |> select(-N_INDIVIDUOS_H),
            by = c("Dicofre" = "DTMNFR21"))

IMOBsd_freg = IMOBsd_freg[c(1, 9, 2, 3, 10, 4:8)] #reorder

saveRDS(IMOBsd_freg, "data/IMOBsd_freg.Rds")


## distancia viagem média - ir à tabela original!
# duração viagem média
# relativamente à freguesia de origem da viagem!
TRIPSdur_freg = IMOBmore |>
  mutate(Duration = as.POSIXlt(Duracao, "%Y-%m-%d %H:%M:%S")) |>
  mutate(Duration = lubridate::hour(Duration)*60 + lubridate::minute(Duration) + lubridate::second(Duration)/60) |> 
  mutate(BGRI11 = paste0(DTCC_or11, FR_or11, Sec_or11, SS_or11)) |> 
  left_join(BGRI |> select(BGRI11, Dicofre)) |> 
  filter(!is.na(Dicofre)) |>  #remove trips outside AML
  group_by(Dicofre) |> 
  summarise(Distance = round(mean(Distancia, na.rm = TRUE)/1000, 3), #in km
            Duration = round(mean(Duration, na.rm = TRUE), 2)) #in minutes

summary(TRIPSdur_freg$Distance)
summary(TRIPSdur_freg$Duration)

saveRDS(TRIPSdur_freg, "data/TRIPSdur_freg.Rds")



