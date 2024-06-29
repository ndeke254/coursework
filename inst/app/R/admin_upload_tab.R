admin_upload_page <- div(
  argonTabSet(
    id = "upload_tabset",
    horizontal = TRUE,
    size = "lg",
    width = 12,
    iconList = list(
      argonIcon("cloud-upload-96", color = "body"),
      argonIcon("curved-next", color = "body"),
      argonIcon("collection", color = "body")
    ),
    argonTab(
      tabName = "Upload",
      active = TRUE,
      h2("Upload Cheatsheets"),
      argonRow(
        center = TRUE,
        argonR::argonCard(
          title = "Upload PDF",
          shadow = TRUE,
          border_level = 5,
          icon = icon("upload", class = "default"),
          status = "default",
          width = 12,
          p("All fields are required", class = "mt--2"),
          div(
            class = "d-flex justify-content-center",
            fileInput("pdfFile", "Select a PDF", width = 500, accept = c(".pdf"))
          ),
          argonRow(
            argonColumn(
              width = 3,
              shinyWidgets::pickerInput(
                inputId = "doc_school",
                label = label_mandatory("School:"),
                options = list(
                  title = "Eg. Limuru Junior Secondary",
                  style = "btn-outline-light",
                  size = 5,
                  `live-search` = TRUE,
                  `live-search-placeholder` = "Search school"
                ),
                choices = NULL,
                autocomplete = TRUE
              )
            ),
            argonColumn(
              width = 3,
              shinyWidgets::pickerInput(
                inputId = "doc_teacher",
                label = label_mandatory("Teacher:"),
                options = list(
                  title = "Eg. John Kamau",
                  style = "btn-outline-light",
                  size = 5
                ),
                choices = kenyan_counties
              )
            ),
            argonColumn(
              width = 3,
              shinyWidgets::pickerInput(
                inputId = "doc_grade",
                label = label_mandatory("Grade/Year:"),
                options = list(
                  style = "btn-outline-light",
                  title = "Eg. Grade 6",
                  size = 5
                ),
                choices = paste(c("Grade"), 1:12)
              )
            ),
            argonColumn(
              width = 3,
              shinyWidgets::pickerInput(
                inputId = "doc_learning_area",
                label = label_mandatory("Learning Area:"),
                options = list(
                  title = "Eg. Math",
                  style = "btn-outline-light",
                  size = 10,
                  `live-search` = TRUE,
                  `live-search-placeholder` = "Search learning area"
                ),
                choices = NULL
              )
            )
          ),
          argonRow(
            argonColumn(
              width = 3,
              shiny::textInput(
                inputId = "doc_topic",
                label = label_mandatory("Topic:"),
                placeholder = "Eg. Addition"
              )
            ),
            argonColumn(
              width = 3,
              shiny::textInput("doc_sub_topic", label_mandatory("Sub-topic:"), "", placeholder = "Eg. Long division method")
            ),
            argonColumn(
              width = 3,
              autonumericInput(
                inputId = "doc_price",
                label_mandatory("Price:"),
                value = 1000,
                currencySymbol = "Ksh ",
                decimalPlaces = 0,
                minimumValue = 100
              )
            )
          ),
          actionButton("upload_btn", "Publish PDF", class = "btn-primary mt-2 mb-2 float-right") |>
            basic_primary_btn()
        )
      )
    ),
    # argonTab(
    #   tabName = "Update",
    #    argonRow(
    #      center = TRUE,
    #       argonR::argonCard(
    #      title = "Update fields",
    #        shadow = TRUE,
    #       border_level = 5,
    #       icon = argonIcon("ui-04", color = "default"),
    #        status = "default",
    #        width = 12,
    #        p("Update PDF upload fields", class = "mt--2")
    #     )
    #    )
    #  ),
    argonTab(
      tabName = "Content",
      h2("PDF Documents Available"),
      bslib::card(
        id = "pdf_card",
        p("Already uploaded PDFs", class = "mt--2"),
        bslib::layout_sidebar(
          sidebar = bslib::sidebar(
            id = "card_sidebar",
            position = "right",
            open = FALSE,
            uiOutput("sidebar_content")
          ),
          uiOutput("pdf_data")
        )
      )
    )
  )
)
