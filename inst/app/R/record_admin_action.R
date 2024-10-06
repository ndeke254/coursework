#' Capture Administrator Action and Update the Timeline Table
#' @examples
#' \dontrun{
#' # Example usage
#' record_admin_action(
#'   user = "Admin123",
#'   action = "Approve",
#'   description = "Approved ticket #038F389E"
#' )
#' }
#'
#' @import DBI
#' @export
record_admin_action <- \(user, action, description) {
  # DB name
  db_name <- Sys.getenv("DATABASE_NAME")

  # Make SQLite connection
  conn <- DBI::dbConnect(drv = RSQLite::SQLite(), db_name)
  on.exit(DBI::dbDisconnect(conn), add = TRUE)

  new_action <- data.frame(
    user = user,
    action = action,
    description = description,
    time = format(Sys.time(), format = "%Y-%m-%d %H:%M:%S"),
    stringsAsFactors = FALSE
  )
  dbAppendTable(
    conn = conn,
    name = "timeline",
    value = new_action
  )
}
