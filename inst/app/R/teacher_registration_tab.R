teacher_registration_tab <- div(
    id = "registration_form",
    class = "pb-2 pt-3",
    create_card(
        title = "Welcome to Keytabu",
        title_icon = NULL,
        class = "container shadow text",
        tags$div(
            class = "d-flex justify-content-center",
            tags$img(
                src = file.path("logo", "logo.png"),
                width = "100px"
            )
        ),
        div(
            id = "teacher_registration",
            p("Teacher Details"),
            fluidRow(
                column(
                    width = 3,
                    shiny::textInput(
                        inputId = "teacher_username",
                        label = label_mandatory("Name:"),
                        value = "",
                        placeholder = "Eg. Joseph Juma"
                    )
                ),
                column(
                    width = 3,
                    shiny::selectizeInput(
                        inputId = "teacher_school",
                        label = label_mandatory("School:"),
                        options = list(maxOptions = 3),
                        choices = NULL
                    )
                ),
                column(
                    width = 3,
                    shiny::selectizeInput(
                        inputId = "teacher_grades",
                        label = label_mandatory("Grades:"),
                        choices = setNames(1:12, paste("Grade", 1:12)),
                        multiple = TRUE,
                        options = list(maxItems = 3, maxOptions = 3)
                    )
                ),
                column(
                    width = 3,
                    autonumericInput(
                        inputId = "teacher_tel_number",
                        label = label_mandatory("Phone:"),
                        value = 123456789,
                        currencySymbol = "254 ",
                        decimalPlaces = 0,
                        digitGroupSeparator = ""
                    )
                )
            ),
            fluidRow(
                column(
                    width = 3,
                    shiny::textInput(
                        inputId = "teacher_email",
                        label = label_mandatory("Email address"),
                        placeholder = "johndoe@example.com"
                    )
                ),
                column(
                    width = 3,
                    shiny::passwordInput(
                        inputId = "teacher_password",
                        label = label_mandatory("Password"),
                        placeholder = "Password"
                    )
                ),
                column(
                    width = 3,
                    shiny::passwordInput(
                        inputId = "teacher_confirm_password",
                        label = label_mandatory("Confirm password"),
                        placeholder = "Password"
                    )
                )
            ),
            privacy_tos_links,
            fluidRow(
                class = "mt-5",
                div(
                    class = "d-flex justify-content-center",
                    shiny::actionButton(
                        inputId = "submit_teacher_details",
                        label = "Submit",
                        class = "px-5",
                        width = "250px"
                    ) |>
                        basic_primary_btn()
                )
            )
        )
    )
)
