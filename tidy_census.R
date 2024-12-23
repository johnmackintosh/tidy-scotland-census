tidy_census <- function(x,
                        write = FALSE,
                        out_folder = "tidy",
                        print = TRUE,
                        return = TRUE){
 start_target <- "S00135307"

  code_value <- stringi::stri_sub(x, 1L, regexpr("-",x) - 2)

  # use skip = 0 and header  = FALSE so that the first n rows will become the eventual column names
  # skipping or specifying a header means we end up with mix of  first row as column header, and subsequent rows in the data, and it is hard to extract them all

  int_dt <- fread(x, skip = 0, header = FALSE)

  # find the row with the start_target value, and retrieve all the rows above it
  headers <- int_dt[,head(.SD,grep(start_target,V1) - 1L)]
  # turn these into character vector of new column names
  new_colnames <- headers[,lapply(.SD,
                                  stringi::stri_join, collapse = " ") |>
                            unlist() |>
                            unname()]
  new_colnames[1] <- "OA2022"

  # remove the first n header rows - the rest of the rows are the data we need to process
  int_dt <- int_dt[,tail(.SD, -dim(headers)[1])]

  setnames(int_dt, new = new_colnames)
  int_dt[,let(Code = code_value)]

  out_dt <- int_dt |>
    data.table::melt(id.vars = c("OA2022", "Code"))

  # replace any multiple underscores in variable column

  col_name <- "variable"

  #rows_to_change <- which(grepl("_{2,}", out_dt[[col_name]]))
  rows_to_change <- out_dt[variable %like% "_{2,}",.I]
  set(out_dt, i = rows_to_change, j = col_name,
     value =  stri_replace_all_regex(out_dt[[col_name]][rows_to_change],
     pattern = "_{2,}",
     replacement = ""))

  #copy the value column to convert to numeric
  out_dt[,let(value_num = value)]

  # value column - remove the  "-" wherever in the relevant rows
   out_dt[value_num %like% "-", let(value_num = NA)]

  out_dt[,let(value_num = as.numeric(value_num))]

  if (write) {
    fname <- paste("./",out_folder,"/", x, sep = "")
    fname <- gsub("\\s{1,}", "-", fname, fixed = TRUE) # strip spaces
    fname <- gsub("-{2,}", "-", fname, fixed = TRUE) # strip hyphens
    fname <- gsub(".csv", ".tsv",fname, fixed = TRUE)

    fwrite(out_dt ,fname, sep = "\t")
  }

  rm(int_dt)

  if (print) {
    print(out_dt)
  }

  if (return) {
    return(out_dt)
  }

}
  
 
