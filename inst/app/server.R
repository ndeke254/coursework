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
    ivr <- InputValidator$new()

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
        requests_data = dbReadTable(conn, "requests"),
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
                alert_fail_ui(
                    session = session,
                    info = "Password do not match",
                    position = "bottom",
                )
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
            alert_fail_ui(
                info = "Name or email or phone already exists!",
                 session = session
                 )
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
        updateSelectInput(
            inputId = "teacher_school",
            choices = rvs$school_data$school_name
        )

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
                        reactable(
                            table,
                            borderless = TRUE,
                            bordered = FALSE,
                            striped = FALSE,
                            outlined = TRUE
                        )
                    })
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
                        reactable(
                            table,
                            borderless = TRUE,
                            bordered = FALSE,
                            striped = FALSE,
                            outlined = TRUE
                        )
                    })
                    grades <- strsplit(signed_user$grade, ", ")[[1]] |>
                        as.numeric()
                    updateSelectizeInput(
                        session = session,
                        inputId = "request_grade",
                        choices = setNames(grades, paste("Grade", grades))
                    )
                    updateSelectizeInput(
                        session = session,
                        inputId = "request_learning_area",
                        choices = learning_areas
                    )

                    # add validation rules
                    ivr <- InputValidator$new()
                    ivr$add_rule("photo_file", sv_required())
                    ivr$add_rule("request_grade", sv_required())
                    ivr$add_rule("request_learning_area", sv_required())
                    ivr$add_rule("request_topic", sv_required())
                    ivr$add_rule("request_sub_topic", sv_required())

                    output$teacher_requests <- renderReactable({
                        # Filter and arrange the data as needed
                        data <- rvs$requests_data |>
                            filter(teacher_id == signed_user$id) |>
                            select(-teacher_id) |>
                            arrange(desc(time))

                        # Set the column names
                        colnames(data) <- c("ID", "No. photos", "Grade", "Learning Area", "Topic", "Sub Topic", "Time", "Status")

                        # Create a reactable with customization
                        reactable(
                            data,
                            searchable = TRUE,
                            sortable = TRUE,
                            defaultPageSize = 10,
                            highlight = TRUE,
                            wrap = FALSE,
                            resizable = TRUE,
                            bordered = TRUE,
                            columns = list(
                                Status = colDef(
                                    style = function(status) {
                                        ifelse(status == "PENDING" ||
                                            status == "CANCELLED",
                                        color <- "#e00000",
                                        color <- "#008000"
                                        )
                                        list(color = color, fontWeight = "bold")
                                    },
                                )
                            ),
                            theme = reactableTheme(
                                borderColor = "#ddd",
                                cellPadding = "8px",
                                borderWidth = "1px",
                                highlightColor = "#f0f0f0"
                            )
                        )
                    })

                    output$teacher_students <- renderReactable({
                        # Filter and arrange the data as needed
                        data <- rvs$students_data |>
                            filter(school_name == signed_user$school_name &
                                grade %in% grades) |>
                            select(id, user_name, grade, paid)

                        # Set the column names
                        colnames(data) <- c("ID", "Name", "Grade", "Paid")

                        # Create a reactable with customization
                        reactable(
                            data,
                            searchable = TRUE,
                            defaultPageSize = 10,
                            wrap = FALSE,
                            highlight = TRUE,
                            borderless = TRUE,
                            columns = list(
                                Paid = colDef(
                                    cell = function(value) {
                                        if (value == "0") "\u274c" else "\u2714\ufe0f"
                                    }
                                )
                            ),
                            theme = reactableTheme(
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
                        req(ivr$is_valid()) # ensure checks are valid)
                        photos <- uploaded_request_files()
                        if (length(photos) == 0) {
                            alert_fail_ui(
                                info = "Upload photos...",
                                session = session
                            )
                            return()
                        }
                        req(length(photos) > 0)
                        table_html <- reactable(
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
                            showCancelButton = TRUE,
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

        ivs$add_rule("doc_request", sv_required())
        ivs$add_rule("doc_teacher_id", sv_required())
        ivs$add_rule("doc_grade", sv_required())
        ivs$add_rule("doc_learning_area", sv_required())
        ivs$add_rule("doc_topic", sv_required())
        ivs$add_rule("doc_sub_topic", sv_required())

        # Update field choices
        observe({
            if (nrow(rvs$school_data) > 0) {
                requests <- rvs$requests_data |>
                    filter(status == "PENDING") |>
                    select(id) |>
                    unlist() |>
                    as.vector()
                updateSelectizeInput(
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
                filter(id == input$doc_request)
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
            # Filter and arrange the data as needed
            data <- rvs$requests_data |>
                filter(teacher_id == signed_user$id) |>
                arrange(desc(time))

            if (nrow(data) > 0) {
                # Set the column names
                colnames(data) <- c("ID", "Teacher ID", "Photos", "Grade", "Learning Area", "Topic", "Sub Topic", "Time", "details")

                # Create a reactable with download and update features
                output$table <- renderReactable({
                    reactable(
                        data = data,
                        searchable = TRUE,
                        sortable = TRUE,
                        resizable = TRUE,
                        defaultPageSize = 10,
                        wrap = FALSE,
                        highlight = TRUE,
                        columns = list(
                            details = colDef(
                                name = "",
                                sortable = FALSE,
                                cell = function() {
                                    htmltools::tags$button(
                                        "",
                                        class = "fa fa-chevron-right border-0 bg-transparent mt-3",
                                        `aria-hidden` = "true"
                                    )
                                }
                            )
                        ),
                        theme = reactableTheme(
                            borderColor = "#ddd",
                            cellPadding = "8px",
                            borderWidth = "1px",
                            highlightColor = "#f0f0f0"
                        ),
                        onClick = JS("function(rowInfo, column) {
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
                table_html <- reactable(
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
                        Input = colDef(name = "Input"),
                        Value = colDef(name = "Value")
                    ),
                    borderless = TRUE,
                    bordered = FALSE,
                    striped = FALSE,
                    outlined = TRUE,
                    wrap = FALSE,
                    class = "text-body_1"
                )
                table_html
            })
        })

        # output table for already exisiting school data
        output$school_data <- renderUI({
            # get the school data
            table_data <- rvs$school_data |>
                arrange(desc(time)) |>
                mutate(details = NA)

            if (nrow(table_data) > 0) {
                # Set the column names
                i <- 2
                colnames(table_data) <- c("ID", "Name", "Level", "Type", "County", "Email", "Price", "Time", "Status", "details")

                output$table1 <- renderReactable({
                    reactable(
                        data = table_data,
                        searchable = TRUE,
                        sortable = TRUE,
                        defaultPageSize = 10,
                        resizable = TRUE,
                        wrap = FALSE,
                        highlight = TRUE,
                        columns = list(
                            ID = colDef(
                                cell = function(value, index) {
                                    name <- table_data$Name[index]
                                    div(
                                        div(value),
                                        div(style = list(fontSize = "0.75rem"), name)
                                    )
                                }
                            ),
                            Price = colDef(format = colFormat(
                                prefix = "Ksh. ",
                                separators = TRUE,
                                digits = 2
                            )),
                            Time = colDef(
                                minWidth = 150
                            ),
                            Level = colDef(
                                cell = function(value, index) {
                                    type <- table_data$Type[index]
                                    div(
                                        div(value),
                                        div(style = list(fontSize = "0.75rem"), type)
                                    )
                                }
                            ),
                            Name = colDef(show = FALSE),
                            Type = colDef(show = FALSE),
                            details = colDef(
                                name = "",
                                sortable = FALSE,
                                cell = function() {
                                    htmltools::tags$button(
                                        id = "",
                                        class = "fa fa-ellipsis-v border-0 bg-transparent mt-3",
                                        `aria-hidden` = "true"
                                    )
                                }
                            )
                        ),
                        theme = reactableTheme(
                            borderColor = "#ddd",
                            cellPadding = "8px",
                            borderWidth = "1px",
                            highlightColor = "#f0f0f0"
                        ),
                        onClick = JS("function(rowInfo, column) {
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
                    class = "btn-danger",
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

        showModal(modalDialog(
            easyClose = TRUE,
            title = paste("Details for", details$ID),
            footer = NULL,
            div(
                class = "pb-3",
                tags$p("Download images:"),
                div(
                    class = "pb-3",
                    download_buttons
                ),
                div(
                    class = "d-flex align-items-center
                    justify-content-evenly",
                    selectInput(
                        inputId = "edit_request_status",
                        label = "Change request status",
                        choices = c("PROCESSING", "CANCELLED")
                    ),
                    actionButton(
                        inputId = "change_request_status",
                        label = "",
                        icon = icon("check"),
                        class = "btn-circle bg-default mt-3"
                    )
                )
            )
        ))

        if (details$details != "PENDING") {
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
        table_html <- reactable(
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
                Input = colDef(name = "Input"),
                Value = colDef(name = "Value")
            ),
            borderless = TRUE,
            bordered = FALSE,
            striped = FALSE,
            outlined = TRUE,
            wrap = FALSE,
            resizable = ,
            class = "text-body_1"
        )

        # Show confirmation dialog with reactable table
        shinyalert(
            session = session,
            inputId = "confirm_pdf_details",
            title = NULL,
            text = tags$div(
                table_html
            ),
            showCancelButton = TRUE,
            confirmButtonCol = "#1D2856",
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

            teacher_name <- rvs$teachers_data |>
                filter(id == input$doc_teacher_id) |>
                select(user_name) |>
                unlist() |>
                as.vector()

            data <- data.frame(
                id = next_pdf_id("content"),
                pdf_name = stringr::str_to_title(input$pdfFile$name),
                teacher = teacher_name,
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
                image_paths <- pdf_to_image(
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
        school_data <- data.frame(
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
            alert_fail_ui(
                info = "Name or email already exists!",
                session = session
            )
        }

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

        ask_confirmation(
            session = session,
            inputId = "confirm_status",
            btn_colors = c("#E76A35", "#1D2856"),
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
            # Update status
            new_status <- input$edit_school_status
            update_school_status(
                user_id = details$ID,
                new_status = if (new_status) "Enabled" else "Disabled"
            )
            # Refresh data
            rvs$school_data <- refresh_table_data(table_name = "schools")
            confirm_message <- if (new_status) "enabled..." else "disabled..."

            alert_success_ui(
                position = "top-end",
                info = paste(details$Name, "has been", confirm_message),
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
    observeEvent(input$delete_school_btn, {
        details <- input$school_menu_details$info

        ask_confirmation(
            session = session,
            inputId = "confirm_delete",
            btn_colors = c("#E76A35", "#1D2856"),
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
                        selected = details$Level
                    )
                ),
                column(
                    width = 3,
                    pickerInput(
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
                    autonumericInput(
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
            class = "shadow-lg",
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
            update_school_details(details$ID, new_values)

            # Close the confirmation modal
            removeModal()

            # Refresh data
            rvs$school_data <- refresh_table_data(table_name = "schools")

            # Show success message
            alert_success_ui(
                info = "School details updated...",
                session = session
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
            rvs$school_data <- refresh_table_data(table_name = "schools")

            alert_success_ui(
                position = "top-end",
                info = paste(details$Name, "has been deleted..."),
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

    observeEvent(input$school_menu_details, {
        details <- input$school_menu_details$info
        html_content <- div(
            h5(paste(details$ID), ":", details$Name),
            div(
                class = "pt-4",
                materialSwitch(
                    inputId = "edit_school_status",
                    label = details$Status,
                    value = ifelse(
                        details$Status == "Enabled", TRUE, FALSE
                    ),
                    status = "success",
                    right = TRUE,
                    inline = TRUE
                ),
                actionButton(
                    inputId = paste0("delete_school_btn"),
                    label = "Delete",
                    class = "bg-default mt-0"
                ),
                actionButton(
                    inputId = paste0("edit_school_btn"),
                    label = "Edit",
                    class = "bg-default mt-0"
                )
            )
        )

        shinyalert(
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
}
