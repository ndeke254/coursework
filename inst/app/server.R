server <- function(input, output, session) {
  upload_pageServer("upload_page")
  observeEvent(input$admin, {
      output$body_content <- renderUI(
        upload_pageUI("upload_page")
      )
  })
}
