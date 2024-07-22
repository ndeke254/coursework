student_content_tab <- div(
  uiOutput("published_pdfs"),
  argonR::argonModal(
    width = 12,
    id = "modal",
    title = "Selected Content",
    status = "secondary",
    gradient = TRUE,
    div(
      id = "modal-content",
      class = "hover-content",
      style = "position: relative;",
      div(
        id = "hover-div",
        class = "bg-translucent-default rounded pt-3 pb-3",
        actionButton(
          inputId = "prev_btn",
          label = "",
          icon = icon("arrow-left"),
          class = "bg-gradient-gray"
        ) |>
          basic_primary_btn(),
        actionButton(
          inputId = "full_screen_btn",
          label = "",
          icon = icon("expand"),
          class = "bg-gradient-gray"
        ) |>
          basic_primary_btn(),
        actionButton(
          inputId = "next_btn",
          label = "",
          icon = icon("arrow-right"),
          class = "bg-gradient-gray"
        ) |>
          basic_primary_btn(),
        uiOutput("progress_bar")
      ),
      imageOutput("pdf_images", height = "auto", width = "100%")
    )
  )
)
