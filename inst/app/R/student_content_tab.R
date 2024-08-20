student_content_tab <- div(
  class = "pt-3",
   uiOutput("signed"),
  student_content_filters,
  class = "container",
  `data-aos` = "fade-up",
  `data-aos-delay` = "100",
  uiOutput("published_pdfs"),
  uiOutput("selected_pdf_frame")
)
