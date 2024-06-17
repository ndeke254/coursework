ui <- argonDash::argonDashPage(
  title = "CHEATSHEETS",
  description = "Course Description/Cheatsheet/Outline",
  author = "Jefferson Ndeke",
  header = argonDash::argonDashHeader(
    color = "default",
    argonR::argonImage(
      src = "logo/imac.svg",
      width = "50px"
    )
  ),
  body = argonDash::argonDashBody(
    argonCard(
      title = "Upload PDF",
      shadow = TRUE,
      border_level = 5,
      icon = icon("upload"),
      status = "default",
      width = 4,
      shinyjs::useShinyjs(),
      includeCSS(
        path = "www/css/styles.css"
      ),
      includeScript(
        path = "www/js/script.js"
      ),
      div(
        fileInput("pdfFile", "Select a PDF", accept = c(".pdf")),
        actionButton("upload_btn", "Publish PDF")
      )
    ),
    div(
      div(
        shinybusy::add_busy_spinner(
          spin = "fading-circle",
          position = "top-right",
          margins = c("30%", "50%")
        )
      ),
      uiOutput("published_pdfs", class = "d-flex flex-wrap"),
      argonR::argonModal(
        width = 12,
        id = "modal",
        title = "Selected Content",
        status = "secondary",
        gradient = TRUE,
        div(
          id = "modal-content",
          div(
            id = "hover-div",
            class = "bg-translucent-default rounded pt-3 pb-3",
            actionButton("prev_btn", "", icon = icon("arrow-left"), class = "bg-gradient-gray") |> remove_btn_default(),
            actionButton("full_screen_btn", "", icon = icon("expand"), class = "bg-gradient-gray") |> remove_btn_default(),
            actionButton("next_btn", "", icon = icon("arrow-right"), class = "bg-gradient-gray") |> remove_btn_default(),
            uiOutput("progress_bar")
          ),
          imageOutput("pdf_images", height = "auto", width = "100%")
        )
      ) |>
        shinyfullscreen::fullscreen_this(
          click_id = "full_screen_btn"
        ),
      # Hidden button to trigger modal display
      shinyjs::hidden(
        argonR::argonButton(
          name = "Show Modal",
          status = "primary",
          icon = NULL,
          size = "sm",
          modal_id = "modal",
        )
      )
    )
  )
)
