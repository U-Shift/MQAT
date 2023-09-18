
## viagens totais com ORIGEM numa freg
TRIPSmode_freg_OR = TRIPSmode_freg |> 
  # filter(Origin_dicofre16 != Destination_dicofre16) |> # sem viagens DENTRO da freguesia
  mutate(internal = ifelse(Origin_dicofre16 != Destination_dicofre16, 1, 0)) |> 
  mutate(internal = factor(internal, labels = c("Yes", "No"))) |> 
  group_by(Origin_dicofre16, internal) |> 
  summarise_if(is.numeric, sum) |> 
  ungroup() |> 
  mutate(Lisboa = as.numeric(Origin_dicofre16)) |> 
  mutate(Lisboa = ifelse(Lisboa < 110600 | Lisboa >= 110700, 0, 1)) |> 
  mutate(Lisboa = factor(Lisboa, labels = c("No", "Yes"))) |> 
  left_join(CENSOS21_freg_gender |> select(-N_INDIVIDUOS_H, -Male_perc),
            by = c("Origin_dicofre16" = "DTMNFR21"))

MODEL1 = TRIPSmode_freg_OR |> 
  mutate(Car_perc = 100*Car/Total) |> 
  left_join(IMOBsd_freg |> select(-N_INDIVIDUOS), by = c("Origin_dicofre16" = "Dicofre")) |> 
  left_join(TRIPSdur_freg, by = c("Origin_dicofre16" = "Dicofre"))

MODEL2 = MODEL1 |> 
  filter(Lisboa == "No",
         internal == "No")


# ver matriz correlacao
library(Hmisc)
library(corrplot)
library(ggcorrplot)

res<-cor(MODEL1[c(9,13:20)], method = "pearson", use = "complete.obs")
#round(res,2)
res_pval <- rcorr(as.matrix(MODEL1[c(9,13:20)],method = "pearson", use = "complete.obs")) #agora com p-values

corrplot(res, p.mat = res_pval$P, type = "upper", order = "FPC", method = "color",
         insig = "pch", pch.cex = .9,tl.col = "black")


# todas as variáveis
ml = lm(Car_perc ~ Male_perc + IncomeHH + Nvehicles + DrivingLic + CarParkFree_Work + PTpass + Distance + Duration + Lisboa + internal,
        data = MODEL1)
summary(ml)

# Lisboa e intra viagens como categóricas 
ml2 = lm(Car_perc ~ 
           # Male_perc +
           # IncomeHH +
           Nvehicles +
           DrivingLic +
           CarParkFree_Work +
           PTpass +
           Distance +
           # Duration +
           Lisboa +
           internal,
         data = MODEL1)
summary(ml2) 

# não tem Lisboa e intra freg, menos vars
ml3 = lm(Car_perc ~ 
           # Male_perc +
           # IncomeHH +
           Nvehicles +
           DrivingLic +
           CarParkFree_Work +
           PTpass +
           Distance, 
         # Duration
         data = MODEL2)
summary(ml3) 

# normalidade
shapiro.test(MODEL1$Car_perc) # humm
shapiro.test(MODEL2$Car_perc) #

ks.test(MODEL1$Car_perc, "pnorm", mean=mean(MODEL1$Car_perc), sd = sd(MODEL1$Car_perc))
ks.test(MODEL2$Car_perc, "pnorm", mean=mean(MODEL2$Car_perc), sd = sd(MODEL2$Car_perc))

nortest::ad.test(MODEL1$Car_perc)
nortest::ad.test(MODEL2$Car_perc)

# outros
car::durbinWatsonTest(ml2)
car::durbinWatsonTest(ml3)
summary(MODEL1$Car_perc)
hist(MODEL1$Car_perc)
plot(ml2)

olsrr::ols_vif_tol(ml2)
olsrr::ols_vif_tol(ml3)

olsrr::ols_eigen_cindex(ml2)
olsrr::ols_eigen_cindex(ml3)



# export
MODEL = MODEL1 |> select(c(1,3:8,20,21,11,10,14:19,2,9)) |>
  left_join(CENSOS21_freg |> ungroup() |> select(DTMNFR21, SHAPE_Area),
            by = c("Origin_dicofre16" = "DTMNFR21")) |> 
  mutate(Area_km2 = SHAPE_Area/1000000) |> 
  select(-SHAPE_Area)

saveRDS(MODEL, "data/IMOBmodel.Rda")
