#' admin to create current term/semester
#' @param term_end_date String. the end date for current term.
#' #' @return An integer indicating the number of rows affected
#'  (typically `1` for a successful insert).
#' @export
add_term_end <- \(term_end_date) {
  # Create the SQLite connection
  db_name <- Sys.getenv("DATABASE_NAME")
  conn <- DBI::dbConnect(drv = RSQLite::SQLite(), db_name)
  on.exit(DBI::dbDisconnect(conn))

  # Update the value for "term_end_date"
  query_end_date <- "UPDATE administrator
                     SET value = :new_end_date
                     WHERE input_col = 'term_end_date'"

  result_end_date <- dbExecute(
    conn,
    query_end_date,
    params = list(new_end_date = as.character(term_end_date))
  )

  # Update the value for "term_label"
  query_term_label <- "UPDATE administrator
                       SET value = :new_term_label
                       WHERE input_col = 'term_label'"

  current_month <- toupper(format(Sys.Date(), "%b"))
  end_month <- toupper(format(as.Date(term_end_date), "%b"))
  current_year <- format(as.Date(term_end_date), "%Y")
  term_label <- paste(current_month, end_month, current_year, sep = "-")

  result_term_label <- dbExecute(
    conn,
    query_term_label,
    params = list(new_term_label = term_label)
  )

  result_end_date + result_term_label
}
