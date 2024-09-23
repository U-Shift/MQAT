
# INTRODUCTION TO R PROGRAMMING

### Create a comment with `ctrl + shift + c`

# Comments help you organize your code. The software will not run the comment. 

# Math operations

    ## Sum

    1+1

    ## Subtraction

    5-2

    ## Multiplication

    2*2

    ## Division

    8/2

## Round the number

    round(3.14)
    round(3.14, 1) # The "1" indicates to round it up to 1 decimal digit.

# You can use help `?round` in the console to see the description of the function.
    
### Perform Combinations
    
    c(1, 2, 3)
    c(1:3) # The ":" indicates a range between the first and second numbers. 
    
#Try to write a combination with the number 10, 11, 56, 57,58
    
    #...

# Install libraries
    
    install.packages(c("tidyverse", "xlsx", "readxl"))
    
# Import library
    library(tidyverse) # Most common library used for Data Science 
    library(xlsx) # Export Excel files
    library(readxl)
    
    # Another alternative to install the package.  
    # Go to Packages on the lower right display window and click install
    # Write the library you want to install and click “install”
    
# Importing a table 
    
# Table: The number of trips between all municipalities in the Lisbon's Metropolitan Area (IMOB,2018).

    # First import the file "TRIPSmode_mun.Rds" 

      Data_original <- readRDS("data/TRIPSmode_mun.Rds")  
    # you may call a database by using <- or =

    # *Note:* It is good practice to not use the original dataset.

    # Assign the original dataset to a new database
      table = Data_original

# 2. Take a first look at the data

    # Summary statistics  
      summary(table)
  
    # First 10 values of each variable
      head(table)
  
    # Take a look at the dataset
      View(table)
  
    # Check the number of rows (observations) and columns (variables)
  
      nrow(table)
  
      ncol(table)
    
# 3. Basic operations

    # Check the total of trips

      sum(table$Total)  # Use '$' to select a variable of the Data

    # Percentage of car trips related to the total

      sum(table$Car)/sum(table$Total) * 100

    # Percentage of active modes related to the total

      (sum(table$Walk)+ sum(table$Bike)) / sum(table$Total) * 100
      

# 4. Modify original dataset

    # a) Create a column of number of trips for active modes

      table$Active = table$Walk + table$Bike
      
      
    # b) Filter by condition
    # Let's say we only want to analyze trips from Lisbon. We can then filter and create a new database
  
      table_Lisbon = filter(table, Origin_mun == "Lisboa")  #Only for rows
  
      table_Out_Lisbon = filter(table, Origin_mun != "Lisboa") #different from Lisbon

      table_in_Out_Lisbon = filter(table, Origin_mun == "Lisboa" & Destination_mun == "Lisboa") #OD in Lisbon
  
      
    # c) Take out a first column that is not needed (different ways to do the same operation)
  
      table_Lisbon = table_Lisbon[,-1] #The first row and column have the id of "1"
  
      # table_Lisbon = select(table_Lisbon,-1)  # Only for columns
  
      # table_Lisbon = select(table_Lisbon,-Origin_mun)  # Only for columns
  
  
# The functions "filter" is for rows, and "select" for columns. 
    
    
    # d) Exclude some columns of the database
    
      # Create a table with only columns with "Destination_mun" and "Total"
        table_Total_Mun = select(table_Lisbon, c(Destination_mun, Total))
  
      # Create a table with only columns with "Destination_mun" and "PTransit"
        table_PT = table_Lisbon[,c(1,6)]
  
      # Create a table with only columns with "Walk","Bike" and "Car"
        table_Modes = table_Lisbon[,c(3:5)]
  
        
# 5. Export "table_Lisbon" in different formats
      
      # Export file 
        write.xlsx(table_Lisbon, 'Data_Lisbon.xlsx')
  
    # b) Csv
        write.csv(table_Lisbon, 'Data_Lisbon.csv', row.names = FALSE) # "row.names" when FALSE excludes line numbers
  
    # c) Rds - native format of R
        saveRDS(table_Lisbon, 'Data_Lisbon.Rds')
        
# 6. Import saved file
        
        Excelsheet = read_excel("Data_Lisbon.xlsx")
        
        csv_file = read.csv("Data_Lisbon.csv")
  