server <- function(input, output, session) {
  # Initialize reactive values
  rv <- reactiveValues(
    image_paths = NULL,
    current_page = 1,
    total_pages = 0,
    selected_pdf = NULL,
    pdf_paths = list()
  )

  # Load existing PDFs and their cover images from the "pdf" folder on app initialization
  observe({
    pdf_files <- list.files("www/pdf", pattern = "\\.pdf$", full.names = TRUE)
    rv$pdf_paths <- lapply(pdf_files, function(pdf) {
      cover_image <- file.path("www/images", paste0(fs::path_ext_remove(basename(pdf)), "_page_1.png"))
      list(pdf = pdf, cover = cover_image)
    })
  })

  # Observe file upload and save the PDF
  observeEvent(input$upload_btn, {
    shinybusy::show_spinner()

    req(input$pdfFile)
    if (!dir.exists("www/pdf")) dir.create("www/pdf", recursive = TRUE)
    if (!dir.exists("www/images")) dir.create("www/images", recursive = TRUE)
    pdf_path <- file.path("www/pdf", input$pdfFile$name)

    file.copy(input$pdfFile$datapath, pdf_path)

    # Convert PDF to images
    pdf <- image_read_pdf(pdf_path)
    image_paths <- vector("list", length(pdf))
    for (i in seq_along(pdf)) {
      image_path <- file.path("www/images", paste0(tools::file_path_sans_ext(input$pdfFile$name), "_page_", i, ".png"))
      image_write(pdf[i], image_path)
      image_paths[[i]] <- image_path
    }
    # Update reactive pdf paths
    rv$pdf_paths <- c(list(list(pdf = pdf_path, cover = image_paths[[1]])), rv$pdf_paths)
  })

  # Render available PDFs
  output$published_pdfs <- renderUI({
    if (length(rv$pdf_paths) == 0) {
      p("No PDFs available.")
    } else {
      shinybusy::show_spinner()
      card_ui <- lapply(seq_along(rv$pdf_paths), function(i) {
        file_info <- rv$pdf_paths[[i]]
        pages_no <- pdf_info(file_info$pdf)$pages
        card_id <- paste0("card_", i)

        argonR::argonCard(
          title = tags$h6(
            class = "text-truncate text-uppercase w-75",
            fs::path_ext_remove(basename(file_info$pdf))
          ),
          hover_lift = TRUE,
          shadow = TRUE,
          border_level = 5,
          icon = icon("file-pdf"),
          status = "default",
          width = 2,
          paste("Grade:", sample(c("5", "6", "4"), 1)), br(),
          paste("Price:", sample(c("Ksh.200", "Ksh.300", "Ksh.500"), 1)),
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
}
