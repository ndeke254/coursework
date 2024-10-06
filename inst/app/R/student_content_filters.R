student_content_filters <- fluidRow(
  id = "filters",
  class = "mt-3 mx-xl-xl",
  column(
    width = 3,
    shinyWidgets::pickerInput(
      inputId = "filter_teacher",
      label = "Teacher:",
      multiple = TRUE,
      options = list(
        title = "Eg. John Kamau",
        style = "btn-outline-light",
        size = 5
      ),
      choices = NULL
    )
  ),
  column(
    width = 3,
    shinyWidgets::pickerInput(
      inputId = "filter_learning_area",
      label = "Learning area:",
      multiple = TRUE,
      options = list(
        title = "Eg. English",
        style = "btn-outline-light",
        size = 5
      ),
      choices = NULL
    )
  ),
  column(
    width = 3,
    shinyWidgets::pickerInput(
      inputId = "filter_topic",
      label = "Topic:",
      multiple = TRUE,
      options = list(
        title = "Eg. Verbs",
        style = "btn-outline-light",
        size = 5
      ),
      choices = NULL
    )
  ),
  column(
    width = 3,
    shinyWidgets::pickerInput(
      inputId = "filter_sub_topic",
      label = "Sub-topic:",
      multiple = TRUE,
      options = list(
        title = "Eg. Continuous verbs",
        style = "btn-outline-light",
        size = 5
      ),
      choices = NULL
    )
  )
)
