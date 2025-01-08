safe_tidy_census <- purrr::safely(tidy_census)

show_results <- function(res_t, x){
  out <-   res_t[x] %>% tibble::enframe() %>%
    tidyr::hoist(value,
                 "result", .simplify = TRUE) %>%
    purrr::pluck("result")

  as.data.table(out)

}

show_errors <- function(res_t, x){
  out <-   res_t[x] %>% tibble::enframe() %>%
    tidyr::hoist(value,
                 "error", .simplify = TRUE) %>%
    purrr::pluck("error")

  as.data.table(out)

}

view_results <- function(res_t){
  res_t %>%
    tibble::enframe() %>%
    tidyr::hoist(value,
                 "result", "error", .simplify = TRUE) %>%
    View()
}

# function to join values from multiple rows to one string and perform the necessary unlisting and unnnaming
combine_rows <- function(x, collapse_sym){
    x <- paste(x, collapse = collapse_sym) |>
      unlist() |>
      unname()
    return(x)
  }



# get start position of first record in each file
  get_start_positions <- function(x, start_target) {
    out <- scan(x, nlines = 10,
         skip = 3, # always skip first 3 rows - in retrospect would have been easier not to skip any rows and have no headers
         what = "", # character
         sep = "\n",
         blank.lines.skip = TRUE)
 res <-  grep(start_target, out)
 return(res)
  }
