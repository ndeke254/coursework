#' Function to send email and log failures to DB
#' @param receipients character. receipients email/s address/ es
#' @param subject string. email header
#' @param body html. email template used.
#' @export
send_email_notification <- \(receipients, subject, body) {
  for (receipient in receipients) {
    tryCatch(
      {
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
      },
      error = function(e) {
        # Make SQLite connection
        db_name <- Sys.getenv("DATABASE_NAME")
        conn <- DBI::dbConnect(drv = RSQLite::SQLite(), db_name)
        on.exit(DBI::dbDisconnect(conn), add = TRUE)

        unique_email_id <- paste0(
          "#",
          toupper(
            substr(uuid::UUIDgenerate(), 1, 8)
          )
        )

        DBI::dbWriteTable(
          conn = conn,
          name = "emails",
          value = data.frame(
            id = unique_email_id,
            sender = Sys.getenv("SYSTEM_EMAIL"),
            receipient = recipients,
            template = body,
            subject = subject,
            time = format(Sys.time(), format = "%Y-%m-%d %H:%M:%S")
          ),
          append = TRUE,
          row.names = FALSE
        )
      }
    )
  }
}
