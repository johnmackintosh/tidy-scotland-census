tidy_census <- function(x,
                        write = FALSE,
                        out_folder = "tidy",
                        collapse_sym = " ", # optional separator when joining strings
                        print = TRUE,
                        return = TRUE){
 start_target <- "S00135307"

  code_value <- stringi::stri_sub(x, 1L, regexpr("-",x) - 2)

  # use skip = 0 and header  = FALSE so that the first n rows will become the eventual column names
  # skipping or specifying a header means we end up with mix of  first row as column header, and subsequent rows in the data, and it is hard to extract them all

  # library(data.table)
  # library(stringi)

  int_dt <- fread(x, skip = 0, header = FALSE)

   headers <- int_dt[V1 == ""]
  int_dt <- fsetdiff(int_dt, headers)

  new_colnames <- headers[,lapply(.SD,
                                  stringi::stri_join,
                                  collapse = collapse_sym) |>
                            unlist() |>
                            unname()]

  new_colnames[1] <- "OA2022"

  setnames(int_dt, new = new_colnames)
  int_dt[,let(Code = code_value)]

  int_dt <- int_dt |> data.table::melt(id.vars = c("OA2022", "Code"))

  # replace any multiple underscores in variable column

  col_name <- "variable"

  rows_to_change <- int_dt[variable %like% "_{2,}",.I]

  set(int_dt ,
      i = rows_to_change,
      j = col_name,
      value =  stringi::stri_replace_all_regex(int_dt[[col_name]][rows_to_change],
                                      pattern = "_{2,}", # 2 or more underscores
                                      replacement = ""))
  rm(rows_to_change)

  #copy the value column to convert to numeric
  int_dt[,let(value_num = value)]

  # value column - remove the  "-" wherever it appears in the relevant rows
  int_dt[value_num %like% "-", let(value_num = NA)]

  int_dt[,let(value_num = as.numeric(value_num))]

  if (write) {
    fname <- paste("./",out_folder,"/", x, sep = "")
    fname <- gsub("\\s{1,}", "-", fname, fixed = TRUE) # strip spaces
    fname <- gsub("-{2,}", "-", fname, fixed = TRUE) # strip hyphens
    fname <- gsub(".csv", ".tsv", fname, fixed = TRUE)

    fwrite(int_dt, fname, sep = "\t")
  }

  if (print) {
    print(int_dt)
  }

rm(headers)
rm(new_colnames)

  if (return) {
    return(int_dt)
  }

}

 
 


  
 
