admin_upload_page <- div(
  argonTabSet(
    id = "upload_tabset",
    horizontal = TRUE,
    size = "lg",
    width = 12,
    iconList = list(
      argonIcon("paper-diploma", color = "body"),
      argonIcon("ungroup", color = "body"),
      argonIcon("collection", color = "body")
    ),
    argonTab(
      tabName = "School content",
      active = TRUE,
      h2("Upload school content"),
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
            fileInput(
              inputId = "pdfFile", 
              label = "Select a PDF", 
              width = 500,
               accept = c(".pdf")
               )
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
                choices = NULL
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
              shiny::textInput(
                inputId = "doc_sub_topic", 
                label_mandatory("Sub-topic:"), 
                value = "",
                 placeholder = "Eg. Long division method")
            )
          ),
          actionButton(
            inputId = "upload_btn", 
            label = "Publish PDF",
             class = "mt-2 mb-2 float-right") |>
            basic_primary_btn()
        )
      )
    ),
    argonTab(
      tabName = "General cheatcheats",
      h2("Upload cheatsheets"),
      argonRow(
        center = TRUE,
        argonR::argonCard(
          title = "University/General users",
          shadow = TRUE,
          border_level = 5,
          icon = argonIcon("folder-17", color = "default"),
          status = "default",
          width = 12,
          p("All fields are required", class = "mt--2")
        )
      )
    ),
    argonTab(
      tabName = "Manage content",
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
