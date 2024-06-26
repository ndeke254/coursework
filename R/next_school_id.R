#' Create a unique id for new school record
#' Records follow in an increasing order
#' @param table_name The name of the table to read the `id` column from
#' @return Character. A character id for the next record
#'
#' @example
#' next_school_id("schools")
#' SCH-058
#' @export

next_school_id <- function(table_name) {
  # DB name
  db_name <- Sys.getenv("DATABASE_NAME")

  # Make SQLite connection
  conn <- DBI::dbConnect(drv = RSQLite::SQLite(), db_name)
  on.exit(DBI::dbDisconnect(conn), add = TRUE)
  
  # Read the table from the database
  school_data <- DBI::dbReadTable(conn, table_name)

  # Check if the table has rows
  if (nrow(school_data) > 0) {
    id_col <- school_data$id

    # Extract numeric part of the ID
    numeric_part <- sub("SCH-", "", id_col)

    # Convert to numeric
    numeric_part <- as.numeric(numeric_part)

    # Get the maximum number and add 1
    next_number <- max(numeric_part, na.rm = TRUE) + 1

    # Return the next ID in the required format
    next_id <- sprintf("SCH-%03d", next_number)

    return(next_id)
  } else {
    # First record id
    return("SCH-001")
  }
}
