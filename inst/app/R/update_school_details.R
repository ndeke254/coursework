#' Update school details and propagate changes
#' @param school_id A character string representing the school ID
#' @param new_values A named list of new values to update in the school record
#' @examples
#' \dontrun{
#' # update_school_details(school_id = "SCH-001", new_values = list(name = "New School Name", email = "newemail@example.com"))
#' }
#'
#' @import DBI
#' @export
update_school_details <- function(school_id, new_values) {
  # DB name
  db_name <- Sys.getenv("DATABASE_NAME")

  # Make SQLite connection
  conn <- DBI::dbConnect(drv = RSQLite::SQLite(), dbname = db_name)
  on.exit(DBI::dbDisconnect(conn), add = TRUE)

  # Check if the new school name already exists
  name_exists <- DBI::dbGetQuery(
    conn,
    "SELECT EXISTS (SELECT 1 FROM schools
    WHERE school_name = :new_school_name)",
    params = list(new_school_name = new_values$school_name)
  )[[1]]

  if (name_exists) {
    return(0)
  }

  # Retrieve the old school name from the database
  old_name <- DBI::dbGetQuery(
    conn,
    "SELECT school_name FROM schools WHERE id = :school_id",
    params = list(school_id = school_id)
  )$school_name

  # Build the SET clause for updating the schools table
  set_clause <- paste0(
    names(new_values),
    " = :",
    names(new_values),
    collapse = ", "
  )

  # Build the query for updating the schools table
  school_query <- paste0("UPDATE schools SET ", set_clause, " WHERE id = :id")

  # Add the school ID to the parameters
  params <- new_values
  params$id <- school_id

  # Update the school details in the schools table
  DBI::dbExecute(conn, school_query, params = params)

  # Update the school name in the students table
  DBI::dbExecute(
    conn,
    "UPDATE students
    SET school_name = :school_name
  WHERE school_name = :old_name",
    params = list(
      school_name = new_values$school_name,
      old_name = old_name
    )
  )

  # Update the school name in the teachers table
  DBI::dbExecute(
    conn,
    "UPDATE teachers
    SET school_name = :school_name
  WHERE school_name = :old_name",
    params = list(
      school_name = new_values$school_name,
      old_name = old_name
    )
  )
}
