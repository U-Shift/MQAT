
#Introduction to R

# First import the file "TRIPSmode_mun.Rds" 

Data_original <- readRDS("data/TRIPSmode_mun.Rds")

Data = Data_original

#Import libraries
library(tidyverse)

# Take a look at the data

  summary(Data)
  
  head(Data)
  
  View(Data)
  
  #Check the number of rows (observations) and columns (variables)
  
  nrow(Data)
  
  ncol(Data)

# 1. Basic operations

  #Check the total of trips

  sum(Data$Total)

  #Percentage of car trips related to the total

  sum(Data$Car)/sum(Data$Total) * 100

  #Percentage of active modes related to the total

  (sum(Data$Walk)+ sum(Data$Bike)) / sum(Data$Total) * 100


# 2. Modify original dataset

  # a) Create a column of number of trips for active modes

  Data$Active = Data$Walk + Data$Bike

  
  
  # b) Filter by condition
  # Let's say we only want to analyze trips from Lisbon. We can then filter and create a new database
  
  Data_Lisbon = filter(Data, Origin_mun == "Lisboa")  #Only for rows
  
  Data_Out_Lisbon = filter(Data, Origin_mun != "Lisboa")

  Data_in_Out_Lisbon = filter(Data, Origin_mun == "Lisboa" & Destination_mun == "Lisboa")
  
  
  
  # c) Take out a first column that is not needed
  
  Data_Lisbon = Data_Lisbon[,-1] #The first row and column have the id of "1"
  
  #Data_Lisbon = select(Data_Lisbon,-1)  # Only for columns
  
  #Data_Lisbon = select(Data_Lisbon,-Origin_mun)  # Only for columns
  
  
  # d) 
  #Create a table with only columns with "Destination_mun" and "Total"
  Data_Total_Mun = select(Data_Lisbon, c(Destination_mun, Total))
  
  #Create a table with only columns with "Destination_mun" and "PTransit"
  Data_PT = Data_Lisbon[,c(1,6)]
  
  #Create a table with only columns with "Walk","Bike" and "Car"
  Data_Modes = Data_Lisbon[,c(3:5)]
  
  
# 3. Export Data Lisbon in different formats
  
  #a) Excel
  library("xlsx")
  write.xlsx(Data_Lisbon, 'Data_Lisbon.xlsx')
  
  #b) Csv
  write.csv(Data_Lisbon, 'Data_Lisbon.csv', row.names = FALSE) #Excludes line number
  
  #c) Rds - native format of R
  saveRDS(Data_Lisbon, 'Data_Lisbon.Rds')
  