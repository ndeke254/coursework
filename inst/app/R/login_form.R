#' User login form
#'
#' This function is intended to be called from within [mod_auth_ui()]
#'
#' @details
#' All input fields must be prefixed with `signin_`
#'
#' @param ns The module namespace from where this function will be called
#' @seealso [mod_auth_ui()], [register_form()]
#' @return [shiny::tags$form()]
login_form <- \(ns) {
    email_input <- shiny::textInput(
        inputId = ns("signin_email"),
        label = "Email address",
        placeholder = "johndoe@example.com",
        width = "400px"
    ) |> make_input_required()
    password_input_id <- ns("signin_password")
    password_input <- shiny::passwordInput(
        inputId = password_input_id,
        label = "Password",
        placeholder = "Password",
        width = "400px"
    ) |> make_input_required()

    # show/hide passwords
    on_click <- password_input_id |>
        sprintf(fmt = "toggle_password('%s')") |>
        paste0(collapse = ";")
    show_password_input <- shiny::checkboxInput(
        inputId = ns("signin_show_password"),
        label = div(
            "Show password",
            class = "mx-2"
        ),
        width = "400px"
    ) |> make_input_required()

    submit_btn_id <- ns("signin_submit")
    submit_btn <- actionButton(
        inputId = submit_btn_id,
        label = "Login",
        class = "btn btn-primary ",
        type = "submit",
        onclick = sprintf("disable_auth_btn('%s')", submit_btn_id)
    )

    tags$form(
        class = "pt-2",
        tags$div(class = "mb-3", email_input),
        tags$div(class = "mb-3", password_input),
        tags$div(class = "d-grid", submit_btn)
    )
}
