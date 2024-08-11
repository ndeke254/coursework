student_content_filters <- argonRow(
    id = "filters",
    class = "mt-3 mx-xl-xl",
    argonColumn(
        width = 3,
        selectizeInput(
            inputId = "filter_teacher",
            label = "Teacher:",
            multiple = TRUE,
            choices = NULL
        )
    ),
    argonColumn(
        width = 3,
        selectizeInput(
            inputId = "filter_learning_area",
            label = "Learning area:",
            multiple = TRUE,
            choices = NULL
        )
    ),
    argonColumn(
        width = 3,
        selectizeInput(
            inputId = "filter_topic",
            label = "Topic:",
            multiple = TRUE,
            choices = NULL
        )
    ),
    argonColumn(
        width = 3,
        selectizeInput(
            inputId = "filter_sub_topic",
            label = "Sub-topic:",
            multiple = TRUE,
            choices = NULL
        )
    )
)

