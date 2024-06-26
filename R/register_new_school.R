#' Register a new school into the DB.
#' Adds a new row to the `schools` table in coursework database.
#' Status of the newly created school is "enabled" by default.
#'
#' @param table_name Name of the table to add a record to.
#' @param data A data.frame of the data to be added. Colnames are id, name, level, type, county, email, status.
#' @return double `1` if school was created. `0` otherwise.
#'
#' @export
register_new_school <- function(table_name, data) {
  # DB name
  db_name <- Sys.getenv("DATABASE_NAME")

  # Make SQLite connection
  conn <- DBI::dbConnect(drv = RSQLite::SQLite(), db_name)
  on.exit(DBI::dbDisconnect(conn), add = TRUE)
  
  # Read the DB table
  table_data <- DBI::dbReadTable(conn, table_name)
  # Check if the school name and email already exists
  if (data$email %in% table_data$email || data$name %in% table_data$name) {
    return(0)  # School already exists
  } else {
    DBI::dbAppendTable(conn = conn, name = table_name, value = data)
    return(1)  # School successfully added
  }
}