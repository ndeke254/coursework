student_registration_tab <- div(
    id = "registration_form",
    class = "p-2 d-flex mt-5 pt-5
    justify-content-center align-items-center",


    # Masked image on 1/3 of the screen with damped opacity
    div(
        style = "
            position: absolute;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            background-image: url('logo/background_image.png');
            background-size: cover;
            background-repeat: no-repeat;
            background-position: center;
            opacity: 0.4;  /* Damped opacity */
            mask-image: linear-gradient(to bottom, black 70%, transparent 100%);
        "
    ),

    # Form card container

    div(
        class = "card",
        style = "max-width: 900px; margin: auto; border-radius: 5px;",
        tags$div(
            id = "s_auth_loader",
            class = "auth_form_loader shinyjs-hide bg-default"
        ),
        # Header image and title
        div(
            class = "rounded bg-light text-center pb-3",
            tags$img(
                src = file.path("logo", "logo.png"),
                width = "80px",
                class = "rounded-circle"
            ),
            h4("Welcome to Candidate", class = "text-body_1 text-bold mt-3")
        ),

        # Form body
        div(
            class = "card-body",
            p("Student Registration",
                class = "text-bold text-muted text-center mb-4"
            ),

            # First row of inputs
            fluidRow(
                column(
                    width = 6,
                    shiny::textInput(
                        inputId = "student_username",
                        label = label_mandatory("Full Name"),
                        placeholder = "E.g., Joseph Juma",
                        width = "100%"
                    )
                ),
                column(
                    width = 6,
                    shinyWidgets::pickerInput(
                        inputId = "student_school",
                        label = label_mandatory("School"),
                        options = list(
                            title = "Select your school",
                            size = 5,
                            `live-search` = TRUE,
                            `live-search-placeholder` = "Search school"
                        ),
                        choices = NULL,
                        width = "100%"
                    )
                )
            ),

            # Second row of inputs
            fluidRow(
                column(
                    width = 6,
                    shinyWidgets::pickerInput(
                        inputId = "student_grade",
                        label = label_mandatory("Grade"),
                        options = pickerOptions(
                            title = "Select grade",
                            size = 5
                        ),
                        choices = setNames(5:9, paste("Grade", 5:9)),
                        width = "100%"
                    )
                ),
                column(
                    width = 6,
                    autonumericInput(
                        inputId = "student_tel_number",
                        label = label_mandatory("Phone Number"),
                        value = NULL,
                        currencySymbol = "254 ",
                        decimalPlaces = 0,
                        digitGroupSeparator = "",
                        placeholder = "E.g., 701234567",
                        width = "100%"
                    )
                )
            ),

            # Third row of inputs
            fluidRow(
                column(
                    width = 6,
                    shiny::textInput(
                        inputId = "student_email",
                        label = label_mandatory("Email Address"),
                        placeholder = "E.g., johndoe@example.com",
                        width = "100%"
                    )
                ),
                column(
                    width = 6,
                    shiny::passwordInput(
                        inputId = "student_password",
                        label = label_mandatory("Password"),
                        placeholder = "Enter your password",
                        width = "100%"
                    )
                )
            ),

            # Password confirmation and visibility toggle
            fluidRow(
                column(
                    width = 6,
                    shiny::passwordInput(
                        inputId = "student_confirm_password",
                        label = label_mandatory("Confirm Password"),
                        placeholder = "Re-enter your password",
                        width = "100%"
                    )
                ),
                column(
                    width = 6,
                    div(
                        class = "form-check mb-3",
                        tags$input(
                            type = "checkbox",
                            class = "form-check-input",
                            id = "show_password",
                            onclick = sprintf(
                                "togglePassword('%s')",
                                "student_password"
                            )
                        ),
                        tags$label(
                            class = "form-check-label text-muted small",
                            `for` = "show_password",
                            "Show Password"
                        )
                    )
                )
            ),

            # Privacy policy agreement
            div(
                class = "mt-2 d-flex justify-content-center",
                shinyWidgets::awesomeCheckbox(
                    inputId = "s_privacy_link_tos",
                    status = "success",
                    label = tags$p(
                        class = "small text-muted text-center",
                        "By continuing, you agree to our",
                        actionLink("s_privacy_policy_link", "Privacy Policy"),
                        "and",
                        actionLink("s_terms_service_link", "Terms of Service")
                    )
                )
            ),

            # Submit button
            div(
                class = "d-flex justify-content-center",
                shiny::actionButton(
                    inputId = "submit_student_details",
                    label = "Submit",
                    width = "300px"
                ) |> basic_primary_btn()
            ),
            tags$div(
                class = "text-center",
                tags$p(
                    class = "mt-4 small text-bold",
                    "Have an account?",
                    actionLink(
                        inputId = "have_an_account",
                        label = "Login"
                    )
                )
            )
        )
    )
)
