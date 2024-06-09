# UI
ui <- bslib::page(
    title = "COURSEWORK",
  theme = bslib::bs_theme(version = 5, preset = "bootstrap"),
  lang = "en",
  shinyjs::useShinyjs(),
  div(
    class = "p-4",
    titlePanel("PDF Page Viewer"),
    fileInput("pdfFile", "Upload PDF"),
    actionButton("publishPDF", "Publish PDF")
  ),
  br(),
  div(
    class = "d-flex align-content-start flex-wrap pt-5",
    uiOutput("published_pdfs")
  ),
  shinyjs::hidden(
    div(
      id = "navigationButtons",
      actionButton(
        inputId = "prevBtn",
        label = "",
        icon = icon("arrow-left"),
        style = "position: fixed; top: 50%; left: 20px; z-index: 1070;",
        class = "border-0"
      ),
      actionButton(
        inputId = "nextBtn",
        label = "",
        icon = icon("arrow-right"),
        style = "position: fixed; top: 50%; right: 20px; z-index: 1070;",
        class = "border-0"
      )
    )
  )
)
