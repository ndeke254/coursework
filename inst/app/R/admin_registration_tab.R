admin_registration_tab <- div(
  class = "container mt-5 mb-5",
  fluidRow(
    textInput(
      inputId = "term_label",
      label = "Term label:",
      placeholder = "Enter term label"
    ),
    airDatepickerInput(
      inputId = "term_end_date",
      label = "Current Term End Date:",
      value = Sys.Date(),
      autoClose = TRUE
    )
  ),
  fluidRow(
    actionButton(
      inputId = "set_term_end",
      label = "Set"
    )
  ),
  argonTabSet(
    id = "registration_tabset",
    horizontal = TRUE,
    size = "lg",
    width = 12,
    iconList = list(
      icon = argonIcon("cloud-upload-96", color = "body"),
      icon = argonIcon("caps-small", color = "body"),
      icon = argonIcon("settings", color = "body")
    ),
    argonTab(
      tabName = "Upload",
      active = TRUE,
      fluidRow(
        center = TRUE,
        bslib::card(
          p("Upload content", class = "mt-3 fw-semibold"),
          p("All fields are required"),
          div(
            class = "d-flex justify-content-center",
            fileInput(
              inputId = "pdfFile",
              label = "Select a PDF",
              width = 500,
              accept = c(".pdf")
            )
          ),
          fluidRow(
            column(
              width = 3,
              shiny::selectizeInput(
                inputId = "doc_request",
                label = label_mandatory("Request ID:"),
                options = list(maxOptions = 3),
                choices = NULL
              )
            ),
            column(
              width = 3,
              disabled(
                shiny::textInput(
                  inputId = "doc_teacher_id",
                  label = label_mandatory("Teacher:"),
                  placeholder = "Eg. John Kamau"
                )
              )
            ),
            column(
              width = 3,
              disabled(
                shiny::textInput(
                  inputId = "doc_grade",
                  label = label_mandatory("Grade:"),
                  placeholder = "Eg. Grade 6"
                )
              )
            ),
            column(
              width = 3,
              disabled(
                shiny::textInput(
                  inputId = "doc_learning_area",
                  label = label_mandatory("Learning Area:"),
                  placeholder = "Eg. Mathematics"
                )
              )
            )
          ),
          fluidRow(
            column(
              width = 3,
              disabled(
                shiny::textInput(
                  inputId = "doc_topic",
                  label = label_mandatory("Topic:"),
                  placeholder = "Eg. Addition"
                )
              )
            ),
            column(
              width = 3,
              disabled(
                shiny::textInput(
                  inputId = "doc_sub_topic",
                  label_mandatory("Sub-topic:"),
                  value = "",
                  placeholder = "Eg. Long division method"
                )
              )
            )
          ),
          div(
            class = "d-flex justify-content-center",
            actionButton(
              inputId = "upload_btn",
              label = "Publish PDF",
              class = "mt-2 mb-2 float-right"
            ) |>
              basic_primary_btn()
          )
        )
      )
    ),
    argonTab(
      tabName = "Registration",
      fluidRow(
        bslib::card(
          h6("School Registration", class = "fw-semibold pt-3"),
          tags$head(
            tags$style(HTML(
              " #step_1, #step_2, #step_u3, #step_u1, #step_u2 {
              height: 15px; width: 15px; margin: 0 10px; border: 0.5px solid;
               border-radius: 50%;
                display: inline-block; opacity: 0.5;
                box-shadow: 0px 0px 10px 0px #0000003b;
                  }
                   #line, #lineu, #lineu1 {
                     box-shadow: 0px 0px 10px 0px #0000003b;
                      height: 2px; background-color: #bbbbbb;
                       margin: 0 5px; flex-grow: 0.5;
                       }
                        "
            ))
          ),
          div(
            id = "reg_form",
            p("All fields are required"),
            div(
              class = "align-items-center
               justify-content-center d-flex",
              span(id = "step_1"),
              span(id = "line"),
              span(id = "step_2")
            ),
            div(
              class = "d-flex pb-3 justify-content-center",
              div(
                class = "w-50 d-flex justify-content-between pt-2",
                p("Details", class = "fw-semibold"),
                p("Confirm", class = "fw-semibold"),
              )
            ),
            div(
              id = "tab_1",
              h6("Details:", class = "mt--3 mb-3"),
              fluidRow(
                column(
                  width = 3,
                  shiny::textInput(
                    inputId = "school_name",
                    label_mandatory("Name:"),
                    value = "",
                    placeholder = "Eg. Lenga Juu"
                  )
                ),
                column(
                  width = 3,
                  shiny::selectizeInput(
                    inputId = "school_level",
                    label = label_mandatory("Level:"),
                    choices = c(
                      "Preparatory", "Primary", "Junior Secondary",
                      "Senior Secondary", "University/College", "Other"
                    )
                  )
                ),
                column(
                  width = 3,
                  shiny::selectizeInput(
                    inputId = "school_type",
                    label = label_mandatory("Type:"),
                    choices = c("Public", "Private", "Other")
                  )
                ),
                column(
                  width = 3,
                  shiny::selectizeInput(
                    inputId = "county",
                    label = label_mandatory("County:"),
                    choices = kenyan_counties,
                    options = list(maxOptions = 5)
                  )
                )
              ),
              fluidRow(
                column(
                  width = 3,
                  shiny::textInput(
                    inputId = "school_email",
                    label_mandatory("Email:"),
                    value = "",
                    placeholder = "Eg. johnwekesa@gmail.com"
                  )
                ),
                column(
                  width = 3,
                  autonumericInput(
                    inputId = "doc_price",
                    label_mandatory("Price:"),
                    value = 1000,
                    currencySymbol = "Ksh ",
                    decimalPlaces = 0,
                    minimumValue = 500
                  )
                )
              )
            ),
            shinyjs::hidden(
              div(
                id = "tab_2",
                p("Confirm school details", class = "mt-3"),
                uiOutput("confirm_school_data")
              )
            ),
            div(
              style = "overflow: auto; margin-top: 20px;",
              div(
                id = "tab_buttons",
                class = "d-flex mt-3 justify-content-end",
                shinyjs::hidden(
                  shiny::actionButton(
                    inputId = "prevBtn",
                    label = "",
                    icon = icon("arrow-left"),
                    class = "px-5"
                  ) |>
                    basic_primary_btn()
                ),
                shinyjs::hidden(
                  shiny::actionButton(
                    inputId = "confirmBtn",
                    label = "",
                    icon = icon("check"),
                    class = "px-5"
                  ) |>
                    basic_primary_btn()
                ),
                shiny::actionButton(
                  inputId = "nextBtn",
                  label = "",
                  icon = icon("arrow-right"),
                  class = "px-5"
                ) |>
                  basic_primary_btn()
              )
            )
          )
        )
      )
    ),
    argonTab(
      tabName = "Manage",
      fluidRow(
        center = TRUE,
        bslib::card(
          argonTabSet(
            id = "users",
            circle = TRUE,
            width = 12,
            iconList = list(
              icon = icon("school"),
              icon = icon("chalkboard-user"),
              icon = icon("children"),
              icon = icon("clock"),
              icon = icon("file-pdf"),
              icon = icon("file-pdf")
            ),
            argonTab(
              tabName = "School",
              active = TRUE,
              p("Existing schools data", class = " fw-semibold mt-3"),
              bslib::card(
                id = "pdf_card",
                uiOutput("school_data")
              )
            ),
            argonTab(
              tabName = "Teacher",
              p("Existing teachers data", class = " fw-semibold mt-3"),
              bslib::card(
                id = "pdf_card",
                uiOutput("teachers_data")
              )
            ),
            argonTab(
              tabName = "Student",
              p("Existing students data", class = " fw-semibold mt-3"),
              bslib::card(
                id = "pdf_card",
                uiOutput("students_data")
              )
            ),
            argonTab(
              tabName = "Requests",
              p("Pending requests:", class = " fw-semibold mt-3"),
              bslib::card(
                id = "pdf_card",
                uiOutput("requests_data")
              )
            ),
            argonTab(
              tabName = "Content",
              p("Published content:", class = " fw-semibold mt-3"),
              bslib::card(
                id = "pdf_card",
                bslib::layout_sidebar(
                  sidebar = bslib::sidebar(
                    id = "card_sidebar",
                    position = "right",
                    open = FALSE,
                    uiOutput("sidebar_content")
                  ),
                  uiOutput("pdf_data")
                )
              )
            ),
            argonTab(
              tabName = "Payments",
              p("Payments records:", class = " fw-semibold mt-3"),
              bslib::card(
                id = "pdf_card",
                uiOutput("payments_data")
              )
            )
          )
        )
      )
    )
  )
)
