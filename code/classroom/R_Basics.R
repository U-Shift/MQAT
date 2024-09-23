
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

    # Assign the original dataset to a new database and transform in data.frame
      table = data.frame(Data_original)

# Take a first look at the data

      # Take a look at the dataset
      View(table)
          
      # Summary statistics  
      summary(table)
  
      # First 10 values of each variable
      head(table)
      
      # Structure
      str(table)
  
      # Check the number of rows (observations) and columns (variables)
  
      nrow(table)
  
      ncol(table)
    
# Basic operations

    # Check the total of trips

      sum(table$Total)  # Use '$' to select a variable of the Data

    # Percentage of car trips related to the total

      sum(table$Car)/sum(table$Total) * 100

    # Percentage of active modes related to the total

      (sum(table$Walk)+ sum(table$Bike)) / sum(table$Total) * 100
      

# Modify original dataset

    # a) Create a column of number of trips for active modes

      table$Active = table$Walk + table$Bike
      
      
    # b) Filter by condition
    # Let's say we only want to analyze trips from Lisbon. We can then filter and create a new database
  
      table_Lisbon = filter(table, Origin_mun == "Lisboa")  #Only for rows
  
      table_Out_Lisbon = filter(table, Origin_mun != "Lisboa") #different from Lisbon

      table_in_Out_Lisbon = filter(table, Origin_mun == "Lisboa" & Destination_mun == "Lisboa") #OD in Lisbon
  
      
    # c) Take out a "Active" column that is not needed 
  
      names(table)
      
      table_out_Active = table[,-9] #The first row and column have the id of "1"
  
      table_out_Active2 = select(table,-9)  # Only for columns
  
      table_out_Active3 = select(table,-Active)  # Only for columns
  
  
# The functions "filter" is for rows, and "select" for columns. 
    
    # d) Exclude some columns of the database
    
      # Create a table with only columns with "Destination_mun" and "Total"
        table_Total_Mun = select(table, c(Destination_mun, Total))
  
      # Create a table with only columns with "Destination_mun" and "PTransit"
        table_PT = table[,c(2,7)]
  
      # Create a table with only columns with "Walk","Bike" and "Car"
        table_Modes = table[,c(4:6)]
  
        
# Export "table_Modes" in different formats
      
    # a) Excel 
        write.xlsx(table_Modes, 'Data_Modes.xlsx')
  
    # b) Csv
        write.csv(table_Modes, 'Data_Modes.csv', row.names = FALSE) # "row.names" when FALSE excludes line numbers
  
    # c) Rds - native format of R
        saveRDS(table_Modes, 'Data_Modes.Rds')
        
# 6. Import saved file
        
        Excelsheet = read_excel("Data_Modes.xlsx")
        
        csv_file = read.csv("Data_Modes.csv")
  