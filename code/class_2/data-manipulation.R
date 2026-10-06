# Data manipulation -------------------------------------------------------
# Code adapted from tutorial at https://u-shift.github.io/MQAT/data-manipulation.html

# In this chapter we will use some very useful `dplyr` functions to handle and manipulate data.

# You can load the `dplyr` package directly, or load the entire tidy universe (`tidyverse`).

# library(tidyverse)
library(dplyr)

# Using the same dataset as in R basics but with slightly differences.
# This dataset includes the number of trips with origin in each neighborhood,
# divided by mode of transport, and inter or intra municipal trips.

# We will do the same operations but in a simplified way.

# Download the dataset TRIPSorigin.Rds and save it in the folder `data`, under your project's root folder.
# https://github.com/U-Shift/MQAT/raw/refs/heads/main/data/TRIPSorigin.Rds

TRIPS = readRDS("data/TRIPSorigin.Rds")

# Note that it is very important to understand the R basics, that's why we started from there,
# even if the following functions will provide the same results.

# You don't need to know everything!
# And you don't need to know by heart.
# The following functions are the ones you will probably use most of the time to handle data.

# There are several ways to reach the same solution.
# Here we present only one of them.


## Select variables -------------------------------------------------------

# Have a look at your dataset.
# You can open using `View()`, look at the information at the "Environment" panel,
# or even print the same information using `glimpse()`

# View(TRIPS)
glimpse(TRIPS)

# We will create a new dataset with Origin, Walk, Bike and Total.
# This time we will use the `select()` function.

TRIPS_new = select(TRIPS, Origin, Walk, Bike, Total) # the first argument is the dataset

# The first argument, as usually in R, is the dataset, and the remaining ones are the columns to select.

# With most of the `dplyr` functions you don't need to refer to `data$...`
# you can simply type the variable names (and even without the "..."!).
# This makes coding in R simpler :)

# You can also remove columns that you don't need.

TRIPS_new = select(TRIPS_new, -Total) # dropping the Total column


### Using pipes! ----------------------------------------------------------

# Now, let's introduce pipes.
# Pipes are a rule as: "With this, do this."

# This is useful to skip the first argument of the functions (usually the dataset to apply the function).

# Applying a pipe to the `select()` function, we can write as:

TRIPS_new = TRIPS |> select(Origin, Walk, Bike, Total)

# Two things to note:
# 1. The pipe symbol can be written as `|>` or `%>%`.
#    To write it you may also use the `ctrl+shift+m` shortcut.
# 2. After typing `select(` you can press `tab` and the list of available variables
#    of that dataset will show up! `Enter` to select. With this you prevent typo errors.


## Filter observations ----------------------------------------------------

# You can filter observations based on a condition using the `filter()` function.

TRIPS2 = TRIPS[TRIPS$Total > 25000,] # using r-base, you cant forget the comma
TRIPS2 = TRIPS2 |> filter(Total > 25000) # using dplyr, it's easier

# You can have other conditions inside the condition.

summary(TRIPS$Total)
TRIPS3 = TRIPS |> filter(Total > median(Total))

# Other filter conditions:
# - `==` equal, `!=` different
# - `<` smaller, `>` greater, `<=` smaller or equal, `>=` greater or equal
# - `&` and, `|` or
# - `is.na`, `!is.na` is not NA
# - `%in%`, `!%in%` not in


## Create new variables ---------------------------------------------------

# You can also try again to create a variable of Car percentage using pipes!
# To create a new variable or change an existing one (overwriting), you can use the `mutate()` function.

TRIPS$Car_perc = TRIPS$Car/TRIPS$Total * 100 # using r-base

TRIPS = TRIPS |> mutate(Car_perc = Car/Total * 100) # using dplyr


## Change data type -------------------------------------------------------

# Data can be in different formats.
# For example, the variable Origin is a character, but we can convert it to a numeric variable.

class(TRIPS$Origin)
TRIPS = TRIPS |> 
  mutate(Origin_num = as.integer(Origin)) # you can use as.numeric() as well
class(TRIPS$Origin_num)

# Most used data types are:
# - integer (`int`)
# - numeric (`num`)
# - character (`chr`)
# - logical (`logical`)
# - date (`Date`)
# - factor (`factor`)


### Factors ---------------------------------------------------------------

# Factors are useful to deal with categorical data.
# You can convert a character to a factor using `as.factor()`,
# and also use labels and levels for categorical ordinal data.

# We can change the `Lisbon` variable to a factor, and `Internal` too.

TRIPS = TRIPS |> 
  mutate(Lisbon_factor = factor(Lisbon, labels = c("No", "Yes")),
         Internal_factor = factor(Internal, labels = c("Inter", "Intra")))

# But how do we know which levels come first?
# A simple way is to use `table()` or `unique()` functions.

unique(TRIPS$Lisbon) # this will show all the different values
table(TRIPS$Lisbon) # this will show the frequency of each value
table(TRIPS$Lisbon_factor)

# The first number to appear is the first level, and so on.

# You can see the difference between using a continuous variable
# (in this case `Lisbon` has 0 and 1) and a categorical variable (`Lisbon_factor`).

plot(TRIPS$Lisbon) # the values range between 0 and 1
plot(TRIPS$Lisbon_factor) # the values are categorical and labeled with Yes/No


## Join data tables -------------------------------------------------------

# When having relational tables - i.e. with a common identifier -
# it is useful to be able to join them in a very efficient way.

# `left_join` is a function that joins two tables by a common column.
# The first table is the one that will be kept, and the second one will be joined to it.

# Let's join the municipalities to this table with a supporting table that includes
# all the relation between neighbourhoods and municipalities, and the respective names and codes.

# Download the dataset Municipalities_names.Rds and save it in the folder `data`, under your project's root folder.
# https://github.com/U-Shift/MQAT/raw/refs/heads/main/data/Municipalities_names.Rds

Municipalities = readRDS("data/Municipalities_names.Rds")

head(TRIPS)
tail(Municipalities)

# We can see that we have a common variable: `Origin` in `TRIPS` and `Neighborhood_code` in `Municipalities`.

# To join these two tables we need to specify the common variable in each table, using the `by` argument.

TRIPSjoin = TRIPS |> left_join(Municipalities, by = c("Origin" = "Neighborhood_code"))

# If you prefer, you can mutate or rename a variable so both tables have the same name.
# When both tables have the same name, you don't need to specify the `by` argument.

Municipalities = Municipalities |> rename(Origin = "Neighborhood_code") # change name
TRIPSjoin = TRIPS |> left_join(Municipalities) # automatic detects common variable

# As you can see, both tables don't need to be the same length.
# The `left_join` function will keep all the observations from the first table, and join the second table to it.
# If there is no match, the variables from the second table will be filled with `NA`.


## group_by and summarize -------------------------------------------------

# We have a very large table with all the neighbourhoods and their respective municipalities.
# We want to know the total number of trips with origin in each municipality.

# To make it easier to understand, let's keep only the variables we need.

TRIPSredux = TRIPSjoin |> select(Origin, Municipality, Internal, Car, Total)
head(TRIPSredux)

# We can group this table by the `Municipality` variable and summarize the number of trips with origin in each municipality.

TRIPSsum = TRIPSredux |> 
  group_by(Municipality) |> # you won't notice any chagne with only this
  summarize(Total = sum(Total))
head(TRIPSsum)

# We summed the total number of trips in each municipality.

# If we want to group by more than one variable, we can add more `group_by()` functions.

TRIPSsum2 = TRIPSredux |> 
  group_by(Municipality, Internal) |> 
  summarize(Total = sum(Total),
            Car = sum(Car))
head(TRIPSsum2)

# We summed the total number of trips and car trips in each municipality, separated by inter and intra municipal trips.

# It is a good practice to use the `ungroup()` function after the `group_by()` function.
# This will remove the grouping.
# If you don't do this, the grouping will be kept and you may have unexpected results in the next time you use that dataset.


## Arrange data -----------------------------------------------------------

# You can sort a dataset by one or more variables.

# For instance, `arrange()` by Total trips, ascending or descending order.

TRIPS2 = TRIPSsum2 |> arrange(Total)
TRIPS2 = TRIPSsum2 |> arrange(-Total) # descending

TRIPS2 = TRIPSsum2 |> arrange(Municipality) # alphabetic

TRIPS4 = TRIPS |> arrange(Lisbon_factor, Total) # more than one variable

# This is not the same as opening the view table and click on the arrows.
# When you do that, the order is not saved in the dataset.
# If you want to save the order, you need to use the `arrange()` function.


## All together now! ------------------------------------------------------

# This is the pipes magic.
# It takes the last result and applies the next function to it.
# "With this, do this.".
# You can chain as many functions as you want.

TRIPS_pipes = TRIPS |> 
  select(Origin, Internal, Car, Total) |> 
  
  mutate(Origin_num = as.integer(Origin)) |> 
  mutate(Internal_factor = factor(Internal, labels = c("Inter", "Intra"))) |> 
  
  filter(Internal_factor == "Inter")|>
  
  left_join(Municipalities) |>
  
  group_by(Municipality) |> 
  summarize(Total = sum(Total),
            Car = sum(Car),
            Car_perc = Car/Total * 100) |> 
  ungroup() |> 
  
  arrange(desc(Car_perc))

# With this code we will have a table with the total number of intercity trips,
# by municipality, with their names instead of codes, arranged by the percentage of car trips.

TRIPS_pipes


## Other dplyr functions --------------------------------------------------

# You can explore other `dplyr` functions and variations to manipulate data in the dplyr cheat sheet:
# https://rstudio.github.io/cheatsheets/data-transformation.pdf