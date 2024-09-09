#' Authentication module UI
#'
#' @param id Module id
mod_auth_ui <- \(id) {
    ns <- NS(id)
    div(
        class = "mt-5 pt-5 container v-100
        d-flex justify-content-center align-items-center",
        div(
            title = "Log in Keytabu",
            title_icon = NULL,
            class = "card",
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
    )
}
