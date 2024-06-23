admin_upload_page <- div(
        h2("Upload Cheatsheets"),
        argonR::argonCard(
          title = "Upload PDF",
          shadow = TRUE,
          border_level = 5,
          icon = icon("upload"),
          status = "default",
          width = 4,
          fileInput("pdfFile", "Select a PDF", accept = c(".pdf")),
          actionButton("upload_btn", "Publish PDF")
        )
)