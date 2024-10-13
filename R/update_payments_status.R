#' Update the Status of a Payments in the Database
#'
#' This function updates the status of a specific payment in the database.
#'
#' @param ticket_id A character string representing the ID of the request
#' that needs to be updated. Example: "TICK-007".
#' @param new_status A character string representing the new status to be
#' set for the request. Example: "PROCESSING".
#' @examples
#' \dontrun{
#' # Example usage:
#' update_payments_status("TICK-007", "APPROVED")
#' update_payments_status("TICK-008", "CANCELLED")
#' }
update_payments_status <- \(
  ticket_id,
  new_status,
  balance,
  total,
  student_id
) {
  # DB name
  db_name <- Sys.getenv("DATABASE_NAME")

  # Make SQLite connection
  conn <- DBI::dbConnect(drv = RSQLite::SQLite(), db_name)
  on.exit(DBI::dbDisconnect(conn), add = TRUE)

  # Construct the SQL query to update the status
  res <- DBI::dbSendQuery(
    conn,
    "UPDATE payments
    SET status = :new_status,
    balance = :balance,
    total = :total
    WHERE ticket_id = :ticket_id"
  )
  DBI::dbBind(
    res,
    params = list(
      new_status = new_status,
      ticket_id = ticket_id,
      balance = balance,
      total = total
    )
  )

  if (balance <= 0) {
    res <- DBI::dbSendQuery(
      conn,
      "UPDATE students
    SET paid = :paid
    WHERE id = :student_id"
    )
    DBI::dbBind(
      res,
      params = list(
        paid = 1,
        student_id = student_id
      )
    )
  }
  DBI::dbClearResult(res)
}
