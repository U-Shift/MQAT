# Quantitative Methods of Analysis in Transportation 
 Materials to be used at the [MQAT course](https://fenix.tecnico.ulisboa.pt/cursos/mst/disciplina-curricular/845953938490333)

## Includes

* R script to prepare the databases
* R scripts for a "follow-me" classes
* db on IMOB trips AML 2018 (see [INE 2018](https://www.ine.pt/xportal/xmain?xpid=INE&xpgid=ine_publicacoes&PUBLICACOESpub_boui=349495406&PUBLICACOESmodo=2&&fbclid=IwAR2QzUZK0mUSEdKySZe1HqmObblKWR62vIyVhtVAAxrQhyNllna-DDfp2bk&xlang=pt))
* db of AML administrative boundaries and areas at _freguesia_ level (DICOFRE), from CAOP 2022 (see [DGTerritório/CAOP](https://www.dgterritorio.gov.pt/cartografia/cartografia-tematica/caop))
* db of socio-demographic statistics from Census 2021 for the AML at BGRI level (see [INE Census 2021](https://mapas.ine.pt/download/index2021.phtml) for other downloads)
    * includes [this variables](https://mapas.ine.pt/download/C2021_FSINTESE_VARIAVEIS.csv)
    
## For classes and home assignments

### Introduction to R

* Script of R basics - [R_Basics.R](https://github.com/U-Shift/MQAT/blob/main/code/classroom/R_Basics.R)
* Database of IMOB trips at municipal level: [TRIPSmode_mun.Rds](https://github.com/U-Shift/MQAT/raw/main/data/TRIPSmode_mun.Rds)


### Linear Regression

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
