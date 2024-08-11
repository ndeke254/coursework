student_registration_tab <- div(
    id = "registration_form",
    create_card(
        title = "Welcome to Keytabu",
        title_icon = NULL,
        class = "shadow text",
        tags$div(
            class = "d-flex justify-content-center",
            tags$img(
                src = file.path("logo", "logo.png"),
                width = "150px"
            )
        ),
        div(
            id = "student_registration",
            p("Student Details"),
            uiOutput("error_styles"), # Include the error CSS

            argonRow(
                argonColumn(
                    width = 4,
                    shiny::textInput(
                        inputId = "student_username",
                        label = label_mandatory("Name:"),
                        value = "",
                        placeholder = "Eg. Joseph Juma"
                    )
                ),
                argonColumn(
                    width = 4,
                    shiny::selectizeInput(
                        inputId = "student_school",
                        label = label_mandatory("School:"),
                        options = list(maxOptions = 3),
                        choices = NULL
                    )
                ),
                argonColumn(
                    width = 4,
                    shiny::selectizeInput(
                        inputId = "student_grade",
                        label = label_mandatory("Grade:"),
                        choices = setNames(1:12, paste("Grade", 1:12)),
                        options = list(maxOptions = 3)
                    )
                )
            ),
            argonRow(
                argonColumn(
                    width = 4,
                    autonumericInput(
                        inputId = ("student_tel_number"),
                        label = label_mandatory("Phone:"),
                        value = 123456789,
                        currencySymbol = "254 ",
                        decimalPlaces = 0,
                        digitGroupSeparator = ""
                    )
                ),
                argonColumn(
                    width = 4,
                    shiny::textInput(
                        inputId = "student_email",
                        label = label_mandatory("Email address"),
                        placeholder = "johndoe@example.com",
                        width = "400px"
                    )
                ),
                argonColumn(
                    width = 4,
                    shiny::passwordInput(
                        inputId = "student_password",
                        label = label_mandatory("Password"),
                        placeholder = "Password",
                        width = "400px"
                    )
                )
            ),
            argonRow(
                argonColumn(
                    width = 4,
                    shiny::passwordInput(
                        inputId = "student_confirm_password",
                        label = label_mandatory("Password"),
                        placeholder = "Password",
                        width = "400px"
                    )
                )
            ),
            privacy_tos_links,
            argonRow(
                class = "mt-5",
                center = TRUE,
                shiny::actionButton(
                    inputId = "submit_student_details",
                    label = "Submit",
                    icon = icon("arrow-right"),
                    class = "px-5"
                ) |>
                    basic_primary_btn()
            )
        )
    )
)
