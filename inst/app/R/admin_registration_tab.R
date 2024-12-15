admin_registration_tab <- div(
  class = "container mt-5 mb-5 pt-5",
  p("Set payment period", class = "lead text-bold text-default_1"),
  fluidRow(
    column(
      width = 4,
      shinyWidgets::airDatepickerInput(
        inputId = "term_end_date",
        label = "Current Term End Date:",
        value = Sys.Date(),
        minDate = lubridate::today(),
        autoClose = TRUE
      )
    ),
    column(
      width = 4,
      shinyjs::disabled(
        textInput(
          inputId = "term_label",
          label = "Term label:",
          placeholder = "Enter term label"
        )
      )
    ),
    column(
      width = 4,
      class = "pt-4 pb-4",
      actionButton(
        inputId = "set_term_end",
        label = "Set",
        width = "175px",
        class = "mt-2"
      ) |>
        basic_primary_btn()
    )
  ),
  fluidRow(
    class = "pb-3",
    uiOutput("term_end_table")
  ),
  argonR::argonTabSet(
    id = "registration_tabset",
    horizontal = TRUE,
    size = "lg",
    width = 12,
    iconList = list(
      icon = argonR::argonIcon("cloud-upload-96", color = "body"),
      icon = argonR::argonIcon("caps-small", color = "body"),
      icon = argonR::argonIcon("settings", color = "body"),
      icon = argonR::argonIcon("envelope", color = "body"),
      icon = argonR::argonIcon("books", color = "body")
    ),
    argonR::argonTab(
      tabName = "Upload",
      active = TRUE,
      fluidRow(
        bslib::card(
          p("Upload content", class = "mt-3 text-bold"),
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
              shinyWidgets::pickerInput(
                inputId = "doc_request",
                label = label_mandatory("Request ID:"),
                options = list(
                  style = "btn-outline-light",
                  title = "Eg. REQ-001",
                  maxOptions = 3
                ),
                choices = NULL
              )
            ),
            column(
              width = 3,
              shinyjs::disabled(
                shiny::textInput(
                  inputId = "doc_teacher_id",
                  label = label_mandatory("Teacher:"),
                  placeholder = "Eg. John Kamau"
                )
              )
            ),
            column(
              width = 3,
              shinyjs::disabled(
                shiny::textInput(
                  inputId = "doc_grade",
                  label = label_mandatory("Grade:"),
                  placeholder = "Eg. Grade 6"
                )
              )
            ),
            column(
              width = 3,
              shinyjs::disabled(
                shiny::textInput(
                  inputId = "doc_learning_area",
                  label = label_mandatory("Learning Area:"),
                  placeholder = "Eg. Mathematics"
                )
              )
            )
          ),
          fluidRow(column(
            width = 3,
            shinyjs::disabled(
              shiny::textInput(
                inputId = "doc_topic",
                label = label_mandatory("Topic:"),
                placeholder = "Eg. Addition"
              )
            )
          ), column(
            width = 3,
            shinyjs::disabled(
              shiny::textInput(
                inputId = "doc_sub_topic",
                label_mandatory("Sub-topic:"),
                value = "",
                placeholder = "Eg. Long division method"
              )
            )
          )),
          div(
            class = "d-flex justify-content-center",
            actionButton(
              inputId = "upload_btn",
              label = "Publish PDF",
              class = "mt-2 mb-2 float-right",
              width = "300px"
            ) |>
              basic_primary_btn()
          )
        )
      )
    ),
    argonR::argonTab(
      tabName = "Registration",
      bslib::card(
        p("School Registration", class = "text-bold mt-3"),
        p("All fields are required"),
        tags$head(tags$style(
          HTML(
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
          )
        )),
        div(
          id = "reg_form",
          div(
            class = "d-flex justify-content-center",
            span(id = "step_1"),
            span(id = "line"),
            span(id = "step_2")
          ),
          div(
            class = "d-flex pb-3 justify-content-center",
            div(
              class = "w-50 d-flex justify-content-between pt-2",
              p("Details", class = "text-bold"),
              p("Confirm", class = "text-bold"),
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
                shinyWidgets::pickerInput(
                  inputId = "school_level",
                  label = label_mandatory("Level:"),
                  options = list(
                    style = "btn-outline-light",
                    title = "Eg. Primary"
                  ),
                  choices = c(
                    "Preparatory", "Primary", "Junior Secondary",
                    "Senior Secondary", "University/College", "Other"
                  )
                )
              ),
              column(
                width = 3,
                shinyWidgets::pickerInput(
                  inputId = "school_type",
                  label = label_mandatory("Type:"),
                  options = list(
                    style = "btn-outline-light",
                    title = "Eg. Public"
                  ),
                  choices = c("Public", "Private", "Other")
                )
              ),
              column(
                width = 3,
                shinyWidgets::pickerInput(
                  inputId = "county",
                  label = label_mandatory("County:"),
                  options = list(
                    title = "Eg. Nairobi",
                    style = "btn-outline-light",
                    size = 5,
                    `live-search` = TRUE,
                    `live-search-placeholder` = "Search county"
                  ),
                  choices = kenyan_counties,
                  autocomplete = TRUE
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
                shinyWidgets::autonumericInput(
                  inputId = "doc_price",
                  label_mandatory("Price:"),
                  value = 1500,
                  currencySymbol = "Ksh ",
                  decimalPlaces = 0,
                  minimumValue = 50
                )
              )
            )
          ),
          shinyjs::hidden(div(
            id = "tab_2",
            p("Confirm school details", class = "mb-3 text-bold"),
            uiOutput("confirm_schools_data")
          )),
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
    ),
    argonR::argonTab(
      tabName = "Manage",
      bslib::card(
        argonR::argonTabSet(
          id = "users",
          circle = TRUE,
          width = 12,
          iconList = list(
            icon = icon("school"),
            icon = icon("chalkboard-user"),
            icon = icon("children"),
            icon = icon("clock"),
            icon = icon("file-pdf"),
            icon = icon("sack-dollar")
          ),
          argonR::argonTab(
            tabName = "School",
            active = TRUE,
            p("Existing schools data", class = " text-bold mt-3"),
            uiOutput("schools_data")
          ),
          argonR::argonTab(
            tabName = "Teacher",
            p("Existing teachers data", class = " text-bold mt-3"),
            uiOutput("teachers_data")
          ),
          argonR::argonTab(
            tabName = "Student",
            p("Existing students data", class = " text-bold mt-3"),
            uiOutput("students_data")
          ),
          argonR::argonTab(
            tabName = "Requests",
            p("Pending requests:", class = " text-bold mt-3"),
            actionButton(
              inputId = "refresh_requests",
              label = "Refresh",
              icon = icon("refresh"),
              class = "mb-3"
            ) |>
              basic_primary_btn(),
            p(class = "text-body-tertiary mb-2", textOutput("requests_refresh_time")),
            uiOutput("requests_data")
          ),
          argonR::argonTab(
            tabName = "Content",
            p("Published content:", class = " text-bold mt-3"),
            bslib::layout_sidebar(
              sidebar = bslib::sidebar(
                id = "card_sidebar",
                position = "right",
                title = "PDF DETAILS",
                open = FALSE,
                uiOutput("sidebar_content")
              ),
              uiOutput("pdf_data")
            )
          ),
          argonR::argonTab(
            tabName = "Payments",
            p("Payments records:", class = " text-bold mt-3"),
            actionButton(
              inputId = "refresh_payments",
              label = "Refresh",
              icon = icon("refresh"),
              class = "mb-3"
            ) |>
              basic_primary_btn(),
            p(class = "text-body-tertiary mb-2", textOutput("payments_refresh_time")),
            uiOutput("payments_data")
          )
        )
      )
    ),
    argonR::argonTab(
      tabName = "Emails",
      bslib::card(
        fluidRow(
          column(
            width = 3,
            shinyWidgets::pickerInput(
              inputId = "receipient_group",
              label = label_mandatory("Group:"),
              options = list(
                style = "btn-outline-light",
                title = "Eg. Student",
                maxOptions = 3
              ),
              choices = c("Students", "Teachers", "Administrators", "Schools")
            )
          ),
          column(
            width = 5,
            shinyWidgets::pickerInput(
              inputId = "select_receipient",
              label = label_mandatory("Emails:"),
              multiple = TRUE,
              options = shinyWidgets::pickerOptions(
                style = "btn-outline-light",
                title = "Eg. johndoe@gmail.com",
                maxOptions = 3,
                actionsBox = TRUE,
                liveSearch = TRUE,
                header = "Search emails",
                noneResultsText = "No email matched",
                selectedTextFormat = "count",
                virtualScroll = 10
              ),
              choices = NULL
            )
          ),
          column(
            width = 4,
            shinyWidgets::pickerInput(
              inputId = "email_template",
              label = label_mandatory("Template:"),
              options = list(
                style = "btn-outline-light",
                title = "Eg. Payment reminders",
                maxOptions = 3
              ),
              choices = NULL
            )
          )
        ),
        fluidRow(
          class = "justify-content-end",
          column(
            width = 3,
            class = "pt-3",
            actionButton(
              inputId = "push_emails",
              label = "Push",
              width = "175px",
              class = "mt-2"
            ) |>
              basic_primary_btn()
          )
        ),
        div(
          class = "mt-5",
          uiOutput("emails_table")
        )
      )
    ),
    argonR::argonTab(
      tabName = "Timeline",
      class = "card card-body",
      p("Administrator actions:",
        class = "text-bold text-center mx-auto pt-2"
      ),
      actionButton(
        inputId = "refresh_timeline",
        label = "Refresh",
        icon = icon("refresh"),
        class = "mb-3"
      ) |>
        basic_primary_btn(),
      p(class = "text-body-tertiary mb-2", textOutput("timeline_refresh_time")),
      div(id = "end"),
      div(class = "loader", uiOutput("loader")),
      shinyjs::hidden(div(id = "empty", "No more records..."))
    )
  )
)
