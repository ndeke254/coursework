#' @export
update_admin_name <- \(email, name) {
  # DB name
  db_name <- Sys.getenv("DATABASE_NAME")

  # Make SQLite connection
  conn <- DBI::dbConnect(drv = RSQLite::SQLite(), db_name)
  on.exit(DBI::dbDisconnect(conn), add = TRUE)
  data <- data.frame(
    input_col = email,
    value = name
  )

  DBI::dbAppendTable(
    conn = conn,
    name = "administrator",
    value = data
  )
}
