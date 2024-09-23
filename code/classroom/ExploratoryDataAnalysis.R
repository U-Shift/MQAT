# EXPLORATORY DATA ANALYSIS

# The database used in this example is a treated database from the Mobility Survey.   
# executed for the metropolitan areas of Lisbon and Porto in 2018 (IMOB 2018).
# We will only focus on trips within the metropolitan area of Lisbon. 

# Variables

  #'*Origin_dicofre16* - Code of Freguesias as set by INE after 2016 (Distrito + Concelho + Freguesia)
  #'*Total* - number of trips with origin in Origin_dicofre16
  #'*Walk* - number of walking trips with origin in Origin_dicofre16
  #'*Bike* - number of bike trips with origin in Origin_dicofre16
  #'*Car* - number of car trips with origin in Origin_dicofre16. Includes taxi and motorcycle.
  #'*PTransit* - number of Public Transit trips with origin in Origin_dicofre16
  #'*Other* - number of other trips (truck, van, tractor, aviation) with origin in Origin_dicofre16
  #'*Distance* - average trip distance (km) with origin in Origin_dicofre16
  #'*Duration* - average trip duration (minutes) with origin in Origin_dicofre16
  #'*Car_perc* - percentage of car trips with origin in Origin_dicofre16
  #'*N_INDIVIDUOS* - number of residents in Origin_dicofre16 (Censos 2021)
  #'*Male_perc* - percentage of male residents in Origin_dicofre16 (Censos 2021)
  #'*IncomeHH* - average household income in Origin_dicofre16
  #'*Nvehicles* - average number of car/motorcycle vehicles in the household in Origin_dicofre16
  #'*DrivingLic* - percentage of car driving licence holders in Origin_dicofre16
  #'*CarParkFree_Work* - percentage of respondents with free car parking at the work location, in Origin_dicofre16
  #'*PTpass* - percentage of public transit monthly pass holders in Origin_dicofre16
  #'*internal* - binary variable (factor). "Yes": internal trips in that freguesia (Origin_dicofre16), "No": external trips from that freguesia
  #'*Lisboa* - binary variable (factor). "Yes": the freguesia is part of Lisbon municipality, "No": otherwise
  #'*Area_km2* - area of in Origin_dicofre16, in km2

# 1. Initial Steps

    # Install Libraries
    #   For the first time, you will need to install some of the packages. 
    #     Step by step: 
 
    #       1. Go to Packages on the lower right display window and click install
    #       2. Write the library you want to install and click "install"
   
    #           Or... `install.packages("readxl","tidyverse")` etc...
 
    #       Depending on the version of your R, `DataExplorer` may need to be installed from source, such as

    #   if (!require(devtools)) install.packages("devtools")
    #   devtools::install_github("boxuancui/DataExplorer")


    # Import Libraries

      library(tidyverse) # Pack of most used libraries for data science
      library(skimr) # Library used for providing a summary of the data
      library(DataExplorer) # Library used in data science to perform exploratory data analysis
      library(corrplot) # Library used for correlation plots


# Import dataset
 
      dataset <- readRDS("data/IMOBmodel.Rds")

# Take a look at the dataset
 
    # Check the summary statistics
      summary(dataset)
      
    # Check the structure of the dataset 
      str(dataset)

    # Take a first look at the dataset
      head(dataset, 10)

    # Check the type and class of the dataset
      typeof(dataset)
      class(dataset)

# Transform the dataset into a dataframe
      df <- data.frame(dataset)

      #' *Note:* Most libraries work with dataframes. It is good practice to always transform the dataset to dataframe format.       

      # Compare the structure of the `dataset` with `df`
 
        str(dataset)
        str(df)

        class(dataset)
        class(df)

        
# Show summary statistics of the dataframe
 
      skim(df)
    
# 5. Identify missing data
 
    # Is there missing data? How many?
      table(is.na(df))

    # Plot the percentage of missing data
      plot_missing(df)
      
# Detect outliers  
 
    # In order to detect outliers and do correlations (further in the exercise),it is necessary to have only continuous variables.
    
    # a) Create a new database only with continuous variables. 

      str(df)
      
      df_continuous = df[,-c(1,18,19)]
   
      boxplot(df_continuous, las = 2)

    # b) Take out the outliers from the variable Total

    # Create function "outlier"
      outlier <- function(x){
        quant <- quantile(x, probs=c(0.25, 0.75))
        caps <- quantile(x, probs=c(0.05, 0.95))
        H <- 1.5* IQR(x, na.rm = TRUE)
        x[x < (quant[1] - H)] <- caps[1]
        x[x > (quant[2] + H)] <- caps[2]
        return(x)
        }

    # Assign the same database for df_outliers
  
      df_outliers = df_continuous
  
    # Take out the outliers in the variable Total
  
      df_outliers$Total = outlier(df_continuous$Total)

 
    # c) Take a look again at the boxplots
 
      boxplot(df_outliers)

        # Compare results of the dataset with and without the outliers  
  
          # Calculate the mean
  
            mean(df$Total)
            mean(df_outliers$Total)

          # Calculate the median
            median(df$Total)
            median(df_outliers$Total)

          # Variance
            var(df$Total)
            var(df_outliers$Total)

#' *Note:* There are many methods to treat outliers. This is just one of them.
  # In the next lecture we will demonstrate other methods of detecting outliers such as the Cook distance and QQ plot.    

# Histograms
    
      # a) Plot histograms of all the continuous variables
      plot_histogram(df, ncol = 3) #with 3 columns
      
    # b) Check how other variables 
    #' How do the other variables behave regarding *Car_perc*
    #' Plot boxplots of each independent variable with *Car_perc*

      plot_boxplot(df, by = "Car_perc", ncol = 3)

#' *Note*: If you increase the "Car_perc", it will decrease PTpass. Take a look at the relation with the other variables. 
#' 

# 8. Correlations
    
    # Plot correlation heatmaps
  
#' *Note:* Correlations are only between continuous variables. 
  
      res <- cor.mtest(df_continuous, conf.level = .95) #store the results so you can call the p-value at the corrplot

      corrplot(cor(df_continuous), p.mat = res$p, method = "circle", type = "upper", order="hclust", sig.level = 0.05)

#' *Note:* The pairwise correlations that are crossed are statistically insignificant. 
#  The null hypothesis is that correlation is zero. 
#  This means that the correlations are only significant when you reject the null hypothesis (pvalue < 0.05).
   
#' See `?corrplot` for more options.  
#  Try putting into method "color" or "circle", and see the difference.  

    # Check the _pvalue_ of a crossed pair correlation: 
 
      cor.test(df_continuous$IncomeHH, df_continuous$Other)

      cor.test(df_continuous$IncomeHH, df_continuous$Duration)

# The default for `cor.test` is Pearson, two-sided, with a 95% confident level. Check `?cor.test` for more options.  