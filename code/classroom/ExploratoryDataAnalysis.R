
library(tidyverse) # Pack of most used libraries for data science
library(skimr) # summary of the data
library(DataExplorer) # exploratory data analysis
library(corrplot) # correlation plots


## ------------------------------------------------------------------------------------------------------------------------------
data = readRDS("data/IMOBmodel.Rds")


## ------------------------------------------------------------------------------------------------------------------------------
View(data) # open in table
glimpse(data) # glimpse of the dataset
str(data) # Structure of the dataset 


## ------------------------------------------------------------------------------------------------------------------------------
summary(data) # Check the summary statistics
skim(data) # In a more organized way


## ------------------------------------------------------------------------------------------------------------------------------
table(is.na(data))


## ------------------------------------------------------------------------------------------------------------------------------
boxplot(data) # This does now work if variables are not all continuous


## ------------------------------------------------------------------------------------------------------------------------------
data_continuous = data |> select(-Origin_dicofre16, -internal, -Lisboa) # Exclude categorical variables
boxplot(data_continuous) # Exclude categorical variables

hist(data_continuous$Total) # histogram
boxplot(data_continuous$Total) # outliers detected


## ------------------------------------------------------------------------------------------------------------------------------
outlier = function(x) {
  q = quantile(x, probs = c(0.25, 0.75), na.rm = TRUE)  # Q1 and Q3
  caps = quantile(x, probs = c(0.05, 0.95), na.rm = TRUE) # 5th and 95th percentile
  H = 1.5 * IQR(x, na.rm = TRUE) # interquartile range
  
  case_when(
    x < (q[1] - H) ~ caps[1], # replace values that are LESS than Q1-1.5*IQR with the P5 value
    x > (q[2] + H) ~ caps[2], # replace values that are MORE than Q3+1.5*IQR with the P95 value
    TRUE ~ x # otherwise, return the original value
  )
}


## ------------------------------------------------------------------------------------------------------------------------------
data_outliers = data_continuous # duplicate the table
data_outliers$Total = outlier(data_outliers$Total) # Use the function to the same variable


## ------------------------------------------------------------------------------------------------------------------------------
boxplot(data_outliers$Total)


## ------------------------------------------------------------------------------------------------------------------------------
# Mean
mean(data$Total)
mean(data_outliers$Total)

# Median
median(data$Total)
median(data_outliers$Total)

# Standard deviation
sd(data$Total)
sd(data_outliers$Total)


## ------------------------------------------------------------------------------------------------------------------------------
plot_histogram(data, ncol = 3) #with 3 columns


## ------------------------------------------------------------------------------------------------------------------------------
plot_boxplot(data, by = "Car_perc", ncol = 3)


## ------------------------------------------------------------------------------------------------------------------------------
# estimate correlation matrix
corrmat = cor(data_continuous, method = "pearson") |> round(2)
corrmat

# store the results so you can call the p-value at the corrplot
res = cor.mtest(data_continuous, conf.level = .95) 

corrplot(
  corrmat,
  method = "color", # or "circle"
  p.mat = res$p,
  sig.level = 0.05,
  type = "upper", # display only the upper triangular
  # order = "hclust", # order by hierarchical clustering
  tl.col = "black" # text label color
)

# other method
plot_correlation(data_continuous)


## ------------------------------------------------------------------------------------------------------------------------------
cor.test(data$IncomeHH, data$Bike)
cor.test(data$IncomeHH, data$Duration)
cor.test(data$Distance, data$Duration)

