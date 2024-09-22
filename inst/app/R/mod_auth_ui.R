#' Authentication module UI
#'
#' @param id Module id
mod_auth_ui <- \(id) {
    ns <- NS(id)

    tabsetPanel(
        id = ns("auth_pages"),
        type = "hidden",
        selected = "login_page",
        tabPanelBody(
            value = "login_page",
            div(
                class = "container vh-100 d-flex justify-content-center
                align-items-center",
                div(
                    title_icon = NULL,
                    class = "card",
                    tags$div(
                        class = "bg-light d-flex justify-content-center",
                        tags$img(
                            src = file.path("logo", "logo.png"),
                            width = "100px"
                        )
                    ),
                    h5("Log in Keytabu", class = "bg-light text-bold text-center
             pb-3"),
                    login_form(ns = ns),
                    tags$div(
                        class = "text-center",
                        tags$p(
                            class = "mt-3 small text-bold",
                            "Forgot password?",
                            actionLink(
                                inputId = ns("reset_password"),
                                label = "Reset"
                            )
                        )
                    )
                )
            )
        ),
        tabPanelBody(
            value = "reset_page",
            div(
                class = "container vh-100 d-flex justify-content-center
                align-items-center",
                div(
                    title_icon = NULL,
                    class = "card",
                    tags$div(
                        class = "bg-light d-flex justify-content-center",
                        tags$img(
                            src = file.path("logo", "logo.png"),
                            width = "100px"
                        )
                    ),
                    h5("Reset Password", class = "bg-light text-bold
                    text-center pb-3"),
                    div(
                        class = "card-body",
                        shiny::textInput(
                            inputId = ns("reset_email"),
                            label = "Email address",
                            placeholder = "johndoe@example.com"
                        ) |> make_input_required(),
                        actionButton(
                            inputId = ns("reset_password_btn"),
                            label = "Reset",
                            type = "submit",
                            width = "300px"
                        ) |>
                            basic_primary_btn()
                    ),
                    tags$div(
                        class = "text-center",
                        tags$p(
                            class = "mt-3 small text-bold",
                            "Want to retry?",
                            actionLink(
                                inputId = ns("back_to_login"),
                                label = "Login"
                            )
                        )
                    )
                )
            )
        )
    )
}
