student_content_tab <- div(
  class = "container pt-5",
  div(
    class = "mb-5",
    uiOutput("signed"),
  ),
  argonTabSet(
    id = "student_content_tabset",
    horizontal = TRUE,
    size = "lg",
    width = 12,
    argonTab(
      tabName = "Library",
      active = TRUE,
      p("Welcome to your library:", class = " fw-semibold mt-3"),
      student_content_filters,
      class = "container",
      `data-aos` = "fade-up",
      `data-aos-delay` = "100",
      uiOutput("published_pdfs"),
      uiOutput("selected_pdf_frame")
    ),
    argonTab(
      tabName = "Payments",
      p("Payments status:", class = " fw-semibold mt-3"),
      fluidRow(
        column(
          width = 3,
          shiny::textInput(
            inputId = "transaction_code",
            label = label_mandatory("Code:"),
            value = "",
            placeholder = "Eg. SHR6H7H8V0"
          )
        ),
        column(
          width = 3,
          autonumericInput(
            inputId = "payment_tel_number",
            label = label_mandatory("Phone:"),
            value = 123456789,
            currencySymbol = "254 ",
            decimalPlaces = 0,
            digitGroupSeparator = ""
          )
        ),
        column(
          width = 3,
          autonumericInput(
            inputId = "amount",
            label_mandatory("Amount paid:"),
            value = 1000,
            currencySymbol = "Ksh ",
            decimalPlaces = 0,
            minimumValue = 500
          )
        ),
        airDatepickerInput(
          inputId = "payment_time",
          label = label_mandatory("Select Date and Time:"),
          timepicker = TRUE,
          timepickerOpts = list(
            hoursStep = 1,
            minutesStep = 5,
            seconds = FALSE
          ),
          value = Sys.time(),
          autoClose = TRUE
        )
      ),
      fluidRow(
        column(
          width = 12,
          actionButton(
            inputId = "create_ticket",
            label = "Add payment",
            class = "mt-3"
          )
        )
      ),
      fluidRow(
        uiOutput(outputId = "payments_tickets_data")
      )
    )
  )
)
