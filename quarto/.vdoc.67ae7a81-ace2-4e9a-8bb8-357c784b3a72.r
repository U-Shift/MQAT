TRIPSjoin <- TRIPS |> left_join(Municipalities, by = c("Origin" = "Neighborhood_code"))
