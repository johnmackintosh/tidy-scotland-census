# tidy-scotland-census
R code to tidy Scotland 2022 Census open data csv files into tidy format

### Source data 
Source data is at output area level and is available from https://www.scotlandscensus.gov.uk/documents/2022-output-area-data/

When unzipped, you should have 71 csv files. These are in wide format, with additional rows of descriptive text above and below the data.
File `UV608 - National Statistics Socio-economic Classification (NS-SeC) of Household Reference Person (HRP).csv` only has one row of data, and should be placed into a separate directory as it's not worth including in this work

(You may also need the output area lookup files to match on specific areas).
As things stand, this code does not filter out for a specific area, so can be used by analysts / interested persons to obtain datasets for all Scotland output areas.

### Issues
- They are .csv files
- Each file has a varying number of columns
- The first 3 rows of each file contain generic information about the dataset and can be discarded for analysis. Because these are of varying widths, various file readers may trip up when reading them in. `data.table` suggests using `fill  = TRUE` when using `fread`, but that causes immediate failure in some cases.
- The last 8 rows contain text that should also be discarded
- Once these rows have been discarded, many files have headers in multiple rows which need to be extracted, combined, and the added back as column headers.
- Need to account for having between 0-5 rows of column headers
- The easy bit -  tidy the data into long format and write it out
- There are some files that defy these steps and so extra filtering and manipulation is required

  ### Method
  After trying various ways using `scan` and `read_lines` to determine the correct number of rows to skip and convert to headers, I realised I could streamline the process.
  This results in only one read for each file and no requirements to save temporary files.
  The slowest part of this function is the use of `gsub`. 

### Notes
Originally I stripped out rows where the value field had `"-"`, but I was concerned that this might mean some missing results in the final tidied data.
So, I copied the value column, which is currently a character vector, replaced the `"-"` with `0L`, and converted to `numeric`
Finally, I added the abbreviated code from each dataset (usually 5 or 6 characters) for easy filtering once the data is combined into a single table. 

### TO DO
- join to higher areas for easier filtering?
- [x] write out as parquet files
- [x] create and add to duckdb 

