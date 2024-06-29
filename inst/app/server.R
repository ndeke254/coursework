server <- function(input, output, session) {
  # make sqlite connection:
  conn <- DBI::dbConnect(
    drv = RSQLite::SQLite(),
    Sys.getenv("DATABASE_NAME")
  )
  # initialize fields validation
  iv <- InputValidator$new()
  ivs <- InputValidator$new()

  # Initialize reactive values
  rv <- reactiveValues(
    image_paths = NULL,
    current_page = 1,
    total_pages = 0,
    selected_pdf = NULL,
    pdf_paths = list()
  )

  # output selected tab
  output$selected_tab <- renderText({
    item <- ifelse(is.null(input$active_sidebar_tab), "DASHBOARD", input$active_sidebar_tab)
    return(stringr::str_to_upper(item))
  })


  # Load existing PDFs and their cover images from the "pdf" folder on app initialization
  observe({
    pdf_files <- list.files("www/pdf", pattern = "\\.pdf$", full.names = TRUE)
    rv$pdf_paths <- lapply(pdf_files, function(pdf) {
      cover_image <- file.path("www/images", paste0(fs::path_ext_remove(basename(pdf)), "_page_1.png"))
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
  ivs$add_rule("doc_price", sv_required())

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
        Input = c("PDF File", "School", "Teacher", "Grade", "Learning Area", "Topic", "Sub Topic", "Price"),
        Value = stringr::str_trunc(
          c(
            input$pdfFile$name,
            input$doc_school,
            input$doc_teacher,
            input$doc_grade,
            input$doc_learning_area,
            input$doc_topic,
            input$doc_sub_topic,
            paste0("Ksh. ", input$doc_price)
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

      # add a new record for it
      data <- data.frame(
        id = next_pdf_id("pdfs"),
        school_name = input$doc_school,
        pdf_name = input$pdfFile$name,
        teacher = input$doc_teacher,
        grade = input$doc_grade,
        learning_area = input$doc_learning_area,
        topic = input$doc_topic,
        sub_topic = input$doc_sub_topic,
        price = input$doc_price,
        time = format(Sys.time(), "%Y-%m-%d %H:%M:%S")
      )

      success <- add_new_pdf(table_name = "pdfs", data = data)

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
        rv$pdf_paths <- c(list(list(pdf = pdf_path, cover = image_paths[[1]])), rv$pdf_paths)

        alert_success_ui(info = "New PDF uploaded successfully!", session = session)
        # refresh added data
        rvs$pdf_data <- refresh_table_data(table_name = "pdfs")
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
        headTitles = c("ID", "Teacher", "Grade", "Learning Area", "Sub Topic", "Price", "Time", ""),
        lapply(1:nrow(pdf_data), function(i) {
          file_info <- rv$pdf_paths[[i]]
          argonTableItems(
            argonTableItem(
              div(
                class = "d-flex",
                argonAvatar(size = "sm", src = sub("^www/", "", file_info$cover)),
                div(
                  class = "d-flex flex-column justify-content-center px-2",
                  h6(class = "mb-0 text-xs", pdf_data$id[i]),
                  p(class = "text-truncate w-75 text-xs text-default mb-0", pdf_data$pdf_name[i])
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
            argonTableItem(
              dataCell = TRUE,
              argonBadge(
                text = paste("Ksh. ", pdf_data$price[i]),
                status = "primary"
              )
            ),
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
          actionButton("edit_btn", "", icon = icon("pencil")) |> basic_primary_btn(),
          actionButton("delete_btn", "", icon = icon("trash")) |> basic_primary_btn()
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
  output$new_price <- renderText({
    table_data <- rvs$pdf_data
    price <- as.numeric(table_data$price[rvs$idx]) + (input$my_knob / 100) * as.numeric(table_data$price[rvs$idx])
    return(paste("Ksh. ", price))
  })
  # Render available PDFs
  output$published_pdfs <- renderUI({
    if (length(rv$pdf_paths) == 0) {
      show_empty_state_ui
    } else {
      shinybusy::show_spinner()


      card_ui <- lapply(seq_along(rv$pdf_paths), function(i) {
        file_info <- rv$pdf_paths[[i]]
        pages_no <- pdf_info(file_info$pdf)$pages
        card_id <- paste0("card_", i)
        pdf_name_filtered <- fs::path_ext_remove(basename(file_info$pdf))
        pdf_data <- rvs$pdf_data |> 
        filter(pdf_name == paste0(pdf_name_filtered, ".pdf"))
        argonR::argonCard(
          title = tags$h6(
              class = "text-truncate text-uppercase w-75",
              pdf_name_filtered
            ),
          hover_lift = TRUE,
          shadow = TRUE,
          border_level = 5,
          icon = icon("file-pdf"),
          status = "default",
          width = 2,
          paste("Topic:", pdf_data$topic), br(), 
          paste("Grade:", pdf_data$grade), br(),
          argonR::argonBadge(
          text = paste("Price:", pdf_data$price),
           pill = TRUE, status = "default"),
          div(
            class = "d-flex justify-content-center",
            onclick = sprintf("Shiny.setInputValue('selected_pdf', '%s'); Shiny.setInputValue('trigger_modal', Math.random());", file_info$pdf),
            argonR::argonImage(
              src = sub("^www/", "", file_info$cover),
              floating = TRUE
            )
          )
        )
      })
      do.call(tagList, card_ui)
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

    image_files <- list.files("www/images", pattern = paste0("^", tools::file_path_sans_ext(tools::file_path_sans_ext(basename(input$selected_pdf))), "_page_.*\\.png$"), full.names = TRUE)
    rv$image_paths <- image_files
    rv$current_page <- 1
    rv$total_pages <- length(image_files)
    rv$selected_pdf <- input$selected_pdf

    # Render progress bar and text
    output$progress_bar <- renderUI({
      page_text <- paste("Page", rv$current_page, "of", rv$total_pages)
      progress_value <- pmin((rv$current_page / rv$total_pages) * 100, 100)
      progress_bar_modified(text = page_text, value = progress_value, status = "gradient-gray")
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

  shinyjs::addCssClass(
    id = "step_1",
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
      status = "Enabled",
      stringsAsFactors = FALSE
    )

    # Call the register_new_school function
    success <- register_new_school(
      table_name = "schools",
      data = school_data
    )

    if (success == 1) {
      alert_success_ui(info = "New school created successfully!", session = session)
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
        headTitles = c("ID", "Name", "Type", "County", "Status", ""),
        lapply(1:nrow(table_data), function(i) {
          argonTableItems(
            argonTableItem(
              div(
                class = "d-flex flex-column justify-content-center",
                h6(class = "mb-0 text-xs", table_data$id[i]),
                p(class = "text-truncate w-50 text-xs text-default mb-0", table_data$email[i])
              )
            ),
            argonTableItem(
              div(
                p(class = "text-xs font-weight-bold mb-0", table_data$school_name[i]),
                p(class = "text-xs text-default mb-0", table_data$level[i])
              )
            ),
            argonTableItem(table_data$type[i]),
            argonTableItem(table_data$county[i]),
            argonTableItem(
              dataCell = TRUE,
              argonBadge(
                text = table_data$status[i],
                status = ifelse(table_data$status[i] == "Enabled", "success", "default")
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
                  onclick = sprintf("Shiny.setInputValue('action_button', '%s');", i)
                ),
                div(
                  class = "pt-2",
                  h5(table_data$school_name[i]),
                  div(
                    class = "mb--4",
                    onclick = sprintf("Shiny.setInputValue('status_button', '%s');", i),
                    materialSwitch(
                      inputId = paste0("status_", i),
                      label = table_data$status[i],
                      value = ifelse(table_data$status[i] == "Enabled", TRUE, FALSE),
                      status = "success"
                    )
                  ),
                  actionButton(
                    inputId = paste0("del_btn_", i),
                    label = "Delete",
                    icon = icon("trash"),
                    status = "secondary",
                    class = "btn-link bg-transparent mx--3 border-0",
                    onclick = sprintf("Shiny.setInputValue('del_button', '%s');", i)
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
  # Create reactive values for school table
  rvs <- reactiveValues(
    message = NULL,
    school_data = dbReadTable(conn, "schools"),
    pdf_data = dbReadTable(conn, "pdfs"),
    idx = NULL,
    status = NULL
  )
  on.exit(DBI::dbDisconnect(conn), add = TRUE)


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
      text = paste("Are you sure you want to", confirm_text, table_data$school_name[id], "?"),
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
      text = paste("Are you sure you want to delete", table_data$school_name[id], "?"),
      btn_labels = c("Cancel", "Yes")
    )
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
}
