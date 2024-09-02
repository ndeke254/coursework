student_content_tab <- div(
  class = "container pt-5",
  div(
    class = "mb-5",
    uiOutput("signed"),
  ),
  uiOutput("term_end_student_table"),
  argonTabSet(
    id = "student_content_tabset",
    horizontal = TRUE,
    size = "lg",
    width = 12,
    argonTab(
      tabName = "Library",
      title = "Library",
      active = TRUE,
      p("Welcome to your library:", class = " fw-semibold mt-3"),
      shinyjs::hidden(
        div(
          id = "payment_required",
          class = "pt-5 mb-5 border-bottom mt-5 text-center",
          div(
            p("Payment required",
              class = "fw-semibold",
            ),
            p(
              textOutput("balance_required")
            )
          )
        )
      ),
      div(
        id = "content_pdfs",
        student_content_filters,
        class = "container",
        `data-aos` = "fade-up",
        `data-aos-delay` = "100",
        uiOutput("published_pdfs"),
        uiOutput("selected_pdf_frame")
      )
    ),
    argonTab(
      tabName = "Payments",
      p("Create a payment ticket:", class = " fw-semibold mt-3"),
      fluidRow(
        class = "container",
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
            value = 500,
            currencySymbol = "Ksh ",
            decimalPlaces = 0,
            minimumValue = 1
          )
        ),
        airDatepickerInput(
          inputId = "payment_time",
          label = label_mandatory("Select Date and Time:"),
          timepicker = TRUE,
          maxDate = lubridate::today(),
          timepickerOpts = list(
            hoursStep = 1,
            minutesStep = 1,
            seconds = FALSE
          ),
          value = Sys.time(),
          autoClose = TRUE
        )
      ),
      fluidRow(
        column(
          class = "d-flex justify-content-end",
          width = 12,
          actionButton(
            inputId = "create_ticket",
            label = "Add payment",
            class = "mt-3 mb-3"
          )
        )
      ),
      column(
        width = 6,
        class = "mb-3",
        textOutput("school_ticket"), br(),
        textOutput("paid_amount"), br(),
        textOutput("balance"), br(),
        p("Payment progress", class = "fw-semibold"),
        progressBar(
          value = 0,
          display_pct = TRUE,
          title = "Payments:",
          id = "payment_progress"
        )
      ),
      uiOutput(outputId = "payments_tickets_data")
    )
  )
)
