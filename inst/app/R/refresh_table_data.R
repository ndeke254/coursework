#' Refresh table data
#' @param table_name A character string representing the table name
#' @examples
#' \dontrun {
#' # Example of refreshing table data (commented out due to missing file)
#' # refresh_table_data(reactive_data = rv$schools_data, table_name = "schools")
#' }
#' @export
refresh_table_data <- function(table_name) {
  # DB name
  db_name <- Sys.getenv("DATABASE_NAME")

  # Make SQLite connection
  conn <- DBI::dbConnect(drv = RSQLite::SQLite(), db_name)
  on.exit(DBI::dbDisconnect(conn), add = TRUE)

  # Read the table from the database
  DBI::dbReadTable(conn, table_name)
}
