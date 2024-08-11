mod_auth_server <- \(id) {
    moduleServer(
        id = id,
        module = \(input, output, session) {
            ns <- session$ns

            # Handle send reset link
            observeEvent(input$reset_password, {
                email <- input$signin_email

                # check if user exists

                tryCatch(
                    expr = {
                        if (!isTruthy(email)) {
                            stop(
                                "Fill the email password to reset.",
                                call. = FALSE
                            )
                        }

                        reset <- frbs::frbs_send_password_reset_email(email)

                        if (!is.null(reset$error)) {
                            stop("Invalid email!", call. = FALSE)
                        }

                        toast_success(
                            message = "Password reset link sent!"
                        )
                    },
                    error = \(e) {
                        print(e)
                        toast_error(message = conditionMessage(e), timeOut = 0)
                    }
                )
            })

            # Signin process
            rv_signed_in <- reactiveVal()
            signed_user_email <- reactiveValues(
                email = NULL
            )

            observeEvent(input$signin_submit, {
                email <- input$signin_email
                password <- input$signin_password

                tryCatch(
                    expr = {
                        if (!isTruthy(email)) {
                            msg <- "Email must be provided."
                            stop(msg, call. = FALSE)
                        }

                        if (!isTruthy(password)) {
                            msg <- "Password cannot be empty."
                            stop(msg, call. = FALSE)
                        }

                        user <- frbs::frbs_sign_in(email, password)
                        if (!is.null(user$error)) {
                            stop("Invalid login credentials!", call. = FALSE)
                        }
                        user_details <- frbs::frbs_get_user_data(user$idToken)

                        # add `idToken` to 'user_details':
                        user_details$idToken <- user$idToken

                        rv_signed_in(user_details)
                    },
                    error = \(e) {
                        print(e)
                        toast_error(message = conditionMessage(e), timeOut = 0)
                    }
                )
            })
            switch_auth_form_tab <- \(selected) {
                freezeReactiveValue(x = input, name = "auth_form")
                updateTabsetPanel(
                    session = session,
                    inputId = "auth_form",
                    selected = selected
                )
            }

            # Check if signin was successful
            observeEvent(rv_signed_in(), {
                switch_auth_form_tab("waiting_signin")
                tryCatch(
                    expr = {
                        user_details <- rv_signed_in() |> lapply(`[[`, 1)
                        
                        user_email <- user_details$users$email

                        # send verification link
                        if (isFALSE(user_details$users$emailVerified)) {
                            frbs::frbs_send_email_verification(
                                id_token = user_details$idToken
                            )
                            modal <- email_verification_modal(user_email)
                            showModal(modal)
                            return()
                        }

                        # sign user in
                        signed_user_email$email <- user_email

                        toast_success(message = "Signed In!")
                    },
                    error = \(e) {
                        switch_auth_form_tab("signin")
                        print(e)
                        toast_error(
                            title = "Error",
                            message = "An error occurred while signing you in"
                        )
                    }
                )
            })

            # Return user details
            signed_user_email
        }
    )
}

