# aim: prepare georreferenced data from home locations (IST mobility survey) to do some routing to IST by mode

library(tidyverse)
library(readxl)
SURVEYist = read_excel("original/UbikeIST_data.xlsx")
# View(SURVEYist)

SURVEYist = SURVEYist |> 
  mutate(SEX = recode(SEX, `1` = "Male", `2` = "Female"),
         AFF = recode(AFF, `1` = "Student", `2` = "Faculty", `3` = "Staff"),
         LIS = recode(LIS, `0` = "AML", `1` = "Lisbon"),
         MODE = recode(MODE, `1` = "Car", `2` = "PT", `3` = "Walk", `4` = "Bike")
         )


SURVEYist = SURVEYist |> 
  filter(LIS == "Lisbon") |> 
  select(ID, AFF, AGE, SEX, MODE, lat, lon)


notinlisbon = c(975, 48, 1778, 1287, 948, 1592, 1838, 743) 

SURVEYist = SURVEYist |> 
  filter(!ID %in% notinlisbon) |> 
  distinct(lat, lon) |> 
  mutate(lat = round(lat, 5),
         lon = round(lon, 6)) |> 
  filter(lat != 38.73688 & lon != -9.137314) |>  # these are exactly at IST - remove
  slice_sample(n = 200)

SURVEYist_geo = sf::st_as_sf(SURVEYist, coords = c("lon", "lat"), crs = 4326)
mapview::mapview(SURVEYist_geo)

write.table(SURVEYist, "geo/SURVEYist.txt", sep = "\t", row.names = FALSE)
