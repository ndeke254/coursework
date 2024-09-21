#' @export
easy_load_data <- function(currentPage, pageSize) {
  # DB name
  db_name <- Sys.getenv("DATABASE_NAME")

  # Make SQLite connection
  conn <- DBI::dbConnect(drv = RSQLite::SQLite(), db_name)
  on.exit(DBI::dbDisconnect(conn), add = TRUE)

  offset <- (currentPage - 1) * pageSize

  query <- sprintf("SELECT * FROM timeline
                   ORDER BY time DESC
                   LIMIT %d OFFSET %d", pageSize, offset)

  data <- data.table::as.data.table(dbGetQuery(conn, query))

  # If no rows are returned, return an empty data frame
  if (nrow(data) == 0) {
    return(data.frame())
  }

  # Convert Date column to datetime
  data$time <- as.POSIXct(data$time, tz = "UTC")
  data <- data %>%
    mutate(
      DateOnly = as.Date(time),
      TimeOnly = format(time, "%H:%M:%S")
    )
    print(data)
  data
}
