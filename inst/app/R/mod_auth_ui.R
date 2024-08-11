#' Authentication module UI
#'
#' @param id Module id
mod_auth_ui <- \(id) {
    ns <- NS(id)
    tagList(
        shinyjs::useShinyjs(),
        tags$div(
            class = "d-flex justify-content-center align-items-center mb-5 mt-3",
            tags$div(
                style = "max-width: 100%;",
                shiny::tabsetPanel(
                    id = ns("auth_form"),
                    type = "hidden",
                    header = tags$div(class = "auth_form_loader bg-white"),
                    tabPanelBody(
                        value = "signin",
                        create_card(
                            title = "Login to Keytabu",
                            title_icon = NULL,
                            class = "shadow text",
                            tags$div(
                                class = "d-flex justify-content-center",
                                tags$img(
                                    src = file.path("logo", "logo.png"),
                                    width = "150px"
                                )
                            ),
                            login_form(ns = ns),
                            tags$div(
                                class = "text-center",
                                tags$p(
                                    class = "mt-3 small",
                                    "Forgot password?",
                                    actionLink(
                                        inputId = ns("reset_password"),
                                        label = "Reset"
                                    )
                                )
                            )
                        )
                    ),
                    tabPanelBody(
                        value = "signup",
                        create_card(
                            title = "Register",
                            title_icon = NULL,
                            class = "shadow text-center",
                            register_form(ns = ns),
                            tags$p(
                                class = "mt-3 small",
                                "Already have an account?",
                                actionLink(
                                    inputId = ns("go_to_signin"),
                                    label = "Login"
                                )
                            )
                        )
                    ),
                    tabPanelBody(value = "waiting_signin")
                )
            )
        )
    )
}
