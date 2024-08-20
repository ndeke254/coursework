teacher_request_tab <- div(
  class = "container pt-5",
  tabsetPanel(
    id = "teacher_tabset",
    type = "tab",
    tabPanel(
      title = "Share your content",
      class = "nav-underline",
      active = TRUE,
      p("Fill all the fields:", class = "mt-5"),
      div(
        class = "d-flex justify-content-center",
        fileInput(
          inputId = "photo_file",
          multiple = TRUE,
          label = "Select a jpg/jpeg",
          width = 500,
          accept = c(".jpeg", ".jpg")
        )
      ),
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
            label = label_mandatory("Learning Area:"),
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
      actionButton(
        inputId = "request_btn",
        label = "Send",
        class = "mt-2 mb-2 float-right"
      ) |>
        basic_primary_btn()
    )
  )
)
