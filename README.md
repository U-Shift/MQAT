# Quantitative Methods of Analysis in Transportation 
Materials to be used at the [MQAT course](https://fenix.tecnico.ulisboa.pt/disciplinas/MQAT11/2024-2025/1-semestre)

## Includes

* R script to prepare the databases
* R scripts for a "follow-me" classes
* db on IMOB trips AML 2018 (see [INE 2018](https://www.ine.pt/xportal/xmain?xpid=INE&xpgid=ine_publicacoes&PUBLICACOESpub_boui=349495406&PUBLICACOESmodo=2&&fbclid=IwAR2QzUZK0mUSEdKySZe1HqmObblKWR62vIyVhtVAAxrQhyNllna-DDfp2bk&xlang=pt))
* db of AML administrative boundaries and areas at _freguesia_ level (DICOFRE), from CAOP 2022 (see [DGTerritório/CAOP](https://www.dgterritorio.gov.pt/cartografia/cartografia-tematica/caop))
* db of socio-demographic statistics from Census 2021 for the AML at BGRI level (see [INE Census 2021](https://mapas.ine.pt/download/index2021.phtml) for other downloads)
    * includes [this variables](https://mapas.ine.pt/download/C2021_FSINTESE_VARIAVEIS.csv)

## Download R and RStudio

[Instructions for installing R and RStudio](Software_install.md). Note that it is very important to install first R and then RStudio. 
    
## For classes and home assignments

### Introduction to R

* Script of R basics - [R_Basics.R](https://github.com/U-Shift/MQAT/blob/main/code/classroom/R_Basics.R)
* Database of IMOB trips at municipal level: [TRIPSmode_mun.Rds](https://github.com/U-Shift/MQAT/raw/main/data/TRIPSmode_mun.Rds)

### Multiple Linear Regression

R script for [Multiple Linear Regression](code/MultipleLinearRegression.R)

Variables included in [MODEL database](https://github.com/U-Shift/MQAT/blob/main/data/IMOBmodel.Rda):

* `Origin_dicofre16` - Code of _Freguesias_ as set by INE after 2016 (_Distrito_ + _Concelho_ + _Freguesia_)
* `Total` - number of trips with origin in `Origin_dicofre16`
* `Walk` - number of walking trips with origin in `Origin_dicofre16`
* `Bike` - number of bike trips with origin in `Origin_dicofre16`
* `Car` - number of car trips with origin in `Origin_dicofre16`. Includes taxi and motorcycle.
* `PTransit` - number of Public Transit trips with origin in `Origin_dicofre16`
* `Other` - number of other trips (truck, van, tractor, aviation) with origin in `Origin_dicofre16`
* `Distance` - average trip distance (km) with origin in `Origin_dicofre16`
* `Duration` - average trip duration (minutes) with origin in `Origin_dicofre16`
* `Car_perc` - percentage of car trips with origin in `Origin_dicofre16`
* `N_INDIVIDUOS` - number of residents in `Origin_dicofre16` (Censos 2021)
* `Male_perc` - percentage of male residents in `Origin_dicofre16` (Censos 2021)
* `IncomeHH` - average household income in `Origin_dicofre16`
* `Nvehicles` - average number of car/motorcycle vehicles in the household in `Origin_dicofre16`
* `DrivingLic` - percentage of car driving licence holders in `Origin_dicofre16`
* `CarParkFree_Work` - percentage of respondents with free car parking at the work location, in `Origin_dicofre16`
* `PTpass` - percentage of public transit monthly pass holders in `Origin_dicofre16`
* `internal` - binary variable (factor). "Yes": internal trips in that _freguesia_ (`Origin_dicofre16`), "No": external trips from that _freguesia_
* `Lisboa` - binary variable (factor). "Yes": the _freguesia_ is part of Lisbon municipality, "No": otherwise
* `Area_km2` - area of in `Origin_dicofre16`, in km2

### Factor and Cluster Analysis

* R script for [Exploratory Factor Analysis](https://github.com/U-Shift/Transport-Demand-Modelling/blob/master/3-FactorAnalysis.md)
* R script for [Cluster Analysis](https://github.com/U-Shift/Transport-Demand-Modelling/blob/master/4-ClusterAnalysis.md)

#### Other materials

* [Getting Started with Data in R](https://moderndive.netlify.app/1-getting-started.html)
* [A gentle introduction to tidy statistics in R (video)](https://posit.co/resources/videos/a-gentle-introduction-to-tidy-statistics-in-r/)
* [Work with data, Tidy your data, Report reproducibility (tutorials)](https://posit.cloud/learn/primers)
* [Intro to R basics (free online course)](https://www.datacamp.com/courses/free-introduction-to-r)
* [Data Frames in R (free online course with video)](https://www.classcentral.com/classroom/youtube-free-r-training-data-frames-in-r-91879)

* [CheatSheet of Data transformation with `dplyr`](https://rstudio.github.io/cheatsheets/data-transformation.pdf): pay attention to filter(), select(), distinct(), arrange(), mutate(), group_by() & summarize(), left_join()
* [CheatSheet of Data transformation with `tidyr`](https://rstudio.github.io/cheatsheets/tidyr.pdf): pay attention to pivot_longer(), pivot_wider()