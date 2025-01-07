#' Assign a unique ID to a user after email verification.
#'
#' Updates the `id` field of a user record in the DB table
#'
#' @param table_name String. Either "teachers" or "students".
#' @param email Email of the user whose `id` needs to be updated.
#' @param new_id The new unique ID to assign to the user.
#' @return 1 if successful, 0 otherwise
#'
#' @examples
#' \dontrun{
#' assign_user_id("teachers", "user@example.com", 12345)
#' }
#'
#' @export
assign_user_id <- function(table_name, email, new_id) {
  db_name <- Sys.getenv("DATABASE_NAME")
  conn <- DBI::dbConnect(drv = RSQLite::SQLite(), db_name)
  on.exit(DBI::dbDisconnect(conn), add = TRUE)

  query <- sprintf(
    "UPDATE %s SET id = ? WHERE email = ? AND id IS NULL",
    table_name
  )
  DBI::dbExecute(conn, query, params = list(new_id, email))
}
