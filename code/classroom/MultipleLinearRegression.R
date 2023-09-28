
 
# Example exercise: Trip production of the Metropolitan Area of Lisbon.

#' **Your task**: Estimate a linear regression model that predicts the car percentage per county.  
 
# Variables:
#' 
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
 
  # Let's begin!
 
    # Import Libraries
      library(tidyverse) # Pack of most used libraries
      library(skimr) # Library used for providing a summary of the data
      library(DataExplorer) # Library used in data science to perform exploratory data analysis
      library(corrplot) # Library used for correlation plots
      library(car) # Library used for testing autocorrelation (Durbin Watson)
      library(olsrr) # Library used for testing multicollinearity (VIF, TOL, etc.)
      library(corrplot) # For correlation plots

    # Import dataset and transform into dataframe
        dataset = readRDS("data/IMOBmodel.Rds")
        
        # Check the class
          class(dataset)

 
        # Transform the dataset into a dataframe
          df = data.frame(dataset)

#'*Assumption 1:* Dependent variable is continuous. 
    
    # Show summary statistics
      skim(df)
      summary(df)

    # Show boxplot
      boxplot(df$Distance)
      
      summary(df$Distance)
 
# Multiple Linear Regression
#' Equation with `Car_perc` as the dependent variable:  

# Checking assumptions
  # Before running the model, you need to check if the assumptions are met.
 
    # Linear relation
      
#'*Assumption 2:* There is a linear relationship between dependent variable (DV) and independent variables (IV)
 
    par(mfrow=c(2,3)) #set plot area as 2 rows and 3 columns
    
    plot(x = df$Car_perc, y = df$Total, xlab = "Car_perc (%)", ylab = "Total (number of trips)")  
    plot(x = df$Car_perc, y = df$Walk, xlab = "Car_perc", ylab = "Walk")  
    plot(x = df$Car_perc, y = df$Bike, xlab = "Car_perc", ylab = "Bike")  
    plot(x = df$Car_perc, y = df$Car, xlab = "Car_perc", ylab = "Car")  
    plot(x = df$Car_perc, y = df$PTransit, xlab = "Car_perc", ylab = "PTransit")
    plot(x = df$Car_perc, y = df$Other, xlab = "Car_perc", ylab = "Other")
    plot(x = df$Car_perc, y = df$Distance, xlab = "Car_perc", ylab = "Distance")
    plot(x = df$Car_perc, y = df$Duration, xlab = "Car_perc", ylab = "Duration")
    plot(x = df$Car_perc, y = df$N_INDIVIDUOS, xlab = "Car_perc", ylab = "N_INDIVIDUOS")
    plot(x = df$Car_perc, y = df$Male_perc, xlab = "Car_perc", ylab = "Male_perc")
    plot(x = df$Car_perc, y = df$IncomeHH, xlab = "Car_perc", ylab = "IncomeHH")
    plot(x = df$Car_perc, y = df$Nvehicles, xlab = "Car_perc", ylab = "Nvehicles")
    plot(x = df$Car_perc, y = df$DrivingLic, xlab = "Car_perc", ylab = "Driving License")
    plot(x = df$Car_perc, y = df$CarParkFree_Work, xlab = "Car_perc", ylab = "Free car parking at work")
    plot(x = df$Car_perc, y = df$PTpass, xlab = "Car_perc", ylab = "PTpass")
    plot(x = df$Car_perc, y = df$internal, xlab = "Car_perc", ylab = "internal trips")
    plot(x = df$Car_perc, y = df$Lisboa, xlab = "Car_perc", ylab = "Lisboa")
    plot(x = df$Car_perc, y = df$Area_km2, xlab = "Car_perc", ylab = "Area_km2")


    #' Or you could execute a pairwise scatterplot matrix, that compares every variable with each other: 
   
    pairs(df[,c(2:17,20)], pch = 19, lower.panel = NULL) #cannot put categorical and character variables in this function

    #This funciton is not visible with many variables. 
    #Try reducing the size. 

    pairs(df[,c(2:10)], pch = 19, lower.panel = NULL)

#'*Assumption 3:* The Dependent Variable should be normally distributed.  

  #' Check the histogram of `Car_perc`

    par(mfrow=c(1,1))
    hist(df$Car_perc)
  
  # If the sample is smaller than 50 observations, use Shapiro-Wilk test: 

    shapiro.test(df$Car_perc)

  # If not, use the Kolmogorov-Smirnov test
 
    ks.test(df$Car_perc, "pnorm", mean=mean(df$Car_perc), sd = sd(df$Car_perc))

#' The null hypothesis of both tests is that the distribution is normal. 
#' Therefore, for the distribution to be normal, the pvalue > 0.05 and you should not reject the null hypothesis.

#'* Multiple linear regression model*
    
#' Check the correlation plot before choosing the variables. 


  model <- lm(Car_perc ~ Total +
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
              data = df)
summary(model)

#'*Tip:* Use the function `names(df)` in the console to obtain the names of the variables.  
#'*Tip:* Use ctrl+shift+c to comment a variable
 
#' **Assessing the model**:
 
#' 1. First check the **pvalue** and the **F statistics** of the model to see if there is any statistical relation 
#' between the dependent variable and the independent variables. 
#' If pvalue < 0.05 and the F statistics > Fcritical = 2,39, then the model is statistically acceptable.  

#' 2. The **R-square** and **Adjusted R-square** evaluate the amount of variance that is explained by the model. 
#' The difference between one and another is that the R-square does not consider the number of variables.
#' If you increase the number of variables in the model, the R-square will tend to increase which can lead to overfitting. 
#' On the other hand, the Adjusted R-square adjust to the number of independent variables. 
 
#' 3. Take a look at the **t-value** and the Pr(>|t|). 
#' If the t-value > 1,96 or Pr(>|t|) < 0,05, then the IV is statistically significant to the model.
   
#' 4. To analyze the **estimates** of the variables, you should first check the **signal** 
#' and evaluate if the independent variable has a direct or inverse relationship with the dependent variable. 
#' It is only possible to evaluate the **magnitude** of the estimate if all variables are continuous and standardized 
#' or by calculating the elasticities. The elasticities are explained and demonstrated in chapter 4. 

#' Residuals
#' Check the following assumptions

#' *Assumption 4:* The error (E) is independent across observations and the error variance is constant across IV – Homoscedasticity
#' *Assumption 5:* Disturbances are approximately normally distributed

#' * **Residuals vs Fitted:** This plot is used to detect non-linearity, heteroscedasticity, and outliers. 

#' **Normal Q-Q:** The quantile-quantile (Q-Q) plot is used to check if the disturbances follow a normal distribution.

#' * **Scale-Location:** This plot is used to verify if the residuals are spread equally (homoscedasticity) or not 
#' (heteroscedasticity) through the sample. 
#' * **Residuals vs Leverage:** This plot is used to detect the impact of the outliers in the model. 
#' If the outliers are outside the Cook-distance, this may lead to serious problems in the model. 
 
#' Try analyzing the plots and check if the model meets the assumptions. 
    par(mfrow=c(2,2))
    plot(model)

 
#' *Assumption 6:* Non-autocorrelation of disturbances
#' Execute the Durbin-Watson test to evaluate autocorrelation of the residuals
    durbinWatsonTest(model)

#' > **Note:** In the Durbin-Watson test, values of the D-W Statistic vary from 0 to 4. 
#' If the values are from 1.8 to 2.2 this means that there is no autocorrelation in the model. 