## ------------------------------------------------------------------------------------------------------------------------------
library(tidyverse) # Pack of most used libraries for data science
library(skimr) # summary of the data
library(DataExplorer) # exploratory data analysis
library(corrplot) # correlation plots

library(car) # Testing autocorrelation (Durbin Watson)
library(olsrr) # Testing multicollinearity (VIF, TOL, etc.)


## ------------------------------------------------------------------------------------------------------------------------------
data = readRDS("data/IMOBmodel.Rds")
data_continuous = data |> select(-Origin_dicofre16, -internal, -Lisboa) # Exclude categorical variables


## ------------------------------------------------------------------------------------------------------------------------------
skim(data)


## ------------------------------------------------------------------------------------------------------------------------------
hist(data$Car_perc)


## ------------------------------------------------------------------------------------------------------------------------------
shapiro.test(data$Car_perc)


## ------------------------------------------------------------------------------------------------------------------------------
ks.test(
  data$Car_perc,
  "pnorm",
  mean = mean(data$Car_perc),
  sd = sd(data$Car_perc)
)


## ------------------------------------------------------------------------------------------------------------------------------
plot(x = data$Car_perc, y = data$Total, xlab = "Car_perc (%)", ylab = "Total (number of trips)")
plot(x = data$Car_perc, y = data$Walk, xlab = "Car_perc", ylab = "Walk")
plot(x = data$Car_perc, y = data$Bike, xlab = "Car_perc", ylab = "Bike")
plot(x = data$Car_perc, y = data$Car, xlab = "Car_perc", ylab = "Car")
plot(x = data$Car_perc, y = data$PTransit, xlab = "Car_perc", ylab = "PTransit")
plot(x = data$Car_perc, y = data$Other, xlab = "Car_perc", ylab = "Other")
plot(x = data$Car_perc, y = data$Distance, xlab = "Car_perc", ylab = "Distance")
plot(x = data$Car_perc, y = data$Duration, xlab = "Car_perc", ylab = "Duration")
plot(x = data$Car_perc, y = data$N_INDIVIDUOS, xlab = "Car_perc", ylab = "N_INDIVIDUOS")
plot(x = data$Car_perc, y = data$Male_perc, xlab = "Car_perc", ylab = "Male_perc")
plot(x = data$Car_perc, y = data$IncomeHH, xlab = "Car_perc", ylab = "IncomeHH")
plot(x = data$Car_perc, y = data$Nvehicles, xlab = "Car_perc", ylab = "Nvehicles")
plot(x = data$Car_perc, y = data$DrivingLic, xlab = "Car_perc", ylab = "Driving License")
plot(x = data$Car_perc, y = data$CarParkFree_Work, xlab = "Car_perc", ylab = "Free car parking at work")
plot(x = data$Car_perc, y = data$PTpass, xlab = "Car_perc", ylab = "PTpass")
plot(x = data$Car_perc, y = data$internal, xlab = "Car_perc", ylab = "internal trips")
plot(x = data$Car_perc, y = data$Lisboa, xlab = "Car_perc", ylab = "Lisboa")
plot(x = data$Car_perc, y = data$Area_km2, xlab = "Car_perc", ylab = "Area_km2")


## ------------------------------------------------------------------------------------------------------------------------------
# pairs(data_continuous, pch = 19, lower.panel = NULL) # we have too many variables, let's split the plots
pairs(data_continuous[,1:6], pch = 19, lower.panel = NULL)
pairs(data_continuous[,7:12], pch = 19, lower.panel = NULL)
pairs(data_continuous[,13:17], pch = 19, lower.panel = NULL)


## ------------------------------------------------------------------------------------------------------------------------------
names(data) # to see the names of the variables

model = lm(
  Car_perc ~ Total +
    Walk +
    Bike +
    Car +
    PTransit +
    Other +
    Distance + 
    Duration + 
    N_INDIVIDUOS + 
    Male_perc + 
    IncomeHH + 
    Nvehicles + 
    DrivingLic + 
    CarParkFree_Work + 
    PTpass + 
    internal + 
    Lisboa + 
    Area_km2,
  data = data
)

summary(model)


## ------------------------------------------------------------------------------------------------------------------------------
car::vif(model)


## ------------------------------------------------------------------------------------------------------------------------------
durbinWatsonTest(model)


## ------------------------------------------------------------------------------------------------------------------------------
plot(model)



