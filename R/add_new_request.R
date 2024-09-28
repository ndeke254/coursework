#' Add a new request into the DB.
#'
#' @param table_name Name of the table to add a record to.
#' @param data A data.frame of the data to be added.
#' @return double `1` if the request was created, `0` otherwise.
#' @import prodlim
#' @import dplyr
#' @export
add_new_request <- function(table_name, data) {
  # DB name
  db_name <- Sys.getenv("DATABASE_NAME")

  # Make SQLite connection
  conn <- DBI::dbConnect(drv = RSQLite::SQLite(), db_name)
  on.exit(DBI::dbDisconnect(conn), add = TRUE)

  # Read the DB table
  table_data <- DBI::dbReadTable(conn, table_name)

  # Check if the request already exists (e.g., by request ID or other unique identifier)
  available <- table_data |>
    select(teacher_id, grade, learning_area, topic, sub_topic)
  new_data <- data |>
    select(teacher_id, grade, learning_area, topic, sub_topic)

  # check for a row with a matching request ID
  match <- prodlim::row.match(new_data, available)

  if (is.na(match)) {
    # Append the new request to the table
    DBI::dbAppendTable(conn = conn, name = table_name, value = data)
    return(1) # Request successfully added
  } else {
    return(0) # Request already exists
  }
}
