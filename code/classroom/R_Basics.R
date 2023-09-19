
#INTRODUCTION TO R PROGRAMMING


# 1. Initial steps - Importing dataset and libraries 

    # First import the file "TRIPSmode_mun.Rds" 

      Data_original <- readRDS("data/TRIPSmode_mun.Rds")  # you may call a database by using <- or =

    #' *Note:* It is good practice to not use the original dataset.



    # Assign the original dataset to a new database
      Data = Data_original

      
    # Install libraries

      install.packages(tidyverse)

    # Import library
      library(tidyverse) # Most common library used for Data Science

    # Another alternative to install the package.  
    # Go to Packages on the lower right display window and click install
    # Write the library you want to install and click “install”


# 2. Take a first look at the data

    # Summary statistics  
      summary(Data)
  
    # First 10 values of each variable
      head(Data)
  
    # Take a look at the dataset
      View(Data)
  
    # Check the number of rows (observations) and columns (variables)
  
      nrow(Data)
  
      ncol(Data)
    

# 3. Basic operations

    # Check the total of trips

      sum(Data$Total)  # Use '$' to select a variable of the Data

    # Percentage of car trips related to the total

      sum(Data$Car)/sum(Data$Total) * 100

    # Percentage of active modes related to the total

      (sum(Data$Walk)+ sum(Data$Bike)) / sum(Data$Total) * 100
      

# 4. Modify original dataset

    # a) Create a column of number of trips for active modes

      Data$Active = Data$Walk + Data$Bike

  
    # b) Filter by condition
    # Let's say we only want to analyze trips from Lisbon. We can then filter and create a new database
  
      Data_Lisbon = filter(Data, Origin_mun == "Lisboa")  #Only for rows
  
      Data_Out_Lisbon = filter(Data, Origin_mun != "Lisboa")

      Data_in_Out_Lisbon = filter(Data, Origin_mun == "Lisboa" & Destination_mun == "Lisboa")
  
  
  
    # c) Take out a first column that is not needed (different ways to do the same operation)
  
      Data_Lisbon = Data_Lisbon[,-1] #The first row and column have the id of "1"
  
      # Data_Lisbon = select(Data_Lisbon,-1)  # Only for columns
  
      # Data_Lisbon = select(Data_Lisbon,-Origin_mun)  # Only for columns
  
  
#' *Note:* The functions "filter" is for rows, and "select" for columns. 
    
    
    # d) Exclude some columns of the database
    
      # Create a table with only columns with "Destination_mun" and "Total"
        Data_Total_Mun = select(Data_Lisbon, c(Destination_mun, Total))
  
      # Create a table with only columns with "Destination_mun" and "PTransit"
        Data_PT = Data_Lisbon[,c(1,6)]
  
      # Create a table with only columns with "Walk","Bike" and "Car"
        Data_Modes = Data_Lisbon[,c(3:5)]
  
  
# 5. Export "Data_Lisbon" in different formats
  
    # a) Excel
      # Install the package in case you never used it.
        install.packages("xlsx") 
  
      # Import Library
        library("xlsx")
      
      # Export file 
        write.xlsx(Data_Lisbon, 'Data_Lisbon.xlsx')
  
    #b) Csv
        write.csv(Data_Lisbon, 'Data_Lisbon.csv', row.names = FALSE) # "row.names" when FALSE excludes line numbers
  
    #c) Rds - native format of R
        saveRDS(Data_Lisbon, 'Data_Lisbon.Rds')
  