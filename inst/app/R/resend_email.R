#' Resend a failed email and delete the record if successful
#'
#' @param email_id string. The unique identifier for the email to be resent.
#' @return logical.
#' @export
resend_email <- \(email_id) {
  # Make SQLite connection
  db_name <- Sys.getenv("DATABASE_NAME")
  conn <- DBI::dbConnect(drv = RSQLite::SQLite(), db_name)
  on.exit(DBI::dbDisconnect(conn), add = TRUE)

  email_info <- DBI::dbGetQuery(
    conn = conn,
    "SELECT * FROM emails WHERE id = :email_id",
    params = list(email_id = email_id)
  )
  if (!identical(nrow(email_info), 1L)) {
    message("Email with the provided ID not found.")
    return(FALSE)
  }

  # Extract email details
  recipients <- email_info$receipient
  subject <- email_info$subject
  body <- email_info$template
  sender <- email_info$sender

  # Compose and resend the email
  tryCatch(
    {
      for (receipient in receipients) {
        mailR::send.mail(
          from = sprintf("Candidate <%s>", Sys.getenv("SYSTEM_EMAIL")),
          to = receipient,
          subject = subject,
          body = body,
          html = TRUE,
          authenticate = TRUE,
          smtp = list(
            host.name = Sys.getenv("SMTP_HOST"),
            port = as.integer(Sys.getenv("SMTP_PORT")),
            user.name = Sys.getenv("SYSTEM_EMAIL"),
            passwd = Sys.getenv("SMTP_PASSWORD"),
            tls = TRUE
          )
        )
      }

      # If successful, delete the record from the database
      DBI::dbExecute(
        conn = conn,
        statement = "DELETE FROM emails WHERE id = :email_id",
        params = list(email_id = email_id)
      )
      return(TRUE)
    },
    error = function(e) {
      return(FALSE)
    }
  )
}
