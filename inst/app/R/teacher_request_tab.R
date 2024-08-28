teacher_request_tab <- div(
  class = "container pt-5",
  div(
    class = "mb-5",
    uiOutput("signed_teacher")
  ),
  argonTabSet(
    id = "teacher_tabset",
    horizontal = TRUE,
    size = "lg",
    width = 12,
    argonTab(
      tabName = "Share your content",
      active = TRUE,
      div(
        class = "card card-body p-4",
        p("Fill all the fields:"),
        p("Requests for unclear images will be cancelled.",
          class = "fa small"
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
            shiny::selectizeInput(
              inputId = "request_grade",
              label = label_mandatory("Grade:"),
              choices = NULL,
              options = list(maxOptions = 5)
            )
          ),
          column(
            width = 3,
            shiny::selectizeInput(
              inputId = "request_learning_area",
              label = label_mandatory(" Search a Learning Area:"),
              choices = NULL,
              options = list(maxOptions = 5)
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
        div(
          class = "d-flex justify-content-center",
          actionButton(
            inputId = "request_btn",
            label = "Send",
            class = "mt-5 w-25 mb-2"
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
    argonTab(
      tabName = "Your students",
      div(
        class = "card card-body",
        p("Your students:", class = "mb-3 fw-bold"),
        reactable::reactableOutput("teacher_students")
      )
    )
  )
)
