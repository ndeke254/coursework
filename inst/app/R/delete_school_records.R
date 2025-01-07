#' Delete school records from the database
#' @param user_id A character string representing the user ID
#' @examples
#' \dontrun{
#' # Example of deleting school records
#' # delete_school_records(user_id = "schools")
#' }
#' @import DBI
#' @export
delete_school_records <- \(user_id) {
  # DB name
  db_name <- Sys.getenv("DATABASE_NAME")

  # Make SQLite connection
  conn <- DBI::dbConnect(drv = RSQLite::SQLite(), db_name)
  on.exit(DBI::dbDisconnect(conn), add = TRUE)

  # Update the status in the database
  query <- "DELETE from schools WHERE id = :id"
  DBI::dbExecute(conn, query, params = list(id = user_id))
}
