server <- function(input, output, session) {
  # get the sign-in user
  user <- session$userData$user()
  email <- user$email
  email_verified <- user$email_verified
  user_role <- user$roles
  is_admin <- user$is_admin

  # output the signed in user
  signed_user <- get_signed_user(email)
  user_status <- signed_user$status

  # show thw user on profile
  output$signed_user <- renderText(
    stringr::word(signed_user$user_name, 1)
  )

  # control access according to status
  if (is.null(user_status) || 
  user_status %in% "Disabled" ||
  length(user_status) == 0) {
    showModal(
    modalDialog(
      id = "access_denied_modal",
      title = "Access Denied",
      "Access denied. Contact the administrator.",
      easyClose = TRUE,
      footer = NULL
    )
    )
  }

  # make sqlite connection:
  conn <- DBI::dbConnect(
    drv = RSQLite::SQLite(),
    Sys.getenv("DATABASE_NAME")
  )

  # initialize fields validation
  iv <- InputValidator$new()
  ivs <- InputValidator$new()
  ivt <- InputValidator$new()

  # Initialize reactive values
  rv <- reactiveValues(
    image_paths = NULL,
    current_page = 1,
    total_pages = 0,
    selected_pdf = NULL,
    pdf_paths = list()
  )

  # Create reactive values for school table
  rvs <- reactiveValues(
    message = NULL,
    school_data = dbReadTable(conn, "schools"),
    pdf_data = dbReadTable(conn, "content"),
    user_data = dbReadTable(conn, "users"),
    idx = NULL,
    status = NULL
  )
  on.exit(DBI::dbDisconnect(conn), add = TRUE)

  # output selected tab
  output$selected_tab <- renderText({
    item <- ifelse(
      is.null(input$active_sidebar_tab), "DASHBOARD", input$active_sidebar_tab
    )
    return(stringr::str_to_upper(item))
  })


  # Load existing PDFs and their cover images from the "pdf"
  # folder on app initialization
  observe({
    pdf_files <- list.files("www/pdf", pattern = "\\.pdf$", full.names = TRUE)
    rv$pdf_paths <- lapply(pdf_files, function(pdf) {
      cover_image <- file.path(
        "www/images", paste0(fs::path_ext_remove(basename(pdf)), "_page_1.png")
      )
      list(pdf = pdf, cover = cover_image)
    })
  })

  # add validation rules
  ivs$add_rule("pdfFile", sv_required())
  ivs$add_rule("pdfFile", function(value) {
    if (!is.null(value) && length(value) > 0) {
      pdf_info <- pdftools::pdf_info(value$datapath)
      pages <- pdf_info$pages
      if (pages > 3) {
        return("PDF exceeded limit of 3 pages!")
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
      updatePickerInput(
        inputId = "doc_school",
        choices = unique(rvs$school_data$school_name),
        choicesOpt = list(
          subtext = rvs$school_data$level
        )
      )
      updatePickerInput(
        inputId = "user_school",
        choices = unique(rvs$school_data$school_name),
        choicesOpt = list(
          subtext = rvs$school_data$level
        )
      )
      updatePickerInput(
        inputId = "doc_learning_area",
        choices = list(
          `Pre-school` = pre_primary,
          `lower primary` = lower_primary,
          `Upper primary` = upper_primary,
          `Junior secondary` = junior_secondary
        ),
        choicesOpt = list(
          content = stringr::str_trunc(
            c(pre_primary, lower_primary, upper_primary, junior_secondary),
            width = 35
          )
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
      data.frame(
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
      bordered = TRUE,
      striped = TRUE
    )

    # Show confirmation dialog with reactable table
    ask_confirmation(
      session = session,
      inputId = "confirm_pdf_details",
      title = NULL,
      text = tags$div(
        table_html
      ),
      btn_labels = c("Cancel", "Yes"),
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
        time = format(Sys.time(), format = "%Y-%m-%d %H:%M:%S")
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
    if (nrow(pdf_data) > 0) {
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
                    class = "text-truncate w-75
                  text-xs text-default mb-0",
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
                h6(class = "text-xs mb-0", pdf_data$learning_area[i]),
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

  # Render available PDFs
  output$published_pdfs <- renderUI({
    if (nrow(rvs$pdf_data) == 0) {
      tags$p("No PDFs available")
    } else {
      shinybusy::show_spinner()

      # Import available content and extract year
      available_content <- rvs$pdf_data
      available_content$year <- substr(available_content$time, 1, 4)

      # Sort years in descending order
      sorted_years <- sort(unique(available_content$year), decreasing = TRUE)

      # List all images in the "www/images" directory
      image_files <- list.files(
        path = "www/images",
        pattern = "_page_1\\.png$",
        full.names = TRUE
      )

      # Create card decks for each year
      card_decks <- lapply(sorted_years, function(year) {
        # Filter data for the current year
        year_data <- filter(available_content, year == !!year)

        div(
          class = "bg-translucent-light has-success heading
          floating jumbotron",
          paste("Year", year),
          div(
            class = "d-flex flex-wrap floating",
            # Create cards for each PDF in the current year
            lapply(1:nrow(year_data), function(i) {
              pdf_info <- year_data[i, ]
              pdf_name_filtered <- fs::path_ext_remove(
                basename(pdf_info$pdf_name)
              )
              # get the cover images
              cover_image <- image_files[
                grepl(
                  paste0(
                    "^www/images/",
                    pdf_name_filtered,
                    "_page_1\\.png$"
                  ), image_files
                )
              ]

              cover_image <- ifelse(
                length(cover_image) > 0, sub("^www/", "", cover_image[1]),
                "images/default_cover.png"
              )

              # create pdf card
              argonR::argonCard(
                title = tags$h6(
                  class = "d-flex text-truncate text-uppercase",
                  pdf_name_filtered, br(),
                  pdf_info$time
                ),
                hover_lift = TRUE,
                shadow = TRUE,
                border_level = 5,
                icon = icon("file-pdf"),
                status = "primary",
                width = 2,
                argonBadge(
                  text = pdf_info$topic,
                  status = "default"
                ),
                div(
                  id = paste("card", i),
                  class = "d-flex justify-content-center",
                  onclick = sprintf(
                    "Shiny.setInputValue('selected_pdf', '%s');
                      Shiny.setInputValue('trigger_modal', Math.random());",
                    pdf_info$pdf_name
                  ),
                  argonR::argonImage(
                    src = cover_image
                  )
                )
              )
            })
          )
        )
      })

      # Wrap all card decks in a tagList
      do.call(tagList, card_decks)
    }
  })


  # Render the current page's image
  output$pdf_images <- renderImage(
    {
      list(
        src = rv$image_paths[[rv$current_page]],
        width = "100%",
        height = "auto",
        class = "rounded"
      )
    },
    deleteFile = FALSE
  )

  # Observe the selected PDF and trigger the modal button click
  observeEvent(input$trigger_modal, {
    runjs('$("#modal").modal("show");')
  })

  # Observe selection change and update image paths
  observeEvent(input$selected_pdf, {
    shinybusy::show_spinner()

    req(input$selected_pdf)

    image_files <- list.files(
      path = "www/images",
      pattern = paste0("^", tools::file_path_sans_ext(
        tools::file_path_sans_ext(basename(input$selected_pdf))
      ), "_page_.*\\.png$"),
      full.names = TRUE
    )
    rv$image_paths <- image_files
    rv$current_page <- 1
    rv$total_pages <- length(image_files)
    rv$selected_pdf <- input$selected_pdf

    # Render progress bar and text
    output$progress_bar <- renderUI({
      page_text <- paste("Page", rv$current_page, "of", rv$total_pages)
      progress_value <- pmin((rv$current_page / rv$total_pages) * 100, 100)
      progress_bar_modified(
        text = page_text,
        value = progress_value,
        status = "gradient-gray"
      )
    })
  })

  # Navigation button observers
  observeEvent(input$prev_btn, {
    shinybusy::show_spinner()

    if (rv$current_page > 1) {
      rv$current_page <- rv$current_page - 1
      output$pdf_images <- renderImage(
        {
          list(
            src = rv$image_paths[[rv$current_page]],
            width = "100%",
            height = "auto",
            class = "rounded"
          )
        },
        deleteFile = FALSE
      )
    }
  })

  observeEvent(input$next_btn, {
    shinybusy::show_spinner()

    if (rv$current_page < rv$total_pages) {
      rv$current_page <- rv$current_page + 1
      output$pdf_images <- renderImage(
        {
          list(
            src = rv$image_paths[[rv$current_page]],
            width = "100%",
            height = "auto",
            class = "rounded"
          )
        },
        deleteFile = FALSE
      )
    }
  })

  # Observe first and last pages
  observe({
    if (rv$current_page == rv$total_pages) {
      shinyjs::hide("next_btn")
      shinyjs::show("prev_btn")
    }
    if (rv$current_page == 1) {
      shinyjs::hide("prev_btn")
      shinyjs::show("next_btn")
    }
    if (rv$total_pages == 1) {
      shinyjs::hide("prev_btn")
      shinyjs::hide("next_btn")
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
          argonTableItem(stringr::str_to_sentence(input$school_name)),
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


  # Register a new teacher
  # add validation rules
  ivt$add_rule("user_name", sv_required())
  ivt$add_rule("user_school", sv_required())
  ivt$add_rule("user_email", sv_required())
  ivt$add_rule("user_grade", sv_required())
  ivt$add_rule("user_tel_number", sv_required())
  ivt$add_rule("user_email", sv_email())
  # Add a validation rule for the phone number input
  ivt$add_rule("user_tel_number", function(value) {
    phone_number <- gsub("\\D", "", value) # Remove non-digit characters
    if (nchar(phone_number) != 9) {
      return("Phone number must be exactly 9 digits long")
    }
    return(NULL) # Return NULL if validation passes
  })
  # Add a validation rule for the user name input
  ivt$add_rule("user_name", function(value) {
    names <- strsplit(value, " ")[[1]]
    if (length(names) != 2) {
      return("Must be 2 names")
    }
    return(NULL) # Return NULL if validation passes
  })
  observeEvent(input$nextBtn_1, {
    req(input$user_type)
    # mark step 1 complete
    shinyjs::addCssClass(
      id = "step_u1",
      class = "bg-green"
    )
    shinyjs::addCssClass(
      id = "step_u2",
      class = "bg-red"
    )
    shinyjs::addCssClass(
      id = "lineu",
      class = "bg-green"
    )
    shinyjs::hide("nextBtn_1")
    shinyjs::show("nextBtn_2")
    shinyjs::show("prevBtn_1")

    shinyjs::show("tab_u2")
    shinyjs::hide("tab_u1")

    shinyjs::removeCssClass(
      id = "tabu_buttons",
      class = "justify-content-end"
    )

    shinyjs::addCssClass(
      id = "tabu_buttons",
      class = "justify-content-between"
    )
  })

  # observe a back move to tab 1
  observeEvent(input$prevBtn_1, {
    shinyjs::show("nextBtn_1")
    shinyjs::hide("nextBtn_2")
    shinyjs::hide("prevBtn_1")

    shinyjs::hide("tab_u2")
    shinyjs::show("tab_u1")

    shinyjs::addCssClass(
      id = "tabu_buttons",
      class = "justify-content-end"
    )

    shinyjs::removeCssClass(
      id = "tabu_buttons",
      class = "justify-content-between"
    )
  })

  # observe next stage
  observeEvent(input$nextBtn_2, {
    ivt$enable() # enable validation check
    req(ivt$is_valid()) # ensure checks are valid

    # mark step 2 complete
    shinyjs::addCssClass(
      id = "step_u2",
      class = "bg-green"
    )
    shinyjs::addCssClass(
      id = "lineu1",
      class = "bg-green"
    )
    shinyjs::show("confirmBtn_1")
    shinyjs::show("tab_u3")
    shinyjs::hide("tab_u2")
    shinyjs::hide("nextBtn_2")
    shinyjs::hide("prevBtn_1")
    shinyjs::show("prevBtn_2")

    # output table for entered data confirmation
    output$confirm_user_data <- renderUI({
      argonTable(
        title = input$school_name,
        headTitles = c(
          "NAME",
          "TYPE",
          "SCHOOL",
          "GRADE",
          "PHONE",
          "EMAIL",
          "STATUS"
        ),
        argonTableItems(
          argonTableItem(stringr::str_to_title(input$user_name)),
          argonTableItem(input$user_type),
          argonTableItem(input$user_school),
          argonTableItem(input$user_grade),
          argonTableItem(paste("+254", input$user_tel_number)),
          argonTableItem(tolower(input$user_email)),
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

  # observe a back move to tab 2
  observeEvent(input$prevBtn_2, {
    shinyjs::hide("confirmBtn_1")
    shinyjs::hide("prevBtn_2")
    shinyjs::hide("tab_u3")
    shinyjs::show("tab_u2")
    shinyjs::show("nextBtn_2")
    shinyjs::show("prevBtn_1")
  })

  # save user data after confirmation
  observeEvent(input$confirmBtn_1, {
    # Get the current year
    current_year <- paste0("Y", format(Sys.Date(), "%Y"))

    # get the available data
    available_data <- refresh_table_data(table_name = "users")

    # Identify existing year columns in the existing data
    year_columns <- colnames(available_data)[grepl(
      "^Y?\\d{4}$",
      colnames(available_data)
    )]

    # Create users data to append
    user_data <- data.frame(
      id = next_user_id("users"),
      user_name = stringr::str_to_title(input$user_name),
      type = input$user_type,
      school_name = input$user_school,
      grade = input$user_grade,
      phone = input$user_tel_number,
      email = input$user_email,
      status = "Enabled",
      stringsAsFactors = FALSE
    )

    # Ensure the current year column is included
    if (!(current_year %in% year_columns)) {
      # Assign FALSE to all existing users
      db_name <- Sys.getenv("DATABASE_NAME")
      conn <- DBI::dbConnect(drv = RSQLite::SQLite(), db_name)
      on.exit(DBI::dbDisconnect(conn), add = TRUE)
      dbExecute(conn, paste0(
        "ALTER TABLE users ADD COLUMN ",
        current_year, " INTEGER DEFAULT 0"
      ))

      # update years for new user
      year_columns <- c(year_columns, current_year)
    }

    # Add FALSE for all year columns in the new user data
    for (year in year_columns) {
      user_data[[year]] <- FALSE
    }

    # Call the register_new_user function
    success <- register_new_user(
      table_name = "users",
      data = user_data
    )

    if (success == 1) {
      alert_success_ui(
        info = "New user created successfully!",
        session = session
      )
      # refresh added data
      rvs$user_data <- refresh_table_data(table_name = "users")
    } else {
      alert_fail_ui(info = "Name or email or phone already exists!", session = session)
    }
  })

  # output table for already exisiting teacher data
  output$teachers_data <- renderUI({
    # get the school data
    table_data <- rvs$user_data
    teachers_data <- table_data |>
      filter(type == "Teacher")
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
            argonTableItem(teachers_data$type[i]),
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
    # get the school data
    table_data <- rvs$user_data
    students_data <- table_data |>
      filter(type == "Student")
    if (nrow(students_data) > 0) {
      argonTable(
        headTitles = c("ID", "School", "Grade", "Type", "Phone", "Status", ""),
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
            argonTableItem(students_data$type[i]),
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
                  h5(table_data$school_name[i]),
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
  observeEvent(input$doc_school, {
    name <- input$doc_school
    user_data <- data.table::as.data.table(rvs$user_data)
    choices <- user_data[
      school_name == name & type == "Teacher",
      .(user_name, grade)
    ]
    updatePickerInput(
      session = session,
      inputId = "doc_teacher",
      choices = unique(choices$user_name),
      choicesOpt = list(
        subtext = unique(choices$grade)
      )
    )
  })

  # Actions for logout button
  observeEvent(input$log_out_session, {
    # Sign user out
    sign_out_from_shiny()
    session$reload()
  })
}

secure_server(server)
