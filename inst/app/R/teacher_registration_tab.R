teacher_registration_tab <- div(
  id = "registration_form",
  class = "p-2 d-flex mt-5 pt-5 justify-content-center align-items-center",

  # Form card container
  div(
    class = "card",
    style = "max-width: 900px; margin: auto; border-radius: 5px;",
    tags$div(
      id = "t_auth_loader",
      class = "auth_form_loader shinyjs-hide bg-default"
    ),

    # Header image and title
    div(
      class = "bg-light rounded text-center pb-3 pt-2",
      tags$img(
        src = file.path("logo", "logo_icon_blue.png"),
        width = "70px"
      ),
      h5("Welcome to Candidate", class = "text-body-1 text-bold mt-3")
    ),

    # Form body
    div(
      class = "card-body",
      p("Teacher Registration", class = "text-bold text-muted text-center mb-4"),

      # First row of inputs
      fluidRow(
        column(
          width = 6,
          shiny::textInput(
            inputId = "teacher_username",
            label = label_mandatory("Full Name"),
            placeholder = "E.g., Joseph Juma",
            width = "100%"
          )
        ),
        column(
          width = 6,
          shinyWidgets::pickerInput(
            inputId = "teacher_school",
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
            inputId = "teacher_grades",
            label = label_mandatory("Grades"),
            multiple = TRUE,
            options = shinyWidgets::pickerOptions(
              title = "Select grades",
              maxOptions = 3,
              size = 5,
              maxOptionsText = "Max 3 grades"
            ),
            choices = setNames(5:9, paste("Grade", 5:9)),
            width = "100%"
          )
        ),
        column(
          width = 6,
          shinyWidgets::autonumericInput(
            inputId = "teacher_tel_number",
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
          width = 12,
          shiny::textInput(
            inputId = "teacher_email",
            label = label_mandatory("Email Address"),
            placeholder = "E.g., johndoe@example.com",
            width = "100%"
          )
        )
      ),

      # Password and Confirm Password on the same row
      fluidRow(
        column(
          width = 6,
          shiny::passwordInput(
            inputId = "teacher_password",
            label = label_mandatory("Password"),
            placeholder = "Enter your password",
            width = "100%"
          )
        ),
        column(
          width = 6,
          shiny::passwordInput(
            inputId = "teacher_confirm_password",
            label = label_mandatory("Confirm Password"),
            placeholder = "Re-enter your password",
            width = "100%"
          )
        )
      ),

      # Show Password toggle
      div(
        class = "mb-3",
        tags$div(
          class = "form-check",
          tags$input(
            type = "checkbox",
            class = "form-check-input",
            id = "t_show_password",
            onclick = sprintf(
              "togglePassword('%s', '%s')",
              "teacher_password", "teacher_confirm_password"
            )
          ),
          tags$label(
            class = "form-check-label text-muted small",
            `for` = "t_show_password",
            "Show Password"
          )
        )
      ),

      # Privacy Policy and Terms
      div(
        class = "mt-2",
        shiny::checkboxInput(
          inputId = "t_privacy_link_tos",
          label = tags$labe(
            class = "small text-muted text-center",
            "By continuing, you agree to our",
            actionLink("t_privacy_policy_link", "Privacy Policy"),
            "and",
            actionLink("t_terms_service_link", "Terms of Service")
          )
        )
      ),

      # Submit button
      div(
        class = "d-flex justify-content-center",
        shiny::actionButton(
          inputId = "submit_teacher_details",
          label = "Submit",
          width = "300px"
        ) |>
          basic_primary_btn()
      ),

      # Already a member?
      tags$div(
        class = "text-center",
        tags$p(
          class = "mt-4 small text-bold",
          "Have an account?",
          actionLink(
            inputId = "already_member",
            label = "Login"
          )
        )
      ),
      tags$div(
        class = "text-center",
        tags$p(
          class = "mt-4 small text-bold",
          "Terms of partnership?",
          actionLink(
            inputId = "top",
            label = "Click here"
          )
        )
      )
    )
  )
)
