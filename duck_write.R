library(data.table)
library(dplyr)
library(DBI)
library(duckdb)


dir.create("./duck")

tidy_files <- dir("./tidy", full.names = TRUE)


con <- DBI::dbConnect(duckdb::duckdb(dbdir = "./duck/census_data.duckdb"))

table_name <- "census_data"

# write the first table

first_data <- fread(tidy_files[1])

duckdb::dbWriteTable(con, table_name, first_data)


append_to_table <- function(x) {
  temp_data <- fread(x)
  duckdb::dbAppendTable(con, table_name, temp_data)
}

walk(tidy_files[2:70], ~ append_to_table(.x))

tidy_files[2:70] |> walk(\(x)(fread(x) |>
                         duckdb::dbAppendTable(con, table_name, x)),
                   .progress = TRUE)

DBI::dbDisconnect(con)

# should perhaps have done 2:69, then run file number 70 individually and disconnected
