# tidy-scotland-census
R code to tidy Scotland 2022 Census open data csv files into tidy format

### Source data 
Source data is at output area level and is available from https://www.scotlandscensus.gov.uk/documents/2022-output-area-data/

When unzipped, you should have 71 csv files. These are in wide format, with additional rows of descriptive text above and below the data.

(You may also need the output area lookup files to match on specific areas - [you can grab them here](https://www.nrscotland.gov.uk/publications/2022-census-geography-products/)).
As things stand, this code does not filter out for a specific area, so can be used by analysts / interested persons to obtain datasets for all Scotland output areas.

### Issues
- They are .csv files
- Each file has a varying number of columns
- The first 3 rows of each file contain generic information about the dataset and can be discarded for analysis. Because these are of varying widths, various file readers may trip up when reading them in. `data.table` suggests using `fill  = TRUE` when using `fread`, but that causes immediate failure in some cases.
- The last 8 rows contain text that should also be discarded
- Once these rows have been discarded, many files have headers in multiple rows which need to be extracted, combined, and the added back as column headers.
- Need to account for having between 0-5 rows of column headers, with some blank rows in between
- Some files have extra delimiters in the first 3 rows
- The easy bit -  tidy the data into long format and write it out
- There are some files that defy these steps and so extra filtering and manipulation is required

### Method
After trying various ways using `scan` and `read_lines` to determine the correct number of rows to skip and convert to headers, I realised I could streamline the process using `fsetdiff`.
This results in only one read for each file, no worrying about which row the data starts in and no requirements to save temporary files.

### Notes
Originally I stripped out rows where the value field had `"-"`, but I was concerned that this might mean some missing results in the final tidied data.
So, I copied the value column, which is currently a character vector, replaced the `"-"` with `NA`, and converted to `numeric`
Finally, I added the abbreviated code from each dataset (usually 5 or 6 characters) for easy filtering if multiple data sets are combined into a single table. 

### TO DO
- [ ] join to higher areas for easier filtering?
- [x] write out as parquet files
- [x] create and add to duckdb

### How to use

Assuming you have downloaded the census file data from https://www.scotlandscensus.gov.uk/documents/2022-output-area-data/

Unzip the files  
copy the source CSV file you want to tidy to the root of your working directory (in the main folder, not a sub-folder)

## Tidying in a single file
Pass the filename to the tidy_census function, and ensure the `write` parameter is set to `TRUE` (which is set to `FALSE` by default)

The data will be read in, tidied (into long format), and  will be written to a sub-folder of your choice - specify it in the function
It will also print to the console so you can see what you are getting back. 
Note - there is no filtering on this data, so it returns OA output for all Scotland.

## Tidying multiple files
I recommend a two step process for this. 
Create a vector of filnames or the file positions
```
files <- dir(pattern = "*.csv") # make a list of file names
my_files <- files[1:10] # take the first ten files
```
Now use the `safe` version of the tidy function (named `safe_tidy`)
The safe function, and some other helper functions, is found in `utilities.R`
```
res <- map(my_files, ~ safe_tidy(.x, write = FALSE, print = FALSE), .progress = TRUE)`
```
Then check to see if there are any errors
```
show_errors(res)
```
Assuming all is OK, use purrr to write the files to disk
```
walk(my_files, ~ tidy_census(.x, write = TRUE, print = FALSE), .progress = TRUE)
```

### More blurb:
https://johnmackintosh.com/blog/rstats/2024-12-22-tidying-text-files/

