#' Authentication module UI
#'
#' @param id Module id
mod_auth_ui <- \(id) {
    ns <- NS(id)
    div(
        class = "container vh-100
        d-flex justify-content-center align-items-center",
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
