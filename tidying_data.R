library(data.table)
library(purrr)
library(tidyr)
library(stringi)

files <- dir(pattern = "*.csv")

# create and view a tidy data set

tidy_census(files[1], return = FALSE)


# run the safe function and check for any errors
# May be best to do this in batches 
res <- map(files[1:10], ~ safe_tidy(.x, write = FALSE, print = FALSE), .progress = TRUE)

show_errors(res)
 #    out
#    <lgcl>
# 1:     NA
# 2:     NA
# 3:     NA
# 4:     NA
# 5:     NA
# 6:     NA
# 7:     NA
# 8:     NA
# 9:     NA
#10:     NA

# If no errors, just walk  over the function to write the files to disk
walk(files[1:10], ~ tidy_census(.x, write = TRUE, print = FALSE), .progress = TRUE)


# if for some unfathomable reason you want everything in a nested list, you can run this - not recommended
res <- map(files, ~ tidy_census(.x, write = FALSE, print = FALSE), .progress = TRUE)

# get the results for the first element
show_results(res,1)

