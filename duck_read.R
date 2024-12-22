library(dplyr)
library(DBI)
library(duckdb)

con <- DBI::dbConnect(duckdb::duckdb(dbdir = "./duck/census_data.duckdb"))

tbl(con, "census_data") %>%
  filter(Code == "UV902")
