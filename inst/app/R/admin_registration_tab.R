admin_registration_tab <- div(
  argonTabSet(
    id = "registration_tabset",
    horizontal = TRUE,
    size = "lg",
    width = 12,
    iconList = list(
      icon("university", class = "text-body"),
      icon("id-badge", class = "text-body"),
      icon = argonIcon("settings", color = "body")
    ),
    argonTab(
      tabName = "School",
      active = TRUE,
      argonRow(
        center = TRUE,
        argonCard(
          title = "School Registration Form",
          status = "default",
          border_level = 5,
          shadow = TRUE,
          icon = icon("address-card"),
          width = 12,
          tags$head(
            tags$style(HTML(
              " #step_1, #step_2, #step_3 {
              height: 15px; width: 15px; margin: 0 10px;
               background-color: #bbbbbb; border: 0.5px solid; border-radius: 50%;
                display: inline-block; opacity: 0.5; box-shadow: 0px 0px 10px 0px #0000003b;
                  }
                   #line {
                     box-shadow: 0px 0px 10px 0px #0000003b;
                      height: 2px; background-color: #bbbbbb; margin: 0 5px; flex-grow: 1;
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
              span(id = "step_2"),
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
              h3("Details", class = "mt--3 mb-3"),
              argonRow(
                argonColumn(
                  width = 3,
                  shiny::textInput("school_name", label_mandatory("Name:"), "", placeholder = "Eg. Lenga Juu")
                ),
                argonColumn(
                  width = 3,
                  shinyWidgets::pickerInput(
                    inputId = "school_level",
                    label = label_mandatory("Level:"),
                    options = list(
                      style = "btn-outline-light",
                      title = "Eg. Primary"
                    ),
                    choices = c("Preparatory", "Primary", "Junior Secondary", "Senior Secondary", "University/College", "Other")
                  )
                ),
                argonColumn(
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
                argonColumn(
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
              argonRow(
                argonColumn(
                  width = 6,
                  shiny::textInput("school_email", label_mandatory("Email:"), "", placeholder = "Eg. johnwekesa@gmail.com")
                )
              )
            ),
            shinyjs::hidden(
              div(
                id = "tab_2",
                argonColumn(
                  width = 12,
                  h3("Confirm", class = "mt--3 mb-3"),
                  p("New school details", class = "mt-3"),
                  uiOutput("confirm_school_data")
                )
              )
            ),
            div(
              style = "overflow: auto; margin-top: 20px;",
              div(
                id = "tab_buttons",
                class = "d-flex mt-3 justify-content-end",
                shinyjs::hidden(
                  shiny::actionButton("prevBtn", "", icon = icon("arrow-left"), class = "btn-primary px-5") |>
                    basic_primary_btn()
                ),
                shinyjs::hidden(
                  shiny::actionButton("confirmBtn", "", icon = icon("check"), class = "btn-primary px-5") |>
                    basic_primary_btn()
                ),
                shiny::actionButton("nextBtn", "", icon = icon("arrow-right"), class = "btn-primary px-5") |>
                    basic_primary_btn()
              )
            )
          )
        )
      )
    ),
    argonTab(
      tabName = "Teacher/Student",
      h2("Register new teacher/student"),
      argonRow(
        center = TRUE,
        argonCard(
          title = "Registration Form",
          status = "default",
          border_level = 5,
          shadow = TRUE,
          icon = icon("graduation-cap"),
          width = 12,
          div(
            id = "reg_form",
            p("All fields are required", class = "mt--2"),
            div(
              class = "align-items-center d-flex m-auto mt-2 w-75",
              span(id = "step_1"),
              span(id = "line"),
              span(id = "step_2"),
              span(id = "line"),
              span(id = "step_3")
            ),
            div(
              class = "m-auto pb-3 w-75",
              div(
                class = "d-flex justify-content-between pt-2",
                p("Type"),
                p("Details"),
                p("Confirm")
              )
            ),
            div(
              id = "tab_1",
              h3("Account type", class = "mt--3 mb-3"),
              div(
                id = "user_type_div",
                class = "d-flex justify-content-center",
                pickerInput(
                  inputId = "user_type",
                  label = label_mandatory("Please select:"),
                  choices = c("Teacher", "Student")
                )
              )
            ),
            shinyjs::hidden(
              div(
                id = "tab_2",
                h3("Details", class = "mt--3 mb-3"),
                argonRow(
                  argonColumn(
                    width = 3,
                    shiny::textInput("user_name", label_mandatory("Name:"), "", placeholder = "Eg. Joseph Juma")
                  ),
                  argonColumn(
                    width = 3,
                    shinyWidgets::pickerInput(
                      inputId = "user_school",
                      label = label_mandatory("School:"),
                      options = list(
                        title = "Eg. Lenga Juu",
                        style = "btn-outline-light",
                        size = 5,
                        `live-search` = TRUE,
                        `live-search-placeholder` = "Search school"
                      ), ,
                      choices = c("Preparatory", "Primary", "Junior Secondary", "Senior Secondary", "University/College", "Other")
                    )
                  ),
                  argonColumn(
                    width = 3,
                    shinyWidgets::pickerInput(
                      inputId = "user_grade",
                      label = label_mandatory("Grade:"),
                      options = list(
                        style = "btn-outline-light",
                        title = "Eg. Grade 6"
                      ),
                      choices = c("Public", "Private", "Other")
                    )
                  ),
                  argonColumn(
                    width = 3,
                    shiny::textInput("user_tel_number", label_mandatory("Phone:"), "", placeholder = "Eg. +254712345678")
                  )
                ),
                argonRow(
                  argonColumn(
                    width = 3,
                    shiny::textInput("user_email", label_mandatory("Email:"), placeholder = "Eg. johnwekesa@gmail.com")
                  )
                )
              )
            ),
            shinyjs::hidden(
              div(
                id = "tab_3",
                argonColumn(
                  width = 12,
                  h3("Confirm", class = "mt--3 mb-3"),
                  p("New user details", class = "mt-3"),
                  uiOutput("user_data")
                )
              )
            ),
            div(
              style = "overflow: auto; margin-top: 20px;",
              div(
                id = "tab_buttons",
                class = "d-flex mt-3 justify-content-end",
                shinyjs::hidden(
                  shiny::actionButton("prevBtn_1", "", icon = icon("arrow-left"), class = "btn-primary px-5") |>
                    basic_primary_btn()
                ),
                shinyjs::hidden(
                  shiny::actionButton("confirmBtn_1", "", icon = icon("check"), class = "btn-primary px-5") |>
                    basic_primary_btn()
                ),
                shiny::actionButton("nextBtn_1", "", icon = icon("arrow-right"), class = "btn-primary px-5") |>
                    basic_primary_btn()
              )
            )
          )
        )
      )
    ),
    argonTab(
      tabName = "Manage",
      h2("Enable/Disable users"),
      argonRow(
        center = TRUE,
        argonCard(
          title = "Shools Records",
          status = "default",
          border_level = 5,
          shadow = TRUE,
          icon = argonIcon("key-25"),
          width = 12,
          argonColumn(
            width = 12,
            p("Existing schools data", class = "mt-3"),
            uiOutput("school_data")
          )
        )
      )
    )
  )
)
