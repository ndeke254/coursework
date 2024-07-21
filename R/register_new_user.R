#' Register a new user into the DB.
#' Adds a new row to the `schools` table in coursework database.
#' Status of the newly created school is "enabled" by default.
#'
#' @param table_name Name of the table to add a record to.
#' @param data A data.frame of the data to be added. Colnames are 
#' id, user_name, type, school_name, grade, phone, email, status
#' @return double `1` if school was created. `0` otherwise.
#'
#' @export
register_new_user <- function(table_name, data) {
  # DB name
  db_name <- Sys.getenv("DATABASE_NAME")

  # Make SQLite connection
  conn <- DBI::dbConnect(drv = RSQLite::SQLite(), db_name)
  on.exit(DBI::dbDisconnect(conn), add = TRUE)
  
  # Read the DB table
  table_data <- DBI::dbReadTable(conn, table_name)
  
  # Check if the school name or email already exists
  name_exists <- data$user_name %in% table_data$user_name
  email_exists <- data$email %in% table_data$email

  phone_exists <- data$phone %in% table_data$phone

  if (!name_exists && !email_exists && !phone_exists) {
    DBI::dbAppendTable(
      conn = conn, 
      name = table_name,
       value = data
       )
    return(1)  # User successfully added
  } else {
    return(0) # User already exists
  }
}
