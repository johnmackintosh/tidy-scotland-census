tidy_census_orig <- function(x,
                        write = FALSE,
                        out_folder = "tidy") {

  # this was a very early attmpt that worked, but was slow, and not particularly elegant
  # definitely do not use this one.
  # however - the basic strategy - scan the file, find target value, use that as basis for reading in file and futher processing, is still sound

start_target <- "S00135307"

code_value <- stringr::str_sub(x, 1L, regexpr("-",x) - 2)

# get start position of first record in each file
  get_start_positions <- function(x, start_target) {
    out <- scan(x, nlines = 10,
         skip = 3, # always skip first 3 rows
         what = "",
         sep = "\n",
         blank.lines.skip = TRUE)
 res <-  grep(start_target, out)
 return(res)
  }


combine_rows <- function(x){
    x <- paste(x, collapse = "_") |>
      unlist() |>
      unname()
    return(x)
  }


start_positions <- get_start_positions(x, start_target)

header_rows <- start_positions - 1L # for reading headers

.int_header_rows <- header_rows + 3L #for reading data only

.int_data <- fread(input = x, skip = .int_header_rows)

headers <- fread(input = x,
                  skip = 3,
                  nrows = header_rows,
                  header = FALSE)

# headers[,lapply(.SD, paste, collapse = "_")|> unlist()|> unname()]

new_colnames <- headers[,lapply(.SD, combine_rows)
                        ][1, as.character(.SD)]

new_colnames[1] <- "OA2022"

#return(new_colnames)

setnames(.int_data, new = new_colnames)

.int_data <- .int_data |>
  data.table::melt(id.vars = "OA2022")|>
  _[OA2022 != ""
  ][OA2022 != "Scotland's Census 2022 - National Records of Scotland"
  ][!OA2022 %like% "Table *"
  ][!OA2022 %like% "All *"]

.int_data [,let(variable = gsub("__","", variable))]
.int_data [,let(variable = gsub("_","", variable))]


# value column - remove the  "-", copy the column and coerce to numeric]

.int_data [,let(value_num = value)]
.int_data [,let(value_num = gsub("-", 0L, value_num))]
.int_data [,let(value_num = as.numeric(value_num))]
.int_data [,let(Code = code_value)]

if(write){
  # this is inelegant to say the least, but I haven't got the time for regex
  # possibly the worst self-own since "Some Kind of Monster"

  
  fname <- paste("./",out_folder,"/", x, sep = "")
  fname <- gsub("  ", "-", fname)
  fname <- gsub(" ", "-", fname)
  fname <- gsub("---", "-", fname)
  fname <- gsub(".csv", ".tsv",fname)

 

  fwrite(.int_data ,fname, sep = "\t")
}


print(.int_data)
return(.int_data )

}

