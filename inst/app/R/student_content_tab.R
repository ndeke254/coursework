student_content_tab <- div(
  class = "container pt-5 mt-5",
  div(
    class = "mb-5",
    uiOutput("signed"),
  ),
  uiOutput("term_end_student_table"),
  argonR::argonTabSet(
    id = "student_content_tabset",
    horizontal = TRUE,
    size = "lg",
    width = 12,
    argonR::argonTab(
      tabName = "Library",
      active = TRUE,
      p("Welcome to your library:", class = "lead text-bold mt-3"),
      uiOutput("balance_required"),
      div(
        id = "content_pdfs",
        student_content_filters,
        #   class = "container",
        `data-aos` = "fade-up",
        `data-aos-delay` = "100",
        uiOutput("published_pdfs"),
        uiOutput("selected_pdf_frame")
      )
    ),
    argonR::argonTab(
      tabName = "Payments",
      div(
        class = "pt-5",
        fluidRow(
          column(
            width = 3,
            bslib::value_box(
              title = "Your invoice",
              value = textOutput("school_ticket"),
              showcase = bsicons::bs_icon("bank"),
              showcase_layout = "top right"
            )
          ),
          column(
            width = 3,
            bslib::value_box(
              title = "Paid amount",
              value = textOutput("paid_amount"),
              showcase = bsicons::bs_icon("credit-card-fill"),
              showcase_layout = "top right"
            )
          ),
          column(
            width = 3,
            bslib::value_box(
              title = "Balance",
              value = textOutput("balance"),
              showcase = bsicons::bs_icon("cash-coin"),
              showcase_layout = "top right"
            )
          ),
          column(
            width = 3,
            bslib::value_box(
              title = "Progress",
              class = "pb-4",
              showcase = bsicons::bs_icon("percent"),
              showcase_layout = "top right",
              value = shinyWidgets::progressBar(
                value = 0,
                display_pct = TRUE,
                id = "payment_progress"
              )
            )
          )
        ), 
        div(
          p("Create a payment ticket", class = "mb-3 lead text-bold"),
          class = "card card-body",
          div(
            class = "row",
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
              shinyWidgets::autonumericInput(
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
              shinyWidgets::autonumericInput(
                inputId = "amount",
                label_mandatory("Amount paid:"),
                value = 799,
                currencySymbol = "Ksh ",
                decimalPlaces = 0,
                minimumValue = 1
              ) 
            ),
            column(
              width = 3,
              shinyWidgets::airDatepickerInput(
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
            )
          ),
          div(
            class = "row",
            column(
              class = "d-flex justify-content-end",
              width = 12,
              actionButton(
                inputId = "create_ticket",
                label = "Add payment",
                width = "300px",
                class = "mt-3 mb-3"
              ) |>
                basic_primary_btn()
            )
          )
        )
      ),
      div(
        class = "card card-body",
        #      p("Payments tickets:", class = "lead mb-3 text-bold"),
        reactable::reactableOutput("payments_tickets_data")
      )
    )
  )
)
