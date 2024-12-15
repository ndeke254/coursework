server <- function(input, output, session) {
  shinyjs::hide("company_copyright")

  # make sqlite connection:
  conn <- DBI::dbConnect(
    drv = RSQLite::SQLite(),
    Sys.getenv("DATABASE_NAME")
  )

  # initialize fields validation
  iv <- shinyvalidate::InputValidator$new()
  ivs <- shinyvalidate::InputValidator$new()
  ivt <- shinyvalidate::InputValidator$new()
  ivp <- shinyvalidate::InputValidator$new()
  ivr <- shinyvalidate::InputValidator$new()
  ivf <- shinyvalidate::InputValidator$new()

  # Initialize reactive values
  rv <- reactiveValues(
    image_paths = NULL,
    current_page = 1,
    total_pages = 0,
    selected_pdf = NULL,
    pdf_paths = list(),
    pdf_time = 0
  )

  # Create reactive values for tables
  rvs <- reactiveValues(
    message = NULL,
    schools_data = DBI::dbReadTable(conn, "schools"),
    pdf_data = DBI::dbReadTable(conn, "content"),
    teachers_data = DBI::dbReadTable(conn, "teachers"),
    students_data = DBI::dbReadTable(conn, "students"),
    payments_data = DBI::dbReadTable(conn, "payments"),
    requests_data = DBI::dbReadTable(conn, "requests"),
    administrators_data = DBI::dbReadTable(conn, "administrator"),
    views_data = DBI::dbReadTable(conn, "views"),
    emails_data = DBI::dbReadTable(conn, "emails"),
    idx = NULL,
    status = NULL
  )


  uploaded_request_files <- reactiveVal(list())

  on.exit(DBI::dbDisconnect(conn), add = TRUE)


  user_details <- mod_auth_server("auth")

  observeEvent(
    list(input$register_now, input$register_now_1),
    {
      updateTabsetPanel(
        inputId = "app_pages",
        selected = "reg_student_page"
      )
      shinyjs::hide("company_copyright")
    },
    ignoreInit = TRUE
  )

  observeEvent(input$lets_partner, {
    updateTabsetPanel(
      inputId = "app_pages",
      selected = "reg_teacher_page"
    )
    shinyjs::hide("company_copyright")
  })

  observeEvent(input$lets_partner, {
    session$sendCustomMessage("resetScroll", list())
    updateTabsetPanel(
      inputId = "app_pages",
      selected = "teachers_info"
    )
    shinyjs::show("company_copyright")
  })

  observeEvent(input$register_teacher, {
    updateTabsetPanel(
      inputId = "app_pages",
      selected = "reg_teacher_page"
    )
    shinyjs::hide("company_copyright")
  })

  observeEvent(input$home_link, {
    updateTabsetPanel(
      inputId = "app_pages",
      selected = "company_website"
    )
    shinyjs::hide("company_copyright")
    shinyjs::runjs("$('#home_section')[0].scrollIntoView({ behavior: 'smooth' });")
  })

  observeEvent(input$about_us_link, {
    updateTabsetPanel(
      inputId = "app_pages",
      selected = "company_website"
    )
    shinyjs::hide("company_copyright")

    shinyjs::runjs("$('#about_us_section')[0].scrollIntoView({ behavior: 'smooth' });")
  })

  observeEvent(input$contact_us_link, {
    updateTabsetPanel(
      inputId = "app_pages",
      selected = "company_website"
    )
    shinyjs::hide("company_copyright")

    shinyjs::runjs("$('#contact_us_section')[0].scrollIntoView({ behavior: 'smooth' });")
  })

  observeEvent(input$students_link, {
    updateTabsetPanel(
      session = session,
      inputId = "app_pages",
      selected = "reg_student_page"
    )
    shinyjs::hide("company_copyright")
  })

  observeEvent(
    list(input$top, input$teachers_link),
    {
      updateTabsetPanel(
        session = session,
        inputId = "app_pages",
        selected = "teachers_info"
      )
      shinyjs::show("company_copyright")
      session$sendCustomMessage("resetScroll", list())
    },
    ignoreInit = TRUE
  )

  observeEvent(input$login_link, {
    updateTabsetPanel(
      session = session,
      inputId = "app_pages",
      selected = "auth_page"
    )
    shinyjs::hide("company_copyright")
  })

  # Register a new teacher
  # add validation rules
  ivt <- shinyvalidate::InputValidator$new()
  ivt$add_rule("teacher_username", shinyvalidate::sv_required())
  ivt$add_rule("teacher_school", shinyvalidate::sv_required())
  ivt$add_rule("teacher_password", shinyvalidate::sv_required())
  ivt$add_rule("teacher_confirm_password", shinyvalidate::sv_required())
  ivt$add_rule("teacher_grades", shinyvalidate::sv_required())
  ivt$add_rule("teacher_tel_number", shinyvalidate::sv_required())
  ivt$add_rule("teacher_email", shinyvalidate::sv_email())
  # Add a validation rule for the phone number input
  ivt$add_rule("teacher_tel_number", function(value) {
    phone_number <- gsub("\\D", "", value) # Remove non-digit characters
    if (nchar(phone_number) != 9) {
      return("Phone number must be 9 digits")
    }
    return(NULL) # Return NULL if validation passes
  })
  # Add a validation rule for the user name input
  ivt$add_rule("teacher_username", function(value) {
    names <- strsplit(value, " ")[[1]]
    if (length(names) != 2) {
      return("Must be 2 names")
    }
    return(NULL) # Return NULL if validation passes
  })

  # Check if the password is at least 8 characters long
  ivt$add_rule("teacher_password", function(value) {
    # Check if the password is at least 8 characters long
    if (nchar(value) < 8) {
      return("Must be at least 8 characters long")
    }

    # Check if the password contains at least one letter
    if (!grepl("[a-zA-Z]", value)) {
      return("Password must contain at least one letter")
    }

    # Check if the password contains at least one number
    if (!grepl("[0-9]", value)) {
      return("Password must contain at least one number")
    }

    # Check if the password contains at least one special character
    if (!grepl("[^a-zA-Z0-9]", value)) {
      return("Password must contain at least one special character")
    }

    return(NULL) # Return NULL if validation passes
  })

  ivt$add_rule("t_privacy_link_tos", function(value) {
    if (value != TRUE) {
      return("Required")
    }
  })

  observeEvent(input$submit_teacher_details, {
    ivt$enable() # enable validation check
    req(ivt$is_valid()) # ensure checks are valid

    password <- input$teacher_password
    password_confirm <- input$teacher_confirm_password

    is_match <- check_confirm_password(
      password = password,
      confirm_password = password_confirm
    )

    if (!is_match) {
      return(
        alert_fail_ui(
          session = session,
          info = "Password do not match",
          position = "bottom"
        )
      )
    }

    tryCatch(
      expr = {
        # Get the list of app users
        app_users <- polished::get_users()[1]$content$email
        # Check if the input email exists in the email column
        email_exists <- input$teacher_email %in% app_users

        if (email_exists) {
          msg <- "User email already exists!"
          stop(msg, call. = FALSE)
        }

        grades <- paste(input$teacher_grades, collapse = ", ")

        table_html <- reactable::reactable(
          data = data.frame(
            Input = c(
              "Name", "School", "Grades",
              "Contact", "Email"
            ),
            Value = stringr::str_trunc(
              c(
                stringr::str_to_title(input$teacher_username),
                input$teacher_school,
                grades,
                input$teacher_tel_number,
                input$teacher_email
              ),
              width = 25
            )
          ),
          columns = list(
            Input = reactable::colDef(name = "Input"),
            Value = reactable::colDef(name = "Value")
          ),
          borderless = TRUE,
          bordered = FALSE,
          striped = FALSE,
          outlined = TRUE,
          wrap = FALSE,
          resizable = FALSE,
          class = "text-gray-dark"
        )

        # Show confirmation dialog with reactable table
        shinyWidgets::ask_confirmation(
          session = session,
          inputId = "confirm_teacher_details",
          title = NULL,
          text = tags$div(
            table_html
          ),
          btn_labels = c("Cancel", "Yes"),
          html = TRUE
        )
      },
      error = \(e) {
        alert_fail_ui(
          session = session,
          position = "bottom",
          info = conditionMessage(e)
        )
      }
    )
  })

  observeEvent(input$confirm_teacher_details, {
    shinyjs::disable("submit_teacher_details")
    shinyjs::show("t_auth_loader")

    # if has confirmed details
    if (input$confirm_teacher_details) {
      tryCatch(
        expr = {
          # add user to firebase
          user <- frbs::frbs_sign_up(
            input$teacher_email,
            input$teacher_password
          )

          if (!is.null(user$error)) {
            shinyjs::enable("confirm_teacher_details")
            shinyjs::hide("t_auth_loader")
            stop("An error occured with your email", call. = FALSE)
          }
          name <- stringr::word(input$teacher_username, 1)

          id_token <- user$idToken
          frbs::frbs_send_email_verification(
            id_token = id_token
          )

          # add user to polished
          polished::add_app_user(
            app_uid = app_uid,
            email = input$teacher_email
          )

          # get user details
          get_new_user <- polished::get_users(
            email = input$teacher_email
          )
          user_uid <- get_new_user$content$uid

          # add role to the user
          polished::add_user_role(
            user_uid = user_uid,
            role_name = "teacher"
          )

          # Convert the vector of grades to a single string
          grades <- paste(input$teacher_grades, collapse = ", ")

          # Create data to append
          new_user <- data.frame(
            id = next_user_id("teachers", "teacher"),
            user_name = stringr::str_to_title(input$teacher_username),
            school_name = input$teacher_school,
            grade = grades,
            phone = input$teacher_tel_number,
            email = input$teacher_email,
            time = format(Sys.time(), format = "%Y-%m-%d %H:%M:%S"),
            status = "Enabled",
            views = 0
          )

          # Call the register_new_user function
          success <- register_new_user(
            table_name = "teachers",
            data = new_user
          )

          if (success == 1) {
            updateTabsetPanel(
              inputId = "app_pages",
              selected = "auth_page"
            )

            email_verification_alert(
              email_address = input$teacher_email,
              session = session
            )
            first_name <- strsplit(new_user$user_name, " ")[[1]][1]
            email_salutation <- email_salutation(first_name)
            send_email_notification(
              receipients = new_user$email,
              subject = "Welcome to Candidate",
              body = email_body_template(
                heading = "",
                salutation = email_salutation,
                body = welcome_body(new_user$id),
                footer = external_email_footer
              )
            )
          } else {
            alert_fail_ui(
              info = "Name or email or phone already exists!",
              session = session
            )
            frbs::frbs_delete_account(id_token = id_token)
            polished::delete_user(user_uid = user_uid)
          }
        },
        error = \(e) {
          alert_fail_ui(
            session = session,
            position = "bottom",
            info = conditionMessage(e)
          )
        }
      )
    } else {
      # if has declined to confirm
      alert_warn_ui(
        info = "Details not confirmed...",
        session = session
      )
    }
    shinyjs::enable("submit_teacher_details")
    shinyjs::hide("t_auth_loader")
  })

  # Register a new student
  # add validation rules
  ivst <- shinyvalidate::InputValidator$new()
  ivst$add_rule("student_username", shinyvalidate::sv_required())
  ivst$add_rule("student_school", shinyvalidate::sv_required())
  ivst$add_rule("student_grade", shinyvalidate::sv_required())
  ivst$add_rule("student_tel_number", shinyvalidate::sv_required())
  ivst$add_rule("student_email", shinyvalidate::sv_email())

  # Add a validation rule for the phone number input
  ivst$add_rule("student_tel_number", function(value) {
    phone_number <- gsub("\\D", "", value) # Remove non-digit characters
    if (nchar(phone_number) != 9) {
      return("Phone number must be 9 digits")
    }
    return(NULL) # Return NULL if validation passes
  })
  # Add a validation rule for the user name input
  ivst$add_rule("student_username", function(value) {
    names <- strsplit(value, " ")[[1]]
    if (length(names) != 2) {
      return("Must be 2 names")
    }
    return(NULL) # Return NULL if validation passes
  })

  # Check if the password is at least 8 characters long
  ivst$add_rule("student_password", function(value) {
    # Check if the password is at least 8 characters long
    if (nchar(value) < 8) {
      return("Must be at least 8 characters long")
    }

    # Check if the password contains at least one letter
    if (!grepl("[a-zA-Z]", value)) {
      return("Password must contain at least one letter")
    }

    # Check if the password contains at least one number
    if (!grepl("[0-9]", value)) {
      return("Password must contain at least one number")
    }

    # Check if the password contains at least one special character
    if (!grepl("[^a-zA-Z0-9]", value)) {
      return("Password must contain at least one special character")
    }

    return(NULL) # Return NULL if validation passes
  })

  ivst$add_rule("s_privacy_link_tos", function(value) {
    if (value != TRUE) {
      return("Required")
    }
  })

  observeEvent(input$submit_student_details, {
    ivst$enable() # enable validation check
    req(ivst$is_valid()) # ensure checks are valid

    password <- input$student_password
    password_confirm <- input$student_confirm_password

    is_match <- check_confirm_password(
      password = password,
      confirm_password = password_confirm
    )

    if (!is_match) {
      return(
        alert_fail_ui(
          session = session,
          info = "Password do not match",
          position = "bottom"
        )
      )
    }

    tryCatch(
      expr = {
        # Get the list of app users
        app_users <- polished::get_users()[1]$content$email
        # Check if the input email exists in the email column
        email_exists <- input$student_email %in% app_users

        if (email_exists) {
          msg <- "User email already exists!"
          stop(msg, call. = FALSE)
        }

        table_html <- reactable::reactable(
          data = data.frame(
            Input = c(
              "Name", "School", "Grade",
              "Contact", "Email"
            ),
            Value = stringr::str_trunc(
              c(
                stringr::str_to_title(input$student_username),
                input$student_school,
                input$student_grade,
                input$student_tel_number,
                input$student_email
              ),
              width = 25
            )
          ),
          columns = list(
            Input = reactable::colDef(name = "Input"),
            Value = reactable::colDef(name = "Value")
          ),
          borderless = TRUE,
          bordered = FALSE,
          striped = FALSE,
          outlined = TRUE,
          wrap = FALSE,
          resizable = FALSE,
          class = "text-gray-dark"
        )

        # Show confirmation dialog with reactable table
        shinyWidgets::ask_confirmation(
          session = session,
          inputId = "confirm_student_details",
          title = NULL,
          text = tags$div(
            table_html
          ),
          btn_labels = c("Cancel", "Yes"),
          html = TRUE
        )
      },
      error = \(e) {
        alert_fail_ui(
          session = session,
          position = "bottom",
          info = conditionMessage(e)
        )
      }
    )
  })

  observeEvent(input$confirm_student_details, {
    shinyjs::disable("submit_student_details")
    shinyjs::show("s_auth_loader")

    # if has confirmed details
    if (input$confirm_student_details) {
      tryCatch(
        expr = {
          # add user to firebase
          user <- frbs::frbs_sign_up(
            input$student_email,
            input$student_password
          )

          if (!is.null(user$error)) {
            shinyjs::enable("confirm_student_details")
            shinyjs::hide("s_auth_loader")
            stop("An error occured with your email", call. = FALSE)
          }
          name <- stringr::word(input$student_username, 1)

          id_token <- user$idToken
          frbs::frbs_send_email_verification(
            id_token = id_token
          )

          # add user to polished
          polished::add_app_user(
            app_uid = app_uid,
            email = input$student_email
          )

          # get user details
          get_new_user <- polished::get_users(
            email = input$student_email
          )
          user_uid <- get_new_user$content$uid

          # add role to the user
          polished::add_user_role(
            user_uid = user_uid,
            role_name = "student"
          )

          # Convert the vector of grades to a single string
          grades <- paste(input$student_grade, collapse = ", ")

          # Create data to append
          new_user <- data.frame(
            id = next_user_id("students", "student"),
            user_name = stringr::str_to_title(input$student_username),
            school_name = input$student_school,
            grade = grades,
            phone = input$student_tel_number,
            email = input$student_email,
            time = format(Sys.time(), format = "%Y-%m-%d %H:%M:%S"),
            status = "Enabled",
            paid = 0
          )

          # Call the register_new_user function
          success <- register_new_user(
            table_name = "students",
            data = new_user
          )

          if (success == 1) {
            name <- stringr::word(input$student_username, 1)
            updateTabsetPanel(
              inputId = "app_pages",
              selected = "auth_page"
            )

            email_verification_alert(
              email_address = input$student_email,
              session = session
            )
            first_name <- strsplit(new_user$user_name, " ")[[1]][1]
            email_salutation <- email_salutation(first_name)
            send_email_notification(
              receipients = new_user$email,
              subject = "Welcome to Candidate",
              body = email_body_template(
                heading = "",
                salutation = email_salutation,
                body = welcome_body(new_user$id),
                footer = external_email_footer
              )
            )
          } else {
            alert_fail_ui(
              info = "Name or email or phone already exists!",
              session = session
            )
            frbs::frbs_delete_account(id_token = id_token)
            polished::delete_user(user_uid = user_uid)
          }
        },
        error = \(e) {
          alert_fail_ui(
            session = session,
            position = "bottom",
            info = conditionMessage(e)
          )
        }
      )
    } else {
      # if has declined to confirm
      alert_warn_ui(
        info = "Details not confirmed...",
        session = session
      )
    }
    shinyjs::enable("confirm_student_details")
    shinyjs::hide("s_auth_loader")
  })

  # now output signed user
  observe({
    shinyWidgets::updatePickerInput(
      inputId = "teacher_school",
      choices = rvs$schools_data$school_name,
      choicesOpt = list(
        subtext = rvs$schools_data$level
      )
    )
    shinyWidgets::updatePickerInput(
      inputId = "student_school",
      choices = rvs$schools_data$school_name,
      choicesOpt = list(
        subtext = rvs$schools_data$level
      )
    )

    if (isTruthy(user_details$email)) {
      shinyjs::show("company_copyright")
      # get signed user details
      signed_email <- user_details$email

      pol_signed_user <- polished::get_app_users(
        app_uid = app_uid,
        email = signed_email
      )

      user_not_found <- identical(nrow(pol_signed_user$content), 0L)
      if (user_not_found) {
        return(
          shinyalert::shinyalert(
            title = "Contact Administrator",
            text = paste(
              "An error occurred with your account."
            ),
            html = TRUE,
            inputId = "error_alert",
            imageUrl = "logo/logo_icon_blue.png",
            imageWidth = 80,
            imageHeight = 50,
            session = session,
            confirmButtonText = "OK",
            confirmButtonCol = "#163142",
            callbackR = function() {
              session$reload()
            }
          )
        )
      }
      user_uid <- pol_signed_user$content$user_uid
      is_admin <- pol_signed_user$content$is_admin
      shinyjs::hide("login_link")

      if (is_admin) {
        admin_data <- rvs$administrators_data
        exists <- signed_email %in% admin_data$input_col

        if (exists) {
          signed_user <- admin_data |>
            dplyr::filter(input_col == signed_email)

          user_name <- signed_user$value
          user_status <- "Enabled"
          user_role <- "admin"
        } else {
          updateTabsetPanel(
            inputId = "app_pages",
            selected = "admin_reg"
          )
          iv_admin <- shinyvalidate::InputValidator$new()
          iv_admin$add_rule("admin_name", shinyvalidate::sv_required())
          iv_admin$add_rule("admin_name", function(value) {
            names <- strsplit(value, " ")[[1]]
            if (length(names) != 2) {
              return("Must be 2 names")
            }
            return(NULL)
          })

          observeEvent(input$admin_name_set, {
            iv_admin$enable()
            req(iv_admin$is_valid())
            update <- update_admin_name(
              email = signed_email,
              name = input$admin_name
            )

            if (identical(update, 1L)) {
              alert_success_ui(
                session = session,
                timer = 0,
                info = "Name updated...Now log in"
              )
              first_name <- strsplit(input$admin_name, " ")[[1]][1]
              email_salutation <- email_salutation(first_name)
              send_email_notification(
                receipients = signed_email,
                subject = "Welcome to Candidate",
                body = email_body_template(
                  heading = "Welcome to Candidate",
                  salutation = email_salutation,
                  body = welcome_body(""),
                  footer = external_email_footer
                )
              )
              session$reload()
            } else {
              alert_fail_ui(
                session = session,
                info = "Name exists! Try another one."
              )
            }
          })
          return()
        }
      } else {
        # get roles
        user_role <- polished::get_user_roles(user_uid = user_uid)
        user_role <- user_role$content$role_name

        if (!identical(length(user_role), 1L)) {
          return(
            shinyalert::shinyalert(
              title = "Contact Administrator",
              text = paste(
                "An error occurred with your account."
              ),
              html = TRUE,
              inputId = "error_alert",
              imageUrl = "logo/logo_icon_blue.png",
              imageWidth = 80,
              imageHeight = 50,
              session = session,
              confirmButtonText = "OK",
              confirmButtonCol = "#163142",
              callbackR = function() {
                session$reload()
              }
            )
          )
        }

        # get the DB details of signed user
        signed_user <- get_signed_user(signed_email, user_role)
        user_status <- signed_user$status
        user_name <- signed_user$user_name
      }

      # show the user on profile
      output$signed_user <- renderText({
        if (length(user_name) == 0) {
          return("Uknown")
        }
        user_name[1]
      })


      # hide login link
      shinyjs::hide("login_link")
      shinyjs::hide("teachers_link")
      shinyjs::hide("students_link")
      shinyjs::show("user_profile_tab")

      observeEvent(input$signed_user_link, {
        req(isTruthy(user_role))
        shinyjs::show("company_copyright")

        if (is_admin) {
          updateTabsetPanel(
            inputId = "app_pages",
            selected = "admin_page"
          )
        } else if (user_role == "student") {
          updateTabsetPanel(
            inputId = "app_pages",
            selected = "student_content"
          )
        } else if (user_role == "teacher") {
          updateTabsetPanel(
            inputId = "app_pages",
            selected = "teacher_content"
          )
        } else {
          return()
        }
      })

      # Show the dashboard page if conditions are met
      if (nrow(signed_user) == 1 &&
        user_status == "Enabled" && !is.na(user_role)) {
        # Control access according to roles
        if (is_admin) {
          updateTabsetPanel(
            inputId = "app_pages",
            selected = "admin_page"
          )
        } else if (user_role == "student") {
          # check if user has paid
          price <- rvs$schools_data |>
            dplyr::filter(school_name == signed_user$school_name) |>
            dplyr::select(price) |>
            as.numeric()

          paid_amount <- rvs$payments_data |>
            dplyr::filter(status == "APPROVED" &
              user_id == "STU-001") |>
            dplyr::select(amount) |>
            unlist() |>
            as.numeric() |>
            sum()

          # Check if the user has paid for the term
          user_paid <- signed_user |>
            dplyr::select(paid) |>
            dplyr::pull(paid) |>
            as.logical()

          balance <- price - paid_amount
          clear <- prettyNum(balance, big.mark = ",")
          if (!user_paid) {
            shinyjs::hide("content_pdfs")

            shinyalert::shinyalert(
              title = "Subscription Required",
              text = paste(
                "Please pay your balance of KES", clear, "to access Candidate content"
              ),
              type = "",
              inputId = "pay_alert",
              imageUrl = "logo/mpesa_poster.jpg",
              imageWidth = 100,
              imageHeight = 60,
              session = session,
              confirmButtonText = "OK",
              confirmButtonCol = "#163142",
              callbackR = function() {
                shinyjs::show("payment_required")
                updateTabsetPanel(
                  session = session,
                  inputId = "student_content_tabset",
                  selected = "Payments"
                )

                output$balance_required <- renderUI({
                  # Define MPESA payment details
                  paybill_no <- "123456"
                  ac_number <- "Your Candidate ID"

                  div(
                    id = "payment_required",
                    class = "card pt-2 border-bottom
                                        text-white",
                    style = "background-color: #3aa335",
                    div(
                      p("Payment required",
                        class = "card-header text-bold text-center",
                      )
                    ),
                    div(
                      class = "card-body",
                      tags$p(
                        "Please clear your balance of KES", clear,
                        "to access your Candidate. Pay via MPESA using the following details:"
                      ),
                      tags$p(
                        "Paybill Number:", paybill_no
                      ),
                      tags$p(
                        "Account Number:", ac_number
                      )
                    ),
                    tags$p(
                      class = "card-footer",
                      "Then create a payment ticket using the MPESA SMS on next tab for approval."
                    )
                  )
                })
              }
            )
          }


          updateTabsetPanel(
            inputId = "app_pages",
            selected = "student_content"
          )

          table <- data.frame(
            ID = signed_user$id,
            SCHOOL = signed_user$school_name,
            GRADE = signed_user$grade,
            EMAIL = signed_user$email,
            PHONE = signed_user$phone
          )
          output$signed <- renderUI({
            reactable::reactable(
              table,
              borderless = TRUE,
              bordered = FALSE,
              striped = FALSE,
              outlined = TRUE
            )
          })

          output$term_end_student_table <- renderUI({
            data <- rvs$administrators_data
            values <- data |>
              dplyr::select(value) |>
              as.vector()

            if (is.na(values$value[1]) || is.na(values$value[2])) {
              p("Welcome Administrator. Create your first term")
            } else {
              p(
                paste("Current term", values$value[2], "ends on", values$value[1]),
                class = "px-2"
              )
            }
          })

          progress_value <- (paid_amount / price) * 100

          shinyWidgets::updateProgressBar(
            session = session,
            "payment_progress",
            value = progress_value
          )

          output$school_ticket <- renderText(
            paste("Ksh.", prettyNum(price, big.mark = ","))
          )
          output$paid_amount <- renderText(
            paste("Ksh.", prettyNum(paid_amount, big.mark = ","))
          )
          output$balance <- renderText(
            paste("Ksh.", prettyNum(balance, big.mark = ","))
          )
          # Filter the student content based on the signed-in user's grade and school
          signed_student_teachers <- rvs$teachers_data |>
            dplyr::filter(school_name == signed_user$school_name) |>
            dplyr::select(user_name) |>
            unlist() |>
            as.vector()

          student_content <- rvs$pdf_data |>
            dplyr::filter(grade == signed_user$grade &
              teacher %in% signed_student_teachers &
              status == "Available")

          # Initialize reactive values
          rvts <- reactiveValues(data = student_content)

          # Update picker inputs with unique values from the filtered data
          shinyWidgets::updatePickerInput(
            session = session,
            inputId = "filter_teacher",
            choices = unique(student_content$teacher)
          )
          shinyWidgets::updatePickerInput(
            session = session,
            inputId = "filter_learning_area",
            choices = unique(student_content$learning_area)
          )
          shinyWidgets::updatePickerInput(
            session = session,
            inputId = "filter_topic",
            choices = unique(student_content$topic)
          )
          shinyWidgets::updatePickerInput(
            session = session,
            inputId = "filter_sub_topic",
            choices = unique(student_content$sub_topic)
          )

          # Observe changes in picker inputs and update filtered data
          observeEvent(
            list(
              input$filter_teacher,
              input$filter_learning_area,
              input$filter_topic,
              input$filter_sub_topic
            ),
            {
              # Reload and filter the data
              rvts$data <- update_filtered_data()
            },
            ignoreNULL = FALSE
          )

          # Apply content filters
          update_filtered_data <- function() {
            filtered_data <- student_content
            columns <- c("teacher", "learning_area", "topic", "sub_topic")

            for (col in columns) {
              selected_values <- input[[paste0("filter_", col)]]

              if (!is.null(selected_values) && length(selected_values) > 0) {
                filtered_data <- filtered_data |>
                  dplyr::filter(get(col) %in% selected_values)
              }
            }

            return(filtered_data)
          }
          # Render available PDFs
          output$published_pdfs <- renderUI({
            filtered_data <- update_filtered_data()

            if (nrow(filtered_data) == 0) {
              # Show empty state if no data is available
              show_empty_state_ui
            } else {
              shinybusy::show_spinner()

              # Find unique teachers
              student_teachers <- unique(rvts$data$teacher)

              # List all images in the "www/images" directory
              image_files <- list.files(
                path = "www/images",
                pattern = "_page_1\\.png$",
                full.names = TRUE
              )

              # Create card decks for each teacher
              card_decks <- lapply(student_teachers, function(s_teacher) {
                # Filter data for the current teacher
                teacher_data <- dplyr::filter(filtered_data, teacher == !!s_teacher)
                teacher_data <- dplyr::arrange(teacher_data, desc(time))

                # Set payment status
                div(
                  class = "d-flex flex-wrap justify-content-center",
                  lapply(seq_len(nrow(teacher_data)), function(i) {
                    pdf_info <- teacher_data[i, ]
                    pdf_name_filtered <- fs::path_ext_remove(basename(pdf_info$pdf_name))

                    table_html <- reactable::reactable(
                      data = data.frame(
                        Input = c("Teacher", "Learning Area", "Topic", "Sub Topic"),
                        Value = stringr::str_trunc(
                          c(
                            input$pdfFile$name,
                            pdf_info$teacher,
                            pdf_info$learning_area,
                            pdf_info$topic,
                            pdf_info$sub_topic
                          ),
                          width = 25
                        )
                      ),
                      columns = list(
                        Input = reactable::colDef(name = "Item"),
                        Value = reactable::colDef(name = "Details")
                      ),
                      borderless = TRUE,
                      bordered = FALSE,
                      striped = FALSE,
                      outlined = TRUE,
                      wrap = FALSE,
                      class = "bg-default"
                    )
                    # Get the cover images
                    cover_image <- image_files[grepl(
                      paste0(
                        "^www/images/",
                        pdf_name_filtered,
                        "_page_1\\.png$"
                      ),
                      image_files
                    )]

                    cover_image <- ifelse(
                      length(cover_image) > 0,
                      sub("^www/", "", cover_image[1]),
                      "logo/default_cover.png"
                    )

                    # Create PDF card
                    div(
                      class = "card w-25 mt-2 hover-card",
                      div(
                        id = paste("card", i),
                        class = "d-flex justify-content-center",
                        onclick = sprintf(
                          "Shiny.setInputValue('selected_pdf', '%s'); Shiny.setInputValue('trigger_modal', Math.random()); Shiny.setInputValue('refresh_pdf', Math.random());",
                          pdf_info$pdf_name
                        ),
                        argonR::argonImage(
                          src = cover_image
                        ),
                        div(
                          class = "card-details",
                          table_html
                        )
                      )
                    )
                  })
                )
              })

              # Wrap all card decks in a tagList
              do.call(tagList, card_decks)
            }
          })


          # Reset selected_pdf when the Go Back button is clicked
          observeEvent(input$go_back_btn, {
            shinyjs::hide("selected_pdf_frame", anim = TRUE, animType = "fade")
            shinyjs::show("published_pdfs", anim = TRUE, animType = "fade")
            shinyjs::show("filters", anim = TRUE, animType = "fade")

            spend_time <- Sys.time() - rv$pdf_time
            spend_time <- as.numeric(spend_time, units = "mins")

            if (spend_time > 2) {
              selected_pdf_details <- rvs$pdf_data |>
                dplyr::filter(pdf_name == input$selected_pdf &
                  grade == signed_user$grade)

              teacher_data <- rvs$teachers_data |>
                dplyr::filter(
                  user_name == selected_pdf_details$teacher
                )

              record_student_view(
                student_id = signed_user$id,
                teacher_id = teacher_data$id,
                pdf_id = selected_pdf_details$id
              )
            }
          })

          # Observe selection change and update image paths
          observeEvent(input$selected_pdf, {
            shinybusy::show_spinner()

            req(input$selected_pdf)
            pdf <- input$selected_pdf
            shinyjs::hide("published_pdfs", anim = TRUE, animType = "fade")
            shinyjs::show("selected_pdf_frame", anim = TRUE, animType = "fade")
            shinyjs::hide("filters", anim = TRUE, animType = "fade")

            # Set reactive timer when the PDF is opened
            rv$pdf_time <- Sys.time()

            output$selected_pdf_frame <- renderUI({
              div(
                div(
                  class = "position-fixed mt-5 mx-5",
                  actionButton(
                    inputId = "go_back_btn",
                    label = "",
                    icon = icon("arrow-left")
                  ) |>
                    basic_primary_btn()
                ),
                tags$iframe(
                  class = "pt-3",
                  src = file.path("pdf", pdf, "#toolbar=0"),
                  style = "width: 100%; height: 100vh; border: none;",
                  scrolling = "no"
                )
              )
            })
          })
        } else if (user_role == "teacher") {
          updateTabsetPanel(
            inputId = "app_pages",
            selected = "teacher_content"
          )
          table <- data.frame(
            ID = signed_user$id,
            SCHOOL = signed_user$school_name,
            GRADE = signed_user$grade,
            EMAIL = signed_user$email,
            PHONE = signed_user$phone,
            VIEWS = signed_user$views,
            EARNINGS = paste("Ksh.", 0)
          )
          output$signed_teacher <- renderUI({
            reactable::reactable(
              table,
              borderless = TRUE,
              bordered = FALSE,
              striped = FALSE,
              outlined = TRUE
            )
          })
          grades <- strsplit(signed_user$grade, ", ")[[1]] |>
            as.numeric()
          shinyWidgets::updatePickerInput(
            session = session,
            inputId = "request_grade",
            choices = setNames(grades, paste("Grade", grades))
          )
          shinyWidgets::updatePickerInput(
            session = session,
            inputId = "request_learning_area",
            choices = learning_areas,
            choicesOpt = list(
              content = stringr::str_trunc(
                learning_areas,
                width = 25
              )
            )
          )

          # add validation rules
          ivr <- shinyvalidate::InputValidator$new()
          ivrd <- shinyvalidate::InputValidator$new()

          ivr$add_rule("photo_file", shinyvalidate::sv_required())
          ivr$add_rule("request_grade", shinyvalidate::sv_required())
          ivr$add_rule("request_learning_area", shinyvalidate::sv_required())
          ivr$add_rule("request_topic", shinyvalidate::sv_required())
          ivr$add_rule("request_sub_topic", shinyvalidate::sv_required())
          ivrd$add_rule("request_description", function(value) {
            if (nchar(value) > 100) {
              return("Limit of 100 characters exceeded!")
            }
          })
          ivrd$enable()

          output$char_count <- renderUI({
            # Use tags$span to create a small class text
            tags$span(
              paste("Character count:", nchar(input$request_description), "/ 100 characters"),
              class = "small text-gray"
            )
          })
          output$teacher_requests <- reactable::renderReactable({
            # Filter and dplyr::arrange the data as needed
            data <- rvs$requests_data |>
              dplyr::filter(teacher_id == signed_user$id) |>
              dplyr::select(-c(teacher_id, description)) |>
              dplyr::arrange(desc(time))

            # Set the column names
            colnames(data) <- c("ID", "No. photos", "Grade", "Learning Area", "Topic", "Sub Topic", "Time", "Status")

            # Create a reactable with customization
            reactable::reactable(
              data,
              searchable = TRUE,
              sortable = TRUE,
              defaultPageSize = 10,
              highlight = TRUE,
              wrap = FALSE,
              resizable = TRUE,
              bordered = TRUE,
              class = "mb-5",
              columns = list(
                Status = reactable::colDef(
                  style = function(status) {
                    color <- dplyr::case_when(
                      status == "DECLINED" ~ "#e00000",
                      status == "PENDING" ~ "#50BD8C",
                      status == "APPROVED" ~ "#008000",
                      .default = "#163142"
                    )
                    list(color = color, fontWeight = "bold")
                  }
                )
              ),
              theme = reactable::reactableTheme(
                borderColor = "#ddd",
                cellPadding = "8px",
                borderWidth = "1px",
                highlightColor = "#f0f0f0"
              )
            )
          })

          output$teacher_students <- reactable::renderReactable({
            # Filter and arrange the data as needed
            data <- rvs$students_data |>
              dplyr::filter(school_name == signed_user$school_name &
                grade %in% grades) |>
              dplyr::select(id, user_name, grade, paid)

            # Set the column names
            colnames(data) <- c("ID", "Name", "Grade", "Paid")

            # Create a reactable with customization
            reactable::reactable(
              data = data,
              searchable = TRUE,
              defaultPageSize = 10,
              wrap = FALSE,
              highlight = TRUE,
              borderless = TRUE,
              columns = list(
                Paid = reactable::colDef(
                  cell = function(value) {
                    if (value == "0") "\u274c" else "\u2714\ufe0f"
                  }
                )
              ),
              theme = reactable::reactableTheme(
                borderColor = "#ddd",
                cellPadding = "8px",
                borderWidth = "1px",
                highlightColor = "#f0f0f0"
              ),
              groupBy = "Grade",
              onClick = "expand",
              rowStyle = list(cursor = "pointer")
            )
          })
          observeEvent(input$request_btn, {
            ivr$enable() # enable validation check
            req(ivr$is_valid()) # ensure checks are valid
            req(ivrd$is_valid())

            photos <- uploaded_request_files()
            if (length(photos) == 0) {
              alert_fail_ui(
                info = "Upload new photos!",
                session = session
              )
              return()
            }
            req(length(photos) > 0)
            table_html <- reactable::reactable(
              data = data.frame(
                Input = c(
                  "No. photos", "Grade", "Learning Area", "Topic", "Sub Topic"
                ),
                Value = stringr::str_trunc(
                  c(
                    length(photos),
                    input$request_grade,
                    input$request_learning_area,
                    input$request_topic,
                    input$request_sub_topic
                  ),
                  width = 25
                )
              ),
              columns = list(
                Input = reactable::colDef(name = "Input"),
                Value = reactable::colDef(name = "Value")
              ),
              borderless = TRUE,
              bordered = FALSE,
              striped = FALSE,
              outlined = TRUE,
              wrap = FALSE,
              resizable = FALSE,
              class = "text-gray-dark"
            )

            # Show confirmation dialog with reactable table
            shinyalert::shinyalert(
              session = session,
              inputId = "confirm_request_details",
              title = NULL,
              text = tags$div(
                table_html
              ),
              showCancelButton = TRUE,
              confirmButtonCol = "#163142",
              html = TRUE
            )
          })

          observeEvent(input$confirm_request_details, {
            shinybusy::show_spinner()
            shinyjs::disable("request_btn")
            photos <- uploaded_request_files()
            # if has confirmed details
            if (input$confirm_request_details) {
              if (!dir.exists("www/requests")) {
                dir.create("www/requests", recursive = TRUE)
              }
              data <- data.frame(
                id = next_request_id("requests"),
                teacher_id = signed_user$id,
                photos = length(photos),
                grade = input$request_grade,
                learning_area = input$request_learning_area,
                topic = input$request_topic,
                sub_topic = input$request_sub_topic,
                description = input$request_description,
                time = format(Sys.time(), format = "%Y-%m-%d %H:%M:%S"),
                status = "PENDING"
              )

              success <- add_new_request(
                table_name = "requests",
                data = data
              )

              # show alert after completing upload
              if (success == 1) {
                requests_datapaths <- sapply(
                  photos,
                  function(file) file$datapath
                )

                # copy pdf to directory
                process_uploaded_photos(
                  photos = requests_datapaths,
                  dest_dir = "www/requests",
                  base_id = data$id
                )

                alert_success_ui(
                  info = "Request created successfully!",
                  session = session
                )
                # Clear the list after processing
                uploaded_request_files(list())

                # refresh added data
                rvs$requests_data <- refresh_table_data(
                  table_name = "requests"
                )
                updateTextAreaInput(
                  session = session,
                  inputId = "request_description",
                  value = ""
                )
              } else {
                alert_fail_ui(
                  info = "Details match found...",
                  session = session
                )
              }
            } else {
              # if has declined to confirm
              alert_warn_ui(info = "Details not confirmed...", session = session)
            }
            shinyjs::enable("request_btn")
          })
        } else if (user_role == "developer") {
        } else {
          return()
        }
      } else {
        shinyalert::shinyalert(
          title = "Contact Administrator",
          text = paste(
            "An error occurred with your account."
          ),
          html = TRUE,
          inputId = "error_alert",
          imageUrl = "logo/logo_icon_blue.png",
          imageWidth = 80,
          imageHeight = 50,
          session = session,
          confirmButtonText = "OK",
          confirmButtonCol = "#163142",
          callbackR = function() {
            session$reload()
          }
        )
      }
    }



    # add validation rules
    ivs$add_rule("pdfFile", shinyvalidate::sv_required())
    ivs$add_rule("pdfFile", function(value) {
      if (!is.null(value) && length(value) > 0) {
        pdf_info <- pdftools::pdf_info(value$datapath)
        pdf_name <- fs::path_ext_remove(basename(value$name))
        pages <- pdf_info$pages
        if (pages > 3) {
          return("PDF exceeded limit of 3 pages")
        }
        if (nchar(pdf_name) > 20) {
          return("Shorten the PDF name")
        }
      }
      return(NULL) # Return NULL if validation passes
    })

    ivs$add_rule("doc_request", shinyvalidate::sv_required())
    ivs$add_rule("doc_teacher_id", shinyvalidate::sv_required())
    ivs$add_rule("doc_grade", shinyvalidate::sv_required())
    ivs$add_rule("doc_learning_area", shinyvalidate::sv_required())
    ivs$add_rule("doc_topic", shinyvalidate::sv_required())
    ivs$add_rule("doc_sub_topic", shinyvalidate::sv_required())

    # Update field choices
    observe({
      if (nrow(rvs$schools_data) > 0) {
        requests <- rvs$requests_data |>
          dplyr::filter(status == "PROCESSING") |>
          dplyr::select(id) |>
          unlist() |>
          as.vector()
        shinyWidgets::updatePickerInput(
          session = session,
          inputId = "doc_request",
          choices = requests
        )

        # hide card sidebar content to allow click first
        shinyjs::hide("card_sidebar")
      }
    })

    observeEvent(input$doc_request, {
      request <- rvs$requests_data |>
        dplyr::filter(id == input$doc_request)
      updateTextInput(
        session = session,
        inputId = "doc_topic",
        value = request$topic
      )
      updateTextInput(
        session = session,
        inputId = "doc_learning_area",
        value = request$learning_area
      )

      updateTextInput(
        session = session,
        inputId = "doc_grade",
        value = request$grade
      )
      updateTextInput(
        session = session,
        inputId = "doc_sub_topic",
        value = request$sub_topic
      )
      updateTextInput(
        session = session,
        inputId = "doc_teacher_id",
        value = unique(request$teacher_id)
      )
    })

    output$requests_data <- renderUI({
      # Filter and dplyr::arrange the data as needed
      data <- rvs$requests_data |>
        dplyr::arrange(desc(time)) |>
        dplyr::mutate(details = NA)

      # Set the column names
      colnames(data) <- c(
        "ID", "Teacher ID", "Photos", "Grade", "Learning Area", "Topic", "Sub Topic", "Additional info",
        "Time", "Status", "details"
      )

      if (nrow(data) > 0) {
        # Create a reactable with download and update features
        output$table <- reactable::renderReactable({
          reactable::reactable(
            data = data,
            searchable = TRUE,
            sortable = TRUE,
            resizable = TRUE,
            defaultPageSize = 10,
            wrap = FALSE,
            highlight = TRUE,
            columns = list(
              details = reactable::colDef(
                name = "",
                sortable = FALSE,
                align = "center",
                cell = function() {
                  htmltools::tags$button(
                    "",
                    class = "fa fa-chevron-right border-0 bg-transparent mt-3",
                    `aria-hidden` = "true"
                  )
                }
              ),
              `Additional info` = reactable::colDef(show = FALSE),
              Status = reactable::colDef(
                style = function(status) {
                  color <- dplyr::case_when(
                    status == "CANCELLED" ~ "#e00000",
                    status == "PENDING" ~ "#50BD8C",
                    status == "APPROVED" ~ "#008000",
                    .default = "#163142"
                  )
                  list(color = color, fontWeight = "bold")
                }
              )
            ),
            theme = reactable::reactableTheme(
              borderColor = "#ddd",
              cellPadding = "8px",
              borderWidth = "1px",
              highlightColor = "#f0f0f0"
            ),
            onClick = reactable::JS("function(rowInfo, column) {
                        if (column.id !== 'details') {
                        return
                         }
                     Shiny.setInputValue('show_details', { index: rowInfo.index + 1, info: rowInfo.values }, { priority: 'event' })
                     }")
          )
        })
      } else {
        # show empty status div
        show_empty_state_ui
      }
    })


    ## ---- ADMIN REGISTRATION TAB ----

    # add validation rules
    iv$add_rule("school_name", shinyvalidate::sv_required())
    iv$add_rule("school_email", shinyvalidate::sv_email())
    iv$add_rule("school_type", shinyvalidate::sv_required())
    iv$add_rule("school_level", shinyvalidate::sv_required())
    iv$add_rule("county", shinyvalidate::sv_required())
    iv$add_rule("doc_price", shinyvalidate::sv_required())


    shinyjs::addCssClass(
      id = "step_1",
      class = "bg-red"
    )
    shinyjs::addCssClass(
      id = "step_u1",
      class = "bg-red"
    )


    # observe events on the back button
    observeEvent(input$prevBtn, {
      shinyjs::hide("prevBtn")
      shinyjs::addCssClass(
        id = "tab_buttons",
        class = "justify-content-end"
      )
      shinyjs::removeCssClass(
        id = "tab_buttons",
        class = "justify-content-between"
      )
      shinyjs::hide("tab_2")
      shinyjs::show("tab_1")
      shinyjs::hide(
        id = "confirmBtn"
      )
      shinyjs::show(
        id = "nextBtn"
      )
    })

    # observe events on the forward button
    observeEvent(input$nextBtn, {
      # enabled error UI show
      iv$enable()
      req(iv$is_valid())

      # mark step 1 complete
      shinyjs::addCssClass(
        id = "step_1",
        class = "bg-green"
      )
      shinyjs::addCssClass(
        id = "line",
        class = "bg-green"
      )
      shinyjs::show("prevBtn")
      shinyjs::show("tab_2")
      shinyjs::hide("tab_1")

      shinyjs::removeCssClass(
        id = "tab_buttons",
        class = "justify-content-end"
      )

      shinyjs::addCssClass(
        id = "tab_buttons",
        class = "justify-content-between"
      )
      shinyjs::show(
        id = "confirmBtn"
      )
      shinyjs::hide(
        id = "nextBtn"
      )
      shinyjs::addCssClass(
        id = "step_2",
        class = "bg-red"
      )

      # output table for entered data confirmation
      output$confirm_schools_data <- renderUI({
        table_html <- reactable::reactable(
          data = data.frame(
            Input = c(
              "Name", "Level", "Type", "County",
              "Email", "Price", "Status"
            ),
            Value = stringr::str_trunc(
              c(
                stringr::str_to_sentence(input$school_name),
                input$school_level,
                input$school_type,
                input$county,
                tolower(input$school_email),
                paste("Ksh. ", input$doc_price),
                "Pending"
              ),
              width = 25
            )
          ),
          columns = list(
            Input = reactable::colDef(name = "Input"),
            Value = reactable::colDef(name = "Value")
          ),
          borderless = TRUE,
          bordered = FALSE,
          striped = FALSE,
          outlined = TRUE,
          wrap = FALSE,
          class = "text-gray-dark"
        )
        table_html
      })
    })

    # output table for already exisiting school data
    output$schools_data <- renderUI({
      # get the school data
      table_data <- rvs$schools_data |>
        dplyr::arrange(desc(time)) |>
        dplyr::mutate(details = NA)

      if (nrow(table_data) > 0) {
        # Set the column names

        colnames(table_data) <- c("ID", "Name", "Level", "Type", "County", "Email", "Price", "Time", "Status", "details")

        output$table1 <- reactable::renderReactable({
          reactable::reactable(
            data = table_data,
            searchable = TRUE,
            sortable = TRUE,
            defaultPageSize = 10,
            resizable = TRUE,
            wrap = FALSE,
            highlight = TRUE,
            columns = list(
              ID = reactable::colDef(
                cell = function(value, index) {
                  name <- table_data$Name[index]
                  div(
                    div(value),
                    div(style = list(fontSize = "0.75rem"), name)
                  )
                }
              ),
              Price = reactable::colDef(format = reactable::colFormat(
                prefix = "Ksh. ",
                separators = TRUE,
                digits = 2
              )),
              Time = reactable::colDef(
                minWidth = 150
              ),
              Level = reactable::colDef(
                cell = function(value, index) {
                  type <- table_data$Type[index]
                  div(
                    div(value),
                    div(style = list(fontSize = "0.75rem"), type)
                  )
                }
              ),
              Name = reactable::colDef(show = FALSE),
              Type = reactable::colDef(show = FALSE),
              details = reactable::colDef(
                name = "",
                sortable = FALSE,
                align = "center",
                cell = function() {
                  htmltools::tags$button(
                    id = "",
                    class = "bi bi-three-dots-vertical border-0 bg-transparent mt-3",
                    `aria-hidden` = "true"
                  )
                }
              )
            ),
            theme = reactable::reactableTheme(
              borderColor = "#ddd",
              cellPadding = "8px",
              borderWidth = "1px",
              highlightColor = "#f0f0f0"
            ),
            onClick = reactable::JS("function(rowInfo, column) {
                     if (column.id !== 'details') {
                     return
                         }
                      Shiny.setInputValue('school_menu_details', { index: rowInfo.index + 1, info: rowInfo.values }, { priority: 'event' })
                      }")
          )
        })
      } else {
        # show empty status div
        show_empty_state_ui
      }
    })

    # output table for already exisiting teacher data
    output$teachers_data <- renderUI({
      # get the teachers data
      teachers_data <- rvs$teachers_data |>
        dplyr::arrange(desc(time)) |>
        dplyr::mutate(details = NA)

      colnames(teachers_data) <- c(
        "ID", "Name", "School", "Grade", "Phone",
        "Email", "Time", "Status", "Views", "details"
      )

      if (nrow(teachers_data) > 0) {
        output$table2 <- reactable::renderReactable({
          reactable::reactable(
            data = teachers_data,
            searchable = TRUE,
            sortable = TRUE,
            defaultPageSize = 10,
            resizable = TRUE,
            wrap = FALSE,
            highlight = TRUE,
            columns = list(
              ID = reactable::colDef(
                cell = function(value, index) {
                  name <- teachers_data$Name[index]
                  div(
                    div(value),
                    div(style = list(fontSize = "0.75rem"), name)
                  )
                }
              ),
              Phone = reactable::colDef(format = reactable::colFormat(
                prefix = "+254"
              )),
              Time = reactable::colDef(
                minWidth = 150
              ),
              School = reactable::colDef(
                cell = function(value, index) {
                  grade <- teachers_data$Grade[index]
                  div(
                    div(value),
                    div(style = list(fontSize = "0.75rem"), grade)
                  )
                }
              ),
              Name = reactable::colDef(show = FALSE),
              Grade = reactable::colDef(show = FALSE),
              details = reactable::colDef(
                name = "",
                sortable = FALSE,
                align = "center",
                cell = function() {
                  htmltools::tags$button(
                    id = "",
                    class = "bi bi-three-dots-vertical border-0 bg-transparent mt-3",
                    `aria-hidden` = "true"
                  )
                }
              )
            ),
            theme = reactable::reactableTheme(
              borderColor = "#ddd",
              cellPadding = "8px",
              borderWidth = "1px",
              highlightColor = "#f0f0f0"
            ),
            onClick = reactable::JS("function(rowInfo, column) {
                     if (column.id !== 'details') {
                     return
                         }
                      Shiny.setInputValue('teacher_menu_details', { index: rowInfo.index + 1, info: rowInfo.values }, { priority: 'event' })
                      }")
          )
        })
      } else {
        # show empty status div
        show_empty_state_ui
      }
    })

    # output table for already exisiting students data
    output$students_data <- renderUI({
      # get the student data
      students_data <- rvs$students_data |>
        dplyr::arrange(desc(time)) |>
        dplyr::mutate(details = NA)

      colnames(students_data) <- c(
        "ID", "Name", "School", "Grade", "Phone",
        "Email", "Time", "Status", "Paid", "details"
      )

      if (nrow(students_data) > 0) {
        output$table3 <- reactable::renderReactable({
          reactable::reactable(
            data = students_data,
            searchable = TRUE,
            sortable = TRUE,
            defaultPageSize = 10,
            resizable = TRUE,
            wrap = FALSE,
            highlight = TRUE,
            columns = list(
              ID = reactable::colDef(
                cell = function(value, index) {
                  name <- students_data$Name[index]
                  div(
                    div(value),
                    div(style = list(fontSize = "0.75rem"), name)
                  )
                }
              ),
              Paid = reactable::colDef(
                cell = function(value) {
                  if (value == "0") "\u274c" else "\u2714\ufe0f"
                }
              ),
              Phone = reactable::colDef(format = reactable::colFormat(
                prefix = "+254"
              )),
              Time = reactable::colDef(
                minWidth = 150
              ),
              School = reactable::colDef(
                cell = function(value, index) {
                  grade <- students_data$Grade[index]
                  div(
                    div(value),
                    div(style = list(fontSize = "0.75rem"), grade)
                  )
                }
              ),
              Name = reactable::colDef(show = FALSE),
              Grade = reactable::colDef(show = FALSE),
              details = reactable::colDef(
                name = "",
                sortable = FALSE,
                align = "center",
                cell = function() {
                  htmltools::tags$button(
                    id = "",
                    class = "bi bi-three-dots-vertical border-0 bg-transparent mt-3",
                    `aria-hidden` = "true"
                  )
                }
              )
            ),
            theme = reactable::reactableTheme(
              borderColor = "#ddd",
              cellPadding = "8px",
              borderWidth = "1px",
              highlightColor = "#f0f0f0"
            ),
            onClick = reactable::JS("function(rowInfo, column) {
                     if (column.id !== 'details') {
                     return
                         }
                      Shiny.setInputValue('student_menu_details', { index: rowInfo.index + 1, info: rowInfo.values }, { priority: 'event' })
                      }")
          )
        })
      } else {
        # show empty status div
        show_empty_state_ui
      }
    })

    # update teachers depending on selected school
    teachers_data <- rvs$teachers_data |>
      data.table::as.data.table()

    observeEvent(input$doc_school, {
      req(input$doc_school != "")
      req(nrow(teachers_data) > 0)

      name <- input$doc_school
      req(isTruthy(name))


      choices <- teachers_data[
        school_name == name,
        .(user_name, grade)
      ]

      shinyWidgets::updatePickerInput(
        session = session,
        inputId = "doc_teacher",
        choices = unique(choices$user_name),
        choicesOpt = list(
          subtext = unique(choices$grade)
        )
      )
    })

    # update a teacher grades
    observeEvent(input$doc_teacher, {
      req(isTruthy(input$doc_teacher))

      name <- input$doc_teacher

      choices <- teachers_data[
        user_name == name,
        .(grade)
      ]
      grade <- strsplit(choices$grade, ", ")[[1]] |>
        as.numeric()

      shinyWidgets::updatePickerInput(
        session = session,
        inputId = "doc_grade",
        choices = setNames(grade, paste("Grade", grade)),
      )
    })


    output$pdf_data <- renderUI({
      # get the teachers data
      pdf_data <- rvs$pdf_data |>
        dplyr::arrange(desc(time)) |>
        dplyr::mutate(details = NA)

      colnames(pdf_data) <- c(
        "ID", "Name", "Teacher", "Grade", "Learning Area",
        "Topic", "Sub Topic", "Time", "Status", "Views", "details"
      )

      if (nrow(pdf_data) > 0) {
        output$table4 <- reactable::renderReactable({
          reactable::reactable(
            data = pdf_data,
            searchable = TRUE,
            sortable = TRUE,
            defaultPageSize = 10,
            resizable = TRUE,
            wrap = FALSE,
            highlight = TRUE,
            columns = list(
              ID = reactable::colDef(
                cell = function(value, index) {
                  name <- pdf_data$Name[index]
                  div(
                    div(value),
                    div(style = list(fontSize = "0.75rem"), name)
                  )
                }
              ),
              Time = reactable::colDef(
                minWidth = 150
              ),
              Status = reactable::colDef(
                align = "center",
                cell = function(value) {
                  if (value == "Available") "\U1F7E2" else "\U1F534"
                }
              ),
              Teacher = reactable::colDef(
                cell = function(value, index) {
                  grade <- pdf_data$Grade[index]
                  div(
                    div(value),
                    div(style = list(fontSize = "0.75rem"), grade)
                  )
                }
              ),
              Name = reactable::colDef(show = FALSE),
              Grade = reactable::colDef(show = FALSE),
              details = reactable::colDef(
                name = "",
                sortable = FALSE,
                align = "center",
                cell = function() {
                  htmltools::tags$button(
                    id = "",
                    class = "bi bi-chevron-right border-0 bg-transparent mt-3",
                    `aria-hidden` = "true"
                  )
                }
              )
            ),
            theme = reactable::reactableTheme(
              borderColor = "#ddd",
              cellPadding = "8px",
              borderWidth = "1px",
              highlightColor = "#f0f0f0"
            ),
            onClick = reactable::JS("function(rowInfo, column) {
                     if (column.id !== 'details') {
                     return
                         }
                      Shiny.setInputValue('pdf_menu_details', { index: rowInfo.index + 1, info: rowInfo.values }, { priority: 'event' })
                      }")
          )
        })
      } else {
        # show empty status div
        show_empty_state_ui
      }
    })

    # show user payments status
    output$payments_data <- renderUI({
      # get the payments data
      payments_data <- rvs$payments_data |>
        dplyr::arrange(desc(time)) |>
        dplyr::select(-term) |>
        dplyr::mutate(details = NA)

      colnames(payments_data) <- c(
        "Ticket ID", "Student ID", "Code", "Amount",
        "Balance", "Total paid", "Number", "Time", "Status", "details"
      )

      if (nrow(payments_data) > 0) {
        output$table5 <- reactable::renderReactable({
          reactable::reactable(
            data = payments_data,
            searchable = TRUE,
            sortable = TRUE,
            defaultPageSize = 10,
            resizable = TRUE,
            wrap = FALSE,
            highlight = TRUE,
            columns = list(
              Number = reactable::colDef(format = reactable::colFormat(
                prefix = "+254"
              )),
              Time = reactable::colDef(
                minWidth = 150
              ),
              Status = reactable::colDef(
                style = function(status) {
                  color <- dplyr::case_when(
                    status == "DECLINED" ~ "#e00000",
                    status == "PENDING" ~ "#50BD8C",
                    status == "APPROVED" ~ "#008000",
                    .default = "#163142"
                  )
                  list(color = color, fontWeight = "bold")
                }
              ),
              details = reactable::colDef(
                name = "",
                sortable = FALSE,
                align = "center",
                cell = function() {
                  htmltools::tags$button(
                    id = "",
                    class = "bi bi-three-dots-vertical border-0 bg-transparent mt-3",
                    `aria-hidden` = "true"
                  )
                }
              )
            ),
            theme = reactable::reactableTheme(
              borderColor = "#ddd",
              cellPadding = "8px",
              borderWidth = "1px",
              highlightColor = "#f0f0f0"
            ),
            onClick = reactable::JS("function(rowInfo, column) {
                     if (column.id !== 'details') {
                     return
                         }
                      Shiny.setInputValue('student_payments_details', { index: rowInfo.index + 1, info: rowInfo.values }, { priority: 'event' })
                      }")
          )
        })
      } else {
        # show empty status div
        show_empty_state_ui
      }
    })

    # create validations
    ivp$add_rule("transaction_code", shinyvalidate::sv_required())
    ivp$add_rule("payment_tel_number", shinyvalidate::sv_required())
    ivp$add_rule("amount", shinyvalidate::sv_required())
    ivp$add_rule("payment_time", shinyvalidate::sv_required())

    # add rule on mobile number
    ivp$add_rule("payment_tel_number", function(value) {
      phone_number <- gsub("\\D", "", value) # Remove non-digit characters
      if (nchar(phone_number) != 9) {
        return("Phone number must be 9 digits")
      }
      return(NULL) # Return NULL if validation passes
    })
    ivp$add_rule("transaction_code", function(value) {
      # Check if the length
      if (!grepl("^[A-Za-z0-9]{10}$", value)) {
        return("Transaction code must be 10 characters")
      }
      return(NULL) # Return NULL if validation passes
    })

    output$payments_tickets_data <- reactable::renderReactable({
      # Filter and arrange the data as needed
      data <- rvs$payments_data |>
        dplyr::filter(user_id == signed_user$id) |>
        dplyr::select(-c(user_id, total, balance)) |>
        dplyr::arrange(desc(time))

      # Set the column names
      colnames(data) <- c(
        "Ticket ID", "Code", " Amount", "Number", "Time", "Term", "Status"
      )
      # Create a reactable with customization
      reactable::reactable(
        data,
        searchable = TRUE,
        sortable = TRUE,
        defaultPageSize = 10,
        highlight = TRUE,
        wrap = FALSE,
        resizable = TRUE,
        bordered = TRUE,
        columns = list(
          Status = reactable::colDef(
            style = function(status) {
              color <- dplyr::case_when(
                status == "DECLINED" ~ "#e00000",
                status == "PENDING" ~ "#50BD8C",
                status == "APPROVED" ~ "#008000",
                .default = "#163142"
              )
              list(color = color, fontWeight = "bold")
            }
          )
        ),
        theme = reactable::reactableTheme(
          borderColor = "#ddd",
          cellPadding = "8px",
          borderWidth = "1px",
          highlightColor = "#f0f0f0"
        )
      )
    })


    # Actions for logout button
    observeEvent(input$log_out_session, {
      # Sign user out
      session$reload()
    })
  })

  #---- TEACHER REQUESTS ----

  observeEvent(input$photo_file, {
    req(input$photo_file)
    new_file <- list(
      name = input$photo_file$name,
      datapath = input$photo_file$datapath
    )
    current_files <- uploaded_request_files()
    uploaded_request_files(c(current_files, list(new_file)))
  })

  output$file_list_ui <- renderUI({
    files <- uploaded_request_files()
    if (length(files) == 0) {
      return(NULL)
    }

    file_ui <- lapply(seq_along(files), function(i) {
      file <- files[[i]]
      # Create a unique ID for each remove button
      div(
        class = "d-flex justify-content-center",
        column(4, p(file$name)),
        column(2, tags$button(
          id = paste0("remove_", i),
          class = "text-red",
          style = "border: none; background: transparent;",
          onclick = sprintf("Shiny.setInputValue('delete_file', %d, {priority: 'event'});", i),
          icon("trash")
        ))
      )
    })

    do.call(tagList, file_ui)
  })

  observeEvent(input$delete_file, {
    file_to_remove <- as.numeric(input$delete_file)
    if (!is.na(file_to_remove)) {
      files <- uploaded_request_files()
      if (file_to_remove <= length(files)) {
        files <- files[-file_to_remove]
        uploaded_request_files(files)
      }
    }
  })

  observeEvent(input$show_details, {
    details <- input$show_details$info

    req_files <- list.files(
      path = "www/requests",
      pattern = paste0("^", details$ID, "-"),
      full.names = TRUE
    )

    download_buttons <- lapply(seq_along(req_files), function(i) {
      file_name <- basename(req_files[i])
      downloadButton(
        outputId = paste0("download_", i),
        label = file_name,
        class = "mb-2 text-white bg-default"
      ) |>
        download_btn()
    })

    showModal(
      modalDialog(
        easyClose = TRUE,
        title = paste("Details for", details$ID),
        footer = NULL,
        div(
          class = "pb-3",
          tags$p("Download images:", class = "text-bold"),
          div(
            class = "d-flex flex-wrap gap-2",
            download_buttons
          )
        ),
        div(
          class = "pb-3",
          tags$p("More details:", class = "text-bold"),
          tags$p(details$`Additional info`)
        ),
        div(
          tags$p("Change request status", class = "text-bold"),
          shinyWidgets::pickerInput(
            inputId = "edit_request_status",
            label = NULL,
            width = "300px",
            choices = c("PROCESSING", "CANCELLED")
          )
        ),
        div(
          class = "d-flex justify-content-end mt-3 modal-footer",
          actionButton(
            inputId = "change_request_status",
            label = "",
            icon = icon("check"),
            class = "btn-circle"
          ) |> basic_primary_btn()
        )
      )
    )


    if (details$Status != "PENDING") {
      shinyjs::disable("edit_request_status")
      shinyjs::disable("change_request_status")
    }

    lapply(seq_along(req_files), function(i) {
      local({
        my_i <- i
        my_file <- req_files[my_i]
        output[[paste0("download_", my_i)]] <- downloadHandler(
          filename = function() {
            basename(my_file)
          },
          content = function(file) {
            file.copy(my_file, file)
          }
        )
      })
    })

    signed_admin_user <- rvs$administrators_data |>
      dplyr::filter(input_col == user_details$email)
    record_admin_action(
      user = signed_admin_user$value,
      action = "View",
      description = paste("Viewed details for", details$ID)
    )
  })

  observeEvent(input$change_request_status, {
    details <- input$show_details$info

    update <- update_request_status(
      request_id = details$ID,
      new_status = input$edit_request_status
    )
    if (update) {
      alert_success_ui(
        info = "Status updated...",
        session = session
      )
      rvs$requests_data <- refresh_table_data("requests")
      signed_admin_user <- rvs$administrators_data |>
        dplyr::filter(input_col == user_details$email)
      record_admin_action(
        user = signed_admin_user$value,
        action = "Update",
        description = paste(
          "Updated", details$ID, "status to",
          input$edit_request_status
        )
      )
      teacher_data <- rvs$requests_data |>
        dplyr::filter(id == details$ID) |>
        dplyr::left_join(rvs$teachers_data, by = c("teacher_id" = "id"))

      teacher_email <- teacher_data |>
        dplyr::select(email) |>
        dplyr::pull()
      teacher_name <- teacher_data |>
        dplyr::select(user_name) |>
        dplyr::pull()
      first_name <- strsplit(teacher_name, " ")[[1]][1]
      email_salutation <- email_salutation(first_name)
      send_email_notification(
        receipients = teacher_email,
        subject = "Request Status Update",
        body = email_body_template(
          heading = "",
          salutation = email_salutation,
          body = updated_request_body(
            details$ID, input$edit_request_status
          ),
          footer = external_email_footer
        )
      )
    } else {
      alert_fail_ui(
        info = "An error occured...",
        session = session
      )
    }
    removeModal()
  })


  # monitor network connectivity
  observeEvent(input$network_status, {
    if (input$network_status == "offline") {
      alert_warn_ui(
        info = "Oops! You are disconnected...",
        session = session,
        timer = 0
      )
    } else {
      alert_success_ui(
        info = "You are now connected...",
        session = session,
        timer = 0
      )
    }
  })

  # observe upload button click
  observeEvent(input$upload_btn, {
    ivs$enable() # enable validation check
    req(ivs$is_valid()) # ensure checks are valid

    # Create a reactable table with the input values
    table_html <- reactable::reactable(
      data = data.frame(
        Input = c(
          "PDF File", "Teacher", "Grade",
          "Learning Area", "Topic", "Sub Topic"
        ),
        Value = stringr::str_trunc(
          c(
            stringr::str_to_title(input$pdfFile$name),
            input$doc_teacher_id,
            input$doc_grade,
            input$doc_learning_area,
            input$doc_topic,
            input$doc_sub_topic
          ),
          width = 25
        )
      ),
      columns = list(
        Input = reactable::colDef(name = "Input"),
        Value = reactable::colDef(name = "Value")
      ),
      borderless = TRUE,
      bordered = FALSE,
      striped = FALSE,
      outlined = TRUE,
      wrap = FALSE,
      class = "text-gray-dark"
    )

    # Show confirmation dialog with reactable table
    shinyalert::shinyalert(
      session = session,
      inputId = "confirm_pdf_details",
      title = NULL,
      text = tags$div(
        table_html
      ),
      showCancelButton = TRUE,
      confirmButtonCol = "#163142",
      html = TRUE
    )
  })

  # Observe file upload and save the PDF
  observeEvent(input$confirm_pdf_details, {
    shinybusy::show_spinner()
    shinyjs::disable("upload_btn")
    # if has confirmed details
    if (input$confirm_pdf_details) {
      if (!dir.exists("www/pdf")) dir.create("www/pdf", recursive = TRUE)
      if (!dir.exists("www/images")) dir.create("www/images", recursive = TRUE)
      pdf_path <- file.path(
        "www/pdf",
        input$pdfFile$name
      )

      teacher_details <- rvs$teachers_data |>
        dplyr::filter(id == input$doc_teacher_id)

      teacher_name <- teacher_details |>
        dplyr::select(user_name) |>
        unlist() |>
        as.vector()
      teacher_email <- teacher_details |>
        dplyr::select(email) |>
        unlist() |>
        as.vector()
      teacher_school <- teacher_details |>
        dplyr::select(school_name) |>
        unlist() |>
        as.vector()

      data <- data.frame(
        id = next_pdf_id("content"),
        pdf_name = input$pdfFile$name,
        teacher = teacher_name,
        grade = input$doc_grade,
        learning_area = input$doc_learning_area,
        topic = input$doc_topic,
        sub_topic = input$doc_sub_topic,
        time = format(Sys.time(), format = "%Y-%m-%d %H:%M:%S"),
        status = "Available",
        views = 0
      )

      success <- add_new_pdf(table_name = "content", data = data)

      # show alert after completing adding PDF
      if (success == 1) {
        # copy pdf to directory
        file.copy(input$pdfFile$datapath, pdf_path)
        update_request_status(
          request_id = input$doc_request,
          new_status = "APPROVED"
        )

        req_files <- list.files(
          path = "www/requests",
          pattern = paste0("^", input$doc_request, "-"),
          full.names = TRUE
        )
        file.remove(req_files)

        # Convert PDF to images
        pdf_to_image(
          pdf_path = pdf_path,
          file_name = input$pdfFile$name,
          output_dir = "www/images"
        )

        alert_success_ui(
          info = "New PDF uploaded successfully!",
          session = session
        )

        # refresh added data
        rvs$pdf_data <- refresh_table_data(table_name = "content")
        rvs$requests_data <- refresh_table_data(table_name = "requests")
        signed_admin_user <- rvs$administrators_data |>
          dplyr::filter(input_col == user_details$email)
        record_admin_action(
          user = signed_admin_user$value,
          action = "Upload",
          description = paste("Uploaded a new PDF:", data$id)
        )
        students_emails <- subset(
          rvs$students_data,
          grade == grade & school_name == teacher_school
        )$email

        for (email in students_emails) {
          student_name <- subset(rvs$students_data, email == email)$user_name
          first_name <- strsplit(student_name, " ")[[1]][1]
          send_email_notification(
            receipients = email,
            subject = "New Content Update",
            body = published_content_body(
              user = first_name,
              teacher_name = teacher_name,
              grade = data$grade,
              learning_area = data$learning_area,
              topic = data$topic,
              sub_topic = data$sub_topic
            )
          )
        }
        send_email_notification(
          receipients = teacher_email,
          subject = "New Content Update",
          body = published_content_body(
            user = strsplit(teacher_name, " ")[[1]][1],
            teacher_name = teacher_name,
            grade = data$grade,
            learning_area = data$learning_area,
            topic = data$topic,
            sub_topic = data$sub_topic
          )
        )
      } else {
        alert_fail_ui(info = "PDF Details already exist!", session = session)
      }
    } else {
      # if has declined to confirm
      alert_warn_ui(info = "Details not confirmed...", session = session)
    }
    shinyjs::enable("upload_btn")
  })

  # Observe confirm button
  observeEvent(input$confirmBtn, {
    # Create data to append
    schools_data <- data.frame(
      id = next_school_id("schools"),
      school_name = stringr::str_to_sentence(input$school_name),
      level = input$school_level,
      type = input$school_type,
      county = input$county,
      email = tolower(input$school_email),
      price = input$doc_price,
      time = format(Sys.time(), format = "%Y-%m-%d %H:%M:%S"),
      status = "Enabled",
      stringsAsFactors = FALSE
    )

    # Call the register_new_school function
    success <- register_new_school(
      table_name = "schools",
      data = schools_data
    )

    if (success == 1) {
      alert_success_ui(
        info = "New school created successfully!",
        session = session
      )
      # refresh added data
      rvs$schools_data <- refresh_table_data(table_name = "schools")
      signed_admin_user <- rvs$administrators_data |>
        dplyr::filter(input_col == user_details$email)
      record_admin_action(
        user = signed_admin_user$value,
        action = "Add",
        description = paste("Added a new school:", schools_data$id)
      )
    } else {
      alert_fail_ui(
        info = "Name or email already exists!",
        session = session
      )
    }

    shinyjs::addCssClass(
      id = "tab_buttons",
      class = "justify-content-end"
    )
    shinyjs::removeCssClass(
      id = "tab_buttons",
      class = "justify-content-between"
    )
    shinyjs::hide("tab_2")
    shinyjs::show("tab_1")
    shinyjs::hide(
      id = "confirmBtn"
    )
    shinyjs::hide(
      id = "prevBtn"
    )
    shinyjs::show(
      id = "nextBtn"
    )
  })

  # change the school status - Enabled/Disabled
  observeEvent(input$edit_school_status, {
    details <- input$school_menu_details$info
    old_status <- details$Status
    new_status <- input$edit_school_status
    valid <- (old_status == "Enabled" & new_status == FALSE) ||
      (old_status == "Disabled" & new_status == TRUE)

    req(!is.null(details))
    req(valid)
    confirm_text <- if (new_status) "enable" else "disable"
    shinyalert::closeAlert()

    shinyWidgets::ask_confirmation(
      session = session,
      inputId = "confirm_status",
      btn_colors = c("#50BD8C", "#163142"),
      title = NULL,
      text = paste(
        "Are you sure you want to",
        confirm_text,
        details$Name,
        details$Level,
        "?"
      ),
      btn_labels = c("Cancel", "Yes")
    )
  })

  observeEvent(input$confirm_status, {
    action <- input$confirm_status

    req(!is.null(action))
    details <- input$school_menu_details$info


    if (action) {
      new_status <- input$edit_school_status
      new_status <- if (new_status) "Enabled" else "Disabled"

      # Update status
      update_user_status(
        user_id = details$ID,
        table_name = "schools",
        new_status = new_status
      )
      # Refresh data
      rvs$schools_data <- refresh_table_data(table_name = "schools")
      confirm_message <- if (new_status == "Enabled") {
        "enabled..."
      } else {
        "disabled..."
      }

      alert_success_ui(
        position = "top-end",
        info = paste(details$Name, "has been", confirm_message),
        session = session
      )
      signed_admin_user <- rvs$administrators_data |>
        dplyr::filter(input_col == user_details$email)
      record_admin_action(
        user = signed_admin_user$value,
        action = "Update",
        description = paste(
          "Updated", details$ID, "status to",
          new_status
        )
      )
    } else {
      alert_warn_ui(
        position = "top-end",
        info = "Action has been cancelled!",
        session = session
      )
    }
  })

  # Delete a school record
  observeEvent(input$delete_school_btn, {
    details <- input$school_menu_details$info

    shinyWidgets::ask_confirmation(
      session = session,
      inputId = "confirm_delete",
      btn_colors = c("#50BD8C", "#163142"),
      title = NULL,
      text = paste(
        "Are you sure you want to delete",
        details$Name,
        details$Level,
        "?"
      ),
      btn_labels = c("Cancel", "Yes")
    )
  })

  # Edit button
  observeEvent(input$edit_school_btn, {
    details <- input$school_menu_details$info

    # Edit modal content
    html_content <- div(
      fluidRow(
        column(
          width = 3,
          textInput(
            inputId = "edit_school_name",
            label_mandatory("Name:"),
            value = details$Name,
            placeholder = "Eg. Lenga Juu"
          )
        ),
        column(
          width = 3,
          shinyWidgets::pickerInput(
            inputId = "edit_school_level",
            label = label_mandatory("Level:"),
            options = list(
              style = "btn-outline-light",
              title = "Eg. Primary"
            ),
            choices = c(
              "Preparatory", "Primary", "Junior Secondary",
              "Senior Secondary", "University/College", "Other"
            ),
            selected = details$Level
          )
        ),
        column(
          width = 3,
          shinyWidgets::pickerInput(
            inputId = "edit_school_type",
            label = label_mandatory("Type:"),
            options = list(
              style = "btn-outline-light",
              title = "Eg. Public"
            ),
            choices = c("Public", "Private", "Other"),
            selected = details$Type
          )
        ),
        column(
          width = 3,
          shinyWidgets::pickerInput(
            inputId = "edit_county",
            label = label_mandatory("County:"),
            options = list(
              title = "Eg. Nairobi",
              style = "btn-outline-light",
              size = 5,
              `live-search` = TRUE,
              `live-search-placeholder` = "Search county"
            ),
            choices = kenyan_counties,
            selected = details$County,
            autocomplete = TRUE
          )
        )
      ),
      fluidRow(
        column(
          width = 3,
          textInput(
            inputId = "edit_school_email",
            label_mandatory("Email:"),
            value = details$Email,
            placeholder = "Eg. johnwekesa@gmail.com"
          )
        ),
        column(
          width = 3,
          shinyWidgets::autonumericInput(
            inputId = "edit_doc_price",
            label_mandatory("Price:"),
            value = details$Price,
            currencySymbol = "Ksh ",
            decimalPlaces = 0,
            minimumValue = 500
          )
        )
      )
    )

    # Show the modal dialog with the HTML content
    showModal(modalDialog(
      title = details$ID,
      size = "xl",
      html_content,
      footer = tagList(
        modalButton("Cancel"),
        actionButton("save_changes", "Save changes") |>
          basic_primary_btn()
      )
    ))
  })

  observeEvent(input$save_changes, {
    # Show confirmation modal
    shinyWidgets::ask_confirmation(
      session = session,
      inputId = "confirm_edit_details",
      title = "Confirm edit",
      text = "Are you sure you want to update the school details?",
      btn_labels = c("Cancel", "Yes")
    )
  })

  observeEvent(input$confirm_edit_details, {
    action <- input$confirm_edit_details
    details <- input$school_menu_details$info

    if (action) {
      new_values <- list(
        school_name = input$edit_school_name,
        level = input$edit_school_level,
        type = input$edit_school_type,
        county = input$edit_county,
        email = input$edit_school_email,
        price = input$edit_doc_price
      )

      # Run the update function
      updated <- update_school_details(details$ID, new_values)
      if (!identical(updated, 0L)) {
        removeModal()
        return(
          alert_fail_ui(
            info = "An error occured!",
            session = session
          )
        )
      }

      # Close the confirmation modal
      removeModal()

      # Refresh data
      rvs$schools_data <- refresh_table_data(table_name = "schools")

      # Show success message
      alert_success_ui(
        info = "School details updated...",
        session = session
      )
      signed_admin_user <- rvs$administrators_data |>
        dplyr::filter(input_col == user_details$email)
      record_admin_action(
        user = signed_admin_user$value,
        action = "Update",
        description = paste(
          "Updated", details$ID, "details."
        )
      )
    } else {
      removeModal()
      alert_warn_ui(
        position = "top-end",
        info = "Action has been cancelled!",
        session = session
      )
    }
  })


  observeEvent(input$confirm_delete, {
    action <- input$confirm_delete
    details <- input$school_menu_details$info

    req(!is.null(action))

    if (action) {
      # Dlete school records
      delete_school_records(user_id = details$ID)
      # Refresh data
      rvs$schools_data <- refresh_table_data(table_name = "schools")

      alert_success_ui(
        position = "top-end",
        info = paste(details$Name, "has been deleted..."),
        session = session
      )
      signed_admin_user <- rvs$administrators_data |>
        dplyr::filter(input_col == user_details$email)
      record_admin_action(
        user = signed_admin_user$value,
        action = "Delete",
        description = paste(
          "Deleted", details$ID, "details."
        )
      )
    } else {
      alert_warn_ui(
        position = "top-end",
        info = "Action has been cancelled!",
        session = session
      )
    }
  })

  observeEvent(input$school_menu_details, {
    details <- input$school_menu_details$info
    html_content <- div(
      h5(paste(details$ID), ":", details$Name),
      div(
        class = "pt-2",
        shinyWidgets::materialSwitch(
          inputId = "edit_school_status",
          label = details$Status,
          value = ifelse(
            details$Status == "Enabled", TRUE, FALSE
          ),
          status = "success",
          right = TRUE,
          inline = TRUE
        ) |>
          modified_switch(),
        div(
          class = "row justify-content-center",
          actionButton(
            inputId = paste0("delete_school_btn"),
            label = "Delete",
            class = "bg-default mt-0"
          ),
          actionButton(
            inputId = paste0("edit_school_btn"),
            label = "Edit",
            class = "bg-default mt-0"
          ),
          actionButton(
            inputId = paste0("view_school_btn"),
            label = "Details",
            class = "bg-default mt-0"
          )
        )
      )
    )

    shinyalert::shinyalert(
      session = session,
      inputId = "edit_school_details",
      title = NULL,
      text = tags$div(
        html_content
      ),
      showCancelButton = TRUE,
      showConfirmButton = FALSE,
      html = TRUE
    )
  })

  # School details button
  observeEvent(input$view_school_btn, {
    details <- input$school_menu_details$info

    # Show the details modal dialog
    showModal(modalDialog(
      title = paste(details$ID, ":", details$Name),
      size = "l",
      reactable::reactableOutput("school_teachers_details"),
      footer = tagList(
        downloadButton(
          outputId = "download_school_payments",
          label = ""
        ),
        modalButton("Cancel")
      )
    ))
  })


  output$school_teachers_details <- reactable::renderReactable({
    details <- input$school_menu_details$info

    teacher_data_with_content <- create_school_payments(
      school_id = details$ID
    )

    # output data table:
    output_payments_data <- teacher_data_with_content |>
      dplyr::select(user_name, grade, per_share, paid_students, earnings)
    colnames(output_payments_data) <- c(
      "Name", "Grade", "% Share", "Paid students", "Earnings"
    )

    output$download_school_payments <- downloadHandler(
      filename = function() {
        paste(details$Name, "-", Sys.Date(), ".xlsx", sep = "")
      },
      content = function(file) {
        writexl::write_xlsx(teacher_data_with_content, file)
      }
    )
    reactable::reactable(
      data = output_payments_data,
      defaultPageSize = 10,
      outlined = TRUE,
      searchable = TRUE,
      wrap = FALSE,
      highlight = TRUE,
      theme = reactable::reactableTheme(
        borderColor = "#ddd",
        cellPadding = "8px",
        borderWidth = "1px",
        highlightColor = "#f0f0f0"
      ),
      groupBy = "Grade",
      onClick = "expand",
      columns = list(
        Grade = reactable::colDef(footer = "Total"),
        `% Share` = reactable::colDef(
          na = "–",
          format = reactable::colFormat(percent = TRUE, digits = 2)
        ),
        `Paid students` = reactable::colDef(
          aggregate = "unique",
          cell = function(value) {
            return("")
          },
          align = "center",
          footer = reactable::JS("function(column, state) {
    let total = 0;
    state.sortedData.forEach(function(row) {
      let value = parseFloat(row[column.id]);  // Convert to a number
      if (!isNaN(value)) {  // Ensure the value is a valid number
        total += value;
      }
    });
    return total.toLocaleString();  // Return total as formatted number
  }"),
          footerStyle = htmltools::css(
            font_weight = 600,
            border_top = "2px solid black"
          )
        ),
        Earnings = reactable::colDef(
          aggregate = "sum",
          footer = reactable::JS("function(column, state) {
          let total = 0
          state.sortedData.forEach(function(row) {
            total += row[column.id]
          })
          return 'Ksh ' + total.toLocaleString('en-US', { minimumFractionDigits: 2, maximumFractionDigits: 2 })
        }"),
          format = reactable::colFormat(
            prefix = "Ksh ",
            digits = 2,
            separators = TRUE
          ),
          footerStyle = htmltools::css(
            font_weight = 600,
            border_top = "2px solid black"
          )
        )
      ),
      rowStyle = reactable::JS(
        "function(rowInfo) {
        if (rowInfo && rowInfo.level == 0) {
          return {
            background: '#16314214',
            borderLeft: '2px solid #50BD8C',
            fontWeight: 600
          }
        }
        return {};
      }"
      ),
      defaultColDef = reactable::colDef(
        footerStyle = list(fontWeight = "bold")
      )
    )
  })

  observeEvent(input$teacher_menu_details, {
    details <- input$teacher_menu_details$info
    html_content <- div(
      h5(paste(details$ID), ":", details$Name),
      div(
        class = "pt-4",
        shinyWidgets::materialSwitch(
          inputId = "edit_teacher_status",
          label = details$Status,
          value = ifelse(
            details$Status == "Enabled", TRUE, FALSE
          ),
          status = "success",
          right = TRUE,
          inline = TRUE
        ) |>
          modified_switch()
      )
    )

    shinyalert::shinyalert(
      session = session,
      inputId = "edit_teacher_details",
      title = NULL,
      text = tags$div(
        html_content
      ),
      showCancelButton = TRUE,
      showConfirmButton = FALSE,
      html = TRUE
    )
  })

  # change teacher status - Enabled/Disabled
  observeEvent(input$edit_teacher_status, {
    details <- input$teacher_menu_details$info
    old_status <- details$Status
    new_status <- input$edit_teacher_status
    valid <- (old_status == "Enabled" & new_status == FALSE) ||
      (old_status == "Disabled" & new_status == TRUE)

    req(!is.null(details))
    req(valid)
    confirm_text <- if (new_status) "enable" else "disable"
    shinyalert::closeAlert()

    shinyWidgets::ask_confirmation(
      session = session,
      inputId = "confirm_teacher_status",
      btn_colors = c("#50BD8C", "#163142"),
      title = NULL,
      text = paste(
        "Are you sure you want to",
        confirm_text,
        details$Name,
        "?"
      ),
      btn_labels = c("Cancel", "Yes")
    )
  })

  observeEvent(input$confirm_teacher_status, {
    action <- input$confirm_teacher_status

    req(!is.null(action))
    details <- input$teacher_menu_details$info


    if (action) {
      new_status <- input$edit_teacher_status
      new_status <- if (new_status) "Enabled" else "Disabled"

      # Update status
      update_user_status(
        table_name = "teachers",
        user_id = details$ID,
        new_status = new_status
      )
      # Refresh data
      rvs$teachers_data <- refresh_table_data(table_name = "teachers")
      confirm_message <- if (new_status == "Enabled") {
        "enabled..."
      } else {
        "disabled..."
      }

      alert_success_ui(
        position = "top-end",
        info = paste(details$Name, "has been", confirm_message),
        session = session
      )
      signed_admin_user <- rvs$administrators_data |>
        dplyr::filter(input_col == user_details$email)
      record_admin_action(
        user = signed_admin_user$value,
        action = "Update",
        description = paste(
          "Updated", details$ID, "status to", new_status
        )
      )
    } else {
      alert_warn_ui(
        position = "top-end",
        info = "Action has been cancelled!",
        session = session
      )
    }
  })

  observeEvent(input$student_menu_details, {
    details <- input$student_menu_details$info
    html_content <- div(
      h5(paste(details$ID), ":", details$Name),
      div(
        class = "pt-4",
        shinyWidgets::materialSwitch(
          inputId = "edit_student_status",
          label = details$Status,
          value = ifelse(
            details$Status == "Enabled", TRUE, FALSE
          ),
          status = "success",
          right = TRUE,
          inline = TRUE
        ) |>
          modified_switch()
      )
    )

    shinyalert::shinyalert(
      session = session,
      inputId = "edit_student_details",
      title = NULL,
      text = tags$div(
        html_content
      ),
      showCancelButton = TRUE,
      showConfirmButton = FALSE,
      html = TRUE
    )
  })

  # change student status - Enabled/Disabled
  observeEvent(input$edit_student_status, {
    details <- input$student_menu_details$info
    old_status <- details$Status
    new_status <- input$edit_student_status
    valid <- (old_status == "Enabled" & new_status == FALSE) ||
      (old_status == "Disabled" & new_status == TRUE)

    req(!is.null(details))
    req(valid)
    confirm_text <- if (new_status) "enable" else "disable"
    shinyalert::closeAlert()

    shinyWidgets::ask_confirmation(
      session = session,
      inputId = "confirm_student_status",
      btn_colors = c("#50BD8C", "#163142"),
      title = NULL,
      text = paste(
        "Are you sure you want to",
        confirm_text,
        details$Name,
        "?"
      ),
      btn_labels = c("Cancel", "Yes")
    )
  })

  observeEvent(input$confirm_student_status, {
    action <- input$confirm_student_status

    req(!is.null(action))
    details <- input$student_menu_details$info

    if (action) {
      # Update status
      new_status <- input$edit_student_status
      new_status <- if (new_status) "Enabled" else "Disabled"

      update_user_status(
        table_name = "students",
        user_id = details$ID,
        new_status = new_status
      )
      # Refresh data
      rvs$students_data <- refresh_table_data(table_name = "students")
      confirm_message <- if (new_status == "Enabled") "enabled..." else "disabled..."

      alert_success_ui(
        position = "top-end",
        info = paste(details$Name, "has been", confirm_message),
        session = session
      )

      signed_admin_user <- rvs$administrators_data |>
        dplyr::filter(input_col == user_details$email)
      record_admin_action(
        user = signed_admin_user$value,
        action = "Update",
        description = paste(
          "Updated", details$ID, "status to", new_status
        )
      )
    } else {
      alert_warn_ui(
        position = "top-end",
        info = "Action has been cancelled!",
        session = session
      )
    }
  })

  iva <- shinyvalidate::InputValidator$new()
  iva$add_rule("term_label", shinyvalidate::sv_required())
  iva$add_rule("term_end_date", shinyvalidate::sv_required())

  observeEvent(input$set_term_end, {
    iva$enable() # enable validation check
    req(iva$is_valid()) # ensure checks are valid

    shinyWidgets::ask_confirmation(
      session = session,
      inputId = "confirm_set_end_date",
      btn_colors = c("#50BD8C", "#163142"),
      title = "Set new term",
      text = paste(
        "Current payments will be reset on",
        input$term_end_date,
        "?"
      ),
      btn_labels = c("Cancel", "Yes")
    )
  })

  observeEvent(input$confirm_set_end_date, {
    action <- input$confirm_set_end_date
    req(!is.null(action))

    if (action) {
      added <- add_term_end(
        term_end_date = input$term_end_date
      )
      if (added == 2) {
        alert_success_ui(
          session = session,
          info = "Term end date updated"
        )
        data <- refresh_table_data("administrator")
        values <- data |>
          dplyr::select(value) |>
          as.vector()

        output$term_end_table <- renderUI({
          p(
            paste("Current term", values$value[2], "ends on", values$value[1]),
            class = "px-2"
          )
        })

        signed_admin_user <- rvs$administrators_data |>
          dplyr::filter(input_col == user_details$email)

        record_admin_action(
          user = signed_admin_user$value,
          action = "Update",
          description = paste(
            "Updated term end date to", input$term_end_date
          )
        )
      } else {
        alert_fail_ui(
          session = session,
          info = "An error occured..."
        )
      }
    }
  })

  output$term_end_table <- renderUI({
    data <- rvs$administrators_data
    values <- data |>
      dplyr::select(value) |>
      as.vector()

    if (is.na(values$value[1]) || is.na(values$value[2])) {
      p("Welcome Administrator. Create your first term")
    } else {
      p(
        paste("Current term", values$value[2], "ends on", values$value[1]),
        class = "px-2"
      )
    }
  })

  observeEvent(input$term_end_date, {
    term_end_date <- input$term_end_date
    current_month <- toupper(format(Sys.Date(), "%b"))
    end_month <- toupper(format(as.Date(term_end_date), "%b"))
    current_year <- format(as.Date(term_end_date), "%Y")
    term_label <- paste(current_month, end_month, current_year, sep = "-")

    updateTextInput(
      inputId = "term_label",
      value = term_label
    )
  })

  observeEvent(input$pdf_menu_details, {
    details <- input$pdf_menu_details$info
    bslib::toggle_sidebar(
      id = "card_sidebar",
      session = session
    )

    status <- details$Status
    label <- ifelse(status == "Available", "Flag", "Unflag")

    shinyjs::show("card_sidebar")

    output$sidebar_content <- renderUI({
      div(
        p(
          class = "text-bold",
          paste(details$ID, details$Name)
        ),
        div(
          class = "d-flex justify-content-between
                 align-items-center",
          actionButton(
            inputId = "flag_pdf",
            label = label
          ) |>
            basic_primary_btn(),
          actionButton(
            inputId = "edit_content_details",
            label = "Edit"
          ) |>
            basic_primary_btn()
        )
      )
    })
  })

  observeEvent(input$flag_pdf, {
    details <- input$pdf_menu_details$info

    status <- details$Status
    label <- ifelse(status == "Available", "Flag", "Unflag")

    shinyWidgets::ask_confirmation(
      session = session,
      inputId = "confirm_flag_action",
      btn_colors = c("#50BD8C", "#163142"),
      title = NULL,
      text = paste(
        "Are you sure you want to",
        tolower(label),
        details$ID, ":",
        details$Name,
        "?"
      ),
      btn_labels = c("Cancel", "Yes")
    )
  })

  observeEvent(input$confirm_flag_action, {
    action <- input$confirm_flag_action

    req(!is.null(action))
    details <- input$pdf_menu_details$info
    status <- details$Status

    if (action) {
      # Update status
      new_status <- ifelse(status == "Available", "Flagged", "Available")
      update_user_status(
        user_id = details$ID,
        table_name = "content",
        new_status = new_status
      )
      # Refresh data
      rvs$pdf_data <- refresh_table_data(table_name = "content")
      message <- ifelse(status == "Available", "flagged", "unflagged")

      alert_success_ui(
        position = "top-end",
        info = paste(details$Name, "has been", message),
        session = session
      )
      signed_admin_user <- rvs$administrators_data |>
        dplyr::filter(input_col == user_details$email)
      record_admin_action(
        user = signed_admin_user$value,
        action = "Flag",
        description = paste(
          "Flagged", details$ID, "status to", new_status
        )
      )
    } else {
      alert_warn_ui(
        position = "top-end",
        info = "Action has been cancelled!",
        session = session
      )
    }
  })


  observeEvent(input$edit_content_details, {
    details <- input$pdf_menu_details$info
    teacher_name <- details$Teacher

    teacher_grades <- rvs$teachers_data |>
      dplyr::filter(user_name == teacher_name) |>
      dplyr::select(grade) |>
      unlist() |>
      as.vector()

    grades <- strsplit(teacher_grades, ", ")[[1]] |> as.numeric()

    # Show the modal with the current details prefilled
    showModal(
      modalDialog(
        size = "xl",
        title = paste(details$ID, ":", details$Name),
        fluidRow(
          column(
            width = 3,
            shinyWidgets::pickerInput(
              inputId = "edit_pdf_grade",
              label = label_mandatory("Grade:"),
              choices = setNames(grades, paste("Grade", grades)),
              selected = details$Grade,
              options = list(size = 3)
            )
          ),
          column(
            width = 3,
            shinyWidgets::pickerInput(
              inputId = "edit_learning_area",
              label = label_mandatory("Search a Learning Area:"),
              choices = learning_areas,
              selected = details$`Learning Area`,
              options = list(
                size = 5,
                title = "Eg. Creative Arts",
                `live-search` = TRUE,
                `live-search-placeholder` = "Type here..."
              ),
            )
          ),
          column(
            width = 3,
            shiny::textInput(
              inputId = "edit_pdf_topic",
              label = label_mandatory("Topic:"),
              value = details$Topic,
              placeholder = "Eg. Addition"
            )
          ),
          column(
            width = 3,
            shiny::textInput(
              inputId = "edit_pdf_sub_topic",
              label = label_mandatory("Sub-topic:"),
              value = details$`Sub Topic`,
              placeholder = "Eg. Long division method"
            )
          )
        ),
        footer = tagList(
          modalButton("Cancel"),
          actionButton("save_content_changes", "Save Changes") |>
            basic_primary_btn()
        )
      )
    )
  })

  # add validation rules
  ivpe <- shinyvalidate::InputValidator$new()
  ivpe$add_rule("edit_pdf_grade", shinyvalidate::sv_required())
  ivpe$add_rule("edit_learning_area", shinyvalidate::sv_required())
  ivpe$add_rule("edit_pdf_sub_topic", shinyvalidate::sv_required())
  ivpe$add_rule("edit_pdf_topic", shinyvalidate::sv_required())

  observeEvent(input$save_content_changes, {
    ivpe$enable() # enable validation check
    req(ivpe$is_valid()) # ensure checks are valid

    table_html <- reactable::reactable(
      data = data.frame(
        Input = c(
          "Grade", "Learning Area", "Topic",
          "Sub Topic"
        ),
        Value = stringr::str_trunc(
          c(
            input$edit_pdf_grade,
            input$edit_learning_area,
            stringr::str_to_sentence(
              input$edit_pdf_topic
            ),
            stringr::str_to_sentence(
              input$edit_pdf_sub_topic
            )
          ),
          width = 25
        )
      ),
      columns = list(
        Input = reactable::colDef(name = "Input"),
        Value = reactable::colDef(name = "Value")
      ),
      borderless = TRUE,
      bordered = FALSE,
      striped = FALSE,
      outlined = TRUE,
      wrap = FALSE,
      class = "text-gray-dark",
      resizable = FALSE
    )
    # Show confirmation modal
    shinyWidgets::ask_confirmation(
      session = session,
      inputId = "confirm_edit_pdf_details",
      title = "Confirm edit",
      text = tags$div(
        table_html
      ),
      btn_labels = c("Cancel", "Yes"),
      html = TRUE
    )
  })

  observeEvent(input$confirm_edit_pdf_details, {
    details <- input$pdf_menu_details$info

    if (input$confirm_edit_pdf_details) {
      update <- update_pdf_details(
        pdf_id = details$ID,
        grade = input$edit_pdf_grade,
        learning_area = input$edit_learning_area,
        topic = input$edit_pdf_topic,
        sub_topic = input$edit_pdf_sub_topic
      )

      if (update) {
        alert_success_ui(
          info = "PDF details updated...",
          session = session
        )

        rvs$pdf_data <- refresh_table_data("content")
        signed_admin_user <- rvs$administrators_data |>
          dplyr::filter(input_col == user_details$email)
        record_admin_action(
          user = signed_admin_user$value,
          action = "Update",
          description = paste(
            "Updated", details$ID, "details"
          )
        )
      } else {
        alert_fail_ui(
          info = "An error occured...",
          session = session
        )
      }
      removeModal()
    } else {
      # if has declined to confirm
      alert_warn_ui(
        info = "Details not confirmed...",
        session = session
      )
    }
  })

  observeEvent(input$create_ticket, {
    ivp$enable() # enable validation check
    req(ivp$is_valid()) # ensure checks are valid

    # Create a reactable table with the input values
    table_html <- reactable::reactable(
      data.frame(
        Input = c("Transaction Code", "Amount", "Number", "Time"),
        Value = c(
          stringr::str_to_upper(input$transaction_code),
          input$amount,
          input$payment_tel_number,
          format(
            lubridate::as_datetime(input$payment_time), "%-d/%-m/%y %-I:%M %p"
          )
        )
      ),
      columns = list(
        Input = reactable::colDef(name = "Input"),
        Value = reactable::colDef(name = "Value")
      ),
      borderless = TRUE,
      bordered = FALSE,
      striped = FALSE,
      outlined = TRUE,
      wrap = FALSE,
      resizable = TRUE,
      class = "text-gray-dark"
    )

    # Show confirmation dialog with reactable table
    shinyWidgets::ask_confirmation(
      session = session,
      inputId = "confirm_ticket_details",
      title = "Confirm your payment details",
      text = tags$div(
        table_html
      ),
      btn_labels = c("Cancel", "Yes"),
      html = TRUE
    )
  })


  # Observe ticket confirmation
  observeEvent(input$confirm_ticket_details, {
    shinybusy::show_spinner()
    shinyjs::disable("create_ticket")
    # if has confirmed details
    signed_email <- user_details$email
    student_data <- rvs$students_data |>
      dplyr::filter(email == signed_email)

    if (input$confirm_ticket_details) {
      data <- rvs$administrators_data
      values <- data |>
        dplyr::select(value) |>
        as.vector()

      unique_ticket_id <- paste0(
        "#",
        toupper(
          substr(uuid::UUIDgenerate(), 1, 8)
        )
      )


      # Create data to append
      payment_data <- data.frame(
        ticket_id = unique_ticket_id,
        user_id = student_data$id,
        code = stringr::str_to_upper(input$transaction_code),
        amount = input$amount,
        balance = 0,
        total = 0,
        number = input$payment_tel_number,
        time = format(
          lubridate::as_datetime(input$payment_time), "%-d/%-m/%y %-I:%M %p"
        ),
        term = values$value[2],
        status = "PENDING",
        stringsAsFactors = FALSE
      )

      # Call the register_new_school function
      success <- create_payment_ticket(
        table_name = "payments",
        data = payment_data
      )

      if (success == 1) {
        alert_success_ui(
          info = "Payment ticket created successfully!",
          session = session
        )
        # refresh added data
        rvs$payments_data <- refresh_table_data(
          table_name = "payments"
        )
      } else {
        alert_fail_ui(
          info = "Ticket already existing...", session = session
        )
      }
    } else {
      # if has declined to confirm
      alert_warn_ui(
        info = "Details not confirmed...",
        session = session
      )
    }
    shinyjs::enable("create_ticket")
  })

  observeEvent(input$student_payments_details, {
    details <- input$student_payments_details$info

    showModal(
      modalDialog(
        easyClose = TRUE,
        title = paste("Approval for ticket", details$Code),
        footer = NULL,
        div(
          tags$p("Change payment status", class = "text-bold"),
          shinyWidgets::pickerInput(
            inputId = "edit_payment_status",
            label = NULL,
            width = "300px",
            choices = c("APPROVED", "DECLINED")
          )
        ),
        div(
          class = "d-flex justify-content-end mt-3 modal-footer",
          actionButton(
            inputId = "change_payment_status",
            label = "",
            icon = icon("check"),
            class = "btn-circle"
          ) |>
            basic_primary_btn()
        )
      )
    )

    if (details$Status != "PENDING") {
      shinyjs::disable("edit_payment_status")
      shinyjs::disable("change_payment_status")
    }
  })

  observeEvent(input$change_payment_status, {
    details <- input$student_payments_details$info
    earlier_pending_tickets <- rvs$payments_data |>
      dplyr::filter(status == "PENDING" &
        user_id == details$`Student ID` &
        time < details$Time)
    if (nrow(earlier_pending_tickets) > 0) {
      alert_warn_ui(
        timer = 0,
        session = session,
        info = paste(
          "Approve earlier tickets first:",
          paste(as.vector(earlier_pending_tickets$ticket_id), collapse = ", ")
        )
      )
    } else {
      student_data <- rvs$students_data |>
        dplyr::filter(id == details$`Student ID`)

      data <- rvs$administrators_data
      values <- data |>
        dplyr::select(value) |>
        as.vector()
      term_end_date <- values$value[1] |> as.Date()

      price <- rvs$schools_data |>
        dplyr::filter(school_name == student_data$school_name) |>
        dplyr::select(price) |>
        as.numeric()

      paid_amount <- rvs$payments_data |>
        dplyr::filter(status == "APPROVED" &
          user_id == details$`Student ID` &
          term == values$value[2]) |>
        dplyr::select(amount) |>
        unlist() |>
        as.numeric() |>
        sum()

      if (input$edit_payment_status == "APPROVED") {
        total_paid <- paid_amount + as.numeric(details$Amount)

        balance <- price - total_paid

        update <- update_payments_status(
          ticket_id = details$`Ticket ID`,
          new_status = input$edit_payment_status,
          balance = balance,
          total = total_paid,
          student_id = student_data$id
        )

        update
      } else {
        balance <- price - paid_amount

        update <- update_payments_status(
          ticket_id = details$`Ticket ID`,
          new_status = input$edit_payment_status,
          balance = balance,
          total = paid_amount,
          student_id = student_data$id
        )
        update
      }

      if (update) {
        alert_success_ui(
          info = "Status updated...",
          session = session
        )
        rvs$payments_data <- refresh_table_data("payments")
        signed_admin_user <- rvs$administrators_data |>
          dplyr::filter(input_col == user_details$email)
        record_admin_action(
          user = signed_admin_user$value,
          action = "Update",
          description = paste(
            "Updated", details$`Ticket ID`, " payment status to", input$edit_payment_status
          )
        )
        first_name <- strsplit(student_data$user_name, " ")[[1]][1]
        send_email_notification(
          receipients = student_data$email,
          subject = "Payment Notification",
          body = updated_payments_body(
            user = first_name,
            ticket_no = details$`Ticket ID`,
            amount = paid_amount,
            payment_status = input$edit_payment_status
          )
        )
      } else {
        alert_fail_ui(
          info = "An error occured...",
          session = session
        )
      }
    }

    removeModal()
  })

  observeEvent(input$refresh_payments, {
    rvs$payments_data <- refresh_table_data("payments")
    last_refresh_time <- Sys.time()

    alert_success_ui(
      info = "Records updated...",
      session = session
    )
    auto_invalidate <- reactiveTimer(60000)

    observe({
      auto_invalidate()

      output$payments_refresh_time <- renderText({
        paste(
          "Last refresh:", round(difftime(Sys.time(), last_refresh_time, units = "mins")), "minute(s) ago"
        )
      })
    })
  })

  observeEvent(input$refresh_requests, {
    rvs$requests_data <- refresh_table_data("requests")
    last_refresh_time <- Sys.time()

    alert_success_ui(
      info = "Records updated...",
      session = session
    )
    auto_invalidate <- reactiveTimer(60000)

    observe({
      auto_invalidate()

      output$requests_refresh_time <- renderText({
        paste(
          "Last refresh:", round(difftime(Sys.time(), last_refresh_time, units = "mins")), "minute(s) ago"
        )
      })
    })
  })

  observeEvent(input$refresh_timeline, {
    initial_data <- load_data(current_page(1), 10)
    initial_ui <- timeline_block(initial_data)
    removeUI(selector = "div#timeline_cards", multiple = TRUE)
    insertUI(selector = "#end", where = "beforeBegin", ui = initial_ui)


    last_refresh_time <- Sys.time()

    output$timeline_refresh_time <- renderText({
      paste("Last refresh:", format(last_refresh_time, format = "%Y-%m-%d %H:%M:%S"))
    })
    alert_success_ui(
      info = "Records updated...",
      session = session
    )
    auto_invalidate <- reactiveTimer(60000)

    observe({
      auto_invalidate()

      output$timeline_refresh_time <- renderText({
        paste(
          "Last refresh:", round(difftime(Sys.time(), last_refresh_time, units = "mins")), "minute(s) ago"
        )
      })
    })
  })

  # Timeline output ------
  # Keep track of current page
  current_page <- reactiveVal(1)
  loading <- reactiveVal(FALSE)

  # all my pages are 10 rows each
  page_size <- 10

  # Render UI for timeline
  timeline_block <- function(data) {
    unique_dates <- unique(data$DateOnly)

    lapply(seq_along(unique_dates), function(i) {
      current_date <- unique_dates[i]

      current_data <- data[data$DateOnly == current_date, ]
      tags$div(
        id = "timeline_cards",
        `data-aos` = "fade-up",
        `data-aos-delay` = "100",
        class = "timeline",
        tags$div(
          class = "figure shadow text-bold rounded p-2 bg-gray mb-5",
          format(current_date, "%d-%m-%Y")
        ),
        lapply(seq_len(nrow(current_data)), function(j) {
          action_icon <- current_data$action[j]
          icon_lookup <- c(
            "Insert" = "bi-plus-circle-fill",
            "Update" = "bi-activity",
            "Approve" = "bi-check-circle-fill",
            "Add" = "bi-person-plus-fill",
            "Flag" = "bi-flag-fill",
            "Delete" = "bi-trash-fill",
            "Edit" = "bi-pencil-fill",
            "Download" = "bi-download",
            "View" = "bi-eye-fill",
            "Upload" = "bi-upload",
            "Decline" = "bi-x-circle-fill"
          )

          set_icon <- icon_lookup[[action_icon]]


          div(
            class = "timeline-item",
            id = "timeline_item",
            div(
              class = "timeline-icon shadow",
              tags$i(class = set_icon)
            ),
            div(
              class = "timeline-content",
              div(class = "timeline-title", action_icon),
              div(
                class = "timeline-time",
                current_data$TimeOnly[j], "-", current_data$user[j]
              ),
              current_data$description[j]
            )
          )
        })
      )
    })
  }

  load_data <- function(current_page, page_size) {
    offset <- (current_page - 1) * page_size
    db_name <- Sys.getenv("DATABASE_NAME")

    conn <- DBI::dbConnect(drv = RSQLite::SQLite(), dbname = db_name)
    on.exit(DBI::dbDisconnect(conn), add = TRUE)
    query <- sprintf("SELECT * FROM timeline
                    ORDER BY time DESC
                    LIMIT %d OFFSET %d", page_size, offset)

    data <- data.table::data.table(DBI::dbGetQuery(conn, query))

    if (nrow(data) == 0) {
      return(data.table::data.table())
    }

    # Convert 'time' column to POSIXct
    data$Date <- as.POSIXct(data$time, tz = "UTC")
    data[, DateOnly := as.Date(Date)]
    data[, TimeOnly := format(Date, "%H:%M:%S")]

    data
  }

  load_next_page <- function() {
    # Increment the page number
    current_page(current_page() + 1)
    next_page_data <- load_data(current_page(), 10)

    if (nrow(next_page_data) == 0) {
      shinyjs::show("empty")
    } else {
      data_ui <- timeline_block(next_page_data)
      insertUI(selector = "#end", where = "beforeBegin", ui = data_ui)
    }
    loading(FALSE)
  }

  output$loader <- renderUI({
    if (loading()) {
      tags$div("Loading more records...", class = "text-muted")
    } else {
      NULL
    }
  })

  observe({
    initial_data <- load_data(current_page(), page_size)
    initial_ui <- timeline_block(initial_data)
    insertUI(selector = "#end", where = "beforeBegin", ui = initial_ui)
    shinyjs::runjs('
        $(document).click(function(event) {
          if (!$(event.target).closest("#feedback_panel").length) {
            $("#feedback_panel").hide();
          }
        });
      ')
  })

  observeEvent(input$scrollToBottom, {
    if (!loading()) {
      loading(TRUE)
      load_next_page()
    }
  })


  observeEvent(
    list(
      input$s_privacy_policy_link,
      input$t_privacy_policy_link,
      input$privacy_link
    ),
    {
      session$sendCustomMessage("resetScroll", list())

      updateTabsetPanel(
        session = session,
        inputId = "app_pages",
        selected = "privacy_policy_page"
      )
      shinyjs::show("company_copyright")
    },
    ignoreInit = TRUE
  )

  observeEvent(
    list(
      input$s_terms_service_link,
      input$t_terms_service_link,
      input$tos
    ),
    {
      session$sendCustomMessage("resetScroll", list())
      updateTabsetPanel(
        session = session,
        inputId = "app_pages",
        selected = "tos_page"
      )
      shinyjs::show("company_copyright")
    },
    ignoreInit = TRUE
  )
  observeEvent(
    list(input$already_member, input$have_an_account),
    {
      updateTabsetPanel(
        session = session,
        inputId = "app_pages",
        selected = "auth_page"
      )
      shinyjs::hide("company_copyright")
    },
    ignoreInit = TRUE
  )

  observeEvent(input$receipient_group, {
    group <- input$receipient_group
    if (group != "") {
      admin_emails <- rvs$administrators_data |>
        dplyr::select(input_col) |>
        dplyr::filter(grepl("*@gmail\\.com$", input_col)) |>
        unlist() |>
        as.vector()

      email_map <- list(
        Students = rvs$students_data$email,
        Teachers = rvs$teachers_data$email,
        Administrators = admin_emails,
        Schools = rvs$schools_data$email
      )

      emails <- email_map[[group]]

      shinyWidgets::updatePickerInput(
        session = session,
        inputId = "select_receipient",
        choices = emails
      )

      group_templates <- list(
        Students = c("Payment reminders"),
        Teachers = c("Earnings Report"),
        Administrators = c("Financial statement"),
        Schools = NULL
      )
      template <- group_templates[[group]]

      shinyWidgets::updatePickerInput(
        session = session,
        inputId = "email_template",
        choices = template
      )
    }
  })

  observeEvent(input$push_emails, {
    req(input$select_receipient)
    template <- input$email_template

    receipient_emails <- input$select_receipient
    receipient_group <- input$receipient_group

    for (email in receipient_emails) {
      if (receipient_group == "Administrators") {
        receipient_name <- rvs$administrators_data |>
          dplyr::filter(grepl(email, input_col)) |>
          dplyr::pull(value)
      } else if (receipient_group == "Students") {
        receipient_name <- rvs$students_data |>
          dplyr::filter(grepl(email, user_name)) |>
          dplyr::pull(value)
      } else {
        receipient_name <- rvs$teachers_data |>
          dplyr::filter(grepl(email, user_name)) |>
          dplyr::pull(value)
      }

      first_name <- strsplit(receipient_name, " ")[[1]][1]
      email_salutation <- email_salutation(first_name)
    }

    if (input$email_template == "Financial statement") {
      financial_data <- rvs$payments_data |>
        dplyr::filter(status == "APPROVED") |>
        dplyr::group_by(term) |>
        dplyr::summarise(total_payments = sum(as.numeric(amount))) |>
        dplyr::rename(
          TERM = term,
          AMOUNT = total_payments
        ) |>
        dplyr::mutate(
          TEACHERS = AMOUNT * (1000 / 1500),
          MANAGERS = AMOUNT * (500 / 1500)
        ) |>
        janitor::adorn_totals() |>
        janitor::adorn_rounding(digits = 2)



      send_email_notification(
        receipients = receipient_emails,
        subject = paste(
          "Financial Statement as at",
          format(Sys.time(), "%Y-%m-%d %H:%M:%S")
        ),
        body = email_body_template(
          heading = "Financial Statement",
          salutation = email_salutation,
          pre_body_text = "Please find attached the financial status:",
          body = generate_html_table(data = financial_data, title = ""),
          footer = internal_email_footer
        )
      )
    }
    rvs$emails_data <- refresh_table_data(table_name = "emails")
  })

  # FEEDBACK
  active_button <- reactiveVal(0)
  observeEvent(
    list(input$contact_us, input$open_chat),
    {
      showModal(
        # The absolutePanel for feedback form
        absolutePanel(
          id = "feedback_panel",
          class = "panel-class",
          fixed = TRUE,
          draggable = TRUE,
          top = "20%",
          left = "50%",
          style = "transform: translateX(-50%); padding: 20px; background: white; border-radius: 10px; box-shadow: 0px 4px 8px rgba(0, 0, 0, 0.2); z-index: 1050;",

          # Close button (X)
          actionButton(
            inputId = "close_feedback_panel",
            label = "",
            icon = icon("times"),
            style = "position: absolute; top: 0px; right: 10px; background-color: transparent; border: none; font-size: 20px; color: #999;"
          ),

          # Your feedback form UI elements
          div(
            class = "card-body",
            div(
              class = "text-center mb-3",
              style = "font-size: 16px; font-weight: bold; color: #163142;",
              "CALL US ON ",
              span(
                "0111672464",
                style = "font-weight: bold; color: #50BD8C;"
              ),
              " or fill the form below:"
            ),
            shinyWidgets::pickerInput(
              inputId = "feedback_user_type",
              label = label_mandatory("You are a:"),
              options = list(
                style = "btn-outline-light",
                title = "Eg. Student",
                maxOptions = 3
              ),
              choices = c("Student", "Teacher", "School", "Other")
            ),
            textInput(
              inputId = "feedback_email",
              label = label_mandatory("Contact Address:"),
              placeholder = "Email address or Phone number"
            ),
            radioButtons(
              inputId = "feedback_type",
              label = label_mandatory("Type of Feedback:"),
              choices = c("Suggestion", "Complaint", "Inquiry", "Other"),
              inline = TRUE
            ),
            textAreaInput(
              inputId = "feedback_text",
              label = label_mandatory("Your inquiry (200 words max):"),
              placeholder = "Write your inquiry, complaint or suggestion here",
              rows = 5
            ),
            p("Rate Your Experience"),
            # Emoji Rating
            div(
              id = "emoji_panel",
              style = "text-align: center;",
              lapply(1:5, function(i) {
                actionButton(
                  inputId = paste0("rating_", i),
                  label = emoji::emoji(c("cry", "confused", "neutral_face", "smile", "star-struck")[i]),
                  style = "font-size: 30px; background-color: transparent; border: none;",
                  class = "emoji-btn"
                )
              })
            ),
            hr(),
            div(
              class = "d-flex justify-content-center",
              actionButton(
                inputId = "feedback_submit_btn",
                label = "Submit",
                icon = icon("paper-plane")
              ) |>
                basic_primary_btn()
            )
          )
        )
      )
    },
    ignoreInit = TRUE
  )

  lapply(1:5, function(i) {
    observeEvent(input[[paste0("rating_", i)]], {
      active_button(i)
      shinyjs::runjs(sprintf(
        "$('.emoji-btn').css('background-color', 'transparent'); // Reset all
         $('#rating_%d').css('background-color', '#F0F0F0'); // Highlight selected",
        i
      ))
    })
  })

  ivf$add_rule("feedback_user_type", shinyvalidate::sv_required())
  ivf$add_rule("feedback_type", shinyvalidate::sv_required())
  ivf$add_rule("feedback_text", shinyvalidate::sv_required())
  ivf$add_rule("feedback_email", shinyvalidate::sv_email())

  observeEvent(input$feedback_submit_btn, {
    ivf$enable()
    req(ivf$is_valid())
    shinyjs::disable("feedback_submit_btn")

    # Capture form data
    feedback_data <- data.frame(
      user = input$feedback_user_type,
      email = input$feedback_email,
      type = input$feedback_type,
      message = input$feedback_text,
      timestamp = Sys.time(),
      rating = active_button(),
      stringsAsFactors = FALSE
    )

    # Append the data to Google Sheet
    tryCatch(
      {
        googlesheets4::sheet_append(sheet_url, feedback_data)
        alert_success_ui(
          info = "Feedback submitted.",
          session = session
        )
      },
      error = function(err) {
        alert_fail_ui(
          info = "Please try again later.",
          session = session
        )
      }
    )
    removeModal()
    shinyjs::enable("feedback_submit_btn")
  })

  observeEvent(input$close_feedback_panel, {
    shiny::removeModal()
  })
  # show failed emails:
  output$emails_table <- renderUI({
    # Get the emails data:
    emails_data <- rvs$emails_data |>
      dplyr::arrange(desc(time)) |>
      dplyr::mutate(actions = NA)

    colnames(emails_data) <- c(
      "ID", "Sender", "Recipient", "Template", "Subject", "Time", "Actions"
    )

    if (nrow(emails_data) > 0) {
      output$table7 <- reactable::renderReactable({
        reactable::reactable(
          data = emails_data,
          searchable = TRUE,
          sortable = TRUE,
          defaultPageSize = 10,
          resizable = TRUE,
          wrap = FALSE,
          highlight = TRUE,
          columns = list(
            Template = reactable::colDef(show = FALSE),
            Time = reactable::colDef(
              minWidth = 150
            ),
            Actions = reactable::colDef(
              name = "Actions",
              sortable = FALSE,
              align = "center",
              cell = function(value, index) {
                email_id <- emails_data$ID[index]
                htmltools::tags$div(
                  htmltools::tags$button(
                    id = paste0("resend_", email_id),
                    class = "bi bi-arrow-repeat border-0 bg-transparent",
                    title = "Resend",
                    onclick = sprintf("Shiny.setInputValue('resend_email', {id: '%s'}, {priority: 'event'})", email_id)
                  ),
                  htmltools::tags$button(
                    id = paste0("view-", index),
                    class = "bi bi-eye border-0 bg-transparent",
                    title = "View"
                  ),
                  htmltools::tags$button(
                    id = paste0("delete_", email_id),
                    class = "bi bi-trash border-0 bg-transparent",
                    title = "Delete",
                    onclick = sprintf("Shiny.setInputValue('delete_email', {id: '%s'}, {priority: 'event'})", email_id)
                  )
                )
              }
            )
          ),
          theme = reactable::reactableTheme(
            borderColor = "#ddd",
            cellPadding = "8px",
            borderWidth = "1px",
            highlightColor = "#f0f0f0"
          ),
          onClick = reactable::JS("
      function(rowInfo, column) {
        if (column.id !== 'Actions') {
          return
        }
        const buttonType = event.target.className.includes('arrow-repeat') ? 'resend' : 'view';
        Shiny.setInputValue(buttonType, { index: rowInfo.index + 1, info: rowInfo.values }, { priority: 'event' });
      }
    ")
        )
      })
    } else {
      # show empty status div
      show_empty_state_ui
    }
  })

  observeEvent(input$resend_email, {
    email_id <- input$resend_email$id
    # Resend:
    resend <- resend_email(email_id)

    if (resend) {
      alert_success_ui(
        session = session,
        info = "Email resent"
      )
      rvs$emails_data <- refresh_table_data(table_name = "emails")
    } else {
      alert_fail_ui(
        session = session,
        info = "Email not resend"
      )
    }
  })

  observeEvent(input$view, {
    index <- input$view$index
    email_template <- rvs$emails_data[index, "template"]
    email_id <- rvs$emails_data[index, "id"]
    showModal(
      modalDialog(
        title = paste("Email", email_id),
        HTML(email_template),
        easyClose = TRUE,
        footer = NULL
      )
    )
  })

  observeEvent(input$delete_email, {
    email_id <- input$delete_email$id

    # Make SQLite connection
    db_name <- Sys.getenv("DATABASE_NAME")
    conn <- DBI::dbConnect(drv = RSQLite::SQLite(), db_name)
    on.exit(DBI::dbDisconnect(conn), add = TRUE)

    DBI::dbExecute(
      conn = conn,
      statement = "DELETE FROM emails WHERE id = :email_id",
      params = list(email_id = email_id)
    )
    alert_success_ui(
      session = session,
      info = "Email deleted"
    )
    rvs$emails_data <- refresh_table_data(table_name = "emails")
  })
}
