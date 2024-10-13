#' Update school details
#' @param school_id A character string representing the school ID
#' @param new_values A named list of new values to update in the school record
#' @examples
#' # update_school_details(school_id = "SCH-001", new_values = list(name = "New School Name", email = "newemail@example.com"))
#'
#' @import DBI
#' @export
update_school_details <- function(school_id, new_values) {
  # DB name
  db_name <- Sys.getenv("DATABASE_NAME")

  # Make SQLite connection
  conn <- DBI::dbConnect(drv = RSQLite::SQLite(), dbname = db_name)
  on.exit(DBI::dbDisconnect(conn), add = TRUE)

  # Build the SET part of the query
  set_clause <- paste0(
    names(new_values),
    " = :",
    names(new_values),
    collapse = ", "
  )

  # Build the full query
  query <- paste0("UPDATE schools SET ", set_clause, " WHERE id = :id")

  # Add the school ID to the parameters
  params <- new_values
  params$id <- school_id

  # Update the school details in the database
  DBI::dbExecute(conn, query, params = params)
}
