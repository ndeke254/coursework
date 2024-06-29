#' Update school status
#' @param user_id A character string representing the user ID
#' @param new_status A character string to asign status
#' @examples
#' # update_school_status(user_id = "SCH-001", new_status = "Disabled")
#'
#' @import DBI
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
