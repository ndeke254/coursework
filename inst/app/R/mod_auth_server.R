mod_auth_server <- \(id) {
  moduleServer(
    id = id,
    module = \(input, output, session) {
      ns <- session$ns

      enable_signin_btn <- \() {
        session$sendCustomMessage(
          type = "enable_auth_btn",
          list(id = ns("signin_submit"))
        )
      }

      enable_reset_btn <- \() {
        session$sendCustomMessage(
          type = "enable_auth_btn",
          list(id = ns("reset_password_btn"))
        )
      }


      # Handle send reset link
      observeEvent(input$reset_password, {
        shinyjs::show("reset_background_image")
        shinyjs::hide("login_background_image")

        updateTabsetPanel(
          inputId = "auth_pages",
          session = session,
          selected = "reset_page"
        )
      })

      observeEvent(input$reset_password_btn, {
        shinyjs::show("authr_loader")
        shinyjs::disable("reset_password_btn")

        email <- input$reset_email

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

            alert_success_ui(
              session = session,
              position = "bottom",
              info = "Password reset link sent!"
            )
          },
          error = \(e) {
            print(e)
            alert_fail_ui(
              session = session,
              position = "bottom",
              info = conditionMessage(e)
            )
          }
        )
        shinyjs::hide("authr_loader")
        shinyjs::enable("reset_password_btn")
      })

      observeEvent(input$back_to_login, {
        shinyjs::hide("reset_background_image")
        shinyjs::show("login_background_image")

        updateTabsetPanel(
          inputId = "auth_pages",
          session = session,
          selected = "login_page"
        )
      })
      # Signin process
      rv_signed_in <- reactiveVal()
      signed_user_email <- reactiveValues(
        email = NULL
      )

      observeEvent(input$signin_submit, {
        shinyjs::show("auth_loader")
        shinyjs::disable("signin_submit")

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
            alert_fail_ui(
              session = session,
              position = "bottom",
              info = conditionMessage(e)
            )
          }
        )

        shinyjs::hide("auth_loader")
        shinyjs::enable("signin_submit")
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
              email_verification_alert(
                user_email,
                session = session
              )
              return()
            }

            # sign user in
            signed_user_email$email <- user_email

            alert_success_ui(
              session = session,
              info = "Welcome to Candidate"
            )
          },
          error = \(e) {
            switch_auth_form_tab("signin")
            print(e)
            alert_fail_ui(
              session = session,
              position = "bottom",
              info = "An error occurred while signing you in"
            )
          }
        )
      })

      # Return user details
      signed_user_email
    }
  )
}
