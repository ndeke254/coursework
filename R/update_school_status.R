#' Update school status
#' @param reactive_data A reactive data frame
#' @param table_name A character string representing the table name
#' @examples
#' # Example of updating school status (commented out due to missing file)
#' # update_school_status(reactive_data = rv$school_data, table_name = "schools")
#' @export
#' 
update_school_status <- \(user_id, new_status) {
  # DB name
  db_name <- Sys.getenv("DATABASE_NAME")

  # Make SQLite connection
  conn <- DBI::dbConnect(drv = RSQLite::SQLite(), db_name)
  on.exit(DBI::dbDisconnect(conn), add = TRUE)

  # Update the status in the database
  query <- "UPDATE schools SET status = :status WHERE id = :id"
  dbExecute(conn, query, params = list(id = user_id, status = new_status))
}

