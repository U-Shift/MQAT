library(tidyverse)

# what is the percentage of households in Lisbon with access to a car?

TRIPSmun_LISBOA = readxl::read_xlsx("D://GIS/MQAT/original/TRIPSmun_LISBOA.xlsx")

FAMILIES_LISBOA = TRIPSmun_LISBOA |> 
  select(Id_aloj_1, N_Automoveis, N_Bicicletas, PESOFIN) |>
  distinct()

table(FAMILIES_LISBOA$N_Automoveis)
table(FAMILIES_LISBOA$N_Bicicletas)

# each household has a representative weight, so we need to sum the PESOFIN to get the total number of households

FAMILIES_LISBOA = FAMILIES_LISBOA |> 
  mutate(Familias_Automoveis = ifelse(N_Automoveis > 0, PESOFIN, 0),
         Familias_Bicicletas = ifelse(N_Bicicletas > 0, PESOFIN, 0))


# now we can calculate the percentage of households with access to a car (N_Automoveis > 0)
sum(FAMILIES_LISBOA$Familias_Automoveis, na.rm = TRUE) / sum(FAMILIES_LISBOA$PESOFIN) * 100 #63.5 %
sum(FAMILIES_LISBOA$Familias_Bicicletas, na.rm = TRUE) / sum(FAMILIES_LISBOA$PESOFIN) * 100 #17.2 %
