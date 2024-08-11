#' User registration form
#'
#' This function is intended to be called from within [mod_auth_ui()]
#'
#' @details All input fields must be prefixed with `signup_`
#'
#' @inheritParams login_form
#' @seealso [mod_auth_ui()], [login_form()]
#' @return [shiny::tags$form()]
register_form <- \(ns) {
    email_input <- floating_email_input(
        inputId = ns("signup_email"),
        label = "Email address",
        placeholder = "johndoe@example.com",
        width = "400px"
    ) |> make_input_required()

    check_no_input <- floating_text_input(
        inputId = ns("user_check_no"),
        label = "Check number",
        placeholder = "Check number",
        width = "400px"
    ) |> make_input_required()

    password_input_ids <- c(ns("signup_password"), ns("signup_confirm_password"))
    password_input <- floating_password_input(
        inputId = password_input_ids[1],
        label = "Create password",
        placeholder = "Create password",
        autocomplete = "new-password",
        width = "400px"
    ) |> make_input_required()
    confirm_password_input <- floating_password_input(
        inputId = password_input_ids[2],
        label = "Confirm password",
        placeholder = "Confirm password",
        autocomplete = "new-password",
        width = "400px"
    ) |> make_input_required()

    # show/hide passwords
    on_click <- password_input_ids |>
        sprintf(fmt = "toggle_password('%s')") |>
        paste0(collapse = ";")
    show_password_input <- checkbox_input(
        inputId = ns("signup_show_password"),
        label = "Show password",
        width = "400px",
        on_click = on_click
    )

    submit_btn_id <- ns("signup_submit")
    submit_btn <- actionButton(
        inputId = submit_btn_id,
        label = "Register",
        class = "btn btn-primary rounded-1 px-3",
        type = "submit",
        onclick = sprintf("disable_auth_btn('%s')", submit_btn_id)
    )

    tags$form(
        class = "pt-2",
        tags$div(class = "mb-3", email_input),
        tags$div(class = "mb-3", check_no_input),
        tags$div(class = "mb-3", password_input),
        tags$div(class = "mb-3", confirm_password_input),
        tags$div(class = "mb-3 text-start", show_password_input),
        privacy_tos_links,
        tags$div(class = "d-grid", submit_btn)
    )
}
