teacher_registration_tab <- div(
    id = "registration_form",
    class = "vh-100 container justify-content-center align-content-center",
    div(
        title_icon = NULL,
        class = "card",
        tags$div(
            class = "bg-light d-flex justify-content-center",
            tags$img(
                src = file.path("logo", "logo.png"),
                width = "100px"
            )
        ),
        h5("Welcome to Keytabu", class = "bg-light text-bold text-center
        pb-3"),
        div(
            id = "teacher_registration",
            class = "card-body",
            p("Teacher Details", class = "text-bold text-muted text-center"),
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
                    shinyWidgets::pickerInput(
                        inputId = "teacher_school",
                        label = label_mandatory("School:"),
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
                column(
                    width = 3,
                    shinyWidgets::pickerInput(
                        inputId = "teacher_grades",
                        label = label_mandatory("Grades:"),
                        multiple = TRUE,
                        options = pickerOptions(
                            style = "btn-outline-light",
                            title = "Eg. Grade 6",
                            size = 5,
                            maxOptions = 3,
                            maxOptionsText = "Max grades selected"
                        ),
                        choices = setNames(1:12, paste("Grade", 1:12)),
                        autocomplete = TRUE
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
            div(
                class = "mt-2 d-flex justify-content-center",
                shinyWidgets::awesomeCheckbox(
                    inputId = "t_privacy_link_tos",
                    status = "success",
                    label = tags$p(
                        class = "small text-center",
                        "By continuing, you are indicating that you accept our",
                        actionLink("t_privacy_policy_link", "Privacy Policy"),
                        "and",
                        actionLink("t_terms_service_link", "Terms of Service")
                    )
                )
            ),
            div(
                class = "d-flex justify-content-center",
                shiny::actionButton(
                    inputId = "submit_teacher_details",
                    label = "Submit",
                    width = "300px"
                ) |>
                    basic_primary_btn()
            )
        )
    )
)
