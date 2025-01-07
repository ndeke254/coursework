#' Get the next request ID
#' @param table_name A character string representing the table name
#' @examples
#' \dontrun{
#' # next_request_id("requests")
#' }
#' @export
next_request_id <- function(table_name) {
  # DB name
  db_name <- Sys.getenv("DATABASE_NAME")

  # Make SQLite connection
  conn <- DBI::dbConnect(drv = RSQLite::SQLite(), db_name)
  on.exit(DBI::dbDisconnect(conn), add = TRUE)

  # Read the table from the database
  request_data <- DBI::dbReadTable(conn, table_name)

  # Define the fixed prefix
  prefix <- "REQ-"

  # Filter the table for the request IDs based on the prefix
  id_col <- request_data$id
  filtered_ids <- id_col[grepl(prefix, id_col)]

  # Check if the filtered IDs have rows
  if (length(filtered_ids) > 0) {
    # Extract numeric part of the ID
    numeric_part <- sub(prefix, "", filtered_ids)

    # Convert to numeric
    numeric_part <- as.numeric(numeric_part)

    # Get the maximum number and add 1
    next_number <- max(numeric_part, na.rm = TRUE) + 1

    # Return the next ID in the required format
    next_id <- sprintf(paste0(prefix, "%03d"), next_number)

    return(next_id)
  } else {
    # First record id
    return(paste0(prefix, "001"))
  }
}
