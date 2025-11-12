library(tidyverse) # Pack of most used libraries for data science
library(readxl) # Import excel files
library(skimr) # Summary statistics
library(mclust) # Model based clustering
library(cluster) # Cluster analysis
library(factoextra) # Visualizing distances

data = read_excel("data/Data_Aeroports_Clustersv1.xlsx")
data = data.frame(data) # as data frame only

head(data, 5)

skim(data)

ggplot(data, aes(x = Destinations, y = Numberofairlines)) +
  geom_point(size = 3, alpha = 0.7) +
  geom_text(aes(label = Airport), vjust = 1.5, size = 3, show.legend = FALSE) +
  labs(
    title = "Airports",
    x = "Number of destinations",
    y = "Number of airlines"
  ) +
  theme_minimal()

data = data |> column_to_rownames(var = "Code")

data_continuous = data |> select(-Ordem, -Airport) # remove chr and id variables

head(data_continuous)

data_scaled = data_continuous |> 
  mutate(across(everything(), ~ ( . - mean(.) ) / sd(.)))
# Result = z-scores, same as scale()

# measure
distance = dist(data_scaled, method = "euclidean")

# heatmap
fviz_dist(
  distance, 
  gradient = list(
    low = "#00AFBB",
    mid = "white",
    high = "#FC4E07"
  ),
  order = FALSE
)

cluster_single = hclust(distance, "single")

# dendogram
plot(
  cluster_single,
    xlab = "Distance - Single linkage",
  hang = -1, # all to the bottom
  cex = 0.6 # label text size
)
rect.hclust(cluster_single, k = 4, border = "purple") # cut on the dendogram at 4 clusters

cluster_complete = hclust(distance, "complete")

# dendogram
plot(
  cluster_complete,
    xlab = "Distance - Complete linkage",
  hang = -1, # all to the bottom
  cex = 0.6 # label text size
)
rect.hclust(cluster_complete, k = 4, border = "blue") # cut on the dendogram at 4 clusters

cluster_average = hclust(distance, "average")

# dendogram
plot(
  cluster_average,
  xlab = "Distance - Average linkage",
  hang = -1, # all to the bottom
  cex = 0.6 # label text size
)
rect.hclust(cluster_complete, k = 4, border = "red") # cut on the dendogram at 4 clusters

cluster_ward = hclust(distance, "ward.D2")

# dendogram
plot(
  cluster_ward,
  xlab = "Distance - Ward's method",
  hang = -1, # all to the bottom
  cex = 0.6 # label text size
)
rect.hclust(cluster_complete, k = 4, border = "orange") # cut on the dendogram at 4 clusters

cluster_centroid = hclust(distance, "centroid")

# dendogram
plot(
  cluster_centroid,
  xlab = "Distance - Centroid method",
  hang = -1, # all to the bottom
  cex = 0.6 # label text size
)
rect.hclust(cluster_complete, k = 4, border = "darkgreen") # cut on the dendogram at 4 clusters

number_clusters = 4 # change here
member_single = cutree(cluster_single, k = number_clusters)
member_complete = cutree(cluster_complete, k = number_clusters)
member_average = cutree(cluster_average, k = number_clusters)
member_ward = cutree(cluster_ward, k = number_clusters)
member_centroid = cutree(cluster_centroid, k = number_clusters)

# make a data frame
cluster_membership = data.frame(member_single,
                                member_complete,
                                member_average,
                                member_ward,
                                member_centroid
                                )
# manipulate data for plot
cluster_long = cluster_membership |>
  rownames_to_column(var = "airport") |>  # keep airport names
  pivot_longer(
    cols = starts_with("member_"),
    names_to = "method",
    values_to = "cluster") |>
  mutate(method = gsub("member_", "", method), # clean names
         method = factor(method, # preserve the label order
                         levels = c("single", "complete", "average", "ward", "centroid")))  
# plot
ggplot(cluster_long,
       aes(x = method,
           y = airport,
           fill = factor(cluster))) +
  geom_tile(color = "white") +
  scale_fill_brewer(palette = "Set3", name = "Cluster") +
  theme_minimal() +
  labs(title = "Cluster memberships by method",
    x = "Clustering method",
    y = "Airport") +
  theme(axis.text.y = element_text(size = 6))

table(member_complete, member_average) # complete linkage vs. average linkage
table(member_complete, member_ward) # complete linkage vs. ward's method

plot(silhouette(member_single, distance))
plot(silhouette(member_complete, distance))
plot(silhouette(member_average, distance))
plot(silhouette(member_ward, distance))
plot(silhouette(member_centroid, distance))

# loop for the 10 cluster trials
kmeans_diagnostic = data.frame()

for (i in 1:10) {
  km = kmeans(data_scaled, centers = i)
  km_diagn = data.frame(
    k = i,
    between_ss = km$betweenss,
    tot_ss = km$totss,
    ratio = km$betweenss / km$totss
  )
  kmeans_diagnostic = rbind(kmeans_diagnostic, km_diagn)
}

# marginal improvements for each new cluster
kmeans_diagnostic = kmeans_diagnostic |> 
  mutate(marginal = ratio - lag(ratio)) 

kmeans_diagnostic

plot(kmeans_diagnostic$k, kmeans_diagnostic$ratio,
     type = "b",
     ylab = "Between SS / Total SS",
     xlab = "Number of clusters")

km_clust = kmeans(data_scaled, centers = 3) # k = 3
km_clust # print the results

# cluster means for each variable
var_cluster_means = data.frame(cluster = 1:nrow(km_clust$centers),
                               size = km_clust$size,
                               km_clust$centers)

# cluster membership for each observation
obs_cluster_member = data.frame(km_clust$cluster)

# add cluster membership to original data
data_clust = data |>  mutate(cluster = factor(km_clust$cluster))

# plot
ggplot(data_clust, aes(x = Destinations, y = Numberofairlines, color = cluster)) +
  geom_point(size = 3, alpha = 0.7) +
  geom_text(aes(label = Airport), vjust = 1.5, size = 3, show.legend = FALSE) +
  scale_color_brewer(palette = "Set1") +
  labs(
    title = "Airports clustered by k-means",
    x = "Number of destinations",
    y = "Number of airlines",
    color = "Cluster"
  ) +
  theme_minimal()
