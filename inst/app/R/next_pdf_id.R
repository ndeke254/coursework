#' Get the next PDF id
#' @param table_name A character string representing the table name
#' @examples
#' # next_pdf_id("pdfs")
#' @export
next_pdf_id <- function(table_name) {
  # DB name
  db_name <- Sys.getenv("DATABASE_NAME")

  # Make SQLite connection
  conn <- DBI::dbConnect(drv = RSQLite::SQLite(), db_name)
  on.exit(DBI::dbDisconnect(conn), add = TRUE)

  # Read the table from the database
  pdf_data <- DBI::dbReadTable(conn, table_name)

  # Check if the table has rows
  if (nrow(pdf_data) > 0) {
    id_col <- pdf_data$id

    # Extract numeric part of the ID
    numeric_part <- sub("PDF-", "", id_col)

    # Convert to numeric
    numeric_part <- as.numeric(numeric_part)

    # Get the maximum number and add 1
    next_number <- max(numeric_part, na.rm = TRUE) + 1

    # Return the next ID in the required format
    next_id <- sprintf("PDF-%03d", next_number)

    return(next_id)
  } else {
    # First record id
    return("PDF-001")
  }
}
