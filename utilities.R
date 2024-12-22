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
