user_profile_tab <-
    shiny::tagList(
        tags$div(
            class = "d-flex float-right align-items-center p-2",
            tags$span(
                class = "mx-2 text-truncate w-75",
                textOutput("signed_user")
            ),
            shinyWidgets::dropdown(
                style = "unite",
                icon = argonIcon("single-02"),
                right = TRUE,
                size = "sm",
                animate = shinyWidgets::animateOptions(
                    enter = shinyWidgets::animations$sliding_entrances$slideInDown,
                    exit = shinyWidgets::animations$fading_exits$fadeOut,
                    duration = 0.5
                ),
                shiny::actionButton(
                    inputId = "user_profile_edit",
                    label = "Edit Profile",
                    icon = icon("user-pen"),
                    width = "100%",
                    class = "px-0 dropdown-item border-0 icon-link shadow"
                ),
                shiny::actionButton(
                    inputId = "log_out_session",
                    label = "Log Out",
                    icon = icon("power-off"),
                    width = "100%",
                    class = "px-0 dropdown-item border-0 icon-link shadow"
                ),
            )
        )
    )
