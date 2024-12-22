library(data.table)
library(arrow)
library(purrr)


dir.create("./arrow")

tidy_files <- dir("./tidy", full.names = TRUE)

tidy_files |> walk(\(x)(fread(x) |>
                          arrow::write_dataset(path = "./arrow",
                                             format = "parquet",
                                             partitioning = c("Code"))),
                   .progress = TRUE)
