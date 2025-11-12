library(tidyverse) # Pack of most used libraries for data science
library(summarytools) # Summary of the dataset
library(foreign) # Read SPSS files
library(nFactors) # Factor analysis
library(GPArotation) # GPA Rotation for Factor Analysis
library(psych) # Personality, psychometric, and psychological research

data = read.spss("data/example_fact.sav", to.data.frame = T)

head(data, 5)
View(data) # open in table

data = data |> column_to_rownames(var = "RespondentID")

str(data)

# skimr::skim(data)
print(dfSummary(data),
      method = "render")

# random regression model
random = rchisq(nrow(data), ncol(data))
fake = lm(random ~ ., data = data)
standardized = rstudent(fake)
fitted = scale(fake$fitted.values)

hist(standardized)

qqnorm(standardized)
abline(0, 1)

plot(fitted, standardized)
abline(h=0, v=0)

corr_matrix = cor(data, method = "pearson")

cortest.bartlett(corr_matrix, n = nrow(data))

KMO(corr_matrix)

num_factors = fa.parallel(
  x = data, 
  fm = "ml", # factor mathod = maximum likelihood
  fa = "fa") # factor analysis

sum(num_factors$fa.values > 1) # Number of factors with eigenvalue > 1
sum(num_factors$fa.values > 0.7) # Number of factors with eigenvalue > 0.7

data_pca = princomp(data,
                    cor = TRUE) # standardizes your dataset before running a PCA
summary(data_pca)  

plot(data_pca, type = "lines", npcs = 31)

# No rotation
data_factor = factanal(
  data,
  factors = 4, # change here the number of facotrs based on the EFA
  rotation = "none",
  scores = "regression",
  fm = "ml"
)

# Rotation Varimax
data_factor_var = factanal(
  data,
  factors = 4,
  rotation = "varimax", # orthogonal rotation (default)
  scores = "regression",
  fm = "ml"
)

# Rotation Oblimin
data_factor_obl = factanal(
  data, 
  factors = 4,
  rotation = "oblimin", # oblique rotation
  scores = "regression",
  fm = "ml"
)

print(data_factor_obl,
      digits = 2,
      cutoff = 0.3, # > 0.3 due to the sample size is higher than 350 observations.
      sort = TRUE) 

View(data_factor_obl$scores)
# write.csv(data_factor_obl$scores, "data/data_factor_obl_scores.csv", sep = "\t")
head(data_factor_obl$scores)

View(data_factor_obl$loadings)
# write.csv(data_factor_obl$loadings, "data/data_factor_obl_loadings.csv", sep = "\t")
head(data_factor_obl$loadings)

# define a plot function
plot_factor_loading <- function(data_factor,
                                f1 = 1,
                                f2 = 2,
                                method = "No rotation",
                                color = "blue") {
  
  # Convert to numeric matrix (works for psych loadings objects)
  L <- as.matrix(data_factor$loadings)
  
  # Extract selected factors
  df <- data.frame(item = rownames(L), x = L[, f1], y = L[, f2])
  
  ggplot(df, aes(x = x, y = y, label = item)) +
    geom_point() +
    geom_text(color = color,
              vjust = -0.5,
              size = 3) +
    geom_hline(yintercept = 0) +
    geom_vline(xintercept = 0) +
    coord_equal(xlim = c(-1, 1), ylim = c(-1, 1)) +
    labs(
      x = paste0("Factor ", f1),
      y = paste0("Factor ", f2),
      title = method
    ) +
    theme_bw()
}

plot_factor_loading(
  data_factor = data_factor, # model no rotation
  f1 = 1, # Factor 1
  f2 = 2, # Factor 2
  method = "No rotation", # plot title
  color = "blue"
)

plot_factor_loading(
  data_factor = data_factor_var, # model varimax
  f1 = 1, # Factor 1
  f2 = 2, # Factor 2
  method = "Varimax rotation",
  color = "red"
)

plot_factor_loading(
  data_factor = data_factor_var, # model oblimn
  f1 = 1, # Factor 1
  f2 = 2, # Factor 2
  method = "Oblimin rotation",
  color = "darkgreen"
)

# create all combinations
p12 <- plot_factor_loading(data_factor, 1, 2, method = "No rotation", color = "blue")
p13 <- plot_factor_loading(data_factor, 1, 3, method = "No rotation", color = "blue")
p14 <- plot_factor_loading(data_factor, 1, 4, method = "No rotation", color = "blue")
p23 <- plot_factor_loading(data_factor, 2, 3, method = "No rotation", color = "blue")
p24 <- plot_factor_loading(data_factor, 2, 4, method = "No rotation", color = "blue")
p34 <- plot_factor_loading(data_factor, 3, 4, method = "No rotation", color = "blue")

library(patchwork)
(p12 + p13 + p14) /
(p23 + p24 + p34)
