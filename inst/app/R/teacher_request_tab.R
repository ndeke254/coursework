teacher_request_tab <- div(
  class = "container pt-5 mt-5",
  div(
    class = "mb-5",
    uiOutput("signed_teacher")
  ),
  argonR::argonTabSet(
    id = "teacher_tabset",
    horizontal = TRUE,
    size = "lg",
    width = 12,
    argonR::argonTab(
      tabName = "Share your content",
      active = TRUE,
      div(
        class = "card card-body p-4",
        p("Fill all the fields:"),
        p("Requests for unclear images will be cancelled.",
          class = "text-red text-bold"
        ),
        div(
          class = "d-flex justify-content-center",
          fileInput(
            inputId = "photo_file",
            label = "You can upload multiple jpg/jpeg/png files:",
            width = 500,
            accept = c(".jpeg", ".jpg", "png")
          )
        ),
        uiOutput("file_list_ui"),
        fluidRow(
          column(
            width = 3,
            shinyWidgets::pickerInput(
              inputId = "request_grade",
              label = label_mandatory("Grade:"),
              options = list(maxOptions = 5),
              choices = NULL
            )
          ),
          column(
            width = 3,
            shinyWidgets::pickerInput(
              inputId = "request_learning_area",
              label = label_mandatory(" Search a Learning Area:"),
              options = list(
                size = 5,
                title = "Eg. Creative Arts",
                `live-search` = TRUE,
                `live-search-placeholder` = "Type here..."
              ),
              choicesOpt = list(
                content = stringr::str_trunc(
                  learning_areas,
                  width = 25
                )
              ),
              choices = NULL
            )
          ),
          column(
            width = 3,
            shiny::textInput(
              inputId = "request_topic",
              label = label_mandatory("Topic:"),
              placeholder = "Eg. Addition"
            )
          ),
          column(
            width = 3,
            shiny::textInput(
              inputId = "request_sub_topic",
              label_mandatory("Sub-topic:"),
              value = "",
              placeholder = "Eg. Long division method"
            )
          )
        ),
        fluidRow(
          column(
            width = 12,
            class = "pt-2",
            textAreaInput(
              inputId = "request_description",
              label = "Other details: (Optional)",
              placeholder = "What should we know about your work?"
            )
          )
        ),
        fluidRow(
          column(
            width = 12,
            uiOutput("char_count")
          )
        ),
        div(
          class = "d-flex justify-content-center",
          actionButton(
            inputId = "request_btn",
            label = "Send",
            width = "300px",
            class = "mt-2 mb-2"
          ) |>
            basic_primary_btn()
        )
      ),
      div(
        class = "mt-5",
        p("Your Requests status:", class = "mb-3 fw-bold"),
        reactable::reactableOutput("teacher_requests")
      )
    ),
    argonR::argonTab(
      tabName = "Your students",
      div(
        class = "card card-body",
        p("Your students:", class = "mb-3 fw-bold"),
        reactable::reactableOutput("teacher_students")
      )
    )
  )
)
