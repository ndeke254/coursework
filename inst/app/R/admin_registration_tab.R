admin_registration_tab <- div(
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
      argonRow(
        center = TRUE,
        argonR::argonCard(
          title = h6("Upload PDF"),
          shadow = TRUE,
          border_level = 5,
          icon = icon("upload", class = "default"),
          status = "default",
          width = 12,
          argonTabSet(
            id = "upload_tabset",
            circle = TRUE,
            horizontal = TRUE,
            width = 12,
            iconList = list(
              argonIcon("books", color = "body"),
              argonIcon("ungroup", color = "body")
            ),
            argonTab(
              tabName = "Content",
              active = TRUE,
              p("All fields are required", class = "mt-5"),
              div(
                class = "d-flex justify-content-center",
                fileInput(
                  inputId = "pdfFile",
                  label = "Select a PDF",
                  width = 500,
                  accept = c(".pdf")
                )
              ),
              argonRow(
                argonColumn(
                  width = 4,
               shiny::selectizeInput(
                 inputId = "doc_school",
                 label = label_mandatory("School:"),
                 options = list(maxOptions = 3),
                 choices = NULL
               )
                ),
                argonColumn(
                  width = 4,
                  shiny::selectizeInput(
                    inputId = "doc_teacher",
                    label = label_mandatory("Teacher:"),
                    choices = NULL,
                    options = list(maxOptions = 5)
                  )
                ),
                argonColumn(
                  width = 4,
                  shiny::selectizeInput(
                    inputId = "doc_grade",
                    label = label_mandatory("Grade:"),
                    choices = NULL,
                    options = list(maxOptions = 5)
                  )
                )
              ),
              argonRow(
                argonColumn(
                  width = 4,
                  shiny::selectizeInput(
                    inputId = "doc_learning_area",
                    label = label_mandatory("Learning Area:"),
                    choices = NULL,
                    options = list(maxOptions = 5)
                  )
                ),
                argonColumn(
                  width = 4,
                  shiny::textInput(
                    inputId = "doc_topic",
                    label = label_mandatory("Topic:"),
                    placeholder = "Eg. Addition"
                  )
                ),
                argonColumn(
                  width = 4,
                  shiny::textInput(
                    inputId = "doc_sub_topic",
                    label_mandatory("Sub-topic:"),
                    value = "",
                    placeholder = "Eg. Long division method"
                  )
                )
              ),
              actionButton(
                inputId = "upload_btn",
                label = "Publish PDF",
                class = "mt-2 mb-2 float-right"
              ) |>
                basic_primary_btn()
            ),
            argonTab(
              tabName = "General",
              p("All fields are required", class = "mt-5")
            )
          )
        )
      )
    ),
    argonTab(
      tabName = "Registration",
      argonRow(
        center = TRUE,
        argonCard(
          title = h6("School Registration"),
          status = "default",
          border_level = 5,
          shadow = TRUE,
          icon = icon("address-card"),
          width = 12,
          tags$head(
            tags$style(HTML(
              " #step_1, #step_2, #step_u3, #step_u1, #step_u2 {
              height: 15px; width: 15px; margin: 0 10px;
               background-color: #bbbbbb; border: 0.5px solid;
               border-radius: 50%;
                display: inline-block; opacity: 0.5;
                box-shadow: 0px 0px 10px 0px #0000003b;
                  }
                   #line, #lineu, #lineu1 {
                     box-shadow: 0px 0px 10px 0px #0000003b;
                      height: 2px; background-color: #bbbbbb;
                       margin: 0 5px; flex-grow: 1;
                       }
                        "
            ))
          ),
          div(
            id = "reg_form",
            p("All fields are required", class = "mt--2"),
            div(
              class = "align-items-center d-flex m-auto mt-2 w-75",
              span(id = "step_1"),
              span(id = "line"),
              span(id = "step_2")
            ),
            div(
              class = "m-auto pb-3 w-75",
              div(
                class = "d-flex justify-content-between pt-2",
                p("Details"),
                p("Confirm")
              )
            ),
            div(
              id = "tab_1",
              h6("Details:", class = "mt--3 mb-3"),
              argonRow(
                argonColumn(
                  width = 4,
                  shiny::textInput(
                    inputId = "school_name",
                    label_mandatory("Name:"),
                    value = "",
                    placeholder = "Eg. Lenga Juu"
                  )
                ),
                argonColumn(
                  width = 4,
                  shiny::selectizeInput(
                    inputId = "school_level",
                    label = label_mandatory("Level:"),
                    choices = c(
                      "Preparatory", "Primary", "Junior Secondary",
                      "Senior Secondary", "University/College", "Other"
                    )
                  )
                ),
                argonColumn(
                  width = 4,
                  shiny::selectizeInput(
                    inputId = "school_type",
                    label = label_mandatory("Type:"),
                    choices = c("Public", "Private", "Other")
                  )
                )
              ),
              argonRow(
                argonColumn(
                  width = 4,
                  shiny::selectizeInput(
                    inputId = "county",
                    label = label_mandatory("County:"),
                    choices = kenyan_counties,
                    options = list(maxOptions = 5)
                  )
                ),
                argonColumn(
                  width = 4,
                  shiny::textInput(
                    inputId = "school_email",
                    label_mandatory("Email:"),
                    value = "",
                    placeholder = "Eg. johnwekesa@gmail.com"
                  )
                ),
                argonColumn(
                  width = 4,
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
            div(
              id = "tab_2",
              argonColumn(
                width = 12,
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
      argonRow(
        center = TRUE,
        argonCard(
          title = h6("Records"),
          status = "default",
          border_level = 5,
          shadow = TRUE,
          icon = argonIcon("key-25"),
          width = 12,
          argonTabSet(
            id = "users",
            circle = TRUE,
            width = 12,
            iconList = list(
              icon = icon("school"),
              icon = icon("chalkboard-user"),
              icon = icon("children"),
              argonIcon("collection", color = "body")
            ),
            argonTab(
              tabName = "School",
              active = TRUE,
              p("Existing schools data", class = "mt-5"),
              uiOutput("school_data")
            ),
            argonTab(
              tabName = "Teacher",
              p("Existing teachers data", class = "mt-5"),
              uiOutput("teachers_data")
            ),
            argonTab(
              tabName = "Student",
              p("Existing students data", class = "mt-5"),
              uiOutput("students_data")
            ),
            argonTab(
              tabName = "Content",
              p("Existing PDFs", class = "mt-5"),
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
            )
          )
        )
      )
    )
  )
)
