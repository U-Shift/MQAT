#### aim: inroduction to R basiscs ####

# examples in the console:
3+3
3*3
1:10
round(3.14)
round(3.14, 1) #1 digit

# , 1 is an argument!
# using TAB helps you to see which other arguments exist in that function
# also, you can see help ?round
?round


# this is a comment

a = 34 # ctrl + shift + c


# basics of r -------------------------------------------------------------

sections # ctrl + shift + r

b=1+2*(2-3) # ctrl + enter
3+4 # select and run more than one line together

b = 1 + 2 * (2 - 3) # the same as above but after ctrl + shit + a 

a = c("car", "bike", "walk") # conjunto


# create a table
t = data.frame(a = 1:9,
               b = cumsum(1:9), #cumulative sum
               c = rep(c("a", "b", NA), 3)) # repeat 3 times

t[3,"b"]
t[3,2]

t[,2]

t[c(1,3),]
t[,c(1,3)]
t[!is.na(t$c),] # is not na

# 
# TABLE[ROW, COLUMN]
# TABLE[CASE, VARIABLE]
# 
# TABLE[CASE,] #implicit that after , is all of the rest of the table

is.na(t$c)
!is.na(t$c)


# read data ---------------------------------------------------------------

TABLE = readRDS("data/IMOBmodel0.Rds") # use the TAB after entering "" will help you navigate in files under th working directory

# Environment -> Import Dataset -> From Text (readr) -> separator TAB
library(readr)
NAMES <- read_delim("data/Dicofre_names.txt", 
                            delim = "\t", escape_double = FALSE, 
                            col_types = cols(DTCC = col_character()), # change the type of this variable to character
                            trim_ws = TRUE)


NAMES$Dicofre = as.character(NAMES$Dicofre)


names(TABLE)

names(TABLE)[1] = "Dicofre"

table(TABLE$Lisboa)

# assign a categorical variable

TABLE$Lisboa = factor(TABLE$Lisboa,
                      levels = c(0, 1),
                      labels = c("No", "Yes"))


table(TABLE$Lisboa)


# create variable ---------------------------------------------------------

TABLE$Car_perc = round(100* TABLE$Car / TABLE$Total, 2)

names(TABLE)

TABLE = TABLE[,-10] # remove the 10th variable



# pipes -------------------------------------------------------------------

# TABLE |> DOTHIS |> DOTHAT |> DOTHIS 
# ctrl + shift + m

library(tidyverse)

TABLE2 = TABLE |> mutate(Car_perc = 100 * Car / Total) |> select(Dicofre, Car_perc)
View(TABLE2)

summary(TABLE$Total)

TABLE3 = TABLE |> filter(Total > 17474)
TABLE3 = TABLE |> filter(Total > median(Total)) # you can call a value inside the condition

TABLE4 = TABLE |> filter(Total > median(Total)) |> filter(Lisboa == "Yes")
TABLE4 = TABLE3 |> filter(Lisboa == "Yes") # equal

TABLE4 = TABLE |> filter(Total > median(Total) & Lisboa == "Yes") # AND
TABLE5 = TABLE |> filter(Total > median(Total) | Total < 5000) #OR

TABLE6 = TABLE3 |> filter(Lisboa != "Yes") # different

t1 = t[!is.na(t$c),] # is not NA
t1 = t |> filter(!is.na(c)) # same thing with pipes! more clear to read.

TABLE3 = TABLE |> filter(Total > median(Total)) |> arrange(Total) # ascending order
TABLE3 = TABLE |> filter(Total > median(Total)) |> arrange(-Total) # descending order
TABLE3 = TABLE |> filter(Total > median(Total)) |> arrange(-Total, Lisboa) #more than one variable, when you have more chacacter variables

TABLE_join = TABLE |> left_join(NAMES)

# if you don't have common variable names in both tables
NAMES_wrong = NAMES |> mutate(Dicofre_bad = Dicofre) |> select(-Dicofre)

TABLE_join2 = TABLE |> left_join(NAMES_wrong) #error! no common variables found
TABLE_join2 = TABLE |> left_join(NAMES_wrong, by = c("Dicofre"= "Dicofre_bad"))

TABLE_join3 = TABLE |> left_join(NAMES) |> filter(Concelho == "Loures") # left_join and filter

TABLE_join4 = TABLE |> left_join(NAMES) |> arrange(Concelho, Freguesia) #sort by concelho, and also by freguesia after concelho



# group_by and summarize --------------------------------------------------

TABLEsumm = TABLE_join |> select(Dicofre, Total, Car, Walk, Bike, Concelho) # keep just some relevant variables

TABLEsumm = TABLEsumm |> group_by(Concelho) |> summarise(Total = sum(Total),
                                                         CatT = sum(Car),
                                                         WalkT = sum(Walk),
                                                         BikeT = sum(Bike))

TABLEsumm2 = TABLE_join |>
  # select(Dicofre, Total, Car, Walk, Bike, Concelho) |> #ctrl + shift + c
  group_by(Concelho, DTCC) |>
  summarise(Total = sum(Total),
            CatT = sum(Car),
            WalkT = sum(Walk),
            BikeT = sum(Bike)) |> 
  ungroup() |>  #detail
  arrange(-Total)


# plots -------------------------------------------------------------------

plot(TABLEsumm2$Total)
plot(TABLEsumm2$Total, TABLEsumm2$CatT)                                                                                                    


hist(TABLE$Total) # histogram
hist(TABLE$Total, labels = TRUE)
abline(v = mean(TABLE$Total), col = "yellow")
abline(v = median(TABLE$Total), col = "red")


