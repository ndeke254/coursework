#' Get the signed in user
#'
#' @param user_email A character string representing the user email
#' @param user_type A character string, either `student` or `teacher`
#' @examples
#' email <- "useremail@gmail.com"
#' get_signed_user(user_email = "useremail@gmail.com", user_type = "student")
#' @import DBI
#' @export
get_signed_user <- function(user_email, user_type) {
    # DB name
    db_name <- Sys.getenv("DATABASE_NAME")

    # Make SQLite connection
    conn <- dbConnect(drv = RSQLite::SQLite(), dbname = db_name)
    on.exit(dbDisconnect(conn), add = TRUE)

    # Determine the table name based on user_type
    table_name <- ifelse(user_type == "student", "students", "teachers")

    # Build the full query
    query <- paste0("SELECT * FROM ", table_name, " WHERE email = :email")

    # Get the user details from the database
    result <- dbGetQuery(
        conn,
        query,
        params = list(email = user_email)
    )

    result
}
