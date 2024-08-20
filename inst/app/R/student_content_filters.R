student_content_filters <- fluidRow(
    id = "filters",
    class = "mt-3 mx-xl-xl",
    column(
        width = 3,
        selectizeInput(
            inputId = "filter_teacher",
            label = "Teacher:",
            multiple = TRUE,
            choices = NULL
        )
    ),
    column(
        width = 3,
        selectizeInput(
            inputId = "filter_learning_area",
            label = "Learning area:",
            multiple = TRUE,
            choices = NULL
        )
    ),
    column(
        width = 3,
        selectizeInput(
            inputId = "filter_topic",
            label = "Topic:",
            multiple = TRUE,
            choices = NULL
        )
    ),
    column(
        width = 3,
        selectizeInput(
            inputId = "filter_sub_topic",
            label = "Sub-topic:",
            multiple = TRUE,
            choices = NULL
        )
    )
)

