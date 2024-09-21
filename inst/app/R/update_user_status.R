#' Update status in a specified table
#' @param table_name A character string representing the name of the table
#' @param user_id A character string representing the user ID
#' @param new_status A character string to assign status
#' @examples
#' # update_status(table_name = "schools", user_id = "SCH-001", new_status = "Disabled")
#'
#' @import DBI
#' @export
update_user_status <- \(table_name, user_id, new_status) {
  # DB name
  db_name <- Sys.getenv("DATABASE_NAME")

  # Make SQLite connection
  conn <- DBI::dbConnect(drv = RSQLite::SQLite(), db_name)
  on.exit(DBI::dbDisconnect(conn), add = TRUE)

  # Update the status in the specified table
  query <- paste0("UPDATE ", table_name, " SET status = :status WHERE id = :id")
  dbExecute(conn, query, params = list(id = user_id, status = new_status))
}
