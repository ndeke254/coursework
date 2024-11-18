#' @export
reset_students <- \(){
  # Create the SQLite connection
  db_name <- Sys.getenv("DATABASE_NAME")
  conn <- DBI::dbConnect(drv = RSQLite::SQLite(), db_name)
  on.exit(DBI::dbDisconnect(conn))

  DBI::dbExecute(conn, "UPDATE students SET paid = 0")
}
