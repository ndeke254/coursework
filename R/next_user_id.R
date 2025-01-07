#' Get the next user ID
#' @param table_name A character string representing the table name
#' @param user_type A character string, either `student` or `teacher`
#' @examples
#' \dontrun{
#' next_user_id("users", "student")
#' }
#' @export
next_user_id <- function(table_name, user_type) {
  # DB name
  db_name <- Sys.getenv("DATABASE_NAME")

  # Make SQLite connection
  conn <- DBI::dbConnect(drv = RSQLite::SQLite(), db_name)
  on.exit(DBI::dbDisconnect(conn), add = TRUE)

  # Read the table from the database
  user_data <- DBI::dbReadTable(conn, table_name)

  # Determine the ID prefix based on user_type
  prefix <- ifelse(user_type == "student", "STU-", "TEA-")

  # Filter the table for the user type based on the prefix
  id_col <- user_data$id
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
