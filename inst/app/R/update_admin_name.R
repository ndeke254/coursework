#' @export
update_admin_name <- \(email, name) {
  db_name <- Sys.getenv("DATABASE_NAME")
  conn <- DBI::dbConnect(drv = RSQLite::SQLite(), db_name)
  on.exit(DBI::dbDisconnect(conn), add = TRUE)

  existing_names <- DBI::dbGetQuery(
    conn = conn,
    "SELECT 1 FROM administrator WHERE value = :name",
    params = list(name = name)
  )
  if (nrow(existing_names) > 0) {
    return(0)
  }

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
