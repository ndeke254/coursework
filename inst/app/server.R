server <- function(input, output, session) {
    # make sqlite connection:
    conn <- DBI::dbConnect(
        drv = RSQLite::SQLite(),
        Sys.getenv("DATABASE_NAME")
    )

    # initialize fields validation
    iv <- InputValidator$new()
    ivs <- InputValidator$new()
    ivt <- InputValidator$new()
    ivp <- InputValidator$new()

    # Initialize reactive values
    rv <- reactiveValues(
        image_paths = NULL,
        current_page = 1,
        total_pages = 0,
        selected_pdf = NULL,
        pdf_paths = list()
    )

    # Create reactive values for tables
    rvs <- reactiveValues(
        message = NULL,
        school_data = dbReadTable(conn, "schools"),
        pdf_data = dbReadTable(conn, "content"),
        teachers_data = dbReadTable(conn, "teachers"),
        students_data = dbReadTable(conn, "students"),
        payments_data = dbReadTable(conn, "payments"),
        idx = NULL,
        status = NULL
    )
    on.exit(DBI::dbDisconnect(conn), add = TRUE)

    user_details <- mod_auth_server("auth")

    observeEvent(
        list(input$register_now, input$register_now_1),
        {
            updateTabsetPanel(
                inputId = "app_pages",
                selected = "reg_student_page"
            )
        },
        ignoreInit = TRUE
    )

    observeEvent(input$lets_partner, {
        updateTabsetPanel(
            inputId = "app_pages",
            selected = "reg_teacher_page"
        )
    })
    observeEvent(input$home_link, {
        updateTabsetPanel(
            inputId = "app_pages",
            selected = "company_website"
        )
        shinyjs::runjs("$('#home_section')[0].scrollIntoView({ behavior: 'smooth' });")
    })

    observeEvent(input$about_us_link, {
        updateTabsetPanel(
            inputId = "app_pages",
            selected = "company_website"
        )

        shinyjs::runjs("$('#about_us_section')[0].scrollIntoView({ behavior: 'smooth' });")
    })

    observeEvent(input$contact_us_link, {
        updateTabsetPanel(
            inputId = "app_pages",
            selected = "company_website"
        )

        shinyjs::runjs("$('#contact_us_section')[0].scrollIntoView({ behavior: 'smooth' });")
    })

    observeEvent(input$students_link, {
        updateTabsetPanel(
            session = session,
            inputId = "app_pages",
            selected = "reg_student_page"
        )
    })

    observeEvent(input$teachers_link, {
        updateTabsetPanel(
            session = session,
            inputId = "app_pages",
            selected = "reg_teacher_page"
        )
    })

    observeEvent(input$login_link, {
        updateTabsetPanel(
            session = session,
            inputId = "app_pages",
            selected = "auth_page"
        )
    })

    # Register a new teacher
    # add validation rules
    ivt <- InputValidator$new()
    ivt$add_rule("teacher_username", sv_required())
    ivt$add_rule("teacher_school", sv_required())
    ivt$add_rule("teacher_password", sv_required())
    ivt$add_rule("teacher_confirm_password", sv_required())

    ivt$add_rule("teacher_grades", sv_required())
    ivt$add_rule("teacher_tel_number", sv_required())
    ivt$add_rule("teacher_email", sv_email())
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
            return("Password must be at least 8 characters long")
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
                alert_fail_ui(session = session, info = "Password do not match")
            )
        }

        # Convert the vector of grades to a single string
        grades <- paste(input$teacher_grades, collapse = ", ")

        # get the available data
        available_data <- refresh_table_data(table_name = "teachers")

        # Create data to append
        new_user <- data.frame(
            id = next_user_id("teachers", "teacher"),
            user_name = stringr::str_to_title(input$teacher_username),
            school_name = input$teacher_school,
            grade = grades,
            phone = input$teacher_tel_number,
            email = input$teacher_email,
            status = "Enabled",
            views = 0
        )

        # Call the register_new_user function
        success <- register_new_user(table_name = "teachers", data = new_user)
        if (success == 1) {
            updateTabsetPanel(
                inputId = "app_pages",
                selected = "auth_page"
            )
            name <- stringr::word(input$teacher_username, 1)
            shinyalert(
                title = paste0(name, ", Welcome to Keytabu"),
                text = "You can now log in",
                type = "",
                inputId = "roles_alert",
                imageUrl = "logo/logo.png",
                imageWidth = 180,
                session = session,
                confirmButtonText = "OK",
                confirmButtonCol = "#1D2856"
            )

            # add user to firebase
            frbs::frbs_sign_up(input$teacher_email, input$teacher_password)
            # add user to polished
            polished::add_app_user(app_uid = app_uid, email = input$teacher_email)
            # get user details
            get_new_user <- polished::get_users(email = input$teacher_email)
            user_uid <- get_new_user$content$uid

            # add role to the user
            polished::add_user_role(user_uid = user_uid, role_name = "teacher")
        } else {
            alert_fail_ui(info = "Name or email or phone already exists!", session = session)
        }
    })

    # Register a new student
    # add validation rules
    ivst <- InputValidator$new()
    ivst$add_rule("student_username", sv_required())
    ivst$add_rule("student_school", sv_required())
    ivst$add_rule("student_grade", sv_required())
    ivst$add_rule("student_tel_number", sv_required())
    ivst$add_rule("student_email", sv_email())

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
            return("Password must be at least 8 characters long")
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
                alert_fail_ui(session = session, info = "Password do not match")
            )
        }
        # Convert the vector of grades to a single string
        grades <- paste(input$student_grade, collapse = ", ")

        # get the available data
        available_data <- refresh_table_data(table_name = "students")

        # Create data to append
        new_user <- data.frame(
            id = next_user_id("students", "student"),
            user_name = stringr::str_to_title(input$student_username),
            school_name = input$student_school,
            grade = grades,
            phone = input$student_tel_number,
            email = input$student_email,
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
            shinyalert(
                title = paste0(name, ", Welcome to Keytabu"),
                text = "You can now log in",
                type = "",
                inputId = "roles_alert",
                imageUrl = "logo/logo.png",
                imageWidth = 180,
                session = session,
                confirmButtonText = "OK",
                confirmButtonCol = "#1D2856"
            )

            # add user to firebase
            frbs::frbs_sign_up(input$student_email, input$student_password)
            # add user to polished
            polished::add_app_user(
                app_uid = app_uid,
                email = input$student_email
            )
            # get user details
            get_new_user <- polished::get_users(email = input$student_email)
            user_uid <- get_new_user$content$uid

            # add role to the user
            polished::add_user_role(
                user_uid = user_uid,
                role_name = "student"
            )
        } else {
            alert_fail_ui(
                info = "Name or email or phone already exists!",
                session = session
            )
        }
    })

    # now output signed user

    observe({
        if (isTruthy(user_details$email)) {
            # get signed user details
            signed_email <- user_details$email

            pol_signed_user <- polished::get_app_users(email = signed_email)
            user_uid <- pol_signed_user$content$user_uid

            # get roles
            user_role <- polished::get_user_roles(user_uid = user_uid)

            user_role <- user_role$content$role_name
            is_admin <- pol_signed_user$content$is_admin

            # get the DB details of signed user
            signed_user <- get_signed_user(signed_email, user_role)
            user_status <- signed_user$status
            user_name <- signed_user$user_name
            table <- data.frame(
                ID = signed_user$id,
                SCHOOL = signed_user$school_name,
                EMAIL = signed_user$email,
                PHONE = signed_user$phone
            )
            output$signed <- renderUI({
                reactable(
                    table,
                    borderless = TRUE,
                    bordered = FALSE,
                    striped = FALSE,
                    outlined = TRUE
                )
            })

            # show the user on profile
            output$signed_user <- renderText({
                if (length(user_name) == 0) {
                    return("Uknown")
                }
                user_name
            })

            # hide login link
            shinyjs::hide("login_link")
            shinyjs::hide("teachers_link")
            shinyjs::hide("students_link")
            shinyjs::show("user_profile_tab")

            observeEvent(input$signed_user_link, {
                if (is_admin) {
                    updateTabsetPanel(
                        inputId = "app_pages",
                        selected = "admin_page"
                    )
                    shinyjs::show("admin_page", anim = TRUE, animType = "fade")
                    return()
                } else if (user_role == "student") {
                    updateTabsetPanel(
                        inputId = "app_pages",
                        selected = "student_content"
                    )
                    shinyjs::show("published_pdfs", anim = TRUE, animType = "fade")
                    shinyjs::show("filters", anim = TRUE, animType = "fade")
                } else if (user_role == "teacher") {
                    updateTabsetPanel(
                        inputId = "app_pages",
                        selected = "teacher_content"
                    )
                    return()
                } else {
                    return()
                }
            })


            # Load existing PDFs and their cover images from the "pdf" folder on app initialization
            observe({
                pdf_files <- list.files("www/pdf", pattern = "\\.pdf$", full.names = TRUE)
                rv$pdf_paths <- lapply(pdf_files, function(pdf) {
                    cover_image <- file.path(
                        "www/images",
                        paste0(fs::path_ext_remove(basename(pdf)), "_page_1.png")
                    )
                    list(pdf = pdf, cover = cover_image)
                })
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
                    shinyjs::show("admin_page", anim = TRUE, animType = "fade")
                } else if (user_role == "student") {
                    updateTabsetPanel(
                        inputId = "app_pages",
                        selected = "student_content"
                    )

                    # Filter the student content based on the signed-in user's grade and school
                    student_content <- rvs$pdf_data %>%
                        filter(grade == signed_user$grade &
                            school_name == signed_user$school_name)

                    # Initialize reactive values
                    rvts <- reactiveValues(data = student_content)

                    # Update picker inputs with unique values from the filtered data
                    updateSelectizeInput(
                        session = session,
                        inputId = "filter_teacher",
                        choices = unique(student_content$teacher)
                    )
                    updateSelectizeInput(
                        session = session,
                        inputId = "filter_learning_area",
                        choices = unique(student_content$learning_area)
                    )
                    updateSelectizeInput(
                        session = session,
                        inputId = "filter_topic",
                        choices = unique(student_content$topic)
                    )
                    updateSelectizeInput(
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

                    # Function to update filtered data based on picker inputs
                    update_filtered_data <- function() {
                        # List of columns to filter
                        columns <- c("teacher", "learning_area", "topic", "sub_topic")

                        for (col in columns) {
                            selected_values <- input[[paste0("filter_", col)]]

                            if (!is.null(selected_values) && length(selected_values) > 0) {
                                filtered_data <- student_content |> dplyr::filter(get(col) %in% selected_values)
                                return(filtered_data)
                            }
                        }

                        student_content
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
                                teacher_data <- filter(filtered_data, teacher == !!s_teacher)
                                teacher_data <- arrange(teacher_data, desc(time))

                                # Check if the user has paid for the year
                                user_paid <- signed_user %>%
                                    select(paid) %>%
                                    pull(paid) %>%
                                    as.character()

                                # Set payment status
                                pay_status <- ifelse(user_paid == "0", "has-danger", "has-success")
                                div(
                                    class = "d-flex flex-wrap justify-content-center",
                                    lapply(1:nrow(teacher_data), function(i) {
                                        pdf_info <- teacher_data[i, ]
                                        pdf_name_filtered <- fs::path_ext_remove(basename(pdf_info$pdf_name))
                                        table_html <- reactable(
                                            data = data.frame(
                                                Input = c("Teacher", "Learning Area", "Topic", "Sub Topic"),
                                                Value = stringr::str_trunc(
                                                    c(
                                                        stringr::str_to_title(input$pdfFile$name),
                                                        pdf_info$teacher,
                                                        pdf_info$learning_area,
                                                        pdf_info$topic,
                                                        pdf_info$sub_topic
                                                    ),
                                                    width = 25
                                                )
                                            ),
                                            columns = list(
                                                Input = colDef(name = "Item"),
                                                Value = colDef(name = "Details")
                                            ),
                                            borderless = TRUE,
                                            bordered = FALSE,
                                            striped = FALSE,
                                            outlined = TRUE,
                                            wrap = FALSE
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
                                            "images/default_cover.png"
                                        )

                                        # Create PDF card
                                        div(
                                            class = "                                    card shadow w-25 mt-2
                                        mx-2 hover-card",
                                            div(
                                                id = paste("card", i),
                                                class = "d-flex justify-content-center",
                                                onclick = sprintf(
                                                    "Shiny.setInputValue('selected_pdf', '%s'); Shiny.setInputValue('trigger_modal', Math.random());",
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


                    observeEvent(input$go_back_btn, {
                        shinyjs::hide("selected_pdf_frame", anim = TRUE, animType = "fade")
                        shinyjs::show("published_pdfs", anim = TRUE, animType = "fade")
                        shinyjs::show("filters", anim = TRUE, animType = "fade")
                    })

                    observeEvent(input$trigger_modal, {
                        # check if user has paid
                        user_paid <- signed_user |>
                            select(paid) |>
                            pull(paid) |>
                            as.character()

                        user_school <- rvs$school_data |>
                            filter(
                                school_name == signed_user$school_name
                            )
                        price <- prettyNum(user_school$price, big.mark = ",")
                        if (user_paid == "0") {
                            return(
                                shinyalert(
                                    title = "Subscription expired",
                                    text = paste(
                                        "Please renew your subscription of KES", price
                                    ),
                                    type = "",
                                    inputId = "pay_alert",
                                    imageUrl = "images/mpesa_poster.jpg",
                                    imageWidth = 180,
                                    session = session,
                                    confirmButtonText = "PAY",
                                    confirmButtonCol = "#1D2856",
                                    callbackR = function() {
                                        session$sendCustomMessage(
                                            type = "update-tabs",
                                            message = "payments"
                                        )
                                    }
                                )
                            )
                        }
                    })


                    # Observe selection change and update image paths
                    observeEvent(input$selected_pdf, {
                        shinybusy::show_spinner()

                        req(input$selected_pdf)
                        shinyjs::hide("published_pdfs", anim = TRUE, animType = "fade")
                        shinyjs::show("selected_pdf_frame", anim = TRUE, animType = "fade")
                        shinyjs::hide("filters", anim = TRUE, animType = "fade")


                        output$selected_pdf_frame <- renderUI({
                            div(
                                div(
                                    class = "position-fixed mt-5 mx-5",
                                    actionButton(
                                        inputId = "go_back_btn",
                                        label = "",
                                        icon = icon("arrow-left")
                                    )
                                ),
                                tags$iframe(
                                    class = "pt-3",
                                    src = file.path("pdf", input$selected_pdf, "#toolbar=0"),
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
                    grade <- strsplit(signed_user$grade, ", ")[[1]] |>
                        as.numeric()
                    updateSelectizeInput(
                        session = session,
                        inputId = "request_grade",
                        choices = setNames(grade, paste("Grade", grade))
                    )
                    updateSelectizeInput(
                        session = session,
                        inputId = "request_learning_area",
                        choices = c(
                            pre_primary,
                            lower_primary,
                            upper_primary,
                            junior_secondary
                        )
                    )

                    observeEvent(input$request_btn, {
                        photos <- input$photo_file
                        table_html <- reactable(
                            data = data.frame(
                                Input = c(
                                    "No. photos", "Grade", "Learning Area", "Topic", "Sub Topic"
                                ),
                                Value = stringr::str_trunc(
                                    c(
                                        nrow(photos),
                                        input$request_grade,
                                        input$request_learning_area,
                                        input$request_topic,
                                        input$request_sub_topic
                                    ),
                                    width = 25
                                )
                            ),
                            columns = list(
                                Input = colDef(name = "Input"),
                                Value = colDef(name = "Value")
                            ),
                            borderless = TRUE,
                            bordered = FALSE,
                            striped = FALSE,
                            outlined = TRUE,
                            wrap = FALSE,
                            resizable = FALSE
                        )

                        # Show confirmation dialog with reactable table
                        shinyalert(
                            session = session,
                            inputId = "confirm_request_details",
                            title = NULL,
                            text = tags$div(
                                table_html
                            ),
                            #              btn_labels = c("Cancel", "Yes"),
                            html = TRUE
                        )
                    })
                } else if (user_role == "developer") {
                } else {
                    return()
                }
            }
        }



        # add validation rules
        ivs$add_rule("pdfFile", sv_required())
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

        ivs$add_rule("doc_school", sv_required())
        ivs$add_rule("doc_teacher", sv_required())
        ivs$add_rule("doc_grade", sv_required())
        ivs$add_rule("doc_learning_area", sv_required())
        ivs$add_rule("doc_topic", sv_required())
        ivs$add_rule("doc_sub_topic", sv_required())

        # Update field choices
        observe({
            if (nrow(rvs$school_data) > 0) {
                updateSelectizeInput(
                    session = session,
                    inputId = "doc_school",
                    choices = unique(rvs$school_data$school_name)
                )
                updateSelectizeInput(
                    session = session,
                    inputId = "student_school",
                    choices = unique(rvs$school_data$school_name)
                )
                updateSelectizeInput(
                    session = session,
                    inputId = "teacher_school",
                    choices = unique(rvs$school_data$school_name)
                )

                updateSelectizeInput(
                    session = session,
                    inputId = "doc_learning_area",
                    choices = c(
                        pre_primary,
                        lower_primary,
                        upper_primary,
                        junior_secondary
                    )
                )

                # hide card sidebar content to allow click first
                shinyjs::hide("card_sidebar")
            }
        })

        # observe upload button click
        observeEvent(input$upload_btn, {
            ivs$enable() # enable validation check
            req(ivs$is_valid()) # ensure checks are valid

            # Create a reactable table with the input values
            table_html <- reactable(
                data = data.frame(
                    Input = c(
                        "PDF File", "School", "Teacher", "Grade",
                        "Learning Area", "Topic", "Sub Topic"
                    ),
                    Value = stringr::str_trunc(
                        c(
                            stringr::str_to_title(input$pdfFile$name),
                            input$doc_school,
                            input$doc_teacher,
                            input$doc_grade,
                            input$doc_learning_area,
                            input$doc_topic,
                            input$doc_sub_topic
                        ),
                        width = 25
                    )
                ),
                columns = list(
                    Input = colDef(name = "Input"),
                    Value = colDef(name = "Value")
                ),
                borderless = TRUE,
                bordered = FALSE,
                striped = FALSE,
                outlined = TRUE,
                wrap = FALSE,
                resizable = TRUE
            )

            # Show confirmation dialog with reactable table
            shinyalert(
                session = session,
                inputId = "confirm_pdf_details",
                title = NULL,
                text = tags$div(
                    table_html
                ),
                #              btn_labels = c("Cancel", "Yes"),
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
                pdf_path <- file.path("www/pdf", input$pdfFile$name)

                data <- data.frame(
                    id = next_pdf_id("content"),
                    school_name = input$doc_school,
                    pdf_name = input$pdfFile$name,
                    teacher = input$doc_teacher,
                    grade = input$doc_grade,
                    learning_area = input$doc_learning_area,
                    topic = input$doc_topic,
                    sub_topic = input$doc_sub_topic,
                    time = format(Sys.time(), format = "%Y-%m-%d %H:%M:%S"),
                    views = 0
                )

                success <- add_new_pdf(table_name = "content", data = data)

                # show alert after completing adding PDF
                if (success == 1) {
                    # copy pdf to directory
                    file.copy(input$pdfFile$datapath, pdf_path)

                    # Convert PDF to images
                    image_paths <- pdf_to_image(
                        pdf_path = pdf_path,
                        file_name = input$pdfFile$name,
                        output_dir = "www/images"
                    )

                    # Update reactive pdf paths
                    rv$pdf_paths <- c(
                        list(
                            list(
                                pdf = pdf_path,
                                cover = image_paths[[1]]
                            )
                        ),
                        rv$pdf_paths
                    )

                    alert_success_ui(
                        info = "New PDF uploaded successfully!", session = session
                    )

                    # refresh added data
                    rvs$pdf_data <- refresh_table_data(table_name = "content")
                } else {
                    alert_fail_ui(info = "PDF Details already exist!", session = session)
                }
            } else {
                # if has declined to confirm
                alert_warn_ui(info = "Details not confirmed...", session = session)
            }
            shinyjs::enable("upload_btn")
        })

        # output uploaded pdf files in a table
        output$pdf_data <- renderUI({
            # get the school data
            pdf_data <- rvs$pdf_data
            if (nrow(pdf_data) > 0 & length(rv$pdf_paths) > 0) {
                argonTable(
                    headTitles = c(
                        "ID", "Teacher", "Grade", "Learning Area", "Sub Topic",
                        "Time", ""
                    ),
                    lapply(1:nrow(pdf_data), function(i) {
                        file_info <- rv$pdf_paths[[i]]
                        argonTableItems(
                            argonTableItem(
                                div(
                                    class = "d-flex",
                                    argonAvatar(
                                        size = "sm",
                                        src = sub("^www/", "", file_info$cover)
                                    ),
                                    div(
                                        class = "d-flex flex-column justify-content-center px-2",
                                        h6(class = "mb-0 text-xs", pdf_data$id[i]),
                                        p(
                                            class = "text-truncate w-75 text-xs text-default mb-0",
                                            pdf_data$pdf_name[i]
                                        )
                                    )
                                )
                            ),
                            argonTableItem(
                                div(
                                    p(class = "text-xs font-weight-bold mb-0", pdf_data$teacher[i]),
                                    p(class = "text-xs text-default mb-0", pdf_data$school_name[i])
                                )
                            ),
                            argonTableItem(pdf_data$grade[i]),
                            argonTableItem(
                                div(
                                    h6(
                                        class = "text-xs mb-0 text-truncate w-75",
                                        pdf_data$learning_area[i]
                                    ),
                                    p(class = "text-xs mb-0", pdf_data$topic[i])
                                )
                            ),
                            argonTableItem(pdf_data$sub_topic[i]),
                            argonTableItem(pdf_data$time[i]),
                            argonTableItem(
                                actionButton(
                                    inputId = paste0("pdf_btn_", i),
                                    label = "",
                                    icon = argonIcon("bold-right"),
                                    size = "sm",
                                    status = "secondary",
                                    outline = TRUE,
                                    flat = TRUE,
                                    class = "btn-link bg-transparent border-0",
                                    onclick = sprintf("Shiny.setInputValue('pdf_button', '%s');", i)
                                )
                            )
                        )
                    })
                )
            } else {
                # show empty status div
                show_empty_state_ui
            }
        })

        # Observe actions on the PDF table
        observeEvent(input$pdf_button, {
            idx <- as.numeric(input$pdf_button)
            rvs$idx <- idx
            bslib::toggle_sidebar(id = "card_sidebar", open = TRUE, session = session)

            shinyjs::show("card_sidebar")

            table_data <- rvs$pdf_data

            output$sidebar_content <- renderUI({
                div(
                    h4(paste("Details for", table_data$id[idx])),
                    p(paste("Viewed:", sample(550:1200, 1))),
                    p(paste("Bought:", sample(100:400, 1))),
                    p(paste("Cart:", sample(15:100, 1))),
                    p(paste("Income: Ksh.", sample(2708:5047, 1))),
                    p(paste("Trend:", "Increasing traffic")),
                    div(
                        id = "buttons_pdf",
                        class = "d-flex justify-content-between",
                        actionButton("edit_btn", "", icon = icon("pencil")) |>
                            basic_primary_btn(),
                        actionButton("delete_btn", "", icon = icon("trash")) |>
                            basic_primary_btn()
                    )
                )
            })
        })

        # observe edit button - change price
        observeEvent(input$edit_btn, {
            insertUI(
                ui = div(
                    class = "pt-3",
                    knobInput(
                        inputId = "my_knob",
                        label = "Adjust %  price:",
                        value = 0,
                        min = -99,
                        displayPrevious = TRUE,
                        bgColor = "#428BCA",
                        post = " %",
                        fontSize = "20px",
                        inputColor = "#428BCA"
                    ),
                    textOutput("new_price")
                ),
                selector = "#sidebar_content",
                where = "beforeEnd"
            )
        })

        # output new price
        # output$new_price <- renderText({
        # table_data <- rvs$pdf_data
        # price <- as.numeric(table_data$price[rvs$idx]) +
        # (input$my_knob / 100) * as.numeric(table_data$price[rvs$idx])
        # return(paste("Ksh. ", price))
        # })


        ## ---- ADMIN REGISTRATION TAB ----

        # add validation rules
        iv$add_rule("school_name", sv_required())
        iv$add_rule("school_email", sv_email())
        iv$add_rule("school_type", sv_required())
        iv$add_rule("school_level", sv_required())
        iv$add_rule("county", sv_required())
        iv$add_rule("doc_price", sv_required())


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
            output$confirm_school_data <- renderUI({
                argonTable(
                    title = input$school_name,
                    headTitles = c(
                        "NAME",
                        "LEVEL",
                        "TYPE",
                        "COUNTY",
                        "EMAIL",
                        "PRICE",
                        "STATUS"
                    ),
                    argonTableItems(
                        argonTableItem(
                            stringr::str_to_sentence(input$school_name)
                        ),
                        argonTableItem(input$school_level),
                        argonTableItem(input$school_type),
                        argonTableItem(input$county),
                        argonTableItem(tolower(input$school_email)),
                        argonTableItem(
                            dataCell = TRUE,
                            argonBadge(
                                text = paste("Ksh. ", input$doc_price),
                                status = "primary"
                            )
                        ),
                        argonTableItem(
                            dataCell = TRUE,
                            argonBadge(
                                text = "Pending",
                                status = "danger"
                            )
                        )
                    )
                )
            })
        })

        # Observe confirm button
        observeEvent(input$confirmBtn, {
            # Create data to append
            school_data <- data.frame(
                id = next_school_id("schools"),
                school_name = stringr::str_to_sentence(input$school_name),
                level = input$school_level,
                type = input$school_type,
                county = input$county,
                email = tolower(input$school_email),
                price = input$doc_price,
                status = "Enabled",
                stringsAsFactors = FALSE
            )

            # Call the register_new_school function
            success <- register_new_school(
                table_name = "schools",
                data = school_data
            )

            if (success == 1) {
                alert_success_ui(
                    info = "New school created successfully!",
                    session = session
                )
                # refresh added data
                rvs$school_data <- refresh_table_data(table_name = "schools")
            } else {
                alert_fail_ui(info = "Name or email already exists!", session = session)
            }
        })



        # output table for already exisiting school data
        output$school_data <- renderUI({
            # get the school data
            table_data <- rvs$school_data
            if (nrow(table_data) > 0) {
                argonTable(
                    headTitles = c("ID", "Name", "Type", "County", "Price", "Status", ""),
                    lapply(1:nrow(table_data), function(i) {
                        argonTableItems(
                            argonTableItem(
                                div(
                                    class = "d-flex flex-column justify-content-center",
                                    h6(class = "mb-0 text-xs", table_data$id[i]),
                                    p(
                                        class = "text-truncate w-50 text-xs text-default mb-0",
                                        table_data$email[i]
                                    )
                                )
                            ),
                            argonTableItem(
                                div(
                                    p(
                                        class = "text-xs font-weight-bold mb-0",
                                        table_data$school_name[i]
                                    ),
                                    p(class = "text-xs text-default mb-0", table_data$level[i])
                                )
                            ),
                            argonTableItem(table_data$type[i]),
                            argonTableItem(table_data$county[i]),
                            argonTableItem(
                                dataCell = TRUE,
                                argonBadge(
                                    text = paste("Ksh. ", table_data$price[i]),
                                    status = "primary"
                                )
                            ),
                            argonTableItem(
                                dataCell = TRUE,
                                argonBadge(
                                    text = table_data$status[i],
                                    status = ifelse(table_data$status[i] == "Enabled", "success",
                                        "primary"
                                    )
                                )
                            ),
                            argonTableItem(
                                dropMenu(
                                    class = "well",
                                    actionButton(
                                        inputId = paste0("btn_", i),
                                        label = "",
                                        icon = icon("ellipsis-v"),
                                        size = "sm",
                                        status = "secondary",
                                        outline = TRUE,
                                        flat = TRUE,
                                        class = "btn-link bg-transparent border-0",
                                        onclick = sprintf("Shiny.setInputValue('action_button',
                  '%s');", i)
                                    ),
                                    div(
                                        class = "pt-2",
                                        h5(table_data$school_name[i]),
                                        div(
                                            class = "mb--4",
                                            onclick = sprintf("Shiny.setInputValue('status_button',
                    '%s');", i),
                                            materialSwitch(
                                                inputId = paste0("status_", i),
                                                label = table_data$status[i],
                                                value = ifelse(table_data$status[i] == "Enabled", TRUE,
                                                    FALSE
                                                ),
                                                status = "success"
                                            )
                                        ),
                                        actionButton(
                                            inputId = paste0("del_btn_", i),
                                            label = "Delete",
                                            icon = icon("trash"),
                                            status = "primary",
                                            class = "btn-link bg-transparent mx--3 border-0",
                                            onclick = sprintf(
                                                "Shiny.setInputValue('del_button', '%s');", i
                                            )
                                        ),
                                        actionButton(
                                            inputId = paste0("view_btn_", i),
                                            label = "Edit",
                                            icon = icon("eye"),
                                            status = "primary",
                                            class = "btn-link bg-transparent mx--3 border-0",
                                            onclick = sprintf(
                                                "Shiny.setInputValue('view_button', '%s');", i
                                            )
                                        )
                                    )
                                )
                            )
                        )
                    })
                )
            } else {
                # show empty status div
                show_empty_state_ui
            }
        })


        # change the school status - Enabled/Disabled
        observeEvent(input$action_button, {
            rvs$idx <- input$action_button
        })

        observeEvent(input$status_button, {
            req(!is.null(rvs$idx))

            table_data <- rvs$school_data
            rvs$status <- input[[paste0("status_", rvs$idx)]]
            rvs$message <- if (rvs$status) "disabled..." else "enabled..."
            confirm_text <- if (rvs$status) "disable" else "enable"
            id <- as.numeric(rvs$idx)

            ask_confirmation(
                session = session,
                inputId = "confirm_status",
                title = "Confirmation",
                text = paste(
                    "Are you sure you want to", confirm_text,
                    table_data$school_name[id], "?"
                ),
                btn_labels = c("Cancel", "Yes")
            )
        })

        observeEvent(input$confirm_status, {
            action <- input$confirm_status

            req(!is.null(action))
            idx <- as.numeric(rvs$idx)
            table_data <- rvs$school_data

            if (action) {
                # Update status
                update_school_status(
                    user_id = table_data$id[idx],
                    new_status = rvs$message |>
                        stringr::str_to_sentence() |>
                        stringr::str_replace("\\.\\.\\.", "")
                )
                # Refresh data
                rvs$school_data <- refresh_table_data(table_name = "schools")

                alert_success_ui(
                    position = "top-end",
                    info = paste(table_data$school_name[idx], "has been", rvs$message),
                    session = session
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
        observeEvent(input$del_button, {
            rvs$idx <- input$del_button
            table_data <- rvs$school_data
            id <- as.numeric(rvs$idx)

            ask_confirmation(
                session = session,
                inputId = "confirm_delete",
                title = "Confirmation",
                text = paste(
                    "Are you sure you want to delete",
                    table_data$school_name[id], "?"
                ),
                btn_labels = c("Cancel", "Yes")
            )
        })

        # Edit button
        observeEvent(input$view_button, {
            rvs$idx <- input$view_button
            idx <- as.numeric(rvs$idx)
            table_data <- rvs$school_data

            # Construct HTML content with normal shiny inputs
            html_content <- div(
                argonRow(
                    argonColumn(
                        width = 3,
                        textInput(
                            inputId = "edit_school_name",
                            label_mandatory("Name:"),
                            value = table_data$school_name[idx],
                            placeholder = "Eg. Lenga Juu"
                        )
                    ),
                    argonColumn(
                        width = 3,
                        pickerInput(
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
                            selected = table_data$level[idx]
                        )
                    ),
                    argonColumn(
                        width = 3,
                        pickerInput(
                            inputId = "edit_school_type",
                            label = label_mandatory("Type:"),
                            options = list(
                                style = "btn-outline-light",
                                title = "Eg. Public"
                            ),
                            choices = c("Public", "Private", "Other"),
                            selected = table_data$type[idx]
                        )
                    ),
                    argonColumn(
                        width = 3,
                        pickerInput(
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
                            selected = table_data$county[idx],
                            autocomplete = TRUE
                        )
                    )
                ),
                argonRow(
                    argonColumn(
                        width = 3,
                        textInput(
                            inputId = "edit_school_email",
                            label_mandatory("Email:"),
                            value = table_data$email[idx],
                            placeholder = "Eg. johnwekesa@gmail.com"
                        )
                    ),
                    argonColumn(
                        width = 3,
                        autonumericInput(
                            inputId = "edit_doc_price",
                            label_mandatory("Price:"),
                            value = table_data$price[idx],
                            currencySymbol = "Ksh ",
                            decimalPlaces = 0,
                            minimumValue = 500
                        )
                    )
                )
            )

            # Show the modal dialog with the HTML content
            showModal(modalDialog(
                title = table_data$school_name[idx],
                html_content,
                footer = tagList(
                    modalButton("Cancel"),
                    actionButton("save_changes", "Save changes")
                )
            ))
        })

        observeEvent(input$save_changes, {
            # Show confirmation modal
            ask_confirmation(
                session = session,
                inputId = "confirm_edit_details",
                title = "Confirm edit",
                text = "Are you sure you want to update the user details?",
                btn_labels = c("Cancel", "Yes")
            )
        })

        observeEvent(input$confirm_edit_details, {
            action <- input$confirm_edit_details
            idx <- as.numeric(rvs$idx)
            table_data <- rvs$school_data
            school_id <- table_data$id[idx]

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
                update_school_details(school_id, new_values)

                # Close the confirmation modal
                removeModal()

                # Refresh data
                rvs$school_data <- refresh_table_data(table_name = "schools")

                # Show success message
                alert_success_ui(info = "School details updated...", session = session)
            } else {
                alert_warn_ui(
                    position = "top-end",
                    info = "Action has been cancelled!",
                    session = session
                )
            }
        })


        observeEvent(input$confirm_delete, {
            action <- input$confirm_delete

            req(!is.null(action))
            idx <- as.numeric(rvs$idx)
            table_data <- rvs$school_data
            user_id <- table_data$id[idx]

            if (action) {
                # Dlete school records
                delete_school_records(user_id = user_id)
                # Refresh data
                rvs$school_data <- refresh_table_data(table_name = "schools")

                alert_success_ui(
                    position = "top-end",
                    info = paste(table_data$school_name[idx], "has been deleted..."),
                    session = session
                )
            } else {
                alert_warn_ui(
                    position = "top-end",
                    info = "Action has been cancelled!",
                    session = session
                )
            }
        })

        # output table for already exisiting teacher data
        output$teachers_data <- renderUI({
            # get the teachers data
            teachers_data <- rvs$teachers_data
            if (nrow(teachers_data) > 0) {
                argonTable(
                    headTitles = c("ID", "School", "Grade", "Type", "Phone", "Status", ""),
                    lapply(1:nrow(teachers_data), function(i) {
                        argonTableItems(
                            argonTableItem(
                                div(
                                    class = "d-flex flex-column justify-content-center",
                                    h6(class = "mb-0 text-xs", teachers_data$user_name[i]),
                                    p(class = "text-xs text-default mb-0", teachers_data$id[i])
                                )
                            ),
                            argonTableItem(
                                div(
                                    p(
                                        class = "text-xs font-weight-bold mb-0",
                                        teachers_data$school_name[i]
                                    ),
                                    p(
                                        class = "text-truncate w-50 text-xs text-default mb-0",
                                        teachers_data$email[i]
                                    )
                                )
                            ),
                            argonTableItem(teachers_data$grade[i]),
                            argonTableItem(paste("+254", teachers_data$phone[i])),
                            argonTableItem(
                                dataCell = TRUE,
                                argonBadge(
                                    text = teachers_data$status[i],
                                    status = ifelse(teachers_data$status[i] == "Enabled", "success",
                                        "primary"
                                    )
                                )
                            ),
                            argonTableItem(
                                dropMenu(
                                    class = "well",
                                    actionButton(
                                        inputId = paste0("btn_", i),
                                        label = "",
                                        icon = icon("ellipsis-v"),
                                        size = "sm",
                                        status = "secondary",
                                        outline = TRUE,
                                        flat = TRUE,
                                        class = "btn-link bg-transparent border-0",
                                        onclick = sprintf("Shiny.setInputValue('action_button',
                  '%s');", i)
                                    ),
                                    div(
                                        class = "pt-2",
                                        h5(teachers_data$school_name[i]),
                                        div(
                                            class = "mb--4",
                                            onclick = sprintf("Shiny.setInputValue('status_button',
                    '%s');", i),
                                            materialSwitch(
                                                inputId = paste0("status_", i),
                                                label = teachers_data$status[i],
                                                value = ifelse(teachers_data$status[i] == "Enabled", TRUE,
                                                    FALSE
                                                ),
                                                status = "success"
                                            )
                                        ),
                                        actionButton(
                                            inputId = paste0("del_btn_", i),
                                            label = "Delete",
                                            icon = icon("trash"),
                                            status = "primary",
                                            class = "btn-link bg-transparent mx--3 border-0",
                                            onclick = sprintf("Shiny.setInputValue('del_button',
                    '%s');", i)
                                        )
                                    )
                                )
                            )
                        )
                    })
                )
            } else {
                # show empty status div
                show_empty_state_ui
            }
        })

        # output table for already exisiting students data
        output$students_data <- renderUI({
            # get the student data
            students_data <- rvs$students_data
            if (nrow(students_data) > 0) {
                argonTable(
                    headTitles = c("ID", "School", "Grade", "Phone", "Status", ""),
                    lapply(1:nrow(students_data), function(i) {
                        argonTableItems(
                            argonTableItem(
                                div(
                                    class = "d-flex flex-column justify-content-center",
                                    h6(class = "mb-0 text-xs", students_data$user_name[i]),
                                    p(class = "text-xs text-default mb-0", students_data$id[i])
                                )
                            ),
                            argonTableItem(
                                div(
                                    p(
                                        class = "text-xs font-weight-bold mb-0",
                                        students_data$school_name[i]
                                    ),
                                    p(
                                        class = "text-truncate w-50 text-xs text-default mb-0",
                                        students_data$email[i]
                                    )
                                )
                            ),
                            argonTableItem(students_data$grade[i]),
                            argonTableItem(paste("+254", students_data$phone[i])),
                            argonTableItem(
                                dataCell = TRUE,
                                argonBadge(
                                    text = students_data$status[i],
                                    status = ifelse(students_data$status[i] == "Enabled", "success",
                                        "primary"
                                    )
                                )
                            ),
                            argonTableItem(
                                dropMenu(
                                    class = "well",
                                    actionButton(
                                        inputId = paste0("btn_", i),
                                        label = "",
                                        icon = icon("ellipsis-v"),
                                        size = "sm",
                                        status = "secondary",
                                        outline = TRUE,
                                        flat = TRUE,
                                        class = "btn-link bg-transparent border-0",
                                        onclick = sprintf("Shiny.setInputValue('action_button',
                  '%s');", i)
                                    ),
                                    div(
                                        class = "pt-2",
                                        h5(students_data$school_name[i]),
                                        div(
                                            class = "mb--4",
                                            onclick = sprintf("Shiny.setInputValue('status_button',
                    '%s');", i),
                                            materialSwitch(
                                                inputId = paste0("status_", i),
                                                label = students_data$status[i],
                                                value = ifelse(students_data$status[i] == "Enabled", TRUE,
                                                    FALSE
                                                ),
                                                status = "success"
                                            )
                                        ),
                                        actionButton(
                                            inputId = paste0("del_btn_", i),
                                            label = "Delete",
                                            icon = icon("trash"),
                                            status = "primary",
                                            class = "btn-link bg-transparent mx--3 border-0",
                                            onclick = sprintf("Shiny.setInputValue('del_button',
                    '%s');", i)
                                        )
                                    )
                                )
                            )
                        )
                    })
                )
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

            updateSelectizeInput(
                session = session,
                inputId = "doc_teacher",
                choices = unique(choices$user_name)
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

            updateSelectizeInput(
                session = session,
                inputId = "doc_grade",
                choices = setNames(grade, paste("Grade", grade)),
            )
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


        # show user payments status
        output$payments_data <- renderUI({
            # get the payments data
            payments_data <- rvs$payments_data |>
                filter(
                    user_email == email
                )
            if (nrow(payments_data) > 0) {
                argonTable(
                    headTitles = c(
                        "Transaction Code", "Amount", "Number",
                        "Time", "Year", "Status"
                    ),
                    lapply(1:nrow(payments_data), function(i) {
                        argonTableItems(
                            argonTableItem(stringr::str_to_upper(payments_data$code[i])),
                            argonTableItem(payments_data$amount[i]),
                            argonTableItem(payments_data$number[i]),
                            argonTableItem(payments_data$time[i]),
                            argonTableItem(payments_data$year[i]),
                            argonTableItem(
                                dataCell = TRUE,
                                argonBadge(
                                    text = payments_data$status[i],
                                    status = ifelse(
                                        payments_data$status[i] == "Approved", "success",
                                        "danger"
                                    )
                                )
                            )
                        )
                    })
                )
            } else {
                # show empty status div
                show_empty_state_ui
            }
        })

        # create validations
        ivp$add_rule("transaction_code", sv_required())
        ivp$add_rule("tel_number", sv_required())
        ivp$add_rule("amount", sv_required())
        ivp$add_rule("payment_time", sv_required())

        # add rule on mobile number
        ivp$add_rule("tel_number", function(value) {
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

        observeEvent(input$create_ticket, {
            ivp$enable() # enable validation check
            req(ivp$is_valid()) # ensure checks are valid

            # Create a reactable table with the input values
            table_html <- reactable(
                data.frame(
                    Input = c("Transaction Code", "Amount", "Number", "Time"),
                    Value = c(
                        stringr::str_to_upper(input$transaction_code),
                        input$amount,
                        input$tel_number,
                        format(
                            lubridate::as_datetime(input$payment_time), "%-d/%-m/%y %-I:%M %p"
                        )
                    )
                ),
                columns = list(
                    Input = colDef(name = "Input"),
                    Value = colDef(name = "Value")
                ),
                borderless = TRUE,
                bordered = FALSE,
                striped = FALSE,
                outlined = TRUE,
                wrap = FALSE,
                resizable = TRUE
            )

            # Show confirmation dialog with reactable table
            ask_confirmation(
                session = session,
                inputId = "confirm_ticket_details",
                title = NULL,
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
            if (input$confirm_ticket_details) {
                # Create data to append
                payment_data <- data.frame(
                    user_email = email,
                    code = input$transaction_code,
                    amount = input$amount,
                    number = input$tel_number,
                    time = format(
                        lubridate::as_datetime(input$payment_time), "%-d/%-m/%y %-I:%M %p"
                    ),
                    status = "Pending",
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

        # Actions for logout button
        observeEvent(input$log_out_session, {
            # Sign user out
            sign_out_from_shiny()
            session$reload()
        })
    })
}
