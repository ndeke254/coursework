server <- function(input, output, session) {
  # Initialize reactive values
  rv <- reactiveValues(
    pdf_paths = list(),
    current_pdf = NULL,
    current_page = 1,
    total_pages = 0
  )

  # Load existing PDFs and their cover images from the "pdf" folder on app initialization
  observe({
    pdf_files <- list.files("pdf", pattern = "\\.pdf$", full.names = TRUE)
    rv$pdf_paths <- lapply(pdf_files, function(pdf) {
      cover_image <- file.path("images", paste0(basename(pdf), "_page1.png"))
      list(pdf = pdf, cover = cover_image)
    })
  })

  observeEvent(input$publishPDF, {
    inFile <- input$pdfFile

    if (!is.null(inFile)) {
      # Create pdf folder if it doesn't exist
      if (!dir.exists("pdf")) {
        dir.create("pdf")
      }

      # Create images folder if it doesn't exist
      if (!dir.exists("images")) {
        dir.create("images")
      }

      # Copy the uploaded pdf to the output directory
      pdf_path <- file.path("pdf", inFile$name)
      file.copy(inFile$datapath, pdf_path, overwrite = TRUE)

      # Extract page 1 for cover image
      cover_image <- pdf_to_image(pdf_path, page = 1, output_dir = "images")

      # Update reactive pdf paths
      rv$pdf_paths <- c(rv$pdf_paths, list(list(pdf = pdf_path, cover = cover_image)))
    }
  })

  # Render available PDFs
  output$published_pdfs <- renderUI({
    if (length(rv$pdf_paths) == 0) {
      return(NULL)
    }

    card_ui <- lapply(seq_along(rv$pdf_paths), function(i) {
      file_info <- rv$pdf_paths[[i]]
      pages_no <- pdf_info(file_info$pdf)$pages
      card_id <- paste0("card_", i)
      div(
        class = "px-3 w-25",
        bslib::card(
          id = card_id,
          height = 300,
          full_screen = ifelse(pages_no > 1, FALSE, TRUE),
          card_header(
            class = "bg-secondary",
            fs::path_ext_remove(basename(file_info$pdf))
          ),
          bslib::card_image(
            file = file_info$cover,
            href = "#",
            onclick = sprintf("Shiny.setInputValue('select_pdf', '%s')", file_info$pdf)
          ),
          bslib::card_body(
            fill = FALSE,
            bslib::card_title(sample(c("Kilimani Primary", "Nairobi Primary"), 1)),
            p(
              class = "fw-light text-muted",
              paste("Grade:", sample(c("Grade 5", "Grade 6", "Grade 4"), 1)),
              br(),
              paste("Price:", sample(c("Ksh.200", "Ksh.300", "Ksh.500"), 1))
            )
          )
        )
      )
    })
    do.call(tagList, card_ui)
  })

  # Function to render a PDF page
  show_pdf_page <- function() {
    png <- pdf_to_image(pdf = rv$current_pdf, page = rv$current_page, output_dir = "images")
    # return(png) # path to the image
    showModal(
      modalDialog(
        tags$img(src = base64enc::dataURI(file = png, mime = "image/png"), width = "100%", height = "600px"),
        easyClose = TRUE,
        footer = tagList(
          actionButton("close", "Dismiss")
        ),
        size = "l"
      )
    )
  }

  # Observe selected PDF card
  observeEvent(input$select_pdf, {
    rv$current_pdf <- input$select_pdf
    rv$total_pages <- pdf_info(rv$current_pdf)$pages
    show_pdf_page()
    shinyjs::show("navigationButtons")
  })

  observeEvent(input$close, {
    shinyjs::hide("navigationButtons")
    removeModal()
  })
  # Previous page action
  observeEvent(input$prevBtn, {
    if (rv$current_page > 1) {
      rv$current_page <- rv$current_page - 1
      show_pdf_page()
    }
  })

  # Next page action
  observeEvent(input$nextBtn, {
    if (rv$current_page < rv$total_pages) {
      rv$current_page <- rv$current_page + 1
      show_pdf_page()
    }
  })
}
