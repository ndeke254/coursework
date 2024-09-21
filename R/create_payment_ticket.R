#' Add a ticket details into the DB.
#'
#' @param table_name Name of the table to add a record to.
#' @param data A data.frame of the data to be added.
#' @return double `1` if ticket was created. `0` otherwise.
#' @import prodlim
#' @export
create_payment_ticket <- function(table_name, data) {
    # DB name
    db_name <- Sys.getenv("DATABASE_NAME")

    # Make SQLite connection
    conn <- DBI::dbConnect(drv = RSQLite::SQLite(), db_name)
    on.exit(DBI::dbDisconnect(conn), add = TRUE)

    # Read the DB table
    table_data <- DBI::dbReadTable(conn, table_name)

    # Check if the school name or email already exists
    available <- table_data |>
        select(user_id, code)
    new_data <- c(data$user_id, data$code)
print(available)
    # check for a row with match
    match <- prodlim::row.match(new_data, available)

    if (is.na(match)) {
        DBI::dbAppendTable(conn = conn, name = table_name, value = data)
        return(1) # Ticket successfully added
    } else {
        return(0) # Ticket already exists
    }
}
