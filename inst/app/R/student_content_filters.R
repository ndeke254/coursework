student_content_filters <- argonRow(
    argonColumn(
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
    argonColumn(
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
    argonColumn(
        width = 3,
        shinyWidgets::pickerInput(
            inputId = "filter_topic",
            label = "Topic:", multiple = TRUE,
            options = list(
                title = "Eg. Verbs",
                style = "btn-outline-light",
                size = 5
            ),
            choices = NULL
        )
    ),
    argonColumn(
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
