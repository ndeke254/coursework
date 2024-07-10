#' Get the signed in user
#'
#' @param user_email A character string representing the user email
#' @examples
#' email <- "useremail@gmail.com"
#' get_signed_user(user_email = email)
#' @import DBI
#' @export
get_signed_user <- function(user_email) {
    # DB name
    db_name <- Sys.getenv("DATABASE_NAME")

    # Make SQLite connection
    conn <- dbConnect(drv = RSQLite::SQLite(), dbname = db_name)
    on.exit(dbDisconnect(conn), add = TRUE)

    # Build the full query
    query <- "SELECT * FROM users WHERE email = :email"

    # Get the user details from the database
    result <- dbGetQuery(
        conn,
        query,
        params = list(email = user_email)
    )

    result
}
