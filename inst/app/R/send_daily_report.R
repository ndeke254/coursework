# Connect to the database
dotenv::load_dot_env(
  file = "/home/jefferson.ndeke/PersonalR/coursework/inst/app/.Renviron"
)
conn <- DBI::dbConnect(
  drv = RSQLite::SQLite(),
  paste0(
    "/home/jefferson.ndeke/PersonalR/coursework/inst/app/",
    Sys.getenv("DATABASE_NAME")
  )
)

# Function to filter data for today's date
filter_today_data <- function(conn, table_name, date_column = "time") {
  tryCatch(
    {
      data <- DBI::dbReadTable(conn, table_name)
      if (identical(date_column, "date")) {
        data <- data |>
          dplyr::rename(time = date)
      }

      data |>
        dplyr::mutate(date = as.Date(time)) |>
        dplyr::filter(date == Sys.Date()) |>
        dplyr::select(-c(date))
      names(data) <- toupper(snakecase::to_title_case(names(data)))
      data
    },
    error = function(e) {
      message(
        sprintf("Error processing table '%s': %s", table_name, e$message)
      )
      return(data.frame())
    }
  )
}

# Filter data from various tables
data_tables <- list(
  schools_data = filter_today_data(conn, "schools", "time"),
  pdf_data = filter_today_data(conn, "content", "time"),
  teachers_data = filter_today_data(conn, "teachers", "time"),
  students_data = filter_today_data(conn, "students", "time"),
  payments_data = filter_today_data(conn, "payments", "time"),
  requests_data = filter_today_data(conn, "requests", "time"),
  views_data = filter_today_data(conn, "views", "date"),
  emails_data = filter_today_data(conn, "emails", "time") |>
    dplyr::select(-c("TEMPLATE"))
)

# Retrieve admin emails from the administrator table
admin_data <- DBI::dbReadTable(conn, "administrator") |>
  dplyr::filter(grepl("*@gmail\\.com$", input_col))

admin_emails <- admin_data |>
  dplyr::select(input_col) |>
  unlist() |>
  as.vector()

# Get the first name of the administrator
receipient_name <- admin_data |>
  dplyr::pull(value)
first_name <- strsplit(receipient_name, " ")[[1]][1]

# Create the salutation for the email
email_salutation <- paste0(
  "<p style='font-size: 16px; line-height: 1.6; font-family: Montserrat, sans-serif;'>Hello <strong>",
  first_name,
  "</strong>,</p>"
)

# Helper function to generate HTML tables with custom CSS styling
generate_html_table <- function(data, title) {
  if (nrow(data) > 0) {
    # Start the HTML table
    table_html <- paste0(
      '<div style="overflow-x:auto; padding: 10px; border-radius: 8px;">',
      '<h3 style="font-family: Montserrat, sans-serif; color: #003366;">', title, "</h3>",
      '<table style="width: 100%; border-collapse: collapse; border-radius: 8px; overflow: hidden;">',
      '<thead style="background-color: #163142; color: #fff;">',
      "<tr>"
    )

    # Add table headers
    for (col in names(data)) {
      table_html <- paste0(
        table_html,
        '<th style="padding: 8px; text-align: left;">', col, "</th>"
      )
    }
    table_html <- paste0(table_html, "</tr></thead><tbody>")

    # Add table rows
    for (i in 1:nrow(data)) {
      table_html <- paste0(table_html, '<tr style="background-color: #f9f9f9;">')
      for (col in names(data)) {
        table_html <- paste0(
          table_html,
          '<td style="padding: 8px; text-align: left; border: 1px solid #50BD8C;">',
          data[i, col], "</td>"
        )
      }
      table_html <- paste0(table_html, "</tr>")
    }

    # Close the table
    table_html <- paste0(table_html, "</tbody></table></div>")

    return(table_html)
  } else {
    return(paste0("<h3>", title, "</h3><p>No data available.</p>"))
  }
}

# Function to generate the email body with HTML tables, including custom styling
email_body <- function(content) {
  paste0(
    '
  <html>
  <head>
    <style>
      body {
        font-family: Montserrat, sans-serif;
      }
      .container {
        background: whitesmoke;
        padding: 40px 0;
        width: 100%;
      }
      .email-wrapper {
        width: 100%;
        max-width: 900px;
        margin: 0 auto;
        padding: 20px;
        background-color: #fff;
        border-radius: 8px;
        box-shadow: 0 4px 8px rgba(0, 0, 0, 0.1);
      }
      .header {
        text-align: center;
        margin-bottom: 20px;
      }
      .header img {
        max-width: 300px;
        height: auto;
      }
      .title {
        font-size: 20px;
        color: #333;
      }
      .title strong {
        color: #003366;
      }
      .content {
        font-size: 16px;
        line-height: 1.6;
      }
      .footer {
        font-size: 16px;
        color: #777;
        margin-top: 30px;
      }
      .footer p {
        color: #444;
      }
      .salutation {
        font-size: 16px;
        line-height: 1.6;
        font-family: Montserrat, sans-serif;
      }
      .salutation strong {
        font-weight: bold;
      }
    </style>
  </head>
  <body>
    <div class="container">
      <div class="email-wrapper">
        <div class="header">
          <img src="https://quickstudy.co.ke/candidate/logo/logo_full.png" alt="CANDIDATE LOGO">
        </div>
        <h1 class="title">
          <strong>Daily Records Update</strong>
        </h1>
        <p class="content">
        Hello <strong>', first_name, '</strong>, <br><br>
        Here is the update on today\'s records:
      </p>
      <div class="content">
        ', content, '
      </div>
      <div class="footer">
        <p>
          Happy Working,<br>
          Your <b>Technical</b> Team
        </p>
      </div>
    </div>
  </div>
  </body>
  </html>
  '
  )
}

# Combine tables into a single email content
email_body_content <- paste0(
  generate_html_table(data_tables$schools_data, "Schools Data"),
  generate_html_table(data_tables$teachers_data, "Teachers Data"),
  generate_html_table(data_tables$students_data, "Students Data"),
  generate_html_table(data_tables$pdf_data, "PDF Content"),
  generate_html_table(data_tables$requests_data, "Requests Data"),
  generate_html_table(data_tables$payments_data, "Payments Data"),
  generate_html_table(data_tables$views_data, "Views Data"),
  generate_html_table(data_tables$emails_data, "Emails Data")
)

# Final email body content
final_email_body <- email_body(email_body_content)

# Send emails to all admins
today_date <- format(Sys.Date(), "%B %d, %Y")
email_subject <- paste("Daily Update -", today_date)
for (recipient in admin_emails) {
  tryCatch(
    {
      mailR::send.mail(
        from = sprintf(
          "Candidate <%s>", Sys.getenv("SYSTEM_EMAIL")
        ),
        to = recipient,
        subject = email_subject,
        body = final_email_body,
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
      message(sprintf("Email sent to %s", recipient))
    },
    error = function(e) {
      warning(sprintf("Failed to send email to %s: %s", recipient, e$message))
    }
  )
}

DBI::dbDisconnect(conn)
