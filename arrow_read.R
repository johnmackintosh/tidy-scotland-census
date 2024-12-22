# https://r4ds.hadley.nz/arrow

library(data.table)
library(dplyr)
library(arrow)
library(purrr)

pq_path <- "./arrow"

census_pq <- open_dataset(pq_path)

# check the size of the files
# tibble::tibble(
#   files = list.files(pq_path, recursive = TRUE),
#   size_MB = file.size(file.path(pq_path, files)) / 1024^2)|>
#   View()


query <- census_pq |>
  filter(Code == "UV902") #  need to write higher levels and join to these
