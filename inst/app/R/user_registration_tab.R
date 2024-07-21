user_registration_tab <- div(
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
      }"
        ))
    ),
    div(
        id = "reg_form",
        p("All fields are required"),
        div(
            class = "align-items-center d-flex m-auto mt-2 w-75 header",
            span(id = "step_u1"),
            span(id = "lineu"),
            span(id = "step_u2"),
            span(id = "lineu1"),
            span(id = "step_u3")
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
            id = "tab_u1",
            class = "card-body",
            h3("Account type", class = "mt--3 mb-3"),
            div(
                id = "user_type_div",
                class = "d-flex justify-content-center",
                pickerInput(
                    inputId = "user_type",
                    label = "Please select:",
                    choices = c("Teacher", "Student")
                )
            )
        ),
        shinyjs::hidden(
            div(
                id = "tab_u2",
                class = "card-body",
                h3("Details", class = "mt--3 mb-3"),
                argonRow(
                    argonColumn(
                        width = 4,
                        shiny::textInput(
                            inputId = "user_name",
                            label = "Name:",
                            value = "",
                            placeholder = "Eg. Joseph Juma"
                        )
                    ),
                    argonColumn(
                        width = 4,
                        shinyWidgets::pickerInput(
                            inputId = "user_school",
                            label = "School:",
                            options = list(
                                title = "Eg. Lenga Juu",
                                style = "btn-outline-light",
                                size = 5,
                                `live-search` = TRUE,
                                `live-search-placeholder` = "Search school"
                            ),
                            choices = NULL
                        )
                    ),
                    conditionalPanel(
                        condition = "input.user_type == 'Teacher'",
                        shinyWidgets::pickerInput(
                            inputId = "user_grade",
                            label = "Grade:",
                            multiple = TRUE,
                            options = pickerOptions(
                                style = "btn-outline-light",
                                title = "Eg. Grade 6",
                                size = 5,
                                maxOptions = 5,
                                maxOptionsText = "Max Grades selected"
                            ),
                            choices = setNames(1:12, paste("Grade", 1:12)),
                            autocomplete = TRUE
                        )
                    ),
                    conditionalPanel(
                        condition = "input.user_type == 'Student'",
                        shinyWidgets::pickerInput(
                            inputId = "user_grade",
                            label = "Grade:",
                            options = pickerOptions(
                                style = "btn-outline-light",
                                title = "Eg. Grade 6",
                                size = 5
                            ),
                            choices = setNames(1:12, paste("Grade", 1:12)),
                            autocomplete = TRUE
                        )
                    )
                ),
                argonRow(
                    argonColumn(
                        width = 4,
                        autonumericInput(
                            inputId = "user_tel_number",
                            label = "Phone:",
                            value = 123456789,
                            currencySymbol = "254 ",
                            decimalPlaces = 0,
                            digitGroupSeparator = ""
                        )
                    )
                )
            )
        ),
        shinyjs::hidden(
            div(
                id = "tab_u3",
                class = "card-body",
                argonColumn(
                    width = 12,
                    h3("Confirm", class = "mt--3 mb-3"),
                    p("New user details", class = "mt-3"),
                    uiOutput("confirm_user_data")
                )
            )
        ),
        div(
            style = "overflow: auto; margin-top: 20px;",
            div(
                id = "tabu_buttons",
                class = "d-flex mt-3 justify-content-end",
                shinyjs::hidden(
                    shiny::actionButton(
                        inputId = "prevBtn_1",
                        label = "",
                        icon = icon("arrow-left"),
                        class = "px-5"
                    ) |>
                        basic_primary_btn()
                ),
                shinyjs::hidden(
                    shiny::actionButton(
                        inputId = "prevBtn_2",
                        label = "",
                        icon = icon("arrow-left"),
                        class = "px-5"
                    ) |>
                        basic_primary_btn()
                ),
                shinyjs::hidden(
                    shiny::actionButton(
                        inputId = "nextBtn_2",
                        label = "",
                        icon = icon("arrow-right"),
                        class = "px-5"
                    ) |>
                        basic_primary_btn()
                ),
                shinyjs::hidden(
                    shiny::actionButton(
                        inputId = "confirmBtn_1",
                        label = "",
                        icon = icon("check"),
                        class = "px-5"
                    ) |>
                        basic_primary_btn()
                ),
                shiny::actionButton(
                    inputId = "nextBtn_1",
                    label = "",
                    icon = icon("arrow-right"),
                    class = "px-5"
                ) |>
                    basic_primary_btn()
            )
        )
    )
)