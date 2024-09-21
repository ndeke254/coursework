#' Update the Status of a Request in the Database
#'
#' This function updates the status of a specific request in the database.
#'
#' @param request_id A character string representing the ID of the request
#' that needs to be updated. Example: "REQ-007".
#' @param new_status A character string representing the new status to be
#' set for the request. Example: "PROCESSING".
#' @examples
#' \dontrun{
#' # Example usage:
#' update_request_status("REQ-007", "PROCESSING")
#' update_request_status("REQ-008", "CANCELLED")
#' }
update_request_status <- function(request_id, new_status) {
  # DB name
  db_name <- Sys.getenv("DATABASE_NAME")

  # Make SQLite connection
  conn <- DBI::dbConnect(drv = RSQLite::SQLite(), db_name)
  on.exit(DBI::dbDisconnect(conn), add = TRUE)

  # Construct the SQL query to update the status
  res <- dbSendQuery(
    conn,
    "UPDATE requests
    SET status = :new_status
    WHERE id = :request_id"
  )
  dbBind(
    res,
    params = list(new_status = new_status, request_id = request_id)
  )

  dbClearResult(res)
}
